// ------------------------------------------------------------------------
// Panasonic Sensor Draw screens
// ------------------------------------------------------------------------
#include "gui.h"
// ------------------------------------------------------------------------
clGUI::clGUI(long refresh_rate, const char* wlcm_msg)
: _last_update(0)
, _wlcm_msg(wlcm_msg)
, _refresh_rate(refresh_rate)
, _curr(ScreenPage::STATUS)
{}
// ------------------------------------------------------------------------
void clGUI::init(void) {
  _last_update = millis();
  
  tft_init(true, 2);  // FONT2: 5 lines
  home();
}

// ------------------------------------------------------------------------
void clGUI::loop(void) {
  auto curr_millis = millis();
  if(curr_millis - _last_update > _refresh_rate) {
    _last_update = curr_millis;
    draw();
  }
}

// ------------------------------------------------------------------------
void clGUI::set(ScreenPage new_screen, bool force) {
  if(new_screen!=_curr || force) {
    _curr = new_screen;
    tft.fillScreen(TFT_BLACK);
    tft_goto_ln(0);
    tft.setTextFont(2);
    
    switch(_curr) {
      case ScreenPage::CONFIG: {
        tft.setTextColor(TFT_ORANGE, TFT_BLACK);
        tft.print(_wlcm_msg);
        tft.println(" (setup)");
        tft.setTextColor(TFT_WHITE, TFT_BLACK);
        tft_draw_lnxln(1);
        
        tft.print("speed: [");
        tft.print(DualDC_MotorCtrl.min_speed);
        tft.print(", ");
        tft.print(DualDC_MotorCtrl.max_speed);
        tft.print("], ");
        
        tft.print("accel: [");
        tft.print(DualDC_MotorCtrl.speed_step);
        tft.print(" / ");
        tft.print(DualDC_MotorCtrl.accel_step_ms);
        tft.println("ms]");
        
        tft.print("PWM: [");
        tft.print(DualDC_MotorCtrl.PWMFreq());
        tft.print(" Hz, 2^");
        tft.print(DualDC_MotorCtrl.PWMResolution());
        tft.println("]");
        
        tft_draw_lnxln(4);
        // -> ends line8
        break;
      }
      case ScreenPage::STATUS: {
        tft.setTextColor(TFT_ORANGE, TFT_BLACK);
        tft.print(_wlcm_msg);
        tft.println(" (status)");
        tft.setTextColor(TFT_WHITE, TFT_BLACK);
        tft_draw_lnxln(1);
        // -> ends line2
        break;
      }
      case ScreenPage::COMMAND: {
        tft.setTextColor(TFT_ORANGE, TFT_BLACK);
        tft.print(_wlcm_msg);
        tft.println(" (status)");
        tft.setTextColor(TFT_WHITE, TFT_BLACK);
        tft_draw_lnxln(1);
        // -> ends line2
        break;
      }
      case ScreenPage::TERMINAL: {
        tft.setTextColor(TFT_ORANGE, TFT_BLACK);
        tft.print(_wlcm_msg);
        tft.println(" (terminal)");
        tft.setTextColor(TFT_WHITE, TFT_BLACK);
        tft_draw_lnxln(1);
        // -> ends line2
        break;
      }
    }
    draw();
  }
}

// ------------------------------------------------------------------------
void clGUI::draw(void) {
  tft.setTextColor(TFT_WHITE, TFT_BLACK);
  switch(_curr) {
    case ScreenPage::CONFIG: {
      break;
    }
    case ScreenPage::STATUS: {
      tft.setTextFont(4);
      tft_del_ln(2);
      tft.print(' ');
      tft.print(DualDC_MotorCtrl.curr_speed());
      tft.print(" st");
      if(DualDC_MotorCtrl.curr_speed() != DualDC_MotorCtrl.TargetSpeed()) {
        tft.print(" (->");
        tft.print(DualDC_MotorCtrl.TargetSpeed());
        tft.print(" st)");
      }
      
      tft_del_ln(3);
      tft.print(' ');
      tft.print(eDualMotorDirection_Names[ static_cast<size_t>(DualDC_MotorCtrl.curr_dir()) ]);
      tft_del_ln(4);
      if(DualDC_MotorCtrl.curr_dir() != DualDC_MotorCtrl.TargetDirection()) {
        tft.print("  ->");
        tft.println(eDualMotorDirection_Names[static_cast<size_t>(DualDC_MotorCtrl.TargetDirection())]);
      }
      
      break;
    }
    case ScreenPage::COMMAND: {
      tft_del_ln(1);
      tft.print("Speed: ");
      tft.print(DualDC_MotorCtrl.curr_speed());
      tft.print(" -> ");
      tft.println(DualDC_MotorCtrl.TargetSpeed());
      
      tft_del_ln(2);
      tft.print("Direction: ");
      tft.print(eDualMotorDirection_Names[ static_cast<size_t>(DualDC_MotorCtrl.curr_dir()) ]);
      tft.print(" -> ");
      tft.println(eDualMotorDirection_Names[static_cast<size_t>(DualDC_MotorCtrl.TargetDirection())]);
      break;
    }
    case ScreenPage::TERMINAL: {
      tft_goto_ln(2);
      tft.println("Not implemented!!!");
      break;
    }
  }
}

// ------------------------------------------------------------------------
#define NEXT_PG(CURR, NEXT) case ScreenPage::CURR : set(ScreenPage::NEXT); break
void clGUI::next_pg(void) {
  switch(_curr) {
    NEXT_PG(CONFIG, STATUS);
    NEXT_PG(STATUS, COMMAND);
    NEXT_PG(COMMAND, TERMINAL);
    NEXT_PG(TERMINAL, CONFIG);
    default: break;
  }
}
// ------------------------------------------------------------------------
#define PREV_PG(CURR, PREV) case ScreenPage::CURR : set(ScreenPage::PREV); break
void clGUI::prev_pg(void){
  switch(_curr) {
    PREV_PG(CONFIG, TERMINAL);
    PREV_PG(TERMINAL, COMMAND);
    PREV_PG(COMMAND, STATUS);
    PREV_PG(STATUS, CONFIG);
    default: break;
  }
}

// ------------------------------------------------------------------------
void buttons_hndlr(Button2& btn) {
  if(btn == lft_button) {
    switch (btn.getClickType()) {
      case SINGLE_CLICK:
        GUI.next_pg();
        break;
        
    case DOUBLE_CLICK:
        GUI.next_pg();
        break;
        
      case TRIPLE_CLICK:
        DualDC_MotorCtrl.stop();
        break;
        
      case LONG_CLICK:
        DualDC_MotorCtrl.emergency_stop();
        break;
    }
  }
  if(btn == rgt_button) {
    switch (btn.getClickType()) {
      case SINGLE_CLICK:
        GUI.prev_pg();
        break;
        
    case DOUBLE_CLICK:
        GUI.prev_pg();
        break;
        
      case TRIPLE_CLICK:
        DualDC_MotorCtrl.stop();
        break;
        
      case LONG_CLICK:
        DualDC_MotorCtrl.emergency_stop();
        break;
    }
  }
  GUI.set(GUI._curr, true);
}
// ------------------------------------------------------------------------
