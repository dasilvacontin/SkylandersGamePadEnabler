//
//  GAXboxController.h
//  Xbox One Controller Enabler
//
//  Created by Guilherme Araújo on 28/03/14.
//  Copyright (c) 2014 Guilherme Araújo. All rights reserved.
//

#import <Foundation/Foundation.h>
#define MAX_SIGNED_BYTE 127

@protocol GAXboxControllerDelegate;

@interface GAXboxController : NSObject

@property (nonatomic, getter = isConnected) BOOL connected;
@property (nonatomic) float leftAnalogXOffset;
@property (nonatomic) float leftAnalogYOffset;
@property (nonatomic) float rightAnalogXOffset;
@property (nonatomic) float rightAnalogYOffset;

@property (weak, nonatomic) id<GAXboxControllerDelegate> delegate;

- (void)connect;
- (void)disconnect;

- (BOOL)DPadUp;
- (BOOL)DPadDown;
- (BOOL)DPadRight;
- (BOOL)DPadLeft;

- (BOOL)A;
- (BOOL)B;
- (BOOL)X;
- (BOOL)Y;

- (BOOL)leftBumper;
- (BOOL)rightBumper;

- (BOOL)menu;

- (float)leftAnalogX;
- (float)leftAnalogY;
- (float)rightAnalogX;
- (float)rightAnalogY;

- (float)leftTrigger;
- (float)rightTrigger;

@end

@protocol GAXboxControllerDelegate <NSObject>

- (void)controllerDidConnect:(GAXboxController *)controller;
- (void)controllerDidDisconnect:(GAXboxController *)controller;
- (void)controllerDidUpdateData:(GAXboxController *)controller;
- (void)controllerConnectionFailed:(GAXboxController *)controller withError:(NSString *)error errorCode:(int)code;

@end