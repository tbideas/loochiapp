//
//  CLAViewController.h
//  CLightApp
//
//  Created by Thomas SARLANDIE on 01/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLALight.h"
#import "ILConnectionViewController.h"

@interface ILColorViewController : UIViewController<ILConnectionDelegate>

@property (nonatomic, retain) CLALight* clight;

-(IBAction)colorModeChanged:(id)sender;
-(IBAction)turnOffTheLight:(id)sender;

@end
