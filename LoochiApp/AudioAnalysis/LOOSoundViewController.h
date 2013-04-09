//
//  LOOSoundViewController.h
//  Illumi
//
//  Created by Thomas SARLANDIE on 8/30/12.
//
//

#import <AudioUnit/AudioUnit.h>
#import <AudioToolbox/AudioServices.h>
#import <UIKit/UIKit.h>
#import "LOOEnchantmentsViewController.h"

#ifndef CLAMP
#define CLAMP(min,x,max) (x < min ? min : (x > max ? max : x))
#endif

@interface LOOSoundViewController : UIViewController<LOOLightClient>
{
    AudioUnit					rioUnit;
}

@property (strong) LOOLamp *lamp;

@property (strong) IBOutlet UISlider *slider1;
@property (strong) IBOutlet UISlider *slider2;
@property (strong) IBOutlet UISlider *slider3;
@property (strong) IBOutlet UISlider *slider4;
@property (strong) IBOutlet UISlider *slider5;
@property (strong) IBOutlet UISlider *slider6;


@end
