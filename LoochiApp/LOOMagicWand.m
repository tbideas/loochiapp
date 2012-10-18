//
//  LOOMagicWand.m
//  Loochi
//
//  Created by Thomas SARLANDIE on 10/16/12.
//
//  A Magic Wand is what you use to cast an Enchantment on a Lamp ;)

#import "DDLog.h"
#import "LOOMagicWand.h"

#define MAGIC_WAND_FREQUENCY 30

@interface LOOMagicWand ()

@property (strong) LOOEnchantment *castedEnchantment;
@property (strong) LOOLamp *enchantedLamp;
@property (strong) NSTimer *spellTimer;
@property (strong) NSDate *castTime;

@end

@implementation LOOMagicWand

static const int ddLogLevel = LOG_LEVEL_WARN;

- (void)castEnchantment:(LOOEnchantment*)enchantment onLamp:(LOOLamp*) lamp
{
    DDLogVerbose(@"Casting enchantment: %@ on lamp: %@", enchantment, lamp);

    if (self.spellTimer != nil) {
        [self.spellTimer invalidate];
        self.spellTimer = nil;
    }
    
    self.castedEnchantment = enchantment;
    self.enchantedLamp = lamp;
    
    self.spellTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 /* /self.castedEnchantment.frequency*/
                                                       target:self
                                                     selector:@selector(spellMove)
                                                     userInfo:nil
                                                      repeats:YES];
    self.castTime = [NSDate date];
}

- (void)dispellEnchantment
{
    [self.spellTimer invalidate];
    self.spellTimer = nil;
    self.castedEnchantment = nil;

    [self.enchantedLamp setColor:[UIColor blackColor]];
    self.enchantedLamp = nil;
}

- (void)spellMove
{
    NSTimeInterval timeInSpell = [[NSDate date] timeIntervalSinceDate:self.castTime];
    if (timeInSpell >= self.castedEnchantment.duration) {
        if (self.castedEnchantment.repeat) {
            // If we have reached the end - re-set the beginning date correctly
            self.castTime = [NSDate dateWithTimeInterval:self.castedEnchantment.duration - timeInSpell sinceDate:[NSDate date]];
            
            timeInSpell = [[NSDate date] timeIntervalSinceDate:self.castTime];
            
            DDLogVerbose(@"Looping spell. start=%f position=%f", [self.castTime timeIntervalSinceReferenceDate], timeInSpell);
        }
        else {
            [self dispellEnchantment];
        }
    }
    
    UIColor *nowColor = [self.castedEnchantment colorForTime:timeInSpell];
    
    float red, green, blue;
    [nowColor getRed:&red green:&green blue:&blue alpha:nil];
    DDLogVerbose(@"Effect '%@' Pos=%2.2f %.2f/%.2f/%.2f", self.castedEnchantment.name, timeInSpell, red, green, blue);
    [self.enchantedLamp setColor:nowColor];
}

@end
