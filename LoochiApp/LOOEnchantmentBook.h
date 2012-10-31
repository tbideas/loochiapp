//
//  LOOSpellBook.h
//  Loochi
//
//  Created by Thomas SARLANDIE on 10/17/12.
//
//

#import <Foundation/Foundation.h>
#import "LOOEnchantment.h"

@interface LOOEnchantmentBook : NSObject

@property (strong) NSMutableArray *enchantments;

- (BOOL)readEnchantmentsFromFile:(NSString*)filePath;
- (BOOL)writeEnchantmentsToFile:(NSString*)filePath;

@end
