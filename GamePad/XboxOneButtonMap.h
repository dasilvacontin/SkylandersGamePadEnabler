//
//  XboxOneButtonMap.h
//  Xbox One Controller Enabler
//
//  Created by Guilherme Araújo on 27/03/14.
//  Copyright (c) 2014 Guilherme Araújo. All rights reserved.
//

//  Xbox One Controller Buttom Map
//  Originally by Brandon Jones
//  Adapted from http://blog.tojicode.com/2014/02/xbox-one-controller-in-chrome-on-osx.html

typedef struct {
  bool menu;  // Not entirely sure what these are

  bool a;
  bool b;
  bool x;
  bool y;

  bool dpad_up;
  bool dpad_down;
  bool dpad_left;
  bool dpad_right;

  bool bumper_left;
  bool bumper_right;

  uint8_t trigger_left;
  uint8_t trigger_right;

  int8_t stick_left_x;
  int8_t stick_left_y;
  int8_t stick_right_x;
  int8_t stick_right_y;

} XboxOneButtonMap;

