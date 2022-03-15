import sys
from pprint import pprint
from enum import Enum
from pathlib import Path
from xml.etree.ElementTree import TreeBuilder

import numpy as np
import pandas as pd
import cv2

# -------------------------------------------------------
# Camera calibration
# https://github.com/opencv/opencv/blob/4.x/doc/pattern.png

# -------------------------------------------------------
class ResMode(Enum):
    LOW = (640, 240)
    MEDIUM = (1280, 480) 
    HIGH = (2560, 720)

# -------------------------------------------------------
# Parameters
resolution = ResMode.MEDIUM

# -------------------------------------------------------
frame_width = resolution.value[0]
frame_height = resolution.value[1]
single_frame_dims = (frame_width//2, frame_height)

# -------------------------------------------------------
print(f'Camera calibration test: opening device 0...')
cam = cv2.VideoCapture(0)
if not cam.isOpened():
    print("Cannot open camera")
    sys.exit(1)

print(f'Setting resolution to w:{frame_width} x h:{frame_height}')
cam.set(cv2.CAP_PROP_FRAME_WIDTH, frame_width)
cam.set(cv2.CAP_PROP_FRAME_HEIGHT, frame_height)

# -------------------------------------------------------
# Load parameters
cv_file = cv2.FileStorage()
cv_file.open(f'stereoCalibrationMap_w{frame_width}_h{frame_height}.xml', cv2.FILE_STORAGE_READ)

lft_stereoMap_x = cv_file.getNode('lft_stereoMap_x').mat()
lft_stereoMap_y = cv_file.getNode('lft_stereoMap_y').mat()
lft_x, lft_y, lft_w, lft_h  = cv_file.getNode('lft_ROI').mat()
lft_x, lft_y, lft_w, lft_h = int(lft_x), int(lft_y), int(lft_w), int(lft_h)

rgt_stereoMap_x = cv_file.getNode('rgt_stereoMap_x').mat()
rgt_stereoMap_y = cv_file.getNode('rgt_stereoMap_y').mat()
rgt_x, rgt_y, rgt_w, rgt_h = cv_file.getNode('rgt_ROI').mat()
rgt_x, rgt_y, rgt_w, rgt_h = int(rgt_x), int(rgt_y), int(rgt_w), int(rgt_h)

print(f"")
# -------------------------------------------------------
while True:
    # Capture frame-by-frame
    ret, frame = cam.read()
    
    # if frame is read correctly ret is True
    if not ret:
        print("Can't receive frame (stream end?). Exiting ...")
        break
    
    # Check captured frame
    lft_frame = frame[:, :frame_width//2]
    rgt_frame = frame[:, frame_width//2:]
    cv2.imshow("lft_frame", lft_frame)
    cv2.imshow("rgt_frame", rgt_frame)
    
    # Transform frames
    lft_remap_frame = cv2.remap(lft_frame, lft_stereoMap_x, lft_stereoMap_y, cv2.INTER_LANCZOS4, cv2.BORDER_CONSTANT, 0)[lft_y:lft_y+lft_h, lft_x:lft_x+lft_w]
    rgt_remap_frame = cv2.remap(rgt_frame, rgt_stereoMap_x, rgt_stereoMap_y, cv2.INTER_LANCZOS4, cv2.BORDER_CONSTANT, 0)[rgt_y:rgt_y+rgt_h, rgt_x:rgt_x+rgt_w]
    
    lft_fn_frame = cv2.resize(lft_remap_frame, single_frame_dims)
    rgt_fn_frame = cv2.resize(rgt_remap_frame, single_frame_dims)
    cv2.imshow("lft_remap_image", lft_fn_frame)
    cv2.imshow("rgt_remap_image", rgt_fn_frame)
    
    # Hit "q" to close the window
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# When everything done, release the capture
cam.release()
cv2.destroyAllWindows()
