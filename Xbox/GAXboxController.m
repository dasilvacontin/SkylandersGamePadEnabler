//
//  GAXboxController.m
//  Xbox One Controller Enabler
//
//  Created by Guilherme Araújo on 28/03/14.
//  Copyright (c) 2014 Guilherme Araújo. All rights reserved.
//

#import "GAXboxController.h"
#import "GAXboxControllerCommunication.h"

#define kHysteresis 0.085

@interface GAXboxController () <GAXboxControllerCommunicationDelegate>

@property (strong, nonatomic) GAXboxControllerCommunication *communication;
@property (nonatomic) XboxOneButtonMap buttonMap;

@end

@implementation GAXboxController

@synthesize buttonMap;
@synthesize communication;

#pragma mark - Object Life Cycle

- (id)init {
  self = [super init];
  
  communication = [[GAXboxControllerCommunication alloc] init];
  [communication setDelegate:self];

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceConnected:) name:@"deviceConnected" object:nil];
  
  _leftAnalogXOffset = 0;
  _leftAnalogYOffset = 0;
  _rightAnalogXOffset = 0;
  _rightAnalogYOffset = 0;
  
  return self;
}

#pragma mark - Connection Management

- (void)connect {
    [communication searchForDevices];
}

-(void) deviceConnected:(NSNotification*)notification {
    [_delegate controllerDidConnect:self];
    _connected = YES;
}

- (void)disconnect {
  [communication closeDevice];
  _connected = NO;
  [_delegate controllerDidDisconnect:self];
}

#pragma mark - Xbox Controller Communication Delegate Method

- (void)controllerDidUpdateData:(XboxOneButtonMap)data {
  buttonMap = data;
  [_delegate controllerDidUpdateData:self];
}

#pragma mark - Buttons & Axes Outputs

- (BOOL)DPadUp{ return buttonMap.dpad_up == 1; }

- (BOOL)DPadDown { return buttonMap.dpad_down == 1; }

- (BOOL)DPadRight { return buttonMap.dpad_right == 1; }

- (BOOL)DPadLeft { return buttonMap.dpad_left == 1; }

- (BOOL)A { return buttonMap.a == 1; }

- (BOOL)B { return buttonMap.b == 1; }

- (BOOL)X { return buttonMap.x == 1; }

- (BOOL)Y { return buttonMap.y == 1; }

- (BOOL)leftBumper { return buttonMap.bumper_left == 1; }

- (BOOL)rightBumper { return buttonMap.bumper_right == 1; }

- (BOOL)menu { return buttonMap.menu == 1; }


- (float)leftAnalogX {
  float v = (float) buttonMap.stick_left_x / MAX_SIGNED_BYTE - _leftAnalogXOffset;
  return (fabs(v) < kHysteresis) ? 0 : v;
}

- (float)leftAnalogY {
  float v = (float) buttonMap.stick_left_y / MAX_SIGNED_BYTE - _leftAnalogYOffset;
  return (fabs(v) < kHysteresis) ? 0 : v;
}

- (float)rightAnalogX {
  float v = (float) buttonMap.stick_right_x / MAX_SIGNED_BYTE - _rightAnalogXOffset;
  return (fabs(v) < kHysteresis) ? 0 : v;
}

- (float)rightAnalogY {
  float v = (float) buttonMap.stick_right_y / MAX_SIGNED_BYTE - _rightAnalogYOffset;
  return (fabs(v) < kHysteresis) ? 0 : v;
}

- (float)leftTrigger {
  return buttonMap.trigger_left > 0 ? 1 : 0;
}

- (float)rightTrigger {
  return buttonMap.trigger_right > 0 ? 1 : 0;
}

@end
