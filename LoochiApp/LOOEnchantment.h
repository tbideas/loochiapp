//
//  ILLightAnimation.h
//  Illumi
//
//  Created by Thomas SARLANDIE on 14/08/12.
//
//

#import <Foundation/Foundation.h>

@interface LOOEnchantment : NSObject

@property (readonly) NSString *name;
@property (readonly) UIImage *image;
@property (readonly) NSTimeInterval duration;
@property (readonly) NSInteger frequency;
@property (readonly) BOOL repeat;

- (UIColor*) colorForTime:(NSTimeInterval)timeInAnimation;

@end
