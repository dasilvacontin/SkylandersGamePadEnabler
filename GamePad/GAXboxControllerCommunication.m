//
//  GAXboxControllerCommunication.m
//  Xbox One Controller Enabler
//
//  Created by Guilherme Araújo on 28/03/14.
//  Copyright (c) 2014 Guilherme Araújo. All rights reserved.
//

#import "GAXboxControllerCommunication.h"
#import <IOKit/IOKitLib.h>
#import <IOKit/IOCFPlugIn.h>
#import <IOKit/usb/IOUSBLib.h>
#import <IOKit/usb/USBSpec.h>
#import "GamePadButtonMap.h"

@interface GAXboxControllerCommunication ()

  @property (nonatomic) GamePadButtonMap buttonMap;

@end

@implementation GAXboxControllerCommunication

  @synthesize delegate;
  @synthesize buttonMap;

#pragma mark - Object Life Cycle

- (id)init {
  self = [super init];
  manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
  return self;
}

#pragma mark - Setup

- (int)searchForDevices {

    //NSLog(@"%s, %@", __PRETTY_FUNCTION__, peripheral);
    if(peripheral && (peripheral.state == CBPeripheralStateConnected)) {
    } else {   /* No outstanding connection, open scan sheet */
        [self startScan];
    }
    
    return 0;
}

- (void)closeDevice {
    [manager cancelPeripheralConnection:peripheral];
}

#pragma mark - Bluetooth Low Energy

#pragma mark - Start/Stop Scan methods

/*
 Uses CBCentralManager to check whether the current platform/hardware supports Bluetooth LE. An alert is raised if Bluetooth LE is not enabled or is not supported.
 */
- (BOOL) isLECapableHardware
{
    NSString * state = nil;

    switch ([manager state])
    {
        case CBCentralManagerStateUnsupported:
            state = @"The platform/hardware doesn't support Bluetooth Low Energy.";
            break;
        case CBCentralManagerStateUnauthorized:
            state = @"The app is not authorized to use Bluetooth Low Energy.";
            break;
        case CBCentralManagerStatePoweredOff:
            state = @"Bluetooth is currently powered off.";
            break;
        case CBCentralManagerStatePoweredOn:
            return TRUE;
        case CBCentralManagerStateUnknown:
        default:
            return FALSE;

    }

    NSLog(@"Central manager state: %@", state);

    return FALSE;
}

/*
 Request CBCentralManager to scan for gamepads using service UUID 0x1531
 */
- (void) startScan
{

    //NSLog(@"%s, %@", __PRETTY_FUNCTION__, manager);
    [manager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:GAMEPAD_SERVICE]] options:nil];
}

/*
 Request CBCentralManager to stop scanning
 */
- (void) stopScan
{
    [manager stopScan];
}

#pragma mark - CBCentralManager delegate methods
/*
 Invoked whenever the central manager's state is updated.
 */
- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    [self isLECapableHardware];
}

/*
 Invoked when the central discovers peripheral while scanning.
 */
- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)aPeripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    //NSLog(@"%s, %@", __PRETTY_FUNCTION__, aPeripheral);
    peripheral = aPeripheral;
    [manager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey: [NSNumber numberWithBool:YES]}];

}

/*
 Invoked whenever a connection is succesfully created with the peripheral.
 Discover available services on the peripheral
 */
- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)aPeripheral
{
    //NSLog(@"%s, %@", __PRETTY_FUNCTION__, aPeripheral);

    [self stopScan];
    [aPeripheral setDelegate:self];
    [aPeripheral discoverServices:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"deviceConnected" object:nil userInfo:nil];
}


/*
 Invoked whenever an existing connection with the peripheral is torn down.
 Reset local variables
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error
{
    if( peripheral ) {
        [peripheral setDelegate:nil];
        peripheral = nil;
    }
}

/*
 Invoked whenever the central manager fails to create a connection with the peripheral.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error
{
    //NSLog(@"Fail to connect to peripheral: %@ with error = %@", aPeripheral, [error localizedDescription]);
    if( peripheral ) {
        [peripheral setDelegate:nil];
        peripheral = nil;
    }
}

#pragma mark - CBPeripheral delegate methods
/*
 Invoked upon completion of a -[discoverServices:] request.
 Discover available characteristics on interested services
 */
- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error
{
    //NSLog(@"Peripheral found %@", aPeripheral);
    for (CBService *aService in aPeripheral.services)  {
        //NSLog(@"Service found %@", aService);
        [aPeripheral discoverCharacteristics:nil forService:aService];
    }
}

/*
 Invoked upon completion of a -[discoverCharacteristics:forService:] request.
 Perform appropriate operations on interested characteristics
 */
- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ( [service.UUID isEqual:[CBUUID UUIDWithString:CBUUIDGenericAccessProfileString]] )
    {
        for (CBCharacteristic *aChar in service.characteristics)
        {
            /* Read device name */
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:CBUUIDDeviceNameString]])
            {
                [aPeripheral readValueForCharacteristic:aChar];
                NSLog(@"Found a Device Name Characteristic");
            }
        }
    }

    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180A"]])
    {
        for (CBCharacteristic *aChar in service.characteristics)
        {
            /* Read manufacturer name */
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A29"]])
            {
                [aPeripheral readValueForCharacteristic:aChar];
                NSLog(@"Found a Device Manufacturer Name Characteristic");
            }
        }
    }

    for (CBCharacteristic *aChar in service.characteristics) {
        if ((aChar.properties & CBCharacteristicPropertyRead) == CBCharacteristicPropertyRead &&
            (aChar.properties & CBCharacteristicPropertyNotify) == CBCharacteristicPropertyNotify) {
            //NSLog(@"Subscribing to characteristic %@ of service %@", aChar.UUID, service.UUID);
            [peripheral setNotifyValue:YES forCharacteristic:aChar];
        }
    }
}

/*
 Invoked upon completion of a -[readValueForCharacteristic:] request or on the reception of a notification/indication.
 */
- (void) peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error: %@", error);
    }
    
    if( (characteristic.value) || !error ) {
        [self decodeGamepad:characteristic.value];
    }

}

-(void) decodeGamepad:(NSData*)input {
  const uint8_t *dataBuffer = [input bytes];
  unsigned long numBytes = [input length];

  if (numBytes == 20) {
    Byte b;

    b = dataBuffer[8];
    buttonMap.dpad_up    = (b & (1 << 0)) != 0;
    buttonMap.dpad_down  = (b & (1 << 1)) != 0;
    buttonMap.dpad_left  = (b & (1 << 2)) != 0;
    buttonMap.dpad_right = (b & (1 << 3)) != 0;

    buttonMap.a = (b & (1 << 4)) != 0;
    buttonMap.b = (b & (1 << 5)) != 0;
    buttonMap.x = (b & (1 << 6)) != 0;
    buttonMap.y = (b & (1 << 7)) != 0;

    b = dataBuffer[9];
      
    buttonMap.menu              = (b & (1 << 2)) != 0;
    buttonMap.bumper_left       = (b & (1 << 4)) != 0;
    buttonMap.bumper_right      = (b & (1 << 5)) != 0;

    buttonMap.trigger_left  = dataBuffer[10];
    buttonMap.trigger_right = dataBuffer[11];

    buttonMap.stick_right_x = dataBuffer[12];
    buttonMap.stick_right_y = dataBuffer[13];

    buttonMap.stick_left_x  = dataBuffer[14];
    buttonMap.stick_left_y  = dataBuffer[15];

    [delegate controllerDidUpdateData:buttonMap];
  }

}

@end
