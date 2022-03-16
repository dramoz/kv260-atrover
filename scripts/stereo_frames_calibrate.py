import sys
import cv2
from pathlib import Path

    
# -----------------------------------------------------------------------------
# Local modules
_workpath = Path(__file__).resolve().parent
sys.path.append(str(_workpath))

# -------------------------------------------------------
class StereoFramesCalibrate:
    class ROI:
        def __init__(self, lft_roi, rgt_roi) -> None:
            self.x = int( max(lft_roi[0], rgt_roi[0]) )
            self.y = int( max(lft_roi[1], rgt_roi[1]) )
            self.w = int( min(lft_roi[2], rgt_roi[2]) )
            self.h = int( min(lft_roi[3], rgt_roi[3]) )
        
    def __init__(self, resolution) -> None:
        # -------------------------------------------------------
        self.frame_width = resolution.value[0]
        self.frame_height = resolution.value[1]
        self.single_frame_dims = (self.frame_width//2, self.frame_height)

        # -------------------------------------------------------
        # Load parameters
        cv_file = cv2.FileStorage()
        cv_file.open(f'camera_calibration_data_gen/stereoCalibrationMap_w{self.frame_width}_h{self.frame_height}.xml', cv2.FILE_STORAGE_READ)
        
        self.lft_stereoMap_x = cv_file.getNode('lft_stereoMap_x').mat()
        self.lft_stereoMap_y = cv_file.getNode('lft_stereoMap_y').mat()
        
        self.rgt_stereoMap_x = cv_file.getNode('rgt_stereoMap_x').mat()
        self.rgt_stereoMap_y = cv_file.getNode('rgt_stereoMap_y').mat()
        
        self.roi = StereoFramesCalibrate.ROI( cv_file.getNode('lft_ROI').mat(), cv_file.getNode('rgt_ROI').mat() )
        
    def _crop_frame(self, frame):
        return frame[self.roi.y:self.roi.y+self.roi.h, self.roi.x:self.roi.x+self.roi.w]
        
    def calibrate(self, stereo_frame, crop_en=True, resize=True):
        lft_frame = stereo_frame[:, :self.frame_width//2]
        rgt_frame = stereo_frame[:, self.frame_width//2:]
        
        lft_calibrated_frame = cv2.remap(lft_frame, self.lft_stereoMap_x, self.lft_stereoMap_y, cv2.INTER_LANCZOS4, cv2.BORDER_CONSTANT, 0)
        rgt_calibrated_frame = cv2.remap(rgt_frame, self.rgt_stereoMap_x, self.rgt_stereoMap_y, cv2.INTER_LANCZOS4, cv2.BORDER_CONSTANT, 0)
        
        if crop_en:
            lft_calibrated_frame = self._crop_frame(lft_calibrated_frame)
            rgt_calibrated_frame = self._crop_frame(rgt_calibrated_frame)
        
        if resize:
            lft_calibrated_frame = cv2.resize(lft_calibrated_frame, self.single_frame_dims)
            rgt_calibrated_frame = cv2.resize(rgt_calibrated_frame, self.single_frame_dims)
            
        return lft_calibrated_frame, rgt_calibrated_frame
        