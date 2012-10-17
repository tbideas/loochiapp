//
//  LOOBLELamp.h
//  Illumi
//
//  Created by Thomas SARLANDIE on 10/3/12.
//
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "LOOLamp.h"

#define LOOCHI_SERVICE_UUID @"4FC10E26-F94A-480F-B1AF-6A2E299B7BF8"
#define LOOCHI_CHARACTERISTIC_RGB @"BB4800AD-7F0C-4A59-8176-3316EBB236A7"

@interface LOOBLELamp : LOOLamp<CBPeripheralDelegate>

- (id) initWithPeripheral:(CBPeripheral*)connectedPeripheral;

@end
