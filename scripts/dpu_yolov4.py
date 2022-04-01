# -------------------------------------------------------------------
import cv2
import numpy as np
import time
from enum import Enum

# =============================================================================
# Ref. design
# https://github.com/Xilinx/Vitis-AI/blob/v1.1/mpsoc/vitis_ai_dnndk_samples/tf_yolov3_voc_py/tf_yolov3_voc.py
# From Vitis-AI Zoo
# 1. data channel order: BGR(0~255)                
# 2. resize: 416 * 416(H * W) 
# 3. mean_value: 0.0, 0.0, 0.0
# 4. scale: 1 / 255.0
# 5. reisze mode: biliner

# Data from yolov4_leaky_spp_m.prototxt
# and Xilinx yolov4-test.py
yolo_anchors = np.array([(12, 16), (19, 36), (40, 28), (36, 75), (76, 55), (72, 146), (142, 110), (192, 243),(459, 401)], np.float32) / 416
yolo_anchor_masks = np.array([[6, 7, 8], [3, 4, 5], [0, 1, 2]])

# -------------------------------------------------------------------
# YOLOv4 data collected from notebook (dpu_test.ipynb)
# 
# inputTensor[0]: name=data_fixed, dims=[1, 416, 416, 3], dtype=xint8
# 
# outputTensor[0]: name=layer138-conv_fixed, dims=[1, 52, 52, 255], dtype=xint8
# outputTensor[1]: name=layer149-conv_fixed, dims=[1, 26, 26, 255], dtype=xint8
# outputTensor[2]: name=layer160-conv_fixed, dims=[1, 13, 13, 255], dtype=xint8

# -------------------------------------------------------------------
# Load .xmodel downloaded from Vitis-AI repository
#yolov4_model_path = "models/yolov4_leaky_spp_m/yolov4_leaky_spp_m.xmodel"
yolov4_model_path = "models/yolov4_leaky_spp_m_pruned_0_36/yolov4_leaky_spp_m_pruned_0_36.xmodel"
# =============================================================================
# -------------------------------------------------------------------
def resize_with_padding(image, size):
    # resize image with unchanged aspect ratio using padding
    ih, iw, _ = image.shape
    w, h = size
    scale = min(w/iw, h/ih)
    
    nw = int(iw*scale)
    nh = int(ih*scale)
    
    image = cv2.resize(image, (nw,nh), interpolation=cv2.INTER_LINEAR)
    new_image = np.ones((h,w,3), np.uint8) * 128
    h_start = (h-nh)//2
    w_start = (w-nw)//2
    new_image[h_start:h_start+nh, w_start:w_start+nw, :] = image
    return new_image

# -------------------------------------------------------------------
def preprocess_img(image, size, fixpos):
    image = image[...,::-1]
    image = resize_with_padding(image, size)
    
    image_data = np.array(image, dtype='float32', order='C')
    fix_scale = 2**fixpos
    image_data *= fix_scale/255
    image_data = np.expand_dims(image_data, 0)
    return image_data
    
# -------------------------------------------------------------------
def sigmoid(x):
    return 1 / (1 + np.exp(-x))

# -------------------------------------------------------------------
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

# -------------------------------------------------------------------
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

# -------------------------------------------------------------------
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

# -------------------------------------------------------------------
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

# -------------------------------------------------------------------
def fix2float(fix_point, value):
    return value.astype(np.float32) * np.exp2(fix_point, dtype=np.float32)

# -------------------------------------------------------------------
def float2fix(fix_point, value):
    return value.astype(np.float32) / np.exp2(fix_point, dtype=np.float32)
