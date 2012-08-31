//
//  ILRainbowScene.m
//  Illumi
//
//  Created by Thomas SARLANDIE on 8/30/12.
//
//

#import "ILRainbowScene.h"
#import "UIColor+ILColor.h"

@interface ILRainbowScene ()

@property NSArray *colors;

@end

@implementation ILRainbowScene

#define TIME_PER_COLOR 1

- (id) init
{
    self = [super init];
    if (self) {
        _colors = @[ [UIColor blackColor], [UIColor redColor], [UIColor orangeColor],
                    [UIColor yellowColor], [UIColor greenColor], [UIColor blueColor],
                    [UIColor colorWithRed:(float)0x4B/0xFF green:0x00/0xFF blue:(float)0x82/0xFF alpha:1],
                    [UIColor purpleColor]];
    }
    return self;
}

- (NSString*) description
{
    return @"Rainbow";
}

- (NSTimeInterval) duration
{
    return TIME_PER_COLOR * [_colors count];
}

- (UIColor*) colorForTime:(NSTimeInterval)timeInAnimation
{
    UIColor *prevColor = [_colors objectAtIndex:floor(timeInAnimation / TIME_PER_COLOR)];
    
    int nextIndex = ceil(timeInAnimation / TIME_PER_COLOR);
    // Loop around when we reach the end
    if (nextIndex >= [_colors count]) {
        nextIndex = 0;
    }
    UIColor *nextColor = [_colors objectAtIndex:nextIndex];
    
    NSLog(@"PrevColor=%@ NextColor=%@", prevColor, nextColor);
    return [UIColor colorByInterpolatingFrom:prevColor to:nextColor at:timeInAnimation - floor(timeInAnimation)];
}

@end
