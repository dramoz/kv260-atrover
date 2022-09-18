# =============================================================================
import xir
import vart
# -------------------------------------------------------------------
import cv2
import numpy as np
import time
from enum import Enum

# -------------------------------------------------------------------
from dpu_yolov4 import *
from coco_labels import get_coco_labels

coco_labels = get_coco_labels()
# =============================================================================
# -------------------------------------------------------------------
class CamResMode(Enum):
    LOW = (640, 240)
    MEDIUM = (1280, 480) 
    HIGH = (2560, 720)
    
# =============================================================================
# -------------------------------------------------------------------
def draw_text(
    frame, text,
    pos = (0, 0),
    text_color = (0, 192, 0), text_color_bg = (0, 0, 0), text_bg_px_offset=(2,2),
    font = cv2.FONT_HERSHEY_PLAIN, font_scale = 1, font_thickness = 1,
):
    x, y = pos
    text_size, _ = cv2.getTextSize(text, font, font_scale, font_thickness)
    text_w, text_h = text_size
    
    bg_x0 = x - text_bg_px_offset[0] if x > text_bg_px_offset[0] else 0
    bg_y0 = y - text_bg_px_offset[1] if y > text_bg_px_offset[1] else 0
    bg_x1 = x + text_w + text_bg_px_offset[0]
    bg_y1 = y + text_h + text_bg_px_offset[1]
    cv2.rectangle(frame, (bg_x0, bg_y0), (bg_x1, bg_y1), text_color_bg, -1)
    
    cv2.putText(frame, text, (x, y + text_h + font_scale - 1), font, font_scale, text_color, font_thickness)
    
    return text_w, text_h + 2*text_bg_px_offset[1]
    
# -------------------------------------------------------------------
def open_cam(resolution = CamResMode.MEDIUM):
    cam = cv2.VideoCapture(0)
    if not cam.isOpened():
        print("Cannot open camera")
        exit()
    
    frame_width = resolution.value[0]
    frame_height = resolution.value[1]
    
    cam.set(cv2.CAP_PROP_FRAME_WIDTH, frame_width)
    cam.set(cv2.CAP_PROP_FRAME_HEIGHT, frame_height)
    
    return frame_width, frame_height, cam
    
# =============================================================================
# -------------------------------------------------------------------
def get_child_subgraph_dpu(graph):
    assert graph is not None, "'graph' should not be None."
    root_subgraph = graph.get_root_subgraph()
    assert (
        root_subgraph is not None
    ), "Failed to get root subgraph of input Graph object."
    if root_subgraph.is_leaf:
        return []
    child_subgraphs = root_subgraph.toposort_child_subgraph()
    assert child_subgraphs is not None and len(child_subgraphs) > 0
    return [
        cs
        for cs in child_subgraphs
        if cs.has_attr("device") and cs.get_attr("device").upper() == "DPU"
    ]

# =============================================================================
# -------------------------------------------------------------------
def execute_async(dpu, tensor_buffers_dict):
    input_tensor_buffers = [ tensor_buffers_dict[t.name] for t in dpu.get_input_tensors() ]
    output_tensor_buffers = [ tensor_buffers_dict[t.name] for t in dpu.get_output_tensors() ]
    
    job_id = dpu.execute_async(input_tensor_buffers, output_tensor_buffers)
    return dpu.wait(job_id)

# -------------------------------------------------------------------
def run_dpu(dpu, frame):
    # get DPU input/output tensors
    input_tensor_buffers = dpu.get_inputs()
    output_tensor_buffers = dpu.get_outputs()
    output_tensors_dims = dpu.get_output_tensors()
    
    input_ndim_1 = tuple(input_tensor_buffers[0].get_tensor().dims)
    fixpos = input_tensor_buffers[0].get_tensor().get_attr("fix_point")
    
    ih, iw, _ = frame.shape
    img = preprocess_img(frame, (416, 416), fixpos)
    input_data = np.asarray(input_tensor_buffers[0])
    input_data[0] = img
    _ = dpu.execute_async(input_tensor_buffers, output_tensor_buffers)
    
    # start post process
    #conv_out = [ np.reshape(output_tensor_buffers[inx], output_tensors_dims[inx].dims) for inx in range(len(output_tensors_dims)) ]
    conv_out = [None] * 3
    conv_out[2] = np.reshape(output_tensor_buffers[2], (1, 13, 13, 3, 85))
    conv_out[1] = np.reshape(output_tensor_buffers[1], (1, 26, 26, 3, 85))
    conv_out[0] = np.reshape(output_tensor_buffers[0], (1, 52, 52, 3, 85))
    
    num_classes = len(coco_labels)
    boxes = []
    #boxes.append( yolo_box(conv_out[0], 52, num_classes,yolo_anchors[yolo_anchor_masks[2]],0) )
    #boxes.append( yolo_box(conv_out[1], 26, num_classes,yolo_anchors[yolo_anchor_masks[1]],1) )
    #boxes.append( yolo_box(conv_out[2], 13, num_classes,yolo_anchors[yolo_anchor_masks[0]],2) )
    #outputs = yolo_non_max_suppression(boxes, 0.25, 0.45)
    #boxes, confidence, classes, nums = outputs
    #print(nums)
    
    # start annotation
    if iw>ih:
        offset = np.array([0, (0.5-ih/(2*iw))])
        scale = iw
    else:
        offset = np.array([(0.5-iw/(2*ih)), 0])
        scale = ih
    # use this draw output funciton if image is resized with keeping original aspect ratio
    #imgdisplay = imgQ_Display.get()
    #img = draw_outputs_scale(frame, scale, offset, outputs, coco_labels)
    #img = draw_outputs_scale(frame, outputs, class_names)
    
    return resize_with_padding(frame, (416, 416))

# =============================================================================
# -------------------------------------------------------------------
xgraph = xir.Graph.deserialize(yolov4_model_path)
subgraphs = get_child_subgraph_dpu(xgraph)
assert len(subgraphs) == 1  # only one DPU kernel

dpu = vart.RunnerExt.create_runner(subgraphs[0], "run")
print(dpu.get_input_tensors())
print(dpu.get_output_tensors())
# =============================================================================
# ------------------------------------------------------------------------
#frame_width, frame_height, cam = open_cam(resolution=CamResMode.MEDIUM)
#single_frame_dims = (frame_width//2, frame_height)
cam = cv2.VideoCapture(0)
if cam.isOpened():
    fps = cam.get(cv2.CAP_PROP_FPS)
    print(f"Sucesfully opened USB/CAM (fps:{fps})")
    
    num_frames = 0
    avg_frames = 10
    tick_cnt_start = cv2.getTickCount()
    text_inital_pos = (10, 10)
    while True:
        # ---------------------------------------------------------------------------
        # Capture frame-by-frame
        proc_txt = []
        text_x_pos, text_y_pos = text_inital_pos
        
        ret, frame = cam.read()
        num_frames += 1
        if not ret:
            print("Can't receive frame (stream end?). Exiting ...")
            break
        
        # ---------------------------------------------------------------------------
        # Single/Split frames?
        #frame, rgt_frame = frame[:, :frame_width//2], frame[:, frame_width//2:]
        #proc_txt.append("lft_frame")
        
        # ---------------------------------------------------------------------------
        # Image transformation
        # ---------------------------------------------------------------------------
        # ---------------------------------------------------------------------------
        # DPU
        img_out = run_dpu(dpu, frame)
        #img_out = frame
        # ---------------------------------------------------------------------------
        
        
        # ---------------------------------------------------------------------------
        # Calculate Frames per second (FPS)
        if num_frames == avg_frames:
            elapsed = (cv2.getTickCount() - tick_cnt_start) / cv2.getTickFrequency()
            fps = num_frames/elapsed
            print(f"fps: {fps}")
            
            tick_cnt_start = cv2.getTickCount()
            num_frames = 0
        
        text_y_pos += draw_text(img_out, f"FPS: {fps:.2f}", (text_x_pos,text_y_pos))[1]
        
        # ---------------------------------------------------------------------------
        # Draw final
        cv2.imshow("org", img_out)
        # ---------------------------------------------------------------------------
        # Check exit
        if cv2.waitKey(1) == ord('q'):
            break
        
# =============================================================================
# -------------------------------------------------------------------
# Close App. properly
cam.release()
cv2.destroyAllWindows()
