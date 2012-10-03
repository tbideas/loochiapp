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
#import "LOOAppDelegate.h"
#import "DDLog.h"

@interface LOOConnectionViewController ()
{
    LOOUDPScanner *_scanner;
}

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
    
    _scanner = [[LOOUDPScanner alloc] init];
    _scanner.delegate = self;
    [_scanner startScanning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [_scanner stopScanning];
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

    [self.delegate selectedIllumi:nil];
}

#pragma mark LOOUDPScannerDelegate

-(void) newLampDetected:(LOOLamp *)light
{
    self.selectedLamp = light;
    
    [self.delegate selectedIllumi:self.selectedLamp];
}

#pragma mark CBCentralManagerDelegate

/* Please note that LOOConnectionViewController is not the delegate of our CBCentralManager
 * just getting events forwarded from LOOAppDelegate when active.
 */

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBCentralManagerStatePoweredOn) {
        DDLogVerbose(@"CBCentralManager powered on");
        
        [central scanForPeripheralsWithServices:nil options:nil];
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
}

@end
