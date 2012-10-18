//
//  LOOSpellBook.h
//  Loochi
//
//  Created by Thomas SARLANDIE on 10/17/12.
//
//

#import <Foundation/Foundation.h>

@interface LOOEnchantmentBook : NSObject

@property (strong, readonly) NSMutableArray *enchantments;

- (BOOL)readEnchantmentsFromFile:(NSString*)filePath;

@end
