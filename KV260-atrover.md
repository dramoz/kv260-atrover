# Kria KV260-ATROVER (mini)

***A journey through machine learning and Xilinx Kria KV260 Vision AI Starter Kit***

<img src="https://github.com/dramoz/kv260-atrover/blob/main/docs_support/kv260_atrover_0001.jpg?raw=true" alt="kv260_atrover_0001.jpg" style="zoom:10%;" />

*Disclaimer:* The following project was done for the [Adaptive Computing Challenge 2021](https://www.hackster.io/contests/xilinxadaptivecomputing2021). Most of the code and 3D models are under [The MIT License | Open Source Initiative](https://opensource.org/licenses/MIT) or  [Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)](https://creativecommons.org/licenses/by-sa/4.0/) unless specified to the contrary. A copy of this document and the corresponding project files are located at [KV260-ATRover GitHub repository](https://github.com/dramoz/kv260-atrover). As part of the application process I received a [free Kria KV260 AI Starter Kit + Basic Accessory Pack](https://www.hackster.io/contests/xilinxadaptivecomputing2021/hardware_applications#challengeNav).

⚠ This project uses high DC amperage which can be ☠ -  please use extremely caution.

⚠ All links and references are set to match the tools version used in this project, which most of the time are not the latest. Readers are welcome to go further, as new releases came with significant improvements.

## Introduction

The idea of having a self driving vehicle platform has been going around my head for a long time now. First, it started with my personal experience with some robot-vacuums which became a relation of love and not-that-much hate. With the pass of the years, I have enjoyed the benefits of keeping my floors clean (I suffer a lot from dust allergies), but with the past of the years I keep seeing the same problems - which became worst when your family grows and your kids behave like kids.

| <img src="https://github.com/dramoz/kv260-atrover/blob/main/docs_support/kv260_atrover_0006.jpg?raw=true" alt="kv260_atrover_0006.jpg" style="zoom:20%;" /> | <img src="https://github.com/dramoz/kv260-atrover/blob/main/docs_support/kv260_atrover_0007.jpg?raw=true" alt="kv260_atrover_0007.jpg" style="zoom:20%;" /> | <img src="https://github.com/dramoz/kv260-atrover/blob/main/docs_support/kv260_atrover_0012.jpg?raw=true" alt="kv260_atrover_0012.jpg" style="zoom:20%;" /> |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |

And then the we moved to a rural house outside Ottawa, and cutting the grass although relaxing, is time consuming. I started working around a full autonomous acreage lawn mower which I wanted to have an FPGA (just because), when I came across the [Adaptive Computing Challenge 2021](https://www.hackster.io/contests/xilinxadaptivecomputing2021) on [HacksterIO](https://www.hackster.io/) - and that was my [application for free hardware](https://www.hackster.io/contests/xilinxadaptivecomputing2021/hardware_applications/13951). But after starting from almost zero knowledge on both Xilinx Zynq Ultrascale+ and AI/ML (Artificial Intelligence/Machine Learning) I run out of time, plus I live in Canada, so a lawnmower was out of the question during winter.

So I decided to step back, and start with a basic ATRover (AuTonomous Rover) and the KRIA KV260-ATRover  mini version was born - the first prototype of an autonomous self driving mini-rover based on the [Kria KV260 Vision AI Starter Kit](https://www.xilinx.com/products/som/kria/kv260-vision-starter-kit.html) (Zynq Ultrascale+)

My objectives when joining the challenge were:

- Learn about the Xilinx Zynq Ultrascale+ devices
- Go into AI (Artificial Intelligence) and ML (Machine Learning)

**KV260-ATROVER (mini)**

The KV260-ATROVER (mini) has the following features:

- Full 3D Printed chassis with OpenSCAD
- KRIA KV260 board (master)
  - AI Object Identification (YOLOv4)
  - OpenCV Stereo Vision for distance estimation (reference)

- TTGO-T1 board (slave)
  - Dual DC motor control


**Motivation**

Stereo Vision, DC motor control, route planning and navigation requires a lot of calibration. In the long term, my final goal is to explore and implement a full autonomous robot with self learning capabilities, where the require effort for initial calibration is minimized.

As an example, you can watch [OpenCV Python](https://www.youtube.com/playlist?list=PLLf0llgjmNiZrt5QocH1zq7ih-GdKMgCY) videos from [Clayton Darwin](https://www.youtube.com/c/ClaytonDarwin) were he does a good explanation of the required process to do triangulation using two cameras and OpenCV. An that is just triangulation, PID motor control, route planning and context awareness by them self are quite complex, doable but limit and constrained - and this is why and where AI/ML (CNN) keeps growing in many fields.

# Hardware

## [Kria KV260 Vision AI Starter Kit](https://www.xilinx.com/products/som/kria/kv260-vision-starter-kit.html)

The hardware selected to this project is the Xilinx KRIA KV260 board, which was awarded as free hardware in this challenge. Another good candidate is the [Avnet - Ultra96-V2 Board](https://www.avnet.com/wps/portal/us/products/new-product-introductions/npi/aes-ultra96-v2/) which has similar characteristics. One advantage of the KRIA Zynq (XCK26) vs the ZU3EG in the Ultra96-V2 is the [VCU (Video Codec Unit)](https://www.xilinx.com/products/intellectual-property/v-vcu.html) which make it an ideal platform for R&D video applications (livestream)

The KRIA SOM installed in the KV260 Vision AI Starter Kit is a special (non-commercial) SOM, with similar characteristics to the [Kria K26C SOM](https://www.xilinx.com/products/som/kria/k26c-commercial.html). The KV260 has only a single 240-Pin connector and is not certified.

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

The scripts are based on [niconielsen32-ComputerVision/stereoVisionCalibration](https://github.com/niconielsen32/ComputerVision/tree/master/stereoVisionCalibration) modified to use one single stereo camera stream plus some personal modifications.

## DC Motors

For the KV260-ATRover the [CHIHAI GM37-550 DC motor](https://www.aliexpress.com/item/4000808942638.html?pdp_ext_f=%7B%22sku_id%22:%2210000008104483462%22,%22ship_from%22:%22%22%7D&gps-id=pcStoreJustForYou&scm=1007.23125.137358.0&scm_id=1007.23125.137358.0&scm-url=1007.23125.137358.0&pvid=49f50fc1-c29b-4a45-91ae-5cb7468be7b7&spm=a2g0o.store_pc_home.smartJustForYou_718209649.0) with ratio 50:1 and 12Vdc with a maximum input power of 40W where selected.

> The current DC motors are too powerful for the KV260-ATRover mini. They were selected initially for the lawnmower which has a bigger heavier chassis (higher torque requirement) and larger wheels (reducing the speed of the ATRover and therefore increasing the minimum required PWM duty cycle)

| <img src="https://ae01.alicdn.com/kf/H3e242e43a0a44acfabd93f7a09ffe272c.jpg" alt="img" style="zoom:50%;" /> |
| :----------------------------------------------------------: |

**DC Motor Driver(s)**

For the motor drivers the [ZK-5AD](https://www.aliexpress.com/item/1005002100401855.html) board was selected. It has two [TA6586](https://www.micros.com.pl/mediaserver/UITA6586_0001.pdf) monolithic IC for driving bi-directional DC motors.

- Working Voltage: DC 3.0V-14V
- Input Signal Voltage: DC 2.2V-6.0V
- Drive Current: 5A
- Stand-by Current: 10uA
- Working Temperature:-20 to 85 Celsuis

| <img src="https://i0.wp.com/shores.rocks/stem-coding/wp-content/uploads/2021/03/Dual-Motor-Drive-Board-zk-5ad.jpg?fit=666%2C540&ssl=1" alt="ZK-5AD L298N5A Dual DC Motor Drive Module (1 piece) ⋆" style="zoom:80%;" /> | <img src="https://i0.wp.com/shores.rocks/stem-coding/wp-content/uploads/2021/03/zk-5ad-motor-driver-5a-high-power.jpg?fit=948%2C924&ssl=1" alt="ZK-5AD L298N5A Dual DC Motor Drive Module (1 piece)" style="zoom:50%;" /> |
| :----------------------------------------------------------: | ------------------------------------------------------------ |

## [LILYGO® TTGO T-Display ESP32](http://www.lilygo.cn/prod_view.aspx?TypeId=50062&Id=1400&FId=t3:50062:3)

For the DC motor control, the future plan is to use the Zynq+ Dual Core ARM  Cortex-R5 processors with FreeRTOS. The initial test was done with a TTGO T-Display (aka TTGO-T1) board. Although I was planning to use the [PMOD](https://digilent.com/reference/pmod/start) to generate the required PWM signals, but after burning two drivers and one TTGO-T1 board I decided to leave it for another day.

You can buy a TTGO-T1 board at [Aliexpress](https://www.aliexpress.com/item/33048962331.html) (Official [LILYGO store](https://lilygo.he.aliexpress.com/store/2090076?spm=a2g0o.detail.1000061.1.59f8142fz8JkSi)). It is based on the [ESP32 Espresiff](https://www.espressif.com/en/products/socs/esp32) ([Wikipedia](https://en.wikipedia.org/wiki/ESP32])), a 32bit MCU Tensilica Xtensa LX6 with integrated WiFi, Bluetooth, and a lot of peripherals. This is the board I usually use for R&D.

## USB WiFi dongle

To do some telemetry and get some real time feedback when testing the system, a wireless communication with good throughput and low latency was required. As the KV260 lacks a dedicated wireless communication interface, a USB WiFi dongle was selected for this. For a more detailed information on how to install the drivers and setup the device used in this project please refer to [Adding USB-WiFi for the Kria KV260 (Ubuntu 20.04.3)](https://www.hackster.io/dramoz/adding-usb-wifi-for-the-kria-kv260-ubuntu-20-04-3-b5e8ea).

## Power considerations



## Other components

To complete assemble an ATRover mini, some other components are required as:

- M3 screws
  - chasis
- Power distribution block
- Power cables
  - KRIA power cable
  - DC motors
- TTGO-T1 ZK-5AD connector
- microUSB cable for Stereo Camera
- USB-C cable for TTGO-T1

# Software/Firmware

The journey through the KRIA KV-260 and Xilinx Development Tools was extensive and extenuating. Although I have learned a lot, at the end, with the timeline nearer everyday, I have to make a choice and start doing some real deployment. Fortunately, [PYNQ for the KV260](https://github.com/Xilinx/Kria-PYNQ) was made available [two months ago](https://community.element14.com/technologies/fpga-group/f/forum/50595/pynq-now-available-for-the-kria-kv260-vision-ai-starter-kit). In retrospective, I should have jumped right away into the PYNQ framework for this challenge, but after testing it and reading some comments in the forum, I decided to give put it on the side. At the end, I came back to it as:

- It is easier to deploy and test any AI
- Works right away, no issues, fewer steps and if you miss any (you probably will not), it is easier to recover.
- This should have been the start point when jumping into something as new as the KRIA KV-260.
  - The KRIA flow is slightly different from other ZYNQ Ultrascale boards like the Ultra96-V2 or Z102
  - There is plenty information about the KRIA, Xilinx Tools, Vitis, Vitis-AI, etc. But the information is hard to grasp, and it feels unorganized. The tutorials lack continuity, e.g. they required different tool versions, different boards, etc.
  - There is no clear line to follow, actually there are several paths to follow - which get confusing and when you finished something, only at the end you realize that it was not the right tool version - and there is no additional information on how to migrate (or probably I did not find it).

## Required tools

- [Kria-PYNQ](https://github.com/Xilinx/Kria-PYNQ)
- [Vitis-AI v1.4](https://github.com/Xilinx/Vitis-AI/tree/1.4): the DPU-PYNQ uses version 1.4
-  [Visual Code](https://code.visualstudio.com/) + [PlatformIO](https://platformio.org/platformio-ide): the KV260 ATRover uses a TTGO-T1 board to control the DC motors via USB/Serial port. Please follow the instructions on each website to install the tools.

## [PYNQ](https://github.com/Xilinx/Kria-PYNQ) to the rescue

> [Kria SOMs x Ubuntu x PYNQ](https://pages.xilinx.com/EN-WB-2022-03-22-KriaPYNQUbuntu_LP-Registration.html): nice introductory webinar

The PYNQ framework on the KRIA KV-260 is pretty simple to use.

- It runs on Ubuntu 20.04.04 LTS
  - Easier to install new drivers or tools for development (e.g. USB WiFi dongle, USB/UART drivers)
  - Visual Code SSH + PlatformIO Remote Development
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

**PYNQ install**

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
  - Run the [DPU resnet50](http://kria:9090/lab/workspaces/auto-e/tree/pynq-dpu/dpu_resnet50.ipynb) to validate the DPU-PYNQ installation

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

## Vitis-AI (v1.4)

> Vitis-AI requires around 100GB of hard drive space

As the current Vitis-AI version is 2.0, but DPU-PYNQ requires v1.4, please follow the next steps to install the proper tool version. Vitis-AI is installed and run in your local machine (Ubuntu)

**Installation steps**

- [Install docker](https://docs.docker.com/engine/install/)

  ```bash
  # Prerequisites
  sudo apt install -y ca-certificates curl gnupg lsb-release
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  
  # Docker engine
  sudo apt install -y docker-ce docker-ce-cli containerd.io
  
  # Setup group access
  sudo groupadd docker
  sudo usermod -aG docker $USER
  su $USER
  
  # Test installation
  sudo docker run hello-world
  ```

- Install Vitis-AI

  ```bash
  mkdir -p ~/repos
  cd repos
  git clone --recurse-submodules https://github.com/Xilinx/Vitis-AI
  cd Vitis-AI
  git checkout 1.4
  ```

- Get [Docker image](https://github.com/Xilinx/Vitis-AI/blob/1.4/docs/quick-start/install/install_docker/load_run_docker.md):

  ```bash
  docker pull xilinx/vitis-ai-cpu:1.4.916
  ```

  Alternatively, you can build the docker image with:

  ```bash
  cd setup/docker
  ./docker_build_cpu.sh
  ```

- Launch Vitis-AI

  ```bash
  ./docker_run.sh xilinx/vitis-ai-cpu:1.4.916
  ```

## Additional Drivers & Ubuntu configuration

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

***Optional packages***

```bash
sudo apt install -y graphviz gtkwave tree meld
```

***Optional Python Virtualenv Wrapper***

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

| <img src="https://github.com/dramoz/kv260-atrover/blob/main/docs_support/old_bash_prompt.png?raw=true" alt="old_bash_prompt.png" style="zoom:100%;" /> |
| ------------------------------------------------------------ |

to

| <img src="https://github.com/dramoz/kv260-atrover/blob/main/docs_support/new_bash_prompt.png?raw=true" alt="new_bash_prompt.png" style="zoom:100%;" /> |
| :----------------------------------------------------------- |

You can install them next after cloning the project repository.

# Project files

```bash
cd ~
mkdir dev
cd dev
git clone https://github.com/dramoz/kv260-atrover
```

NOTE: you can use [Visual Code remotely with SSH](https://code.visualstudio.com/docs/remote/ssh).

> Click ≶ icon on the bottom left corner and create a new connection.

Create a symbolic link to the repository so it is accessible from jupyter-lab

```bash
cd $PYNQ_JUPYTER_NOTEBOOKS
ln -s $HOME/dev/kv260-atrover/ kv260-atrover
```

Copy the `.bashrc` configuration (optional)

```bash
cp -fv ~/dev/kv260-atrover/scripts/.bash* ~/
source ~/.bashrc
```

Finally install the required python dependencies:

```bash
pip install -r ~/dev/kv260-atrover/scripts/requirements.txt
```

**TTGO-T1 firmware**

The TTGO-T1 code is a simple four channel PWM generator connected to the ZK-5AD motor driver. It communicates to the KV260 board with a USB/Serial port. The KV260 application send the following commands as requried:

- `*m###, m in [f, b, r, l, s]`

  - f: forward
  - b: backward
  - r: turn right
  - l: turn left
  - s: stop
  - ###: desired step value, between `min/max_step` range (number string must be 3 numeric characters)

  example: `*f064`

- `!xxxx`: emergency stop (any four *xxxx* characters)

The following parameters can be configured (required to flash a new firmware into the board):

- `min/max speed`: in steps to control the PWM duty cycle
- `PWM frequency` and `PWM resolution`
- acceleration: by means of `speed_step` and update rate (`accel_step_ms`)

The default parameters were set on a trial an error basis as:

- `min_step`: 32, `max_step`: 128
- [PWM frequency](https://electronics.stackexchange.com/questions/242293/is-there-an-ideal-pwm-frequency-for-dc-brush-motors/): 8Hz
- `speed_step`: 8, `accel_step_ms`: 200

The firmware of the TTGO-T1 board was developed using Visual Code PlatformIO. After installing Visual Code + PlatformIO, clone the project repository on a local machine and add the [ttgo-atrover-motor-control](https://github.com/dramoz/kv260-atrover/tree/main/ttgo-atrover-motor_control) project to PlatformIO. Connect the board to an available USB serial port, compile (✓) and flash (➔) the board by clicking on the icons located at the bottom tool bar in VS code.

It is possible to program the TTGO-T1 board directly from the KRIA KV-260 with [PlatformIO Remote Development](https://docs.platformio.org/en/stable/plus/pio-remote.html) tools.

> A free PlatformIO account is required for remote development.

On your local machine

- Open Visual Studio Code

  ```bash
  # CTRL+SHIFT+P
  # Start typing Platf...
  # -> Click PlatformIO: New Terminal
  pio account register
  pio account login
  ```

On the KV260

- Install

  ```bash
  python3 -c "$(curl -fsSL https://raw.githubusercontent.com/platformio/platformio/master/scripts/get-platformio.py)"
  ```

- Update `.bashrc` (already present if `.bashrc` was updated from the repository)

  ```bash
  export PATH=$PATH:$HOME/.platformio/penv/bin
  ```

- Install the [platformio-udev-rules](https://docs.platformio.org/en/stable/faq.html#platformio-udev-rules)

  ```bash
  curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core/master/scripts/99-platformio-udev.rules | sudo tee /etc/udev/rules.d/99-platformio-udev.rules
  sudo service udev restart
  sudo usermod -a -G dialout $USER
  sudo usermod -a -G plugdev $USER
  ```

- Login and start the remote agent

  ```bash
  pio account login
  pio remote agent start
  ```

- > The first call to `pio remote agent start` will require some time while the required packages and dependencies are installed

Local machine remote programming

- On a PlatformIO terminal in VS code

  > Check that the terminal current path is at `~/dev/kv260-atrover/ttgo-atrover-motor_control/`

- Check KV260 remote agent

  ```bash
  #pio account login (if required)
  pio remote agent list
  ```

  > kria
  > \----
  > ID: 827c99104301d4120ea475faee3371703eddc89f
  > Started: 2022-03-27 00:28:45

  ```bash
  pio remote run -t upload --upload-port /dev/ttyCH343USB0
  ```

PlatformIO Remote Development is a useful remote programing tool, as if required for example to change the PWM frequency for the DC motors control, we can reprogram the TTGO-T1 without the need of unplugging it from the KV260 board.

# Basic system tests

All the scripts are done in Python using Visual Studio code. Although JupyterLab was nice for the initial R&D, it is faster to run some OpenCV like `imshow()` outside the Jupyter environment, with `ssh -X`.

**TTGO-T1 and DC motors**

```bash
ssh ubuntu@kria_ip
screen /dev/ttyCH343USB0 115200
```

Press the TTGO-T1 reset button, a message similar to this would appear

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

Run some commands

- `*f064`, `*b128`, `*s0000`, `*l128`, `!0000` ...

When done, disconnect screen to free serial port

> `ctrl+a, k`
>
> Really kill this window [y/n] `y`
>
> [screen is terminating]
> ubuntu@kria:~/$

**Stereo camera test**

To run a simple test on the stereo camera:

```bash
ssh -X ubuntu@kria_ip
cd ~/dev/kv260-atrover/scripts/
python camera_test.py
```

| <img src="https://github.com/dramoz/kv260-atrover/blob/main/docs_support/camera_test.png?raw=true" alt="camera_test.png" style="zoom:100%;" /> |
| :----------------------------------------------------------: |

The triangulation test is based on [niconielsen32-ComputerVision/StereoVisionDepthEstimation/](https://github.com/niconielsen32/ComputerVision/tree/master/StereoVisionDepthEstimation) modified to use one single stereo camera stream.

> The triangulation test is loading the calibration matrices and applying the OpenCV remap on both frames. As can be seen in the pictures, the black regions surrounding the frames are a side effect of remapping the frames. It is also noticeable the difference between both camera module lenses.

```bash
ssh -X ubuntu@kria_ip
~/dev/kv260-atrover/scripts/triangulation_example/
python camera_test.py
python stereoVision.py
```

| <img src="https://github.com/dramoz/kv260-atrover/blob/main/docs_support/triangulation_test.png?raw=true" alt="triangulation_test.png" style="zoom:100%;" /> |
| :----------------------------------------------------------: |

| <img src="https://github.com/dramoz/kv260-atrover/blob/main/docs_support/triangulation_test2.png?raw=true" alt="triangulation_test.png" style="zoom:100%;" /> |
| ------------------------------------------------------------ |

>  ☝ At the moment, the triangulation demo is exiting with a `Segmentation fault (core dumped)` error which I did not have time to investigate further at the moment of writing this project.

**Movement Test**

A simple script to validate the communication between the KV260 board and the TTGO while testing the motors was done.

VIDEO: https://youtu.be/WgYcuWozWEg

# Selecting the model(s)

Xilinx provides with the Vitis-AI a set of pre-trained NN models that can be used as a starting point. It is referenced as [Vitis-AI AI-Model-Zoo](https://github.com/Xilinx/Vitis-AI/tree/master/models/AI-Model-Zoo). The models are deployed on the FPGA on the DPU IP. As the DPU comes in different flavors, please note that if the model is not available for the current DPU model, extra steps are required with Vitis-AI framework to deploy the solution properly.

- The KRIA KV260 examples run on Petalinux and use a [DPU B3136](https://xilinx.github.io/kria-apps-docs/2020.2/build/html/docs/smartcamera/docs/hw_arch_accel.html), with Xilinx tools 2021.1
- The PYNQ has an overlay [DPU-PYNQ](https://github.com/Xilinx/DPU-PYNQ) with a [DPU B4096](https://github.com/Xilinx/DPU-PYNQ/blob/master/boards/KV260/dpu_conf.vh), and uses Vitis-AI 1.4.0

When selecting the model for this project, one useful metric available at the AI Model Zoo worth mentioning is the [Performance on Kria KV260 SOM](https://github.com/Xilinx/Vitis-AI/tree/v1.4/models/AI-Model-Zoo#performance-on-kria-kv260-som). It summarizes the KV260 latency and throughput of the available model.

CNNs are available in different topologies, which basically define the application target. Furthermore, each model can be trained using different data sets ([ImageNet](https://www.image-net.org/), [COCO](https://cocodataset.org/), [CityScapes](https://www.cityscapes-dataset.com/), [SYNTHIA](http://synthia-dataset.net/) among others)

From the different topologies available in the AI Model Zoo, the following were selected to do some R&D:

- [YOLO](https://towardsdatascience.com/yolo-you-only-look-once-real-time-object-detection-explained-492dc9230006): (You Only Look Once) object detection and classification
- [SSD](https://towardsdatascience.com/understanding-ssd-multibox-real-time-object-detection-in-deep-learning-495ef744fab): (Single Shot MultiBox Detector) object detection.
- [FADnet](https://arxiv.org/abs/2003.10758) ([GitHub repository](https://github.com/HKBU-HPML/FADNet)): disparity estimation

[**Downloading a model**](https://github.com/Xilinx/Vitis-AI/tree/1.4/models/AI-Model-Zoo#automated-download-script)

> Models are downloaded to the local machine where Vitis-AI was installed and later transfer with `spc` to the ATRover.

> To validate the Kria-PYNQ framework running on the KV-260, the resnet50 model was also downloaded. 

To download the models, for each model do:

```bash
cd ~/repos/Vitis-AI/models/AI-Model-Zoo/

# -----------------------------------------------------------
# Caffe resnet50
# file: resnet50-zcu102_zcu104_kv260-r1.4.0.tar.gz
python downloader.py
> input: `cf resnet50`
2: ['type', 'xmodel']['board', 'zcu102 & zcu104 & kv260']
> input num: `2`
done
# -----------------------------------------------------------
# Darknet YOLOV4
# file: yolov4_leaky_spp_m-zcu102_zcu104_kv260-r1.4.0.tar.gz
python downloader.py
> input:dk yolov4
1 : dk_yolov4_coco_416_416_60.1G_1.4
> input num:1
2:  ['type', 'xmodel']['board', 'zcu102 & zcu104 & kv260']
> input num:2
done
# -----------------------------------------------------------
# PyTorch FADnet
# file: FADNet_2_pt-zcu102_zcu104_kv260-r1.4.0.tar.gz
python downloader.py
> input:pt fadnet
4:  ['type', 'xmodel']['board', 'zcu102 & zcu104 & kv260']
> input num:4
done
# -----------------------------------------------------------
# TensorFlow SSD
# file:
python downloader.py 
> input:tf ssd
4 : tf_ssdresnet50v1_fpn_coco_640_640_178.4G_1.4
> input num:4
2:  ['type', 'xmodel']['board', 'zcu102 & zcu104 & kv260']
> input num:2
done
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# Models are downloaded as *tar.gz files
du -h *.gz
106M	FADNet_2_pt-zcu102_zcu104_kv260-r1.4.0.tar.gz
18M	resnet50-zcu102_zcu104_kv260-r1.4.0.tar.gz
45M	yolov4_leaky_spp_m-zcu102_zcu104_kv260-r1.4.0.tar.gz

# transfer them to the KV260 SDcard with
scp *.gz ubuntu@192.168.0.198:/home/ubuntu/dev/kv260-atrover/scripts/models

# Connect to the board and untar the files
ssh -X ubuntu@kria_ip
cd ~/dev/kv260-atrover/scripts/models/
for f in ../*.gz; do tar -xvzf "$f"; done
```

>FADNet_2_pt/
>FADNet_2_pt/FADNet_2_pt.xmodel
>FADNet_2_pt/md5sum.txt
>resnet50/
>resnet50/resnet50.prototxt
>resnet50/resnet50.xmodel
>resnet50/md5sum.txt
>yolov4_leaky_spp_m/
>yolov4_leaky_spp_m/yolov4_leaky_spp_m.prototxt
>yolov4_leaky_spp_m/yolov4_leaky_spp_m.xmodel
>yolov4_leaky_spp_m/md5sum.txt

The `*.xmodel` files would be the models to load into the DPU.

**Running the scripts**

> Each models requires a pre-process to the input frames and a post-process of the output different in each case. The information can be gather from the Board/GPU models that can be downloaded using the same previous steps (`python downloads.py`) and selecting the board/GPU option
>
> `1:  ['type', 'float & quantized']['board', 'GPU']`
>
> The downloaded files are `.zip` type.
>
> ```bash
> du -h *.zip
> 208M	cf_resnet50_imagenet_224_224_7.7G_1.4.zip
> 529M	dk_yolov4_coco_416_416_60.1G_1.4.zip
> 1.2G	pt_fadnet_sceneflow_576_960_359G_1.4.zip
> ```
>
> The preprocess information is located in the `readme.md` file in each case.
>
> The postprocess depends on each CNN output vector format.

## Deploying TF SSD

```bsh
pip install --upgrade tensorflow
```

## Deploying YOLOv4

[Yolo 2 Explained](https://towardsdatascience.com/yolo2-walkthrough-with-examples-e40452ca265f#:~:text=Yolo%20Output%20Format&text=Yolo2%20uses%20a%20VGG%2Dstyle,to%20increase%20speed%20or%20accuracy.&text=As%20you%20can%20see%2C%20yolo's,what%20we've%20seen%20before.) ([GitHub](https://github.com/zzxvictor/YOLO_Explained))

[Old Vitis-AI YOLO example](https://github.com/Xilinx/Vitis-AI/blob/v1.1/mpsoc/vitis_ai_dnndk_samples/tf_yolov3_voc_py/tf_yolov3_voc.py)



## Improving the model(s)

Vitis-AI is the tool required to tailor the neural network model to project particular needs. As realized by running some tests, it would be necessary to re-train the current CNN models.

- A suitable dataset: although there are some indoor datasets, most are at higher levels.
- Gathering a dataset is time consuming, and resources hungry.

# Final Remarks

This experience was a short/long journey with the KRIA KV-260. Initially I was contemplating getting a Ultra96-V2 as it seemed better on paper for this type of project, but the free hardware option was the KV-260.

In retrospective, my gut feeling was 50/50. On one side, I think the Ultra96-V2 is "better" suited for the ATRover with it smaller form factor, ready WiFi and more I/O ports available out of the box. On the other side, the Kria KV-260 has more USB-Ports, extra camera ports, doubles the DDR-RAM and is capable of video streaming with its integrated VCU (Video Codec Unit) - features which make it ideal for R&D, which at the end is the main idea behind the KV-260 Starter kit.

As a plus, there is no need to configure any jumpers to select the boot target and the capability of dynamic loading overlays it is key. Finally, in my case, getting Ubuntu out-of-the shelf ready and working without any issues is awesome.

Unfortunately I run out of time for the [Adaptive Computing Challenge 2021](https://www.hackster.io/contests/xilinxadaptivecomputing2021) when things where finally getting interesting, and I was only able to deploy a simple application. Learning all this and going through the available documentation, examples was extenuating. Maybe next time I should spend less time at my 3D printer.

But it was worth the journey, I came from almost zero AI/ML knowledge and Vitis/Zynq+ to be able to deploy some CNN on a small vehicle platform and make it move around while identifying some objects.

The final activities to have a proper closure of the first ATRover phase that are not done yet give the timing left before submitting the project are:

- BOM: improve the bill of materials with a guide on how to assemble the whole project
- Chassis 3D print: the 3D models are available as OpenSCAD files, but they were fine tune to my printer (Ender3 modified to print 2.85mm)
- TTGO-T1 UART drivers installation on the KRIA KV-260 Ubuntu desktop OS: only a short explanation was given in this document.
- DC motor characterization + improve DC motor control: the current scripts do not have any proper motor control (e.g. PID) and there is no proper motor parameters characterization. Also, the current motor setup is generating too much vibration while running at medium speed.

# Future work

- **Proper Overlay Pipeline**

  As mentioned earlier, the available overlays for the Kria-PYNQ does not allow to perform video pre-processing while using a DPU. The next step would be to develop a PYNQ overlay more suitable for the KV260-ATRover setup. The overlay should also include a proper video stream generation using the video codec capabilities of the KRIA SOM.

- **Training Dataset**

  For what I found, most current datasets pictures are up to high, and the world is shown from a complete different perspective than an almost at floor level the ATRover sees (which make you thing how little kids see the world). Now that the ATRover has some limited mobility, it will be possible to gather new training images to improve the CNN training.

- **DC motors downgrade**

  The current DC motors are too powerful for the KV260-ATRover mini. They were selected initially for the lawnmower which has a bigger heavier chassis (higher torque requirement) and larger wheels (reducing the speed of the ATRover and therefore increasing the minimum required PWM duty cycle)

- **More sensors**

  Additional sensors are planned (and required) to improve the ATRover control:

  - 9-DOF: 3-axis accelerometer and 3-axis gyroscope

  - Ultrasound distance measurement

  - Additional cameras for mapping

  - Cliff sensor

- **Chassis upgrade**

  - Lower the camera position or update the lens to wide angle to capture nearer objects

  - Battery compartment for easy battery replacement.

- **R&D other CNN topologies**
  - Multitask CNN look like an ideal solution for path control and planning including DC motor control.
  - Single CNN dual camera SSD/YOLO with distance estimation as output
  - Self-learning/self-calibration CNN for stereovision camera

- **[ROS2](https://docs.ros.org/en/foxy/index.html)**

  Although ROS2 is available, it is still on the alpha release side

- **Web Interface**

  - Although JupyterLab is nice for some work, a minimalistic webInterface would be nice to have

- **From PYNQ to C++**

  - test performance difference between running on Python and C++
  - almost everything in the Vitis-AI is done in C++, but everything looks prettier on Python

# Future Projects

While learning about the Kria KV-260 a couple of projects came to my mind:

- *Where is my dog?* I am on a rural area and occasionally I let my dog out. As he is a small breed I am always worried about him, and a solution like Alexa "show me cam##" does not satisfices my needs. I already got new IP cameras with RTSP and will begin to do some test early summer.
- *Monitor my-Kids free-time*. I work from home, which is great, but for a couple of hours while I am working, my kids are supposed to do the homework - which usually does not work as expected. There should be an easier way to monitor and time screen-time.

Finally, I will try to write some starting tutorials on deploying AI/ML on the Xilinx - MPSoCs, while following the contest forums it was clear that I was not the only one - and I should have asked more questions rather than trying to solve all by myself (but I think that's how I learn more)

# Acknowledgments

I want to tank the HacksterIO community for sharing, answering and asking questions. HacksterIO and Xilinx staff for the effort and time into promoting these challenges and activities - and answering questions. I found them a great way to improve my know-how.

Last but not the least, my wife and my kids for supporting and not letting me quit, for understanding my occasional absences (or more often coming late to dinner) and helping with the chores (the ones I was supposed to do)

As always, comments are most welcome.

# References & Links

| Title                           | Remarks                 | URL                                     |
| ------------------------------- | ----------------------- | --------------------------------------- |
| KV260-ATRover GitHub repository | This project repository | https://github.com/dramoz/kv260-atrover |

**Tutorials**

| Title                            | Remarks | URL                                                      |
| -------------------------------- | ------- | -------------------------------------------------------- |
| Stereo Vision Camera Calibration |         | https://youtu.be/yKypaVl6qQo                             |
| Camera Calibration using OpenCV  |         | https://learnopencv.com/camera-calibration-using-opencv/ |

**Blogs**

| Title        | Remarks                 | URL                                              |
| ------------ | ----------------------- | ------------------------------------------------ |
| Learn OpenCV | Stereo Vision Tutorials | https://learnopencv.com/author/kaustubh-sadekar/ |

**Xilinx**

| Title            | Remarks                                                      | URL                                                          |
| ---------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| VART             | [C++ APIs](https://docs.xilinx.com/r/1.4.1-English/ug1414-vitis-ai/C-APIs)<br />[Python APIs](https://docs.xilinx.com/r/1.4.1-English/ug1414-vitis-ai/Python-APIs) | https://docs.xilinx.com/r/1.4.1-English/ug1414-vitis-ai/VART-Programming-APIs |
| XIR              | [Xilinx Intermediate Representation](https://docs.xilinx.com/r/en-US/ug1414-vitis-ai/Compiling-with-an-XIR-based-Toolchain)<br />graph-based intermediate representation of AI algorithms | https://github.com/Xilinx/Vitis-AI/tree/master/tools/Vitis-AI-Runtime/VART/xir |
| DNNDK            | Deep Neural Network Development Kit User Guide               | https://docs.xilinx.com/v/u/1.6-English/ug1327-dnndk-user-guide |
| Vitis-AI         | User Guide                                                   | https://docs.xilinx.com/r/1.4-English/ug1414-vitis-ai/Revision-History |
| Vitis-AI Library | User Guide                                                   | https://docs.xilinx.com/r/1.4-English/ug1354-xilinx-ai-sdk/Revision-History |

> ⚠ A lot of time was wasted while looking at the wrong Vitis AI User Guide (UG1414) version [v1.4](https://docs.xilinx.com/r/1.4-English/ug1414-vitis-ai/) which was incorrect, the [v1.4.1](https://docs.xilinx.com/r/1.4.1-English/ug1414-vitis-ai/) does contains the required VART API information required to deploy with Vitis AI-1.4

**Wiki**

| Title                        | Remarks                                                      | URL                                                          |
| ---------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| CNN Tensor Shape (aka .dims) | Tensors are in the form NHWC (batchsize, height,width,channels) | https://deeplizard.com/learn/video/k6ZF1TSniYk               |
| YOLO output                  | YOLO output data post-processing                             | https://towardsdatascience.com/yolo2-walkthrough-with-examples-e40452ca265f |
| YOLO + OpenCV                | YOLO object detection with OpenCV                            | https://pyimagesearch.com/2018/11/12/yolo-object-detection-with-opencv/ |

