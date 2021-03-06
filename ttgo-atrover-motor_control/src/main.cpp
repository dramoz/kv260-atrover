// ------------------------------------------------------------------------
// TTGO-T1
// - ATROVER DC motors control (via UART)
//
// Serial protocol
// !###: Emergency stop
// *: commands (speed = atoi(###))
//    f###: move forward
//    b###: move backward atoi(###)
//    l###: turn left atoi(###)
//    r###: turn right atoi(###)
//    s000: stop
//
// B: busy
// I: idle
// I###: ACK idle
// ------------------------------------------------------------------------
#include <Arduino.h>
#include <stdlib.h>
#include "ttgo-t1-setup.h"
// ------------------------------------------------------------------------
#include "gui.h"
// refresh_rate=1000ms, wlcm_msg
clGUI GUI(1000, static_cast<const char*>("K-ATR Motor Ctrl"));
// ------------------------------------------------------------------------
#include "dc_motors_pwm.h"
// PWMFreq=5000, PWMResolution=8, min_speed=32, max_speed=0, speed_step=8, accel_step_ms=1
// max_speed == 0 -> set max available
clDualDC_MotorCtrl DualDC_MotorCtrl(8, 8, 48, 128, 8, 400);
// ------------------------------------------------------------------------
void setup(void) {
  buttons_init(buttons_hndlr);
  GUI.init();
  DualDC_MotorCtrl.init();
  
  Serial.begin(115200);
  Serial.print("?TTGO");
}
// ------------------------------------------------------------------------
bool report_idle = false;
void loop() {
  loop_buttons();
  GUI.loop();
  if(DualDC_MotorCtrl.loop()) {
    if(report_idle==true) {
      Serial.print('I');
    }
  }
  
  if(Serial.available()>4)
  {
    uint8_t buff[5];
    static_cast<void>( Serial.read(buff, 5) );
    
    // ACK received command by echo
    Serial.write(buff, 5);
    
    // Emergency stop
    if(buff[0]=='!') {
      DualDC_MotorCtrl.emergency_stop();
    }
    // ACK IDLE
    else if(buff[0]=='I') {
      report_idle = false;
    }
    // New movement request
    else if(buff[0]=='*') {
      report_idle = true;
      auto speed = atoi(reinterpret_cast<char*>(&buff[2]));
      switch(buff[1]) {
        case 'f': {
          DualDC_MotorCtrl.move_forward(speed);
          break;
        }
        case 'b': {
          DualDC_MotorCtrl.move_backward(speed);
          break;
        }
        case 'l': {
          DualDC_MotorCtrl.turn_left(speed);
          break;
        }
        case 'r': {
          DualDC_MotorCtrl.turn_right(speed);
          break;
        }
        default: {
          DualDC_MotorCtrl.stop();
          break;
        }
      }
    }
  }
}
// ------------------------------------------------------------------------
