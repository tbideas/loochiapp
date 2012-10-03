//
//  CLAViewController.h
//  CLightApp
//
//  Created by Thomas SARLANDIE on 01/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LOOLamp.h"
#import "LOOLightClient.h"

@interface ILColorViewController : UIViewController<LOOLightClient>

@property (nonatomic, retain) LOOLamp* lamp;

-(IBAction)turnOffTheLight:(id)sender;

@end
