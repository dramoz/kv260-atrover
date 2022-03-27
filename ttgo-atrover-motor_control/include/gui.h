// ------------------------------------------------------------------------
// TTGO-T1 GUI for Dual DC Motor Control Test
// Pages:
// * Emergenxy Stop Button
//   + at any time, if pressed, kill PWMs and set inputs to 0
// - Welcome Page
// - Manual Test
//   + Input speed and direction target
//   + Start
//   + Release GUI when completed
// - Automatic Test
//   + Wait on START Button
//   + Go from MIN_SPEED to MAX_SPEED
// ------------------------------------------------------------------------
#pragma once
// ------------------------------------------------------------------------
#include <Arduino.h>
#include "ttgo-t1-setup.h"
#include "ttgo-t1_ttf.h"
// ------------------------------------------------------------------------
#include "dc_motors_pwm.h"
// ------------------------------------------------------------------------
void buttons_hndlr(Button2& btn);
// ------------------------------------------------------------------------
enum class ScreenPage {CONFIG, STATUS, COMMAND, TERMINAL};
// --------------------------------------------------------------------------------
class clGUI {
  public:
    clGUI(long refresh_rate, const char wlcm_msg[]);
    void init(void);
    void loop(void);
    void set(ScreenPage screen, bool force=false);
    void draw(void);
    
    void home(void) { set(ScreenPage::STATUS, true); }
    void next_pg(void);
    void prev_pg(void);
    
  private:
    long _last_update;
    const char* _wlcm_msg;
    long _refresh_rate;
    ScreenPage _curr;
    
    friend void buttons_hndlr(Button2& btn);
};

extern clGUI GUI;
