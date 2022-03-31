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
# -------------------------------------------------------------------
overlay.load_model("models/ssd_resnet_50_fpn_coco_tf/ssd_resnet_50_fpn_coco_tf.xmodel")

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
# From Vitis-AI Zoo
# 1. Data preprocess
#   data channel order: RGB(0~255)                
#   resize: 640 * 640 (tf.image.resize_images(image, tf.stack([new_height, new_width]), method=tf.image.ResizeMethod.BILINEAR, align_corners=False))
#   channel_means = [123.68, 116.779, 103.939]
#   input = input - channel_means
# 
# 2. Node information
#   input node: 'image_tensor:0'
#   output nodes: 'concat:0', 'concat_1:0'
# 
# -------------------------------------------------------------------
_R_MEAN = 123.68
_G_MEAN = 116.779
_B_MEAN = 103.939
MEANS = [_B_MEAN,_G_MEAN,_R_MEAN]

# -------------------------------------------------------------------
def resize(image, size):
    return cv2.resize(image, (size, size), interpolation=cv2.INTER_LINEAR)
# -------------------------------------------------------------------
def resize_shortest_edge(image, size):
    H, W = image.shape[:2]
    if H >= W:
        nW = size
        nH = int(float(H)/W * size)
    else:
        nH = size
        nW = int(float(W)/H * size)
    return cv2.resize(image,(nW,nH))
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
def mean_image_subtraction(image, means):
    B, G, R = cv2.split(image)
    B = B - means[0]
    G = G - means[1]
    R = R - means[2]
    image = cv2.merge([R, G, B])
    return image
# -------------------------------------------------------------------
def BGR2RGB(image):
    B, G, R = cv2.split(image)
    image = cv2.merge([R, G, B])
    return image
# -------------------------------------------------------------------
def preprocess_img(image, size=640):
    image = resize(image, size)
    image = mean_image_subtraction(image, MEANS)
    return image
# -------------------------------------------------------------------
def run_dpu(frame):
    preprocessed = preprocess_img(frame)
    image[0,...] = preprocessed.reshape(shapeIn[0][1:])
    job_id = dpu.execute_async(input_data, output_data)
    dpu.wait(job_id)
    
    print(f"max: {labels[0][0].argmax()}, size: {labels[0][0].size}, shape:{labels[0][0].shape}")
    print(f"bbox: {bboxes[0][0]}, size: {bboxes[0][0].size}, shape:{bboxes[0][0].shape}")
    for tensor in output_data:
        print(f"size: {tensor.size}, shape:{tensor.shape}")
        
    return
    
# =============================================================================
# -------------------------------------------------------------------
dpu = overlay.runner

inputTensors = dpu.get_input_tensors()
outputTensors = dpu.get_output_tensors()

# Reserve Input buffers
shapeIn  = [tuple(tensor.dims) for tensor in inputTensors]
input_data = [ np.empty(shape, dtype=np.float32, order="C") for shape in shapeIn ]

# Reserve Output Buffers
shapeOut = [tuple(tensor.dims) for tensor in outputTensors]
output_data = [ np.empty(shape, dtype=np.float32, order="C") for shape in shapeOut ]

#outputSize = int(outputTensors[0].get_data_size() / shapeIn[0])
#softmax = np.empty(outputSize)
# -------------------------------------------------------------------
# Label input/output vectors
image = input_data[0]
labels = output_data[0]
bboxes = output_data[1]

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
        img_out = resize(img_out, 640)
        
        # ---------------------------------------------------------------------------
        # DPU
        run_dpu(frame)
        
        
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
