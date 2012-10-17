//
//  LOOMagicWand.h
//  Loochi
//
//  Created by Thomas SARLANDIE on 10/16/12.
//
//

#import <Foundation/Foundation.h>
#import "LOOEnchantment.h"
#import "LOOLamp.h"

@interface LOOMagicWand : NSObject

@property (strong, readonly) LOOEnchantment *castedEnchantment;
@property (strong, readonly) LOOLamp *enchantedLamp;

- (void)castEnchantment:(LOOEnchantment*)enchantment onLamp:(LOOLamp*) lamp;
- (void)dispellEnchantment;

@end
