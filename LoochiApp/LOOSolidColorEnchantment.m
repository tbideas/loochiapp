//
//  LOOSolidColorEnchantment.m
//  Loochi
//
//  Created by Thomas SARLANDIE on 10/16/12.
//
//

#import "LOOSolidColorEnchantment.h"

@implementation LOOSolidColorEnchantment

- (id)init
{
    self = [super init];
    if (self) {
        self.repeat = YES;
        self.duration = 1.0;
        self.frequency = 1;
    }
    return self;
}

- (id)initWithColor:(UIColor*) color andDescription:(NSString*) aDescription andImage:(UIImage*) anImage;
{
    self = [self init];
    if (self) {
        self.solidColor = color;
        self.name = aDescription;
        self.image = anImage;
    }
    return self;
}

- (UIColor*) colorForTime:(NSTimeInterval)timeInAnimation
{
    return self.solidColor;
}

@end
