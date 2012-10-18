//
//  ILLightAnimation.h
//  Illumi
//
//  Created by Thomas SARLANDIE on 14/08/12.
//
//

#import <Foundation/Foundation.h>

@interface LOOEnchantment : NSObject

@property (strong) NSString *name;
@property (strong) UIImage *image;
@property (assign) NSTimeInterval duration;
@property (assign) NSInteger frequency;
@property (assign) BOOL repeat;

- (UIColor*) colorForTime:(NSTimeInterval)timeInAnimation;

@end
