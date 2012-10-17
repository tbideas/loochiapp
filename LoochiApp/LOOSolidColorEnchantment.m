//
//  LOOSolidColorEnchantment.m
//  Loochi
//
//  Created by Thomas SARLANDIE on 10/16/12.
//
//

#import "LOOSolidColorEnchantment.h"

@interface LOOSolidColorEnchantment ()

@property (strong) NSString *description;
@property (strong) UIImage *image;
@property (assign) NSTimeInterval duration;
@property (assign) BOOL repeat;
@property (assign) NSInteger frequency;

@end

@implementation LOOSolidColorEnchantment

@synthesize description, image, duration, repeat, frequency;

- (id)initWithColor:(UIColor*) color andDescription:(NSString*) aDescription andImage:(UIImage*) anImage;
{
    self = [super init];
    if (self) {
        self.solidColor = color;
        self.description = aDescription;
        self.image = anImage;
        self.repeat = YES;
        self.duration = 1.0;
        self.frequency = 1;
    }
    return self;
}

- (UIColor*) colorForTime:(NSTimeInterval)timeInAnimation
{
    return self.solidColor;
}

@end
