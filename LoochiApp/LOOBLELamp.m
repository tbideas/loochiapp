//
//  LOOBLELamp.m
//  Illumi
//
//  Created by Thomas SARLANDIE on 10/3/12.
//
//

#import "LOOBLELamp.h"
#import "DDLog.h"

@interface LOOBLELamp ()

@property (strong) CBPeripheral *peripheral;
@property (strong) CBCharacteristic *rgbChar;
@property (assign) BOOL writeInProgress;
@property (strong) UIColor *nextWrite;

@end

@implementation LOOBLELamp

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

- (id) initWithPeripheral:(CBPeripheral*)connectedPeripheral
{
    self = [super init];
    if (self) {
        self.peripheral = connectedPeripheral;
        self.peripheral.delegate = self;
        
        // Services and characteristics should have been discovered before
        for (CBService *aService in self.peripheral.services) {
            if ([aService.UUID isEqual:[CBUUID UUIDWithString:LOOCHI_SERVICE_UUID]]) {
                for (CBCharacteristic *aChar in aService.characteristics) {
                    if ([aChar.UUID isEqual:[CBUUID UUIDWithString:LOOCHI_CHARACTERISTIC_RGB]]) {
                        self.rgbChar = aChar;
                    }
                }
            }
        }
        
        self.writeInProgress = NO;
        
        if (!self.rgbChar) {
            DDLogWarn(@"Unable to find RGB characteristic");
        }
    }
    return self;
}

- (void)performWrite:(UIColor*) color
{
    float fred, fgreen, fblue, falpha;
    uint8_t rgb[3];
    
    [color getRed:&fred green:&fgreen blue:&fblue alpha:&falpha];
    
    rgb[0] = fred * 255;
    rgb[1] = fgreen * 255;
    rgb[2] = fblue * 255;
    
    DDLogVerbose(@"Writing %x %x %x on BLE module", rgb[0], rgb[1], rgb[2]);
    [self.peripheral writeValue:[NSData dataWithBytes:rgb length:3] forCharacteristic:self.rgbChar type:CBCharacteristicWriteWithResponse];
    self.writeInProgress = YES;
}

- (void) setColor:(UIColor*) color
{
    /* 
     * We implement a very simple depth=1 buffer to avoid writing a new value until the previous one has been sent.
     */
    if (self.writeInProgress == NO) {
        DDLogVerbose(@"setColor immediate: %@", color);
        [self performWrite:color];
    }
    else {
        DDLogVerbose(@"setColor buffered: %@", color);
        self.nextWrite = color;
    }
}

#pragma mark CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    DDLogVerbose(@"Write ack.");
    self.writeInProgress = NO;
    if (self.nextWrite) {
        DDLogVerbose(@"De-buffering value");
        [self performWrite:self.nextWrite];
        self.nextWrite = nil;
    }
}

@end
