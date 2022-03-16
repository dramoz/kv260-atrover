# -----------------------------------------------------------------------------
import sys
from pathlib import Path
import numpy as np
import cv2

# -----------------------------------------------------------------------------
# Local modules
_workpath = Path(__file__).resolve().parent
sys.path.append(str(_workpath))

from stereo_frames_calibrate import StereoFramesCalibrate

# -----------------------------------------------------------------------------
from enum import Enum
class CamResMode(Enum):
    LOW = (640, 240)
    MEDIUM = (1280, 480) 
    HIGH = (2560, 720)

# -----------------------------------------------------------------------------
class StereoCam:
    def __del__(self):
        self.cam.release()
        cv2.destroyAllWindows()
    
    def __init__(self, cam_id=0, resolution=CamResMode.MEDIUM.value, show_stats=False) -> None:
        self.remap = False
        self.crop_en = False
        self.resize = False
        
        self.show_stats = show_stats
        self.num_frames = 0
        self.avg_frames = 10
        self.tick_cnt_start = cv2.getTickCount()
        
        self.cam = cv2.VideoCapture(cam_id)
        
        if not self.cam.isOpened():
            print(f"Cannot open camera with cam_id: {cam_id}")
            sys.exit(1)
            
        # -------------------------------------------------------
        self.resolution = resolution
        self.frame_width = resolution.value[0]
        self.frame_height = resolution.value[1]
        self.single_frame_dims = (self.frame_width//2, self.frame_height)
        
        self.cam.set(cv2.CAP_PROP_FRAME_WIDTH, self.frame_width)
        self.cam.set(cv2.CAP_PROP_FRAME_HEIGHT, self.frame_height)
        self.fps = self.cam.get(cv2.CAP_PROP_FPS)
        
    def enable_calibration_eng(self, remap=True, crop_en=True, resize=True):
        self.remap = remap
        self.crop_en = crop_en
        self.resize = resize
        self.calibration_eng = StereoFramesCalibrate(resolution=self.resolution)
        
    def draw_text(self, frame, txt, location, color = (128,128,128)):
        cv2.putText(frame, txt, location, cv2.FONT_HERSHEY_PLAIN, 1, color, 1, cv2.LINE_4)
    
    def get_frame(self):
        # Capture frame-by-frame
        ret, frame = self.cam.read()
        
        # if frame is read correctly ret is True
        if not ret:
            print("Can't receive frame (stream end?). Exiting ...")
            sys.exit(1)
        
        if self.remap:
            lft_frame, rgt_frame = self.calibration_eng.calibrate(frame, crop_en=self.crop_en, resize=self.resize)
            
        else:
            lft_frame, rgt_frame = frame[:, :self.frame_width//2], frame[:, self.frame_width//2:]
            
        if self.show_stats:
            self.draw_text(lft_frame, f"FPS: {self.fps:.2f}", (20,50))
        
        # FPS
        if(self.show_stats):
            self.num_frames += 1
            
            if self.num_frames == self.avg_frames:
                elapsed = (cv2.getTickCount() - self.tick_cnt_start) / cv2.getTickFrequency()
                self.fps = self.num_frames/elapsed
                
                self.tick_cnt_start = cv2.getTickCount()
                self.num_frames = 0
        
        return lft_frame, rgt_frame
        #frame = cv2.hconcat([lft_frame, rgt_frame])
        
# -----------------------------------------------------------------------------
class CamUtils:
    def __init__(self, resolution=CamResMode.MEDIUM, min_area_p=10, max_area_p=80) -> None:
        # -------------------------------------------------------
        self.resolution = resolution
        self.frame_width = resolution.value[0]
        self.frame_height = resolution.value[1]
        self.single_frame_dims = (self.frame_width//2, self.frame_height)
        
        self.farea = self.single_frame_dims[0] * self.single_frame_dims[1]
        
        self.min_area_p = min_area_p
        self.max_area_p = max_area_p
    
    def get_contours(self, lft_frame, rgt_frame):
        results = []
        
        for frame in [lft_frame, rgt_frame]:
            # gray -> blur -> canny -> dilate
            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
            frame = cv2.GaussianBlur(frame, (5, 5), cv2.BORDER_DEFAULT)
            #frame = cv2.threshold(frame, 50, 150, cv2.THRESH_BINARY)[1]
            frame = cv2.Canny(frame, 30, 150)
            
            # dilation
            dilation_value = 3
            dilation_iterations = 2
            dilation_kernel = np.ones((dilation_value,dilation_value),np.uint8)
            #frame = cv2.dilate(frame, dilation_kernel, iterations=dilation_iterations)
            
            contours,hierarchy = cv2.findContours(frame, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
            tgt = []
            for c in contours:
                carea = cv2.contourArea(c)
                crect_x, crect_y, crect_w, crect_h = cv2.boundingRect(c)
                crect_area = crect_w*crect_w
                
                p = 100*crect_area/self.farea
                #print(f"p:{p} %")
                if (p >= self.min_area_p) and (p <= self.max_area_p):
                    center_x = crect_x + crect_w//2
                    center_y = crect_y + crect_h//2
                    tgt.append( {'contour':c, '%':p, 'center': [center_x, center_y], 'bbox': [crect_x, crect_y, crect_w, crect_h]} )

            results.append( tgt )
            
        return results
        
    def draw_contours(self, lft_frame, rgt_frame, contours_info, draw_center=True, draw_contours=True, draw_bbox=True):
        frames = []
        r = 5
        colors = [
            (  0, 0,   0),
            (128, 0,   0),
            (255, 0,   0),
            (  0, 0, 128),
            (128, 0, 128),
            (255, 0, 128),
            (  0, 0, 255),
            (128, 0, 255),
            (255, 0, 255),
            (  0, 0, 128),
            (128, 0, 128),
            (255, 0, 128),
            (  0, 0, 255),
            (128, 0, 255),
            (255, 0, 255),
        ]
        for inx, data in enumerate(zip([lft_frame, rgt_frame], contours_info)):
            frame, fc_info = data
            for jnx, c_info in enumerate(fc_info):
                color = colors[(inx+jnx)%len(colors)]
                
                if draw_contours:
                    cv2.drawContours(frame, [c_info['contour']], 0 , color, 4)
                    
                if draw_bbox:
                    crect_x, crect_y, crect_w, crect_h = c_info['bbox']
                    cv2.rectangle(frame, (crect_x, crect_y), (crect_x+crect_w, crect_y+crect_h), color, 3)
                    
                if draw_center:
                    x, y = c_info['center']
                    if (x+r) < self.single_frame_dims[0] and (y+r) < self.single_frame_dims[1]:
                        #color = frame[x, y]
                        cv2.circle(frame,(x,y), r, color, -1)
                        
            frames.append(frame)
        
        return frames
            #for size,x,y,bx,by,bw,bh,c in targets:
            #    cv2.drawContours(frame,[c],0,self.contour_color,self.contour_line)
            #    cv2.circle(frame,(x,y),self.contour_point,self.contour_color,self.contour_pline)

        
        
# -----------------------------------------------------------------------------
