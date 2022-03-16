import sys
from pathlib import Path

import numpy as np
import pandas as pd
import cv2
import random as rnd
from pathlib import Path
from pprint import pprint

# -----------------------------------------------------------------------------
# Local modules
_workpath = Path(__file__).resolve().parent
sys.path.append(str(_workpath))

from stereocam import CamResMode, StereoCam, CamUtils

cam = StereoCam(0, CamResMode.MEDIUM, False)
cam_utils = CamUtils()
cam.enable_calibration_eng(remap=False, crop_en=False, resize=False)

while True:
    lft_frame, rgt_frame = cam.get_frame()
    contours_info = cam_utils.get_contours(lft_frame, rgt_frame)
    print(f"lft_contours: {len(contours_info[0])}, rgt_contours: {len(contours_info[1])}")
    lft_frame, rgt_frame = cam_utils.draw_contours(lft_frame, rgt_frame, contours_info, draw_center=True, draw_contours=False, draw_bbox=True)
    
    cv2.imshow("lft_frame", lft_frame)
    cv2.imshow("rgt_frame", rgt_frame)
    
    if cv2.waitKey(1) == ord('q'):
        break
