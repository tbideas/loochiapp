//
//  CLAAppDelegate.m
//  CLightApp
//
//  Created by Thomas SARLANDIE on 01/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

#import "LOOAppDelegate.h"
#import "TestFlight.h"

#import "DDASLLogger.h"
#import "DDTTYLogger.h"

#import "LOOLightClient.h"

/* This is to avoid a warning when calling uniqueIdentifier for TestFlight */
@protocol UIDeviceHack <NSObject>

- (NSString*) uniqueIdentifier;

@end

@interface LOOAppDelegate () <CBCentralManagerDelegate>

@property BOOL animateConnectionViewApperance;
@property CBCentralManager *cbManager;
@property LOOConnectionViewController *connectionViewController;

@end

@implementation LOOAppDelegate

@synthesize window = _window;

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

-(id)init
{
    self = [super init];
    
    if (self)
    {
        // When the app is started, we do not want the animation - we want a
        // smooth transition from the splash screen to the connectionVC
        _animateConnectionViewApperance = NO;
    }
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    DDLogInfo(@"didFinishLaunchingWithOptions");

    [TestFlight takeOff:@"e8642e72fc14638e855c49593d0bb606_MTE5NzQzMjAxMi0wOC0wOSAxNjo1OTowMy43MTMwNjI"];
#ifdef DEBUG
    // This is disabled in production (forbidden APIs) - Used here to improve beta reporting.
    [TestFlight setDeviceIdentifier:[(id<UIDeviceHack>)[UIDevice currentDevice] uniqueIdentifier]];
#endif
    [TestFlight passCheckpoint:@"LAUNCH"];

    if (!self.cbManager) {
        self.cbManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    DDLogInfo(@"applicationDidBecomeActive");
    
    // Display the connection window until we are sure to have a connection
    UIStoryboard *storyboard;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        storyboard = [UIStoryboard storyboardWithName:@"LargeStoryboard" bundle:nil];
    else
        storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
    if (self.connectionViewController == nil) {
        self.connectionViewController =
        (LOOConnectionViewController*) [storyboard instantiateViewControllerWithIdentifier:@"connectionViewController"];
        self.connectionViewController.delegate = self;
        self.connectionViewController.cbCentralManager = self.cbManager;
    }
    [self.window.rootViewController presentModalViewController:self.connectionViewController
                                                      animated:_animateConnectionViewApperance];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    DDLogInfo(@"applicationWillResignActive");
    
    // If the connection window is still there - dismiss it
    // It will be re-created when becoming active again
    // We do this to make sure that the associated network sockets are closed on resign
    // and restarted on becomeActive.
    
    if (self.window.rootViewController.modalViewController != nil) {
        [self.window.rootViewController dismissModalViewControllerAnimated:NO];

        // Do not animate because we want the user to think it stayed there.
        _animateConnectionViewApperance = NO;
    }
    else {
        // Animate the view next time we start
        _animateConnectionViewApperance = YES;
    }
    
    // Get rid of existing connection
    [self setLampOnViewControllers:nil];
}

#pragma mark ILConnectionDelegate

- (void) selectedLamp:(LOOLamp *)lamp
{
    [TestFlight passCheckpoint:@"CONNECTED"];

    [self setLampOnViewControllers:lamp];
    
    [self.window.rootViewController dismissModalViewControllerAnimated:YES];
}

-(void)setLampOnViewControllers:(LOOLamp*)lamp
{
    if ([self.window.rootViewController isKindOfClass:[UITabBarController class]])
    {
        UITabBarController *tabBarController = (UITabBarController*)self.window.rootViewController;
        for (UIViewController *vc in tabBarController.viewControllers)
        {
            if ([vc conformsToProtocol:@protocol(LOOLightClient)]) {
                id<LOOLightClient> lampVC = (id<LOOLightClient>)vc;

                [lampVC setLamp:lamp];
            }
        }
    }
}

#pragma mark default stuff

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    DDLogInfo(@"applicationDidEnterBackground");
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    DDLogInfo(@"applicationWillEnterForeground");
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    DDLogInfo(@"applicationWillTerminate");
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    [self.connectionViewController centralManagerDidUpdateState:central];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    [self.connectionViewController centralManager:central didDiscoverPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [self.connectionViewController centralManager:central didConnectPeripheral:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self.connectionViewController centralManager:central didDisconnectPeripheral:peripheral error:error];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    DDLogVerbose(@"AppDelegate: didFailToConnectPeripheral (%@)", error);
}

- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
    DDLogVerbose(@"AppDelegate: didRetrieveConnectedPeripherals");
}

- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    DDLogVerbose(@"AppDelegate: didRetrievePeripherals");
}

@end
