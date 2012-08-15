//
//  CLAAppDelegate.m
//  CLightApp
//
//  Created by Thomas SARLANDIE on 01/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ILAppDelegate.h"
#import "TestFlight.h"

#import "DDASLLogger.h"
#import "DDTTYLogger.h"

#import "ILLightClient.h"

/* This is to avoid a warning when calling uniqueIdentifier for TestFlight */
@protocol UIDeviceHack <NSObject>

- (NSString*) uniqueIdentifier;

@end

@interface ILAppDelegate ()

@end

@implementation ILAppDelegate

@synthesize window = _window;

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    DDLogError(@"Starting the app!");

    [TestFlight takeOff:@"e8642e72fc14638e855c49593d0bb606_MTE5NzQzMjAxMi0wOC0wOSAxNjo1OTowMy43MTMwNjI"];
#ifdef DEBUG
    // This is disabled in production (forbidden APIs) - Used here to improve beta reporting.
    [TestFlight setDeviceIdentifier:[(id<UIDeviceHack>)[UIDevice currentDevice] uniqueIdentifier]];
#endif
    
    // FIXME
    // I have to create the window manually and the initial View Controller by
    // hand - otherwise the modal view does not appear for some weird reasons...
    UIViewController *mainViewController = self.window.rootViewController;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    self.window.rootViewController = mainViewController;

    // Create and show the connection window
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    ILConnectionViewController *cvc = (ILConnectionViewController*) [storyboard instantiateViewControllerWithIdentifier:@"connectionViewController"];
    cvc.delegate = self;
    [self.window.rootViewController presentModalViewController:cvc animated:NO];

    [TestFlight passCheckpoint:@"LAUNCH"];

    return YES;
}

#pragma mark ILConnectionDelegate

- (void) selectedIllumi:(CLALight *)illumi
{
    [TestFlight passCheckpoint:@"CONNECTED"];

    if ([self.window.rootViewController isKindOfClass:[UITabBarController class]])
    {
        UITabBarController *tabBarController = (UITabBarController*)self.window.rootViewController;
        for (UIViewController *vc in tabBarController.viewControllers)
        {
            if ([vc conformsToProtocol:@protocol(ILLightClient)]) {
                id<ILLightClient> lampVC = (id<ILLightClient>)vc;
                [lampVC setLamp:illumi];
            }
        }
    }
    [self.window.rootViewController dismissModalViewControllerAnimated:YES];
}

#pragma mark default stuff

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
