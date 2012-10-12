//
//  ILRainbowScene.h
//  Illumi
//
//  Created by Thomas SARLANDIE on 8/30/12.
//
//

#import "LOOEnchantment.h"

@interface ILRainbowScene : LOOEnchantment

- (id) initWithColors:(NSArray*) colors andDurationPerColor:(NSTimeInterval) duration
       andDescription:(NSString*) aDescription andImage:(UIImage*) anImage andRepeat:(BOOL) aRepeat;

@end
