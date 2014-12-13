//
//  GAXboxControllerCommunication.h
//  Xbox One Controller Enabler
//
//  Created by Guilherme Araújo on 28/03/14.
//  Copyright (c) 2014 Guilherme Araújo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOBluetooth/IOBluetooth.h>
#import "XboxOneButtonMap.h"

#define GAMEPAD_SERVICE @"1531"

@protocol GAXboxControllerCommunicationDelegate <NSObject>
- (void)controllerDidUpdateData:(XboxOneButtonMap)data;

@end

@interface GAXboxControllerCommunication : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>
{
    CBCentralManager *manager;
    CBPeripheral *peripheral;
    NSMutableArray *gamepads;
}
@property (weak, nonatomic) id<GAXboxControllerCommunicationDelegate> delegate;

- (int)searchForDevices;
- (void)closeDevice;
- (void)startPollingController;
- (void)stopPollingController;

- (void) startScan;
- (void) stopScan;
- (BOOL) isLECapableHardware;


@end
