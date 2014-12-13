typedef struct {
  bool menu;

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

} GamePadButtonMap;

