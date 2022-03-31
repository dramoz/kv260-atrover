# =============================================================================
# First order of things is to import DPU and load the overlay
from xml.sax.saxutils import prepare_input_source
from pynq_dpu import DpuOverlay

from pprint import pprint
overlay = DpuOverlay("dpu.bit")
#pprint(overlay.ip_dict)

# -------------------------------------------------------------------
import cv2
import numpy as np
import time
from enum import Enum

# =============================================================================
# -------------------------------------------------------------------
class CamResMode(Enum):
    LOW = (640, 240)
    MEDIUM = (1280, 480) 
    HIGH = (2560, 720)
    
# =============================================================================
# Ref. design
# https://github.com/Xilinx/Vitis-AI/blob/v1.1/mpsoc/vitis_ai_dnndk_samples/tf_yolov3_voc_py/tf_yolov3_voc.py
# From Vitis-AI Zoo
# 1. data channel order: BGR(0~255)                
# 2. resize: 416 * 416(H * W) 
# 3. mean_value: 0.0, 0.0, 0.0
# 4. scale: 1 / 255.0
# 5. reisze mode: biliner

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
overlay.load_model("models/yolov4_leaky_spp_m/yolov4_leaky_spp_m.xmodel")
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
def resize_with_padding(image, size):
    # resize image with unchanged aspect ratio using padding
    ih, iw, _ = image.shape
    w = h = size
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
def preprocess_img(image, size):
    image = image[...,::-1]
    image = resize_with_padding(image, size)
    
    image_data = np.array(image, dtype='float32')
    image_data /= 255.
    image_data = np.expand_dims(image_data, 0)
    
    return image_data

# -------------------------------------------------------------------
def run_dpu(frame):
    preprocessed = preprocess_img(frame, 416)
    image[0,...] = preprocessed.reshape(shapeIn[1:])
    job_id = dpu.execute_async(input_data, output_data)
    dpu.wait(job_id)
    
    for tensor in output_data:
        print(f"size: {tensor.size}, shape:{tensor.shape}")
    
    return 
    
# =============================================================================
# -------------------------------------------------------------------
dpu = overlay.runner

inputTensors = dpu.get_input_tensors()
outputTensors = dpu.get_output_tensors()

shapeIn = tuple(inputTensors[0].dims)
shapeOut = tuple(outputTensors[0].dims)
outputSize = int(outputTensors[0].get_data_size() / shapeIn[0])

# -------------------------------------------------------------------
output_data = [np.empty(shapeOut, dtype=np.float32, order="C")]
input_data = [np.empty(shapeIn, dtype=np.float32, order="C")]
image = input_data[0]

# =============================================================================
# ------------------------------------------------------------------------
frame_width, frame_height, cam = open_cam(resolution=CamResMode.MEDIUM)
single_frame_dims = (frame_width//2, frame_height)
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
        frame, rgt_frame = frame[:, :frame_width//2], frame[:, frame_width//2:]
        img_out = frame.copy()
        proc_txt.append("lft_frame")
        
        # ---------------------------------------------------------------------------
        # Image transformation
        # ---------------------------------------------------------------------------
        img_out = resize_with_padding(img_out, 416)
        
        # ---------------------------------------------------------------------------
        # DPU
        run_dpu(frame)
        
        # ---------------------------------------------------------------------------
        
        
        # ---------------------------------------------------------------------------
        # Calculate Frames per second (FPS)
        if num_frames == avg_frames:
            elapsed = (cv2.getTickCount() - tick_cnt_start) / cv2.getTickFrequency()
            fps = num_frames/elapsed
            
            tick_cnt_start = cv2.getTickCount()
            num_frames = 0
        
        text_y_pos += draw_text(img_out, f"FPS: {fps:.2f}", (text_x_pos,text_y_pos))[1]
        
        # ---------------------------------------------------------------------------
        # Draw final
        cv2.imshow("org", frame)
        cv2.imshow("resize_padding", img_out)
        
        # ---------------------------------------------------------------------------
        # Check exit
        if cv2.waitKey(1) == ord('q'):
            break
        
# =============================================================================
# -------------------------------------------------------------------
# Close App. properly
cam.release()
cv2.destroyAllWindows()
