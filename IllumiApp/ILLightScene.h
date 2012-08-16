//
//  ILLightAnimation.h
//  Illumi
//
//  Created by Thomas SARLANDIE on 14/08/12.
//
//

#import <Foundation/Foundation.h>

@interface ILLightScene : NSObject

@property (readonly) NSString *description;
@property (readonly) NSTimeInterval duration;

- (UIColor*) colorForTime:(NSTimeInterval)timeInAnimation;

@end
