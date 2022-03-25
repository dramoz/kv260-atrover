# KRIA KV260-ATROVER (mini)

## Introduction

Being the optimistic person I am, I wanted to do a full autonomous acreage lawn mower - and that was my [application for free hardware](https://www.hackster.io/contests/xilinxadaptivecomputing2021/hardware_applications/13951). Now, being more realistic, and after experiencing some drawbacks typical of such an endeavor + COVID-19 issues which sadly touch my family at the beginning of this year, here I am happy to present you the KRIA KV260-ATROVER (AuTonomous ROVER) mini version - the first prototype of an autonomous self driving mini-rover based on Xilinx KRIAM SOM (Zynq Ultrascale+)

I work as a RTL Verification Engineer, and has been involved with embedded systems and FPGAs since 1998. I learn about the existence of the Zynq devices since the beginning, but never got the time or the opportunity to work with them. Finally last year I decided to sit down and update my skills. My objectives when joining the challenge were:

- Learn about the Xilinx Zynq Ultrascale+ devices
- Go into AI (Artificial Intelligence)

### KV260-ATROVER (mini)

The KV260-ATROVER (mini) has the following features

- Stereo Vision

Why CNN, because of the calibration process:

https://youtu.be/sW4CVI51jDY

## Tools

Xilinx Tools v2021.1

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

## DC Motors

https://electronics.stackexchange.com/questions/242293/is-there-an-ideal-pwm-frequency-for-dc-brush-motors/

[MG37-550 DC motor](https://www.aliexpress.com/item/4000808942638.html?pdp_ext_f=%7B%22sku_id%22:%2210000008104483462%22,%22ship_from%22:%22%22%7D&gps-id=pcStoreJustForYou&scm=1007.23125.137358.0&scm_id=1007.23125.137358.0&scm-url=1007.23125.137358.0&pvid=49f50fc1-c29b-4a45-91ae-5cb7468be7b7&spm=a2g0o.store_pc_home.smartJustForYou_718209649.0)

| <img src="https://ae01.alicdn.com/kf/H3e242e43a0a44acfabd93f7a09ffe272c.jpg" alt="img" style="zoom:50%;" /> |
| :----------------------------------------------------------: |



# Software/Firmware

The journey through the KRIA KV-260 and Xilinx Development Tools was extensive and extenuating. Although I have learned a lot, at the end, with the timeline nearer everyday, I have to make a choice and start doing some real deployment. Fortunately, [PYNQ for the KV260](https://github.com/Xilinx/Kria-PYNQ) was made available [two months ago](https://community.element14.com/technologies/fpga-group/f/forum/50595/pynq-now-available-for-the-kria-kv260-vision-ai-starter-kit). In retrospective, I should have jumped right away into the PYNQ framework for this challenge, but after testing it and reading some comments in the forum, I decided to give put it on the side. At the end, I came back to it as:

- It is easier to deploy and test any AI
- Works right away, no issues, fewer steps and if you miss any (you probably will not), it is easier to recover.
- This should have been the start point when jumping into something as new as the KRIA KV-260.
  - The KRIA flow is slightly different from other ZYNQ Ultrascale boards like the Ultra96-V2 or Z102
  - There is plenty information about the KRIA, Xilinx Tools, Vitis, Vitis-AI, etc. But the information is hard to grasp, and it feels unorganized. The tutorials lack continuity, e.g. they required different tool versions, different boards, etc.
  - There is no clear line to follow, actually there are several paths to follow - which get confusing and when you finished something, only at the end you realize that it was not the right tool version - and there is no additional information on how to migrate.

## [PYNQ](https://github.com/Xilinx/Kria-PYNQ) to the rescue

> [Kria SOMs x Ubuntu x PYNQ](https://pages.xilinx.com/EN-WB-2022-03-22-KriaPYNQUbuntu_LP-Registration.html): nice introductory webinar

The PYNQ framework on the KRIA KV-260 is pretty simple to use.

- It runs on Ubuntu 20.04.04 LTS
  - Easier to install new drivers or tools for development
- Faster to test and deploy new ideas
  - Python + Jupyter-lab
  - DPU ready overlay
- Easy to install and error prune

### PYNQ install

> At the moment, PYNQ - KRIA installation is broken [Unable to install PYNQ #9](https://github.com/Xilinx/Kria-PYNQ/issues/9)
> **It is possible to get PYNQ with Xilinx Dev. working by skipping the initial** `sudo apt update; sudo apt upgrade`
> *Currently Canonical and PYNQ are working on a new release that will address this issue.*

To install, just follow the instructions on the official GitHub repository https://github.com/Xilinx/Kria-PYNQ, which can be summarized as:

- Download the [Ubuntu Desktop 20.04.4 LTS for Xilinx Kria KV260](https://ubuntu.com/download/xilinx) ([direct download link](https://people.canonical.com/~platform/images/xilinx/kria/iot-kria-classic-desktop-2004-x03-20211110-98.img.xz))

- Burn the image on an SD card

  - Load the SC card and power up the board

- Logging (GUI or Terminal, GUI experience is nicer)

  - **username**: ubuntu

  - **password**: ubuntu (OS will prompt to set a new password)

    after the first password input, key the current password again - **ubuntu** and enter a new password (twice)

  - Skip Ubuntu/GNOME settings (I did not see a need to do a full Ubuntu configuration at the moment)
  - Optional Settings (GUI: right click)
    - Appearance: move and resize the toolbar
    - Power.Blank_Screen: Never

- On a terminal window

  > Skip this step until [Unable to install PYNQ #9](https://github.com/Xilinx/Kria-PYNQ/issues/9) is closed!!!

  ```bash
  sudo apt update -y; sudo apt upgrade -y; sudo apt autoremove -y;
  sudo reboot
  ```

> Note: As soon as you power up the KRIA KV260, after login - the OS will start an update status query, which will lock some process causing the next steps to lock for a couple of minutes.
>
> Some info related to this issue can be read here https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/2037317633/Getting+Started+with+Certified+Ubuntu+20.04+LTS+for+Xilinx+Devices

| <img src="https://www.xilinx.com/content/dam/xilinx/imgs/products/som/som-connections-600x600.gif" alt="SOM Kria KV260 connection animation" style="zoom:90%;" /> |
| :----------------------------------------------------------: |

> The IAS camera module is not required!!!

- Setup Xilinx Development Environment

  ```bash
  # if GUI, open a new terminal session (right click)
  cd ~
  sudo snap install xlnx-config --classic
  xlnx-config.sysinit
  ```

- Install PYNQ

  ```bash
  git clone https://github.com/Xilinx/Kria-PYNQ.git
  cd Kria-PYNQ/
  sudo bash install.sh
  ```

  > `sudo apt update -y; sudo apt upgrade -y; sudo apt autoremove -y; sudo reboot`
  >
  > Issue #9

- Testing PYNQ

```bash
# Open in your local desktop webbrowser:
kria:9090/lab
-> run some examples
# -> The kria as an address should work if you have bonyour, otherwise you can try with the 
```

##  Selecting the model

Xilinx provides with the Vitis-AI a set of pre-trained NN models that can be used as a starting point. The models are deployed on the FPGA on the DPU IP. As the DPU comes in different flavors, please note that if the model is not available for the current DPU model, extra steps are required with Vitis-AI framework to deploy the solution properly.

- The KRIA KV260 examples run on Petalinux and use a [DPU B3136](https://xilinx.github.io/kria-apps-docs/2020.2/build/html/docs/smartcamera/docs/hw_arch_accel.html), with Xilinx tools 2021.1
- The PYNQ has an overlay [DPU-PYNQ](https://github.com/Xilinx/DPU-PYNQ) with a [DPU B4096](https://github.com/Xilinx/DPU-PYNQ/blob/master/boards/KV260/dpu_conf.vh), and uses Vitis-AI 1.4.0

https://github.com/Xilinx/Vitis-AI/tree/master/models/AI-Model-Zoo

Why a pre-trained model? Speed up development. The Vitis-AI version was selected as [Vitis-AI 1.4.0](https://github.com/Xilinx/Kria-PYNQ) as it is the one currently available in PYNQ for Kria.

The available [Xilinx Vitis AI-Model-Zoo](https://github.com/Xilinx/Vitis-AI/tree/1.4.1/models/AI-Model-Zoo) pre trained models are grouped as:

- Training framework: [comparison](https://wiki.pathmind.com/comparison-frameworks-dl4j-tensorflow-pytorch)
  - Caffe, Tensorflow/Tensorflow2, Darknet, PyTorch
    - Darknet: not too many information, it is a very small open source effort
    - Caffe, Tensorflow, Pytorch
      - Python, C/C++
      - Caffe tends to outperform Tensorflow and Pytorch (https://github.com/Xilinx/Vitis-AI/tree/master/models/AI-Model-Zoo#performance-on-kria-kv260-som)

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