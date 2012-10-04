//
//  ILConnectionViewController.m
//  Illumi
//
//  Created by Thomas SARLANDIE on 03/08/12.
//
//

#import "LOOConnectionViewController.h"
#import "TestFlight.h"
#import "LOOUDPScanner.h"
#import "LOOBLELamp.h"
#import "LOOAppDelegate.h"
#import "DDLog.h"

@interface LOOConnectionViewController ()

@property (strong) LOOUDPScanner *udpScanner;
@property (strong) CBPeripheral *connectingPeripheral;

@end

@implementation LOOConnectionViewController

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.udpScanner = [[LOOUDPScanner alloc] init];
    self.udpScanner.delegate = self;
    [self.udpScanner startScanning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self.udpScanner stopScanning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return YES;
    else
        if (interfaceOrientation == UIInterfaceOrientationPortrait)
            return YES;
        else
            return NO;
}


-(IBAction)useADemoIllumi:(id)sender
{
    [TestFlight passCheckpoint:@"DEMO"];

    [self.delegate selectedLamp:nil];
}

#pragma mark LOOUDPScannerDelegate

-(void) newLampDetected:(LOOUDPLamp *)udpLamp
{
    [self.delegate selectedLamp:udpLamp];
}

#pragma mark CBCentralManagerDelegate

/* Please note that LOOConnectionViewController is not the delegate of our CBCentralManager
 * just getting events forwarded from LOOAppDelegate when active.
 */

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBCentralManagerStatePoweredOn) {
        DDLogVerbose(@"CBCentralManager powered on");
        
        [central scanForPeripheralsWithServices:@[ [CBUUID UUIDWithString:LOOCHI_SERVICE_UUID] ] options:nil];
    }
    else if (central.state == CBCentralManagerStatePoweredOff) {
        DDLogVerbose(@"CBCentralManager powered off");
    }
    else {
        DDLogVerbose(@"CBCentralManager state: %i", central.state);
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    DDLogVerbose(@"Discovered peripheral: %@ advertisement %@ RSSI: %@", [peripheral description], [advertisementData description], [RSSI description]);

    DDLogVerbose(@"Connecting to peripheral...");
    [central connectPeripheral:peripheral options:nil];
    // we need to retain the peripheral we are connecting too.
    self.connectingPeripheral = peripheral;
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    DDLogVerbose(@"DidConnectToPeripheral");
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}

#pragma mark CBPeripheralDelegate

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    DDLogVerbose(@"DidDiscoverServices");
    for (CBService* aService in peripheral.services) {
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:LOOCHI_SERVICE_UUID]]) {
            [peripheral discoverCharacteristics:nil forService:aService];
        }
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    DDLogVerbose(@"DidDiscoverCharacteristics");
    
    // Now that we have explored the device, we can create the object
    LOOBLELamp *bleLamp = [[LOOBLELamp alloc] initWithPeripheral:peripheral];
    [self.delegate selectedLamp:bleLamp];
    
    // we can release the peripheral, it will be retained by the bleLamp while used.
    self.connectingPeripheral = nil;
}

@end
