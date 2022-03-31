"""
Copyright 2019 Xilinx Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
"""

from ctypes import *
from typing import List
import cv2
import numpy as np
import xir
import vart
import os
import math
import threading
import time
import sys
import queue
import hashlib
import vitis_ai_library

BUF_SIZE = 5
imgQ_Display = queue.Queue(BUF_SIZE)
imgQ_Display_Final = queue.Queue(BUF_SIZE)
imgQ = queue.Queue(BUF_SIZE)
yolo_anchors = np.array([(12, 16), (19, 36), (40, 28), (36, 75), (76, 55), (72, 146), (142, 110), (192, 243),(459, 401)], np.float32) / 416
yolo_anchor_masks = np.array([[6, 7, 8], [3, 4, 5], [0, 1, 2]])

num_classes = 80
class_names = [c.strip() for c in open("coco.names").readlines()]


'''resize image with unchanged aspect ratio using padding'''


def letterbox_image(image, size):
    ih, iw, _ = image.shape
    w, h = size
    scale = min(w / iw, h / ih)

    nw = int(iw * scale)
    nh = int(ih * scale)

    image = cv2.resize(image, (nw, nh), interpolation=cv2.INTER_LINEAR)
    imgQ_Display.put(image)
    new_image = np.ones((h, w, 3), np.uint8) * 128
    h_start = (h - nh) // 2
    w_start = (w - nw) // 2
    new_image[h_start:h_start + nh, w_start:w_start + nw, :] = image
    return new_image


'''image preprocessing'''


def pre_process(image, model_image_size, fixpos):
    image = image[..., ::-1]
    image_h, image_w, _ = image.shape

    if model_image_size != (None, None):
        assert model_image_size[0] % 32 == 0, 'Multiples of 32 required'
        assert model_image_size[1] % 32 == 0, 'Multiples of 32 required'
        boxed_image = letterbox_image(image, tuple(reversed(model_image_size)))

    else:
        new_image_size = (image_w - (image_w % 32), image_h - (image_h % 32))
        boxed_image = letterbox_image(image, tuple(reversed(model_image_size)))

    
    image_data = np.array(boxed_image, dtype='float32', order='C')
    fix_scale = 2**fixpos
    image_data *= fix_scale/255
    image_data = np.expand_dims(image_data, 0)
    image_data = np.expand_dims(image_data, 0)
    image_data = image_data.astype(np.int8)
    return image_data


def sigmoid(x):
    return 1 / (1 + np.exp(-x))


def draw_outputs(img, outputs, class_names):
    boxes, objectness, classes, nums = outputs
    ih, iw, _ = img.shape
    wh = np.array([iw, ih])

    for i in range(nums):
        x1y1 = tuple((np.array(boxes[i][0:2]) * wh).astype(np.int32))
        x2y2 = tuple((np.array(boxes[i][2:4]) * wh).astype(np.int32))
        img = cv2.rectangle(img, x1y1, x2y2, (255, 0, 0), 2)
        img = cv2.putText(
            img, '{} {:.4f}'.format(class_names[int(classes[i])],
                                    objectness[i]), x1y1,
            cv2.FONT_HERSHEY_COMPLEX_SMALL, 1, (0, 0, 255), 2)
    return img


def draw_outputs_scale(img, scale, offset, outputs, class_names):
    boxes, objectness, classes, nums = outputs
    for i in range(nums):
        x1y1 = tuple(
            ((np.array(boxes[i][0:2]) - offset) * scale).astype(np.int32))
        x2y2 = tuple(
            ((np.array(boxes[i][2:4]) - offset) * scale).astype(np.int32))
        img = cv2.rectangle(img, x1y1, x2y2, (255, 0, 0), 2)
        img = cv2.putText(
            img, '{} {:.4f}'.format(class_names[int(classes[i])],
                                    objectness[i]), x1y1,
            cv2.FONT_HERSHEY_COMPLEX_SMALL, 1, (0, 0, 255), 2)
    return img


def yolo_box(conv_output, grid_size, num_classes, anchors, layer_id):
    box_xy = conv_output[:, :, :, :, 0:2]
    box_wh = conv_output[:, :, :, :, 2:4]
    objectness = conv_output[:, :, :, :, 4]
    objectness = np.expand_dims(objectness, axis=-1)
    class_probs = conv_output[:, :, :, :, 5:]

    box_xy = sigmoid(box_xy)
    objectness = sigmoid(objectness)
    class_probs = sigmoid(class_probs)

    grid = np.meshgrid(range(grid_size), range(grid_size))
    grid = np.expand_dims(np.stack(grid, axis=-1), axis=2)

    box_xy = (box_xy + grid) / grid_size

    box_wh = np.exp(box_wh) * anchors

    box_x1y1 = box_xy - box_wh / 2
    box_x2y2 = box_xy + box_wh / 2
    box_x1y1 = box_x1y1 
    box_x2y2 = box_x2y2
    bbox = np.concatenate((box_x1y1, box_x2y2), axis=-1)
    return bbox, objectness, class_probs


def yolo_non_max_suppression(outputs, score_thres, iou_thres):
    # bbox, objectness, class_index
    b, c, t = [], [], []

    for o in outputs:
        b.append(np.reshape(o[0], (-1, o[0].shape[-1])))
        c.append(np.reshape(o[1], (-1, o[1].shape[-1])))
        t.append(np.reshape(o[2], (-1, o[2].shape[-1])))

    bbox = np.concatenate(b)
    objectness = np.concatenate(c)
    class_probs = np.concatenate(t)

    scores = objectness * class_probs

    # find the highes class score for each box
    max_scores = np.amax(scores, axis=-1)
    class_index = np.argmax(scores, axis=-1)

    # pick boxes that meet score threshold
    pick_index = np.where(max_scores > score_thres)
    maxScores = max_scores[pick_index]
    classIndex = class_index[pick_index]
    x1 = bbox[pick_index, 0][0]
    y1 = bbox[pick_index, 1][0]
    x2 = bbox[pick_index, 2][0]
    y2 = bbox[pick_index, 3][0]
    boxArea = (x2 - x1) * (y2 - y1)
    boxIndex = np.argsort(maxScores)

    # start non maximum suppression
    boxes, confidence, classes = [], [], []
    nums = 0

    while len(boxIndex) > 0:
        last = len(boxIndex) - 1

        # pick the boxes with the highest scores
        k = boxIndex[last]
        boxes.append([x1[k], y1[k], x2[k], y2[k]])
        confidence.append(maxScores[k])
        classes.append(classIndex[k])
        nums = nums + 1

        # calculate IOU
        xx1 = np.maximum(x1[k], x1[boxIndex[:last]])
        yy1 = np.maximum(y1[k], y1[boxIndex[:last]])
        xx2 = np.minimum(x2[k], x2[boxIndex[:last]])
        yy2 = np.minimum(y2[k], y2[boxIndex[:last]])

        inter_area = (xx2 - xx1) * (yy2 - yy1)
        union_area = boxArea[k] + boxArea[boxIndex[:last]] - inter_area
        iou = inter_area / union_area

        # delete the currect and the boxes with larger IOU
        boxIndex = np.delete(
            boxIndex, np.concatenate(([last], np.where(iou > iou_thres)[0])))

    return boxes, confidence, classes, nums


def fix2float(fix_point, value):
    return value.astype(np.float32) * np.exp2(fix_point, dtype=np.float32)


def float2fix(fix_point, value):
    return value.astype(np.float32) / np.exp2(fix_point, dtype=np.float32)


def execute_async(dpu, tensor_buffers_dict):
    input_tensor_buffers = [
        tensor_buffers_dict[t.name] for t in dpu.get_input_tensors()
    ]
    output_tensor_buffers = [
        tensor_buffers_dict[t.name] for t in dpu.get_output_tensors()
    ]
    jid = dpu.execute_async(input_tensor_buffers, output_tensor_buffers)
    return dpu.wait(jid)

def getimages(fixpos):
    vid = cv2.VideoCapture(0)
    vid.set(3,640)
    vid.set(4,480)
    while (True):
        if not imgQ.full():
            ret, frame = vid.read()
            img = pre_process(frame, (416, 416), fixpos)
            imgQ.put(img)

def displayimages():
    while (True):
        if not imgQ_Display_Final.empty():
            frame = imgQ_Display_Final.get()
            cv2.imshow('yolov4', frame)
            # the 'q' button is set as the
            # quitting button you may use any
            # desired button of your choice
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break
    cv2.destroyAllWindows()
  

def runDPU(dpu_1):
    print("Start DPU Threads")
    # get DPU output tensors
    input_tensor_buffers = dpu_1.get_inputs()
    output_tensor_buffers = dpu_1.get_outputs()

    input_ndim_1 = tuple(input_tensor_buffers[0].get_tensor().dims)
    fixpos = input_tensor_buffers[0].get_tensor().get_attr("fix_point")
    while True:
        if not imgQ.empty():
            img = imgQ.get()
            input_data = np.asarray(input_tensor_buffers[0])
            input_data[0] = img
            job_id = dpu_1.execute_async(input_tensor_buffers, output_tensor_buffers)

            # start post process
            conv_out2 = np.reshape(output_tensor_buffers[2], (1, 13, 13, 3, 85))
            conv_out1 = np.reshape(output_tensor_buffers[1], (1, 26, 26, 3, 85))
            conv_out0 = np.reshape(output_tensor_buffers[0], (1, 52, 52, 3, 85))

            boxes_0 = yolo_box(conv_out0, 52, num_classes,yolo_anchors[yolo_anchor_masks[2]],0)
            boxes_1 = yolo_box(conv_out1, 26, num_classes,yolo_anchors[yolo_anchor_masks[1]],1)
            boxes_2 = yolo_box(conv_out2, 13, num_classes,yolo_anchors[yolo_anchor_masks[0]],2)
            outputs = yolo_non_max_suppression((boxes_0, boxes_1, boxes_2), 0.25, 0.45)

            # use this draw output funciton if image is resized with keeping original aspect ratio
            imgdisplay = imgQ_Display.get()
                    # start annotation
            ih, iw, _ = imgdisplay.shape
            if iw>ih:
                offset = np.array([0, (0.5-ih/(2*iw))])
                scale = iw
            else:
                offset = np.array([(0.5-iw/(2*ih)), 0])
                scale = ih
            img = draw_outputs_scale(imgdisplay, scale, offset, outputs, class_names)
            imgQ_Display_Final.put(img)


def main(argv):
    global threadnum

    threadAll = []
    threadnum=5
    g = xir.Graph.deserialize('yolov4_leaky_spp_m.xmodel')
    dpu_1 = vitis_ai_library.GraphRunner.create_graph_runner(g)
    input_tensor_buffers = dpu_1.get_inputs()
    input_ndim_1 = tuple(input_tensor_buffers[0].get_tensor().dims)
    fixpos = input_tensor_buffers[0].get_tensor().get_attr("fix_point")

    dpu_runner_1 = []

    for i in range(int(threadnum)):
        dpu_runner_1.append(dpu_1)

    """
    The cnt variable is used to control the number of times a single-thread DPU runs.
    Users can modify the value according to actual needs. It is not recommended to use
    too small number when there are few input images, for example:
    1. If users can only provide very few images, e.g. only 1 image, they should set
        a relatively large number such as 360 to measure the average performance;
    2. If users provide a huge dataset, e.g. 50000 images in the directory, they can
        use the variable to control the test time, and no need to run the whole dataset.
    """
    cnt = BUF_SIZE
    """run with batch """
    
    treader = threading.Thread(target=getimages, args=(fixpos,))
    threadAll.append(treader)
    
    for i in range(int(threadnum)):
        t1 = threading.Thread(target=runDPU, args=(dpu_runner_1[i],))
        threadAll.append(t1)

    tdisplay = threading.Thread(target=displayimages)
    threadAll.append(tdisplay)
    
    j = 0
    for x in threadAll:
        print("starting thread: ", j)
        j+=1
        x.start()
    for x in threadAll:
        x.join()

    del dpu_runner_1

if __name__ == "__main__":
    main(sys.argv)
