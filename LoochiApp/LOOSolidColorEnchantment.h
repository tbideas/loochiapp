//
//  LOOSolidColorEnchantment.h
//  Loochi
//
//  Created by Thomas SARLANDIE on 10/16/12.
//
//

#import "LOOEnchantment.h"

@interface LOOSolidColorEnchantment : LOOEnchantment

@property UIColor *solidColor;

- (id)initWithColor:(UIColor*) color andDescription:(NSString*) aDescription andImage:(UIImage*) anImage;

@end
