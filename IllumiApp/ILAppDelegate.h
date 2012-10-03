//
//  CLAAppDelegate.h
//  CLightApp
//
//  Created by Thomas SARLANDIE on 01/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LOOConnectionViewController.h"
#import "ILColorViewController.h"

@interface ILAppDelegate : UIResponder <UIApplicationDelegate, LOOConnectionDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
