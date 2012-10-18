//
//  LOOSequenceEnchantment.m
//  Loochi
//
//  Created by Thomas SARLANDIE on 10/17/12.
//
//

#import "LOOSequenceEnchantment.h"

@implementation LOOSequenceEnchantment

- (id)init
{
    self = [super init];
    if (self) {
        self.repeat = NO;
    }
    return self;
}

- (NSTimeInterval)duration
{
    NSTimeInterval totalDuration = 0;
    for (LOOEnchantment *e in self.enchantments) {
        totalDuration += e.duration;
    }
    return totalDuration;
}

- (UIColor*) colorForTime:(NSTimeInterval)timeInAnimation
{
    NSAssert(self.enchantments && [self.enchantments count] > 0, @"Need at least one enchantment in a sequence.");
    
    LOOEnchantment *currentEnchantment;
    NSTimeInterval pastAnimationsTime = 0;
    for (LOOEnchantment* e in self.enchantments) {
        currentEnchantment = e;
        
        if (timeInAnimation < pastAnimationsTime + e.duration)
            break;
        else
            pastAnimationsTime += e.duration;
    }
    return [currentEnchantment colorForTime:timeInAnimation - pastAnimationsTime];
}

@end
