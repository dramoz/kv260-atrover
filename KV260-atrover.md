# KRIA KV260-ATROVER (mini)

*Disclaimer:* The following project was done for the [Adaptive Computing Challenge 2021](https://www.hackster.io/contests/xilinxadaptivecomputing2021). Most of the code and 3D models are under [The MIT License | Open Source Initiative](https://opensource.org/licenses/MIT) or  [Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)](https://creativecommons.org/licenses/by-sa/4.0/) unless specified to the contrary. A copy of this document and the corresponding project files are located at [KV260-ATRover GitHub repository](https://github.com/dramoz/kv260-atrover). As part of the application process I received a [free Kria KV260 AI Starter Kit + Basic Accessory Pack](https://www.hackster.io/contests/xilinxadaptivecomputing2021/hardware_applications#challengeNav).

⚠ This project uses high DC amperage which can be ☠ -  please use extremely caution.

## Introduction

Being the optimistic person I am, I wanted to do a full autonomous acreage lawn mower - and that was my [application for free hardware](https://www.hackster.io/contests/xilinxadaptivecomputing2021/hardware_applications/13951). Now, being more realistic, and after experiencing some drawbacks typical of such an endeavor + COVID-19 issues which sadly touch my family at the beginning of this year, here I am happy to present you the KRIA KV260-ATROVER (AuTonomous ROVER) mini version - the first prototype of an autonomous self driving mini-rover based on the [Kria KV260 Vision AI Starter Kit](https://www.xilinx.com/products/som/kria/kv260-vision-starter-kit.html) (Zynq Ultrascale+)

My objectives when joining the challenge were:

- Learn about the Xilinx Zynq Ultrascale+ devices
- Go into AI (Artificial Intelligence) and ML (Machine Learning)

**KV260-ATROVER (mini)**

The KV260-ATROVER (mini) has the following features:

- Full 3D Printed chassis (OpenSCAD) available
- KRIA KV260 board (master)
  - AI Object Identification + Depth estimation
  - OpenCV Stereo Vision for distance estimation (reference)

- TTGO-T1 board (slave)
  - Dual DC motor control


**Motivation**

Stereo Vision, DC motor control, route planning and navigation requires a lot of calibration. In the long term, my final goal is to explore and implement a full autonomous robot with self learning capabilities, where the require effort for initial calibration is minimized.

As an example, you can watch [OpenCV Python](https://www.youtube.com/playlist?list=PLLf0llgjmNiZrt5QocH1zq7ih-GdKMgCY) videos from [Clayton Darwin](https://www.youtube.com/c/ClaytonDarwin) were he does a good explanation of the required process to do triangulation using two cameras and OpenCV. An that is just triangulation, PID motor control, route planning and context awareness by them self are quite complex, doable but limit and constrained - and this is why and where AI/ML (CNN) keeps growing in many fields.

# Hardware

## [Kria KV260 Vision AI Starter Kit](https://www.xilinx.com/products/som/kria/kv260-vision-starter-kit.html)

The hardware selected to this project is the Xilinx KRIA KV260 board, which was awarded as free hardware in this challenge. Another good candidate is the [Avnet - Ultra96-V2 Board](https://www.avnet.com/wps/portal/us/products/new-product-introductions/npi/aes-ultra96-v2/) which has similar characteristics.

## Stereo Camera

For this project the [HBVCAM-1780-2](https://www.hbvcamera.com/dual-lens-usb-cameras/1mp-720p-hd-binocular-camera-module.html) binocular camera was selected as it already outputs a dual stereo image synchronized in a single USB port (stream), and it has a decent price.

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

As the camera lenses produce some distortion on the capture images, it is necessary to perform a camera calibration as described in [Stereo Vision Camera Calibration in Python with OpenCV](https://youtu.be/yKypaVl6qQo). A modified set of Python scripts used for this project can be found at https://github.com/dramoz/kv260-atrover/tree/main/scripts/camera_calibration_data_gen. The parameters obtained are particular for the module used in this project, and it must be done on a per module basis.

## DC Motors



https://electronics.stackexchange.com/questions/242293/is-there-an-ideal-pwm-frequency-for-dc-brush-motors/

[MG37-550 DC motor](https://www.aliexpress.com/item/4000808942638.html?pdp_ext_f=%7B%22sku_id%22:%2210000008104483462%22,%22ship_from%22:%22%22%7D&gps-id=pcStoreJustForYou&scm=1007.23125.137358.0&scm_id=1007.23125.137358.0&scm-url=1007.23125.137358.0&pvid=49f50fc1-c29b-4a45-91ae-5cb7468be7b7&spm=a2g0o.store_pc_home.smartJustForYou_718209649.0)

| <img src="https://ae01.alicdn.com/kf/H3e242e43a0a44acfabd93f7a09ffe272c.jpg" alt="img" style="zoom:50%;" /> |
| :----------------------------------------------------------: |

DC Motor Driver(s)



## [LILYGO® TTGO T-Display ESP32](http://www.lilygo.cn/prod_view.aspx?TypeId=50062&Id=1400&FId=t3:50062:3)

For the DC motor control, the future plan is to use the Zynq+ Dual Core ARM  Cortex-R5 processors with FreeRTOS. The initial test was done with a TTGO T-Display (aka TTGO-T1) board. Although I was planning to use the [PMOD](https://digilent.com/reference/pmod/start) to generate the required PWM signals, but after burning two drivers and one TTGO board I decided to leave it to another day.

For this road test, I decide to use the  (aka TTGO T-Display) which can be purchased at [Aliexpress](https://www.aliexpress.com/item/33048962331.html) (Official [LILYGO store](https://lilygo.he.aliexpress.com/store/2090076?spm=a2g0o.detail.1000061.1.59f8142fz8JkSi)). The TTGO-T1 is based on the [ESP32 Espresiff](https://www.espressif.com/en/products/socs/esp32) ([Wikipedia](https://en.wikipedia.org/wiki/ESP32])), a 32bit MCU Tensilica Xtensa LX6 with integrated WiFi, Bluetooth, and a lot of peripherals.

There were some particular reasons I selected this board for the road test:

- Integrated Display + available libraries
- The SN-GCJA5 requires a dual voltage operation
  - 5V power supply
  - 3.3V TTL logic
- User buttons
- WiFi ready (which would be used for future apps)

As the TTGO-T1 works with 3.3V TTL and has a USB port that can provide 5Vdc it was a suitable candidate.

## USB WiFi dongle

## Power considerations

Drivers:https://github.com/WCHSoftGroup/ch343ser_linux

```bash
lusb
```

> Bus 002 Device 002: ID 0424:5744 Microchip Technology, Inc. (formerly SMSC) Hub
> Bus 002 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
> Bus 001 Device 004: ID 0424:2740 Microchip Technology, Inc. (formerly SMSC)
> Bus 001 Device 003: ID 15aa:1955 Gearway Electronics (Dong Guan) Co., Ltd.
> **Bus 001 Device 006: ID 1a86:55d4 QinHeng Electronics**
> Bus 001 Device 002: ID 0424:2744 Microchip Technology, Inc. (formerly SMSC) Hub
> Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub

Install driver

```bash
mkdir repos
cd repos
git clone https://github.com/WCHSoftGroup/ch343ser_linux.git
cd ch343ser_linux/driver
make ARCH=arm64

# Testing driver
sudo insmod ch343.ko
# -> un-plug / plug USB
ls /dev/tty*USB*
/dev/ttyCH343USB0
```

> **/dev/ttyCH343USB0**

```bash
screen /dev/ttyCH343USB0 115200
# press TTGO reset button
```

> rst:0x1 (POWERON_RESET),boot:0x13 (SPI_FAST_FLASH_BOOT)
> configsip: 0, SPIWP:0xee
> clk_drv:0x00,q_drv:0x00,d_drv:0x00,cs0_drv:0x00,hd_drv:0x00,wp_drv:0x00
> mode:DIO, clock div:2
> load:0x3fff0018,len:4
> load:0x3fff001c,len:1216
> ho 0 tail 12 room 4
> load:0x40078000,len:10944
> load:0x40080400,len:6360
> entry 0x400806b4
> **?TTGO**

```bash
# -> run some commands
*f064
# disconnect screen:
# -> CTRL+a, y
Really kill this window [y/n]
```

> [screen is terminating]
> ubuntu@kria:~/repos$

# Software/Firmware

The journey through the KRIA KV-260 and Xilinx Development Tools was extensive and extenuating. Although I have learned a lot, at the end, with the timeline nearer everyday, I have to make a choice and start doing some real deployment. Fortunately, [PYNQ for the KV260](https://github.com/Xilinx/Kria-PYNQ) was made available [two months ago](https://community.element14.com/technologies/fpga-group/f/forum/50595/pynq-now-available-for-the-kria-kv260-vision-ai-starter-kit). In retrospective, I should have jumped right away into the PYNQ framework for this challenge, but after testing it and reading some comments in the forum, I decided to give put it on the side. At the end, I came back to it as:

- It is easier to deploy and test any AI
- Works right away, no issues, fewer steps and if you miss any (you probably will not), it is easier to recover.
- This should have been the start point when jumping into something as new as the KRIA KV-260.
  - The KRIA flow is slightly different from other ZYNQ Ultrascale boards like the Ultra96-V2 or Z102
  - There is plenty information about the KRIA, Xilinx Tools, Vitis, Vitis-AI, etc. But the information is hard to grasp, and it feels unorganized. The tutorials lack continuity, e.g. they required different tool versions, different boards, etc.
  - There is no clear line to follow, actually there are several paths to follow - which get confusing and when you finished something, only at the end you realize that it was not the right tool version - and there is no additional information on how to migrate (or probably I did not find it).

## [PYNQ](https://github.com/Xilinx/Kria-PYNQ) to the rescue

> [Kria SOMs x Ubuntu x PYNQ](https://pages.xilinx.com/EN-WB-2022-03-22-KriaPYNQUbuntu_LP-Registration.html): nice introductory webinar

The PYNQ framework on the KRIA KV-260 is pretty simple to use.

- It runs on Ubuntu 20.04.04 LTS
  - Easier to install new drivers or tools for development
- Faster to test and deploy new ideas
  - Python + Jupyter-lab
  - DPU ready overlay (B4096)
- Easy to install and error prune
- Remote access with remote graphics applications (`ssh -X` )

But there are some "*drawbacks*":

- Cannot load multiple overlays
  - e.g. if you need the DPU but at the same time some video pre-processing you are out of luck, but of course you can develop your own overlays
- Performance: in theory, as you are running over Python you will suffer from latency and throughput. 
  - I have not test it, but I will do in the future. Nevertheless, for R&D and testing it is good enough.

### PYNQ install

> At the moment, PYNQ - KRIA installation is *"broken"* [Unable to install PYNQ #9](https://github.com/Xilinx/Kria-PYNQ/issues/9)
> **It is possible to get PYNQ with Xilinx Dev. working by skipping the initial:**
>
>    `sudo apt update; sudo apt upgrade`
>
> and do it only at the end!
>
> *Currently Canonical and PYNQ are working on a new release that will address this issue.*

To install, just follow the instructions on the official GitHub repository https://github.com/Xilinx/Kria-PYNQ, which can be summarized as:

- Download the [Ubuntu Desktop 20.04.4 LTS for Xilinx Kria KV260](https://ubuntu.com/download/xilinx) ([direct download link](https://people.canonical.com/~platform/images/xilinx/kria/iot-kria-classic-desktop-2004-x03-20211110-98.img.xz))

- Burn the image on an SD card

  - Load the SC card and power up the board

- Logging (GUI or Terminal, GUI experience is recommended)

  - **username**: ubuntu

  - **password**: ubuntu (OS will prompt to set a new password)

    after the first password input, key the current password again - **ubuntu** and enter a new password (twice)

  - Skip Ubuntu/GNOME settings (I did not see a need to do a full Ubuntu configuration at the moment)
  - Optional Settings (GUI: right click)
    - Appearance: move and resize the toolbar
    - Power.Blank_Screen: Never

> After initial configuration and having a valid IP, I prefer to do most of the configuration using ssh
>
> `ssh ubuntu@xxx.xxx.xxx.xxx`

- On a terminal window

  ```bash
  # Setup git credentials
  git config --global user.email "yout@email"
  git config --global user.name "Your Name"
  ```

  > **Skip next step until new Ubuntu/PYNQ release**

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
  # -> [Y] when asked
  ```

- Install PYNQ

  ```bash
  git clone https://github.com/Xilinx/Kria-PYNQ.git
  cd Kria-PYNQ/
  sudo bash install.sh
  ```

- Testing PYNQ

```bash
# Open in your local desktop webbrowser:
kria:9090/lab
# !try some examples
# if the kria:9090/lab is not working, try the IP directly
# To get the IP type the `ip a` command and look for eth0:...
ip a
```

> 3: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
>     link/ether 00:0a:35:00:22:01 brd ff:ff:ff:ff:ff:ff
>     inet **192.168.0.134**/24 brd 192.168.0.255 scope global dynamic noprefixroute eth0
>        valid_lft 7191sec preferred_lft 7191sec
>     inet6 fe80::1fe:9c9e:1eaf:a932/64 scope link noprefixroute 
>        valid_lft forever preferred_lft forever

### Additional Drivers & Ubuntu configuration

**Ubuntu packages**

```bash
sudo apt install -y dkms net-tools build-essential
```

**USB WiFi**

```bash
mkdir repos; cd repos
git clone https://github.com/morrownr/88x2bu-20210702
cd 88x2bu-20210702
sudo ARCH=arm64 ./install-driver.sh
```

> Do you want to edit the driver options file now? [y/N] **n**
> Do you want to reboot now? (recommended) [y/N] **n**

```bash
# TTGO-T1 UART/USB drivers
cd ~/repos
git clone https://github.com/WCHSoftGroup/ch343ser_linux.git
cd ch343ser_linux/driver
make ARCH=arm64
sudo make install
sudo reboot
```

**WiFi configuration**

The easiest way to configure the WiFi is through GNOME. After login, click on the down icon near the power button ⏻▼ and select your network. This connection will be preserved after shutdown without the need of login.

Alternatively you can set it on the command line. Currently I do not know how to make a connection permanently (aka WiFi connection without login), so the GUI method is recommended.

**Final steps**

```bash
sudo apt update -y; sudo apt upgrade -y; sudo apt autoremove -y; sudo reboot
```

*Optional packages*

```bash
sudo apt install -y graphviz gtkwave tree meld
```

*Optional Python Virtualenv Wrapper*

> ⚠ PYNQ has its own `virtualenv` setup, I did not test creating a new one and I do not know if there would be any side effect on doing so

```bash
cd ~
pip3 install virtualenv virtualenvwrapper
```

With your favorite editor append the following lines to `.bashrc`

> \# virtualenv and virtualenvwrapper
> export WORKON_HOME=\${HOME}/.virtualenvs
> export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
> export VIRTUALENVWRAPPER_VIRTUALENV=\$HOME/.local/bin/virtualenv
> source \$HOME/.local/bin/virtualenvwrapper.sh

💡In the [KV260-ATRover GitHub repository](https://github.com/dramoz/kv260-atrover) I have provide a set of `.bash` configuration scripts that include some extra setup for Ubuntu command line terminals including the above `virtualenv and virtualwrapper` setup. 

They will transform the command line prompt from

![image-20220326223900003](D:\Virtualbox\shared\dev\kv260-atrover\docs_support\old_bash_prompt.png)

to

![image-20220326224050424](D:\Virtualbox\shared\dev\kv260-atrover\docs_support\new_bash_prompt.png)

You can install them next after cloning the project repository,

## Project files

```bash
cd ~
mkdir dev
cd dev
git clone https://github.com/dramoz/kv260-atrover
```

NOTE: you can use [Visual Code remotely with SSH](https://code.visualstudio.com/docs/remote/ssh).

> Click ≶ icon on the bottom left corner and create a new connection.

Finally, create a symbolic link to the repository so it is accessible from jupyter-lab

```bash
cd $PYNQ_JUPYTER_NOTEBOOKS
ln -s $HOME/dev/kv260-atrover/ kv260-atrover
```

```bash
# Copy new .bashrc configuration (optional)
cp -fv ~/dev/kv260-atrover/scripts/.bash* ~/
source ~/.bashrc
```



## TTGO-T1 firmware

Programming TTGO

# Selecting the model

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

# Conclusion and Future work



**Multitask CNN**



**ROS2**



**Pending immediate tasks**

Given the time limit I have, some guides are missing from this project as there are less relevant at the moment:

- Chassis 3D print: the 3D models are available as OpenSCAD files, but they were fine tune to my printer. A how-to print and assemble guide will be provided later.
- TTGO-T1 UART drivers installation on the KRIA KV-260 Ubuntu desktop OS
- DC motor characterization: the current scripts do not have any proper motor control (e.g. PID) and there is no proper motor parameters characterization.

## References & Links

| Title                           | Remarks                 | URL                                     |
| ------------------------------- | ----------------------- | --------------------------------------- |
| KV260-ATRover GitHub repository | This project repository | https://github.com/dramoz/kv260-atrover |

### Tutorials

| Title                            | Remarks | URL                                                      |
| -------------------------------- | ------- | -------------------------------------------------------- |
| Stereo Vision Camera Calibration |         | https://youtu.be/yKypaVl6qQo                             |
| Camera Calibration using OpenCV  |         | https://learnopencv.com/camera-calibration-using-opencv/ |

### Blogs

| Title        | Remarks                 | URL                                              |
| ------------ | ----------------------- | ------------------------------------------------ |
| Learn OpenCV | Stereo Vision Tutorials | https://learnopencv.com/author/kaustubh-sadekar/ |