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
    UIColor *startColor, *endColor;
}

@end

@implementation ILFireScene

- (id) init
{
    self = [super init];
    if (self) {
        startColor = [UIColor redColor];
        endColor = [UIColor orangeColor];
    }
    return self;
}

- (NSString*) description
{
    return @"Fire scene";
}

- (NSTimeInterval) duration
{
    return 0.5;
}

- (UIColor*) colorForTime:(NSTimeInterval)timeInAnimation
{
    // Returns the interpolation of the two colors
    return [UIColor colorByInterpolatingFrom:startColor to:endColor at:timeInAnimation/[self duration]];
}

@end
