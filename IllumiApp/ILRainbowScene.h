//
//  ILRainbowScene.h
//  Illumi
//
//  Created by Thomas SARLANDIE on 8/30/12.
//
//

#import "ILLightScene.h"

@interface ILRainbowScene : ILLightScene

- (id) initWithColors:(NSArray*) colors andDurationPerColor:(NSTimeInterval) duration
       andDescription:(NSString*) description andRepeat:(BOOL) repeat;

@end
