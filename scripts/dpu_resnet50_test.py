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
# -> This is a simple test to validate that the # .xmodel downloaded from
# Vitis-AI matchs the .xmodel of DPU-PYNQ notebook example.

# Load DPU notebook .xmodel and related files
#overlay.load_model("models/resnet50/dpu_resnet50.xmodel")
#with open("models/resnet50/words.txt", "r") as f:
#    softmax_labels = f.readlines()

# Load .xmodel downloaded from Vitis-AI repository
overlay.load_model("models/resnet50.2/resnet50.xmodel")
with open("models/resnet50/words.txt", "r") as f:
    softmax_labels = f.readlines()

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
_R_MEAN = 123.68
_G_MEAN = 116.78
_B_MEAN = 103.94

MEANS = [_B_MEAN,_G_MEAN,_R_MEAN]

def resize_shortest_edge(image, size):
    H, W = image.shape[:2]
    if H >= W:
        nW = size
        nH = int(float(H)/W * size)
    else:
        nH = size
        nW = int(float(W)/H * size)
    return cv2.resize(image,(nW,nH))

def mean_image_subtraction(image, means):
    B, G, R = cv2.split(image)
    B = B - means[0]
    G = G - means[1]
    R = R - means[2]
    image = cv2.merge([R, G, B])
    return image

def BGR2RGB(image):
    B, G, R = cv2.split(image)
    image = cv2.merge([R, G, B])
    return image

def central_crop(image, crop_height, crop_width):
    image_height = image.shape[0]
    image_width = image.shape[1]
    offset_height = (image_height - crop_height) // 2
    offset_width = (image_width - crop_width) // 2
    return image[offset_height:offset_height + crop_height, offset_width:
                 offset_width + crop_width, :]

def normalize(image):
    image=image/256.0
    image=image-0.5
    image=image*2
    return image

def preprocess_fn(image, crop_height = 224, crop_width = 224):
    image = resize_shortest_edge(image, 256)
    image = mean_image_subtraction(image, MEANS)
    image = central_crop(image, crop_height, crop_width)
    return image
# -------------------------------------------------------------------
def calculate_softmax(data):
    result = np.exp(data)
    return result

# -------------------------------------------------------------------
def run_dpu(frame):
    preprocessed = preprocess_fn(frame)
    image[0,...] = preprocessed.reshape(shapeIn[1:])
    job_id = dpu.execute_async(input_data, output_data)
    dpu.wait(job_id)
    temp = [j.reshape(1, outputSize) for j in output_data]
    softmax = calculate_softmax(temp[0][0])
    
    return softmax
    
# =============================================================================
# -------------------------------------------------------------------
dpu = overlay.runner

inputTensors = dpu.get_input_tensors()
outputTensors = dpu.get_output_tensors()

shapeIn = tuple(inputTensors[0].dims)
shapeOut = tuple(outputTensors[0].dims)
outputSize = int(outputTensors[0].get_data_size() / shapeIn[0])

softmax = np.empty(outputSize)
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
        # ...
        
        # ---------------------------------------------------------------------------
        # DPU
        softmax = run_dpu(frame)
        softmax_inx = np.argmax(softmax)-1
        proc_txt.append(f"softmax_inx: {softmax_inx}")
        proc_txt.append(f"label: {softmax_labels[softmax_inx]}")
        
        # ---------------------------------------------------------------------------
        text_y_pos += draw_text(img_out, f"[{('| ').join(proc_txt)}]", (text_x_pos, text_y_pos))[1]
        
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
        cv2.imshow("Countours", img_out)
        
        # ---------------------------------------------------------------------------
        # Check exit
        if cv2.waitKey(1) == ord('q'):
            break
        
# =============================================================================
# -------------------------------------------------------------------
# Close App. properly
cam.release()
cv2.destroyAllWindows()
