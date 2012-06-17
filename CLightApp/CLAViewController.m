//
//  CLAViewController.m
//  CLightApp
//
//  Created by Thomas SARLANDIE on 01/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CLAViewController.h"

@implementation CLAViewController

@synthesize clight;
@synthesize lampSwitch;

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title = clight.host;
    lampSwitch.on = NO;
}

#pragma mark Methods for UI elements

- (IBAction)toggleLamp:(id)sender
{
    if (lampSwitch.on) {
        [clight sendCommand:@"LEDON"];
    }
    else {
        [clight sendCommand:@"LEDOFF"];
    }
}

@end
