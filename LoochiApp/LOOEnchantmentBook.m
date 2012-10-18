//
//  LOOSpellBook.m
//  Loochi
//
//  Created by Thomas SARLANDIE on 10/17/12.
//
//  A spell book contains a list of enchantments.

#import "LOOEnchantmentBook.h"
#import "DDLog.h"
#import "LOOEnchantment.h"
#import "LOOSolidColorEnchantment.h"
#import "UIColor+ILColor.h"

@interface LOOEnchantmentBook ()

@property (strong, readwrite) NSMutableArray *enchantments;

@end

@implementation LOOEnchantmentBook

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

- (id) init
{
    self = [super init];
    if (self) {
        self.enchantments = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

/* 
 * Reads a list of spells from a JSon file and adds them to the current spellbook.
 *
 * Returns YES if the data parsed was valid or no otherwise.
 */
- (BOOL)readEnchantmentsFromFile:(NSString*)filePath
{
    NSError *error;
    NSData *fileContent = [NSData dataWithContentsOfFile:filePath options:0 error:&error];

    if (fileContent == nil) {
        DDLogWarn(@"Unable to read content of file: %@ (%@)", filePath, error);
        return NO;
    }
    
    id jsonObject = [NSJSONSerialization JSONObjectWithData:fileContent options:0 error:&error];

    if (jsonObject == nil || ![jsonObject isKindOfClass:[NSDictionary class]]) {
        DDLogWarn(@"Invalid spellbook content of type: %@", [jsonObject class]);
        return NO;
    }

    return [self readEnchantmentsFromDictionary:jsonObject];
}

- (BOOL)readEnchantmentsFromDictionary:(NSDictionary*) spellBook
{
    if (spellBook[@"enchantments"] == nil || ![spellBook[@"enchantments"] isKindOfClass:[NSArray class]]) {
        DDLogWarn(@"No enchantments in enchantment book.");
        return NO;
    }
    int readEnchantments = 0;
    NSArray *newEnchantments = spellBook[@"enchantments"];
    for (id item in newEnchantments) {
        if ([item isKindOfClass:[NSDictionary class]]) {
            LOOEnchantment *e = [self createEnchantmentFromJSonDictionary:item];
            [(NSMutableArray*)self.enchantments addObject:e];
            readEnchantments++;
        }
        else {
            DDLogWarn(@"Found an item in enchantments that is not a dictionnary. (%@)", item);
        }
    }
    DDLogVerbose(@"Read %i enchantments from enchantment book.", readEnchantments);
    return YES;
}

- (LOOEnchantment*)createEnchantmentFromJSonDictionary:(NSDictionary*) dict
{
    LOOEnchantment *e;
    
    if ([dict[@"type"] isEqualToString:@"solid"]) {
        e = [[LOOSolidColorEnchantment alloc] initWithColor:[UIColor colorFromHexString:dict[@"color"]]
                                             andDescription:dict[@"name"]
                                                   andImage:[UIImage imageNamed:dict[@"image"]]];
    }
    
    return e;
}

@end
