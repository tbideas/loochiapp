//
//  UIColor+ILColor.m
//  Illumi
//
//  Created by Thomas SARLANDIE on 15/08/12.
//
//

#import "UIColor+ILColor.h"

@implementation UIColor (ILColor)

- (NSString *)colorInHexString
{
    CGFloat red, green, blue, alpha;
    [self getRed:&red green:&green blue:&blue alpha:&alpha];
    
    return [NSString stringWithFormat:@"#%02X%02X%02X", (int)(red * 255), (int)(green * 255), (int)(blue * 255)];
}

+ (UIColor*) colorByInterpolatingFrom:(UIColor*) colorA to:(UIColor*) colorB at:(float)position
{
    CGFloat redA, greenA, blueA;
    CGFloat redB, greenB, blueB;
    CGFloat alpha;
    
    [colorA getRed:&redA green:&greenA blue:&blueA alpha:&alpha];
    [colorB getRed:&redB green:&greenB blue:&blueB alpha:&alpha];
    
    CGFloat red, green, blue;
    
    red = redA * (1 - position) + redB * position;
    green = greenA * (1 - position) + greenB * position;
    blue = blueA * (1 - position) + blueB * position;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

// http://stackoverflow.com/questions/1560081/how-can-i-create-a-uicolor-from-a-hex-string
// Assumes input like "#00FF00" (#RRGGBB).
+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
