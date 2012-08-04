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

@interface CLAViewController : UIViewController<UIImagePickerControllerDelegate, ILConnectionDelegate>

@property (nonatomic, retain) CLALight* clight;
@property (nonatomic, weak) IBOutlet UISwitch* lampSwitch;

- (IBAction)toggleLamp:(id)sender;

@end
