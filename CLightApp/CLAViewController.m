//
//  CLAViewController.m
//  CLightApp
//
//  Created by Thomas SARLANDIE on 01/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CLAViewController.h"

@interface CLAViewController ()

@property (weak) IBOutlet UISlider *redSlider;
@property (weak) IBOutlet UISlider *greenSlider;
@property (weak) IBOutlet UISlider *blueSlider;

@end

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
    [clight setLed:lampSwitch.on];
}

- (IBAction)rgbValueUpdated:(id)sender
{
    [clight setRed:self.redSlider.value
             green:self.greenSlider.value
              blue:self.blueSlider.value];
}

@end
