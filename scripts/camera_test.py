import numpy as np
import pandas as pd
import cv2
import random as rnd
from pprint import pprint

def drawText(frame, txt, location, color = (128,128,128)):
    cv2.putText(frame, txt, location, cv2.FONT_HERSHEY_PLAIN, 1, color, 1, cv2.LINE_4)
    
def print_webcam_resolutions(cam):
    #https://www.learnpythonwithrune.org/find-all-possible-webcam-resolutions-with-opencv-in-python/
    url = "https://en.wikipedia.org/wiki/List_of_common_resolutions"
    table = pd.read_html(url)[0]
    table.columns = table.columns.droplevel()
    resolutions = {}
    
    for index, row in table[["W", "H"]].iterrows():
        cam.set(cv2.CAP_PROP_FRAME_WIDTH, row["W"])
        cam.set(cv2.CAP_PROP_FRAME_HEIGHT, row["H"])
        width = cam.get(cv2.CAP_PROP_FRAME_WIDTH)
        height = cam.get(cv2.CAP_PROP_FRAME_HEIGHT)
        resolutions[str(width)+" x "+str(height)] = "OK"
    
    print(f"Webcam resolutions (WxH)): {resolutions}")

def get_fps(cam, num_frames=100):
    tick_cnt_start = cv2.getTickCount()
    for _ in range(0, num_frames):
        ret, frame = cam.read()
        
    elapsed = (cv2.getTickCount() - tick_cnt_start) / cv2.getTickFrequency()
    return num_frames/elapsed

def get_cam_params(cam):
    cam_params = {
        "width": cam.get(cv2.CAP_PROP_FRAME_WIDTH),
        "height": cam.get(cv2.CAP_PROP_FRAME_HEIGHT),
        "fps": cam.get(cv2.CAP_PROP_FPS),
        "bright": cam.get(cv2.CAP_PROP_BRIGHTNESS),
        "contr": cam.get(cv2.CAP_PROP_CONTRAST ),
        "sat": cam.get(cv2.CAP_PROP_SATURATION ),
        "hue": cam.get(cv2.CAP_PROP_HUE),
        "gain": cam.get(cv2.CAP_PROP_GAIN),
        "exposure ": cam.get(cv2.CAP_PROP_EXPOSURE ),
        "ch": cam.get(cv2.CAP_PROP_CHANNEL),
        "auto-wb": cam.get(cv2.CAP_PROP_AUTO_WB ),
        "wb-temp": cam.get(cv2.CAP_PROP_WB_TEMPERATURE ),
        "bitrate": cam.get(cv2.CAP_PROP_BITRATE),
    }
    return {nm:vl for nm, vl in cam_params.items() if vl>=0}
    
cam = cv2.VideoCapture(0)
if not cam.isOpened():
    print("Cannot open camera")
    exit()
    
# Setup camera
#pprint(get_cam_params(cam))
#print(f"Measured fps: {get_fps(cam)}")

# Select resolution
#print_webcam_resolutions(cam)

#cam.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
#cam.set(cv2.CAP_PROP_FRAME_HEIGHT, 240)
cam.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
frame_width = 1280
cam.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
frame_heigth = 480
#cam.set(cv2.CAP_PROP_FRAME_WIDTH, 2560)
#cam.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)
#pprint(get_cam_params(cam))
#fps = get_fps(cam)
#print(f"Measured fps: {fps}")
fps = cam.get(cv2.CAP_PROP_FPS)

num_frames = 0
avg_frames = 10
tick_cnt_start = cv2.getTickCount()
while True:
    # Capture frame-by-frame
    ret, frame = cam.read()
    #frame, rgt_frame = frame[:, :frame_width//2], frame[:, frame_width//2:]
    
    img_out = frame.copy()
    num_frames += 1
    
    # if frame is read correctly ret is True
    if not ret:
        print("Can't receive frame (stream end?). Exiting ...")
        break
    
    # Show original
    cv2.imshow('original', frame)
    proc_txt = []
    
    # flip
    #flipped = cv2.flip(frame, 0)
    
    # gray -> blur -> canny
    frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    #proc_txt.append("COLOR_BGR2GRAY")
    frame = cv2.GaussianBlur(frame, (5, 5), 0)
    #proc_txt.append("GaussianBlur(5x5)")
    frame = cv2.Canny(frame, 30, 150)
    #proc_txt.append("Canny(30->150)")
    
    # dilation
    dilation_value = 3
    dilation_iterations = 2
    dilation_kernel = np.ones((dilation_value,dilation_value),np.uint8)
    #frame = cv2.dilate(frame, dilation_kernel, iterations=dilation_iterations)
    
    # show transformations
    cv2.imshow('filtered', frame)
    
    # Countours
    contours, hierarchy = cv2.findContours(frame, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    proc_txt.append(f"contours#: {len(contours)}")
    
    # Generate output
    cv2.drawContours(img_out, contours, -1, (250,250,250), 1)
    #for i in range(len(contours)):
    #    color = (rnd.randint(0,256), rnd.randint(0,256), rnd.randint(0,256))
    #    cv2.drawContours(img_out, contours, i, color, 2, cv2.LINE_8, hierarchy, 0)
    
    # Draw info
    drawText(img_out, f"[{('| ').join(proc_txt)}]", (20,20))
    
    # Calculate Frames per second (FPS)
    if num_frames == avg_frames:
        elapsed = (cv2.getTickCount() - tick_cnt_start) / cv2.getTickFrequency()
        fps = num_frames/elapsed
        
        tick_cnt_start = cv2.getTickCount()
        num_frames = 0
    
    drawText(img_out, f"FPS: {fps:.2f}", (20,50))
    
    # Draw final
    cv2.imshow("Countours", img_out)
    
    if cv2.waitKey(1) == ord('q'):
        break
    
# When everything done, release the capture
cam.release()
cv2.destroyAllWindows()
