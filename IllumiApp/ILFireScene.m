//
//  ILFireScene.m
//  Illumi
//
//  Created by Thomas SARLANDIE on 14/08/12.
//
//

#import "ILFireScene.h"
#import "UIColor+ILColor.h"

@interface ILFireScene ()
{
    UIColor *baseColor, *brightColor;
    float brightness;
}

@end

@implementation ILFireScene

static const int ddLogLevel = LOG_LEVEL_WARN;

- (id) init
{
    self = [super init];
    if (self) {
        baseColor = [UIColor colorWithRed:(float)0xFF/0xFF green:(float)0x00/0xFF blue:(float)0x00/0xFF alpha:1];
        brightColor = [UIColor colorWithRed:(float)0xFF/0xFF green:(float)0x8A/0xFF blue:(float)0x00/0xFF alpha:1];
        brightness = 0;
    }
    return self;
}

- (NSString*) description
{
    return @"Fire scene";
}

- (NSTimeInterval) duration
{
    // does not matter here
    return 42;
}

#define ARC4RANDOM_MAX      0x100000000
#define RANDF() ((double)arc4random() / ARC4RANDOM_MAX)

- (UIColor*) colorForTime:(NSTimeInterval)timeInAnimation
{
    // Sometimes the fire goes brighter
    float alea = RANDF();
    if (alea > 0.98) {
        brightness = MIN(1, brightness + RANDF() / 4);
        DDLogVerbose(@"Fire boost! brightness now %.3f (alea = %.4f)", brightness, alea);
    }
    // The fire always diminishes
    brightness = MAX(0, brightness - brightness*brightness / 50);
    
    DDLogVerbose(@"Brightness is %.3f", brightness);
    // Returns the interpolation of the two colors
    return [UIColor colorByInterpolatingFrom:baseColor to:brightColor at:brightness];
}

@end
