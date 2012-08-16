//
//  ILFireScene.m
//  Illumi
//
//  Created by Thomas SARLANDIE on 14/08/12.
//
//

#import "ILFireScene.h"

@interface ILFireScene ()

@end

@implementation ILFireScene

- (id) init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (NSString*) description
{
    return @"Fire scene";
}

- (NSTimeInterval) duration
{
    return 10.0;
}

- (UIColor*) colorForTime:(NSTimeInterval)timeInAnimation
{
    float red, green, blue;
    
    red = 0.8;
    green = 0.2 + 2/3 * fabs(random() * 1.0 / LONG_MAX);
    blue = 1/5 * fabs(random() * 1.0 / LONG_MAX);
    
    float alpha = fabs(random() * 1.0 / LONG_MAX);
    red *= alpha;
    green *= alpha;
    blue *= alpha;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

@end
