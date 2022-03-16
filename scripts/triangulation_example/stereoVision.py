import sys
import cv2
import numpy as np
import time
import imutils
from matplotlib import pyplot as plt

# Function for stereo vision and depth estimation
import triangulation as tri
import calibration

# Mediapipe for face detection
import mediapipe as mp
import time

mp_facedetector = mp.solutions.face_detection
mp_draw = mp.solutions.drawing_utils

# Open both cameras
cam = cv2.VideoCapture(0)
if not cam.isOpened():
    print("Cannot open camera")
    exit()

cam.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
frame_width = 1280
cam.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
frame_heigth = 480

# Stereo vision setup parameters
frame_rate = 30   #Camera frame rate
B = 6             #Distance between the cameras [cm]
f = 3.6           #Camera lense's focal length [mm]
alpha = 70        #Camera field of view in the horisontal plane [degrees]

# Main program loop with face detector and depth estimation using stereo vision
with mp_facedetector.FaceDetection(min_detection_confidence=0.7) as face_detection:

    while(cam.isOpened()):
        ret, frame = cam.read()
        lft_frame, rgt_frame = frame[:, :frame_width//2], frame[:, frame_width//2:]
        # if frame is read correctly ret is True
        if not ret:
            print("Can't receive frame (stream end?). Exiting ...")
            break
        
        # Remap
        rgt_frame, lft_frame = calibration.undistortRectify(rgt_frame, lft_frame)
        
        start = time.time()
        
        # Convert the BGR image to RGB
        rgt_frame = cv2.cvtColor(rgt_frame, cv2.COLOR_BGR2RGB)
        lft_frame = cv2.cvtColor(lft_frame, cv2.COLOR_BGR2RGB)

        # Process the image and find faces
        results_right = face_detection.process(rgt_frame)
        results_left = face_detection.process(lft_frame)

        # Convert the RGB image to BGR
        rgt_frame = cv2.cvtColor(rgt_frame, cv2.COLOR_RGB2BGR)
        lft_frame = cv2.cvtColor(lft_frame, cv2.COLOR_RGB2BGR)
        
        # Depth Calc.
        center_right = 0
        center_left = 0
        
        if results_right.detections:
            for id, detection in enumerate(results_right.detections):
                mp_draw.draw_detection(rgt_frame, detection)

                bBox = detection.location_data.relative_bounding_box

                h, w, c = rgt_frame.shape

                boundBox = int(bBox.xmin * w), int(bBox.ymin * h), int(bBox.width * w), int(bBox.height * h)

                center_point_right = (boundBox[0] + boundBox[2] / 2, boundBox[1] + boundBox[3] / 2)

                cv2.putText(rgt_frame, f'{int(detection.score[0]*100)}%', (boundBox[0], boundBox[1] - 20), cv2.FONT_HERSHEY_SIMPLEX, 2, (0,255,0), 2)


        if results_left.detections:
            for id, detection in enumerate(results_left.detections):
                mp_draw.draw_detection(lft_frame, detection)

                bBox = detection.location_data.relative_bounding_box

                h, w, c = lft_frame.shape

                boundBox = int(bBox.xmin * w), int(bBox.ymin * h), int(bBox.width * w), int(bBox.height * h)

                center_point_left = (boundBox[0] + boundBox[2] / 2, boundBox[1] + boundBox[3] / 2)

                cv2.putText(lft_frame, f'{int(detection.score[0]*100)}%', (boundBox[0], boundBox[1] - 20), cv2.FONT_HERSHEY_SIMPLEX, 2, (0,255,0), 2)




        # If no ball can be caught in one camera show text "TRACKING LOST"
        if not results_right.detections or not results_left.detections:
            cv2.putText(rgt_frame, "TRACKING LOST", (75,50), cv2.FONT_HERSHEY_SIMPLEX, 1, (0,0,255),2)
            cv2.putText(lft_frame, "TRACKING LOST", (75,50), cv2.FONT_HERSHEY_SIMPLEX, 1, (0,0,255),2)

        else:
            # Function to calculate depth of object. Outputs vector of all depths in case of several balls.
            # All formulas used to find depth is in video presentaion
            depth = tri.find_depth(center_point_right, center_point_left, rgt_frame, lft_frame, B, f, alpha)

            cv2.putText(rgt_frame, "Distance: " + str(round(depth,1)), (50,50), cv2.FONT_HERSHEY_SIMPLEX, 1.2, (0,255,0),3)
            cv2.putText(lft_frame, "Distance: " + str(round(depth,1)), (50,50), cv2.FONT_HERSHEY_SIMPLEX, 1.2, (0,255,0),3)
            # Multiply computer value with 205.8 to get real-life depth in [cm]. The factor was found manually.
            print("Depth: ", str(round(depth,1)))



        end = time.time()
        totalTime = end - start

        fps = 1 / totalTime
        #print("FPS: ", fps)

        cv2.putText(rgt_frame, f'FPS: {int(fps)}', (20,450), cv2.FONT_HERSHEY_SIMPLEX, 1.2, (0,255,0), 2)
        cv2.putText(lft_frame, f'FPS: {int(fps)}', (20,450), cv2.FONT_HERSHEY_SIMPLEX, 1.2, (0,255,0), 2)                                   


        # Show the frames
        cv2.imshow("frame right", rgt_frame) 
        cv2.imshow("frame left", lft_frame)


        # Hit "q" to close the window
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break


# Release and destroy all windows before termination
cam.release()
cv2.destroyAllWindows()
