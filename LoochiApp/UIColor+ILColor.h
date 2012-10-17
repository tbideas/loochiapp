//
//  UIColor+ILColor.h
//  Illumi
//
//  Created by Thomas SARLANDIE on 15/08/12.
//
//

#import <UIKit/UIKit.h>

@interface UIColor (ILColor)

+ (UIColor*) colorByInterpolatingFrom:(UIColor*) colorA to:(UIColor*) colorB at:(float)position;
+ (UIColor *)colorFromHexString:(NSString *)hexString;

@end
