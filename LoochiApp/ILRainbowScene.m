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

@property NSString *name;
@property UIImage *image;
@property NSTimeInterval durationPerColor;
@property NSArray *colors;
@property (readwrite) BOOL repeat;
@property (readwrite) NSInteger frequency;

@end

@implementation ILRainbowScene

// Have to synthesize the property I override.
@synthesize name;
@synthesize repeat;
@synthesize image;
@synthesize frequency;

- (id) init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (id) initWithColors:(NSArray*) colors andDurationPerColor:(NSTimeInterval) duration
       andDescription:(NSString*) aDescription andImage:(UIImage*) anImage andRepeat:(BOOL) aRepeat
{   self = [super init];
    if (self) {
        _colors = colors;
        _durationPerColor = duration;
        name = aDescription;
        image = anImage;
        repeat = aRepeat;
        frequency = 30;
    }
    return self;
}

- (NSTimeInterval) duration
{
    return _durationPerColor * ([_colors count] - 1);
}

- (UIColor*) colorForTime:(NSTimeInterval)timeInAnimation
{
    UIColor *prevColor = [_colors objectAtIndex:floor(timeInAnimation / _durationPerColor)];
    
    int nextIndex = ceil(timeInAnimation / _durationPerColor);
    // Loop around when we reach the end
    if (nextIndex >= [_colors count]) {
        nextIndex = 0;
    }
    UIColor *nextColor = [_colors objectAtIndex:nextIndex];
        
    float position = fmod(timeInAnimation, _durationPerColor) / _durationPerColor;
    return [UIColor colorByInterpolatingFrom:prevColor to:nextColor at:position];
}

@end
