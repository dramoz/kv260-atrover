# KRIA KV260-ATROVER (mini)

## Introduction

Being the optimistic person I am, I wanted to do a full autonomous acreage lawn mower - and that was my [application for free hardware](https://www.hackster.io/contests/xilinxadaptivecomputing2021/hardware_applications/13951). Now, being more realistic, and after experiencing some drawbacks typical of such an endeavor + COVID-19 issues which sadly touch my family at the beginning of this year, here I am happy to present you the KRIA KV260-ATROVER (AuTonomous ROVER) mini version - the first prototype of an autonomous self driving mini-rover based on Xilinx KRIAM SOM (Zynq Ultrascale+)

I work as a RTL Verification Engineer, and has been involved with embedded systems and FPGAs since 1998. I learn about the existence of the Zynq devices since the beginning, but never got the time or the opportunity to work with them. Finally last year I decided to sit down and update my skills. My objectives when joining the challenge were:

- Learn about the Xilinx Zynq Ultrascale+ devices
- Go into AI (Artificial Intelligence)

### KV260-ATROVER (mini)

The KV260-ATROVER (mini) has the following features

- Stereo Vision

## Tools

Xilinx Tools v2021.2

## Creating the Platform

https://github.com/Xilinx/Vitis-Tutorials/tree/2021.2/Vitis_Platform_Creation/Design_Tutorials/01-Edge-KV260



# Hardware

## Stereo Camera

For this project I am using the [HBVCAM-1780-2](https://www.hbvcamera.com/dual-lens-usb-cameras/1mp-720p-hd-binocular-camera-module.html) binocular camera. This camera was selected as it already outputs a dual image in a single USB port (stream).

The camera was tested with https://webcamtests.com/ to validate the manufacturer parameters:

- Max. resolution: 1.84 MP, 30 FPS at 2560×720 (dual image, 2x 1280x720)
- Angle of view: 72 degrees (3.6mm lenses)
- Distance between lenses: 60mm
- Object distance: 30cm ~ $\infty$ (fixed focus - manual adjustable)
- Dual Image Resolution: `640*240 (30fps), 1280*480 (30fps), 2560*720 (25fps)` (validated)
  - single camera: `320*240 (30fps), 640*480(30fps), 1280*720 (30fps)`

- Connection: micro USB2.0
- 2x[OV9732](https://www.ovt.com/products/ov09732-h35a/) Sensors
  - Optical format: 1/4"
  - Array size: 1280*720

There is also a Python script `camera_test.py` with the following results:

| Platform           | Resolution                          | Measured fps |
| ------------------ | ----------------------------------- | ------------ |
| Ubuntu 20.04 (i7)  | 640x240<br />1280x480<br />2560x720 | ~25pfs       |
| KRIA KV-260 (PynQ) |                                     |              |

### Camera Calibration

https://github.com/opencv/opencv/blob/4.x/doc/pattern.png

- https://youtu.be/yKypaVl6qQo
- https://temugeb.github.io/opencv/python/2021/02/02/stereo-camera-calibration-and-triangulation.html
- https://docs.opencv.org/3.4/dc/dbb/tutorial_py_calibration.html

## Reference

### Tutorials

| Title                            | Remarks | URL                                                      |
| -------------------------------- | ------- | -------------------------------------------------------- |
| Stereo Vision Camera Calibration |         | https://youtu.be/yKypaVl6qQo                             |
| Camera Calibration using OpenCV  |         | https://learnopencv.com/camera-calibration-using-opencv/ |
|                                  |         |                                                          |
|                                  |         |                                                          |

### Blogs

| Title        | Remarks                 | URL                                              |
| ------------ | ----------------------- | ------------------------------------------------ |
| Learn OpenCV | Stereo Vision Tutorials | https://learnopencv.com/author/kaustubh-sadekar/ |
|              |                         |                                                  |
|              |                         |                                                  |