import sys
import numpy as np
import time
import imutils
import cv2

# Camera parameters to undistort and rectify images
cv_file = cv2.FileStorage()
cv_file.open('stereoCalibrationMap_w1280_h480.xml', cv2.FileStorage_READ)

lft_stereoMap_x = cv_file.getNode('lft_stereoMap_x').mat()
lft_stereoMap_y = cv_file.getNode('lft_stereoMap_y').mat()
rgt_stereoMap_x = cv_file.getNode('rgt_stereoMap_x').mat()
rgt_stereoMap_y = cv_file.getNode('rgt_stereoMap_y').mat()


def undistortRectify(frameR, frameL):
    # Undistort and rectify images
    undistortedL= cv2.remap(frameL, lft_stereoMap_x, lft_stereoMap_y, cv2.INTER_LANCZOS4, cv2.BORDER_CONSTANT, 0)
    undistortedR= cv2.remap(frameR, rgt_stereoMap_x, rgt_stereoMap_y, cv2.INTER_LANCZOS4, cv2.BORDER_CONSTANT, 0)
    
    return undistortedR, undistortedL