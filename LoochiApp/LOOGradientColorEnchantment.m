//
//  LOOGradientColorEnchantment.m
//  Loochi
//
//  Created by Thomas SARLANDIE on 10/17/12.
//
//

#import "LOOGradientColorEnchantment.h"
#import "UIColor+ILColor.h"

@implementation LOOGradientColorEnchantment

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (UIColor*) colorForTime:(NSTimeInterval)timeInAnimation
{
    return [UIColor colorByInterpolatingFrom:self.startColor to:self.endColor at:timeInAnimation / self.duration];
}

@end
