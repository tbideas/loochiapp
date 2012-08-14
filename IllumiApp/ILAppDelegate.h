//
//  CLAAppDelegate.h
//  CLightApp
//
//  Created by Thomas SARLANDIE on 01/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ILConnectionViewController.h"
#import "ILColorViewController.h"

@interface ILAppDelegate : UIResponder <UIApplicationDelegate, ILConnectionDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ILColorViewController *colorViewController;

@end
