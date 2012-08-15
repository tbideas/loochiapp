//
//  CLAViewController.h
//  CLightApp
//
//  Created by Thomas SARLANDIE on 01/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLALight.h"
#import "ILLightClient.h"

@interface ILColorViewController : UIViewController<ILLightClient>

@property (nonatomic, retain) CLALight* clight;

-(IBAction)turnOffTheLight:(id)sender;

@end
