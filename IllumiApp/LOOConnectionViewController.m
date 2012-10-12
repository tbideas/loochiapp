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

@property          BOOL             scanning;
@property (strong) LOOUDPScanner    *udpScanner;
@property (strong) CBPeripheral     *connectingPeripheral;

@end

@implementation LOOConnectionViewController

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.scanning = NO;
    }
    return self;
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

- (void) viewDidAppear:(BOOL)animated
{
    [self startScanning];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [self stopScanning];
}

-(IBAction)useADemoIllumi:(id)sender
{
    [TestFlight passCheckpoint:@"DEMO"];

    [self.delegate selectedLamp:nil];
}

#pragma mark Start/Stop scanning

-(void) startScanning
{
    self.scanning = YES;
    
    DDLogVerbose(@"Start scanning... self.cbCentralManager=%@ state=%i", self.cbCentralManager, self.cbCentralManager.state);
#ifdef LOOCHI_UDP_SUPPORT
    self.udpScanner = [[LOOUDPScanner alloc] init];
    self.udpScanner.delegate = self;
    [self.udpScanner startScanning];
#endif
    
#ifdef LOOCHI_BLE_SUPPORT
    if (self.cbCentralManager.state == CBCentralManagerStatePoweredOn) {
        [self performBLEScan:self.cbCentralManager];
    }
#endif
}

-(void) performBLEScan:(CBCentralManager*)central
{
    DDLogVerbose(@"Starting scan with central=%@", central);
    [central scanForPeripheralsWithServices:@[ [CBUUID UUIDWithString:LOOCHI_SERVICE_UUID] ] options:nil];
    
    if (self.connectingPeripheral != nil) {
        DDLogVerbose(@"Trying to reconnect to %@", self.connectingPeripheral);
        // If we were pre-connected to something, let's try reconnecting to it. This happens when opening/closing the app for example.
        [central connectPeripheral:self.connectingPeripheral options:nil];
    }
}

-(void) stopScanning
{
    self.scanning = NO;
    
    DDLogVerbose(@"Stop scanning...");
#ifdef LOOCHI_UDP_SUPPORT
    [self.udpScanner stopScanning];
#endif
    
#ifdef LOOCHI_BLE_SUPPORT
    [self.cbCentralManager stopScan];
#endif
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
        
        if (self.scanning) {
            [self performBLEScan:central];
        }
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

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    DDLogVerbose(@"AppDelegate: didDisconnectPeripheral (%@)", error);
    DDLogVerbose(@"Trying to reconnect ...");
    [central connectPeripheral:peripheral options:nil];
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
}

@end
