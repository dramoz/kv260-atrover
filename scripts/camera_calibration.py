import sys
import shutil
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
# resolution: max. resolution should give better calibration results
# termination criteria: corner refinement
resolution = ResMode.MEDIUM
#criteria = (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER, 30, 0.001)
criteria = (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER, 100, 0.0001)

size_of_chessboard_squares_mm = 18
chessboard_dims = (10-1, 7-1)

# -------------------------------------------------------

frame_width = resolution.value[0]
frame_height = resolution.value[1]
single_frame_dims = (frame_width//2, frame_height)
img_path = f'images/calibration/w{frame_width}_h{frame_height}'

"""
print(f"Capture new images? [y/N]")
k = cv2.waitKey(0)
if k == ord('y'):
    capture_images = True
    
else:
    capture_images = False
"""
capture_images = True
chessboard = cv2.imread(f"images/pattern.png")

# Points
objp = np.zeros((np.prod(chessboard_dims),3), np.float32)
objp[:,:2] = np.mgrid[0:chessboard_dims[0],0:chessboard_dims[1]].T.reshape(-1,2)
objp = objp * size_of_chessboard_squares_mm

# Arrays to store object points and image points from all the images.
objpoints = [] # 3d point in real world space
lft_imgpoints = [] # 2d points in image plane.
rgt_imgpoints = [] # 2d points in image plane.

# -------------------------------------------------------
print(f'Camera calibration... opening device 0...')
cam = cv2.VideoCapture(0)
if not cam.isOpened():
    print("Cannot open camera")
    sys.exit(1)

print(f'Setting resolution to w:{frame_width} x h:{frame_height}')
cam.set(cv2.CAP_PROP_FRAME_WIDTH, frame_width)
cam.set(cv2.CAP_PROP_FRAME_HEIGHT, frame_height)

# -------------------------------------------------------
print("Capturing chessboard images")
print(f"Captured Images: 0, points: 0 (c:capture next, d:done, q:exit)")
num_frames = 0
lft_frames = []
rgt_frames = []
capturing = False

if capture_images:
    if Path(img_path).exists():
      shutil.rmtree(img_path)
    Path(img_path).mkdir(parents=True, exist_ok=True)

while capture_images:
    # Capture frame-by-frame
    ret, frame = cam.read()
    
    # if frame is read correctly ret is True
    if not ret:
        print("Can't receive frame (stream end?). Exiting ...")
        break
    
    # Show original
    cv2.imshow('original', frame)
    if not capturing:
        k = cv2.waitKey(100)
        if k == ord('d'):
            break
        
        elif k == ord('q'):
            print("Exit by user...")
            sys.exit(1)
            
        elif k == ord('c'):
            capturing = True
            print("Capturing next frame...")
    
    else:
        # Check captured frame
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        lft_image = gray[:, :frame_width//2]
        rgt_image = gray[:, frame_width//2:]
        
        # Find the chess board corners
        lft_ret, lft_corners = cv2.findChessboardCorners(lft_image, chessboard_dims, None)
        rgt_ret, rgt_corners = cv2.findChessboardCorners(rgt_image, chessboard_dims, None)
        
        # If found, add object points, image points (after refining them)
        print(f"lft_ret: {lft_ret}, rgt_ret: {rgt_ret}")
        if lft_ret == True and rgt_ret == True:
            objpoints.append(objp)
            
            lft_corners = cv2.cornerSubPix(lft_image, lft_corners, (11,11), (-1,-1), criteria)
            rgt_corners = cv2.cornerSubPix(rgt_image, rgt_corners, (11,11), (-1,-1), criteria)
            
            # Draw and display the corners
            cv2.drawChessboardCorners(lft_image, chessboard_dims, lft_corners, lft_ret)
            cv2.imshow('lft_image', lft_image)
            #cv2.moveWindow('lft_image', frame_width, 10)
            
            cv2.drawChessboardCorners(rgt_image, chessboard_dims, rgt_corners, rgt_ret)
            cv2.imshow('rgt_image', rgt_image)
            #cv2.moveWindow('rgt_image', 2*frame_width, 10)
            
            print("Valid frame (s:save, d:done, q:exit, any:skip)")
            k = cv2.waitKey(0)
            if k == ord('d'):
                break
            
            elif k == ord('q'):
                print("Exit by user...")
                sys.exit(1)
                
            elif k == ord('s'):
                capturing = False
                # Store data
                lft_imgpoints.append(lft_corners)
                rgt_imgpoints.append(rgt_corners)
                lft_frames.append(lft_image)
                rgt_frames.append(rgt_frames)
                
                cv2.imwrite(f"{img_path}/lft_{num_frames}.png", lft_image)
                cv2.imwrite(f"{img_path}/rgt_{num_frames}.png", rgt_image)
                
                num_frames += 1
                
            print(f"Captured Images: {num_frames}, points: {len(objpoints)} (d:done, q:exit)")
            cv2.destroyWindow('lft_image')
            cv2.destroyWindow('rgt_image')
            
        else:
            k = cv2.waitKey(100)
            if k == ord('d'):
                break
            
            elif k == ord('q'):
                print("Exit by user...")
                sys.exit(1)
        
# -------------------------------------------------------
# Calibrate Single Cams
single_frame_dims = (frame_width//2, frame_height)
lft_ret, lft_CamMatrix, lft_distCoeff, lft_RotVectors, lft_TransVectors = cv2.calibrateCamera(objpoints, lft_imgpoints, single_frame_dims, None, None)
rgt_ret, rgt_CamMatrix, rgt_distCoeff, rgt_RotVectors, rgt_TransVectors = cv2.calibrateCamera(objpoints, rgt_imgpoints, single_frame_dims, None, None)

if True:
    lft_CamMatrix, lft_roi = cv2.getOptimalNewCameraMatrix(lft_CamMatrix, lft_distCoeff, single_frame_dims, 0, single_frame_dims)
    rgt_CamMatrix, rgt_roi = cv2.getOptimalNewCameraMatrix(rgt_CamMatrix, rgt_distCoeff, single_frame_dims, 0, single_frame_dims)

# -------------------------------------------------------
# Calibrate Stereo Cam
stereoCalibration_flags = cv2.CALIB_FIX_INTRINSIC
stereo_ret, stereo_lft_CamMatrix, stereo_lft_distCoeff, stereo_rgt_CamMatrix, stereo_rgt_distCoeff, stereo_RotVectors, stereo_TransVectors, essentialMatrix, fundamentalMatrix = cv2.stereoCalibrate(objpoints, lft_imgpoints, rgt_imgpoints, lft_CamMatrix, lft_distCoeff, rgt_CamMatrix, rgt_distCoeff, single_frame_dims, criteria=criteria, flags=stereoCalibration_flags)

# -------------------------------------------------------
# Stereo Rectification
rectifyScale = 1
newImageSize = (0,0)  # same
lft_rectT, rgt_rectT, lft_projMatrix, rgt_projMatrix, Q, lft_roi, rgt_roi= cv2.stereoRectify(lft_CamMatrix, lft_distCoeff, rgt_CamMatrix, rgt_distCoeff, single_frame_dims, stereo_RotVectors, stereo_TransVectors, alpha=rectifyScale, newImageSize=newImageSize)

lft_stereoMap = cv2.initUndistortRectifyMap(lft_CamMatrix, lft_distCoeff, lft_rectT, lft_projMatrix, single_frame_dims, cv2.CV_16SC2)
rgt_stereoMap = cv2.initUndistortRectifyMap(rgt_CamMatrix, rgt_distCoeff, rgt_rectT, rgt_projMatrix, single_frame_dims, cv2.CV_16SC2)

print("Saving parameters!")
cv_file = cv2.FileStorage(f'stereoCalibrationMap_w{frame_width}_h{frame_height}.xml', cv2.FILE_STORAGE_WRITE)

cv_file.write('lft_stereoMap_x',lft_stereoMap[0])
cv_file.write('lft_stereoMap_y',lft_stereoMap[1])
cv_file.write('lft_ROI',lft_roi)

cv_file.write('rgt_stereoMap_x',rgt_stereoMap[0])
cv_file.write('rgt_stereoMap_y',rgt_stereoMap[1])
cv_file.write('rgt_ROI',rgt_roi)

cv_file.release()

# When everything done, release the capture
cam.release()
cv2.destroyAllWindows()
