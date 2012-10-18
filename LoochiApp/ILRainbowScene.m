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

@property NSTimeInterval durationPerColor;
@property NSArray *colors;

@end

@implementation ILRainbowScene

- (id) init
{
    self = [super init];
    if (self) {
        self.frequency = 30;
    }
    return self;
}

- (id) initWithColors:(NSArray*) colors andDurationPerColor:(NSTimeInterval) duration
       andDescription:(NSString*) aDescription andImage:(UIImage*) anImage andRepeat:(BOOL) aRepeat
{   self = [self init];
    if (self) {
        _colors = colors;
        _durationPerColor = duration;
        self.name = aDescription;
        self.image = anImage;
        self.repeat = aRepeat;
        self.duration = _durationPerColor * ([_colors count] - 1);
    }
    return self;
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
