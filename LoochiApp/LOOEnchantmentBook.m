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
#import "LOOGradientColorEnchantment.h"
#import "LOOSequenceEnchantment.h"
#import "LOOStoryboardEnchantment.h"
#import "UIColor+ILColor.h"

@interface LOOEnchantmentBook ()

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
        DDLogWarn(@"Invalid spellbook content of type: %@ (%@)", [jsonObject class], error);
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
    
    NSArray *newEnchantments = [self createEnchantmentsFromJSonArray:spellBook[@"enchantments"]];
    DDLogVerbose(@"Read %i enchantments from enchantment book.", [newEnchantments count]);
    
    [self.enchantments addObjectsFromArray:newEnchantments];

    return YES;
}

- (NSArray*) createEnchantmentsFromJSonArray:(NSArray*) array
{
    NSMutableArray *newEnchantments = [[NSMutableArray alloc] initWithCapacity:[array count]];
    
    for (id item in array) {
        if ([item isKindOfClass:[NSDictionary class]]) {
            LOOEnchantment *e = [self createEnchantmentFromJSonDictionary:item];
            [newEnchantments addObject:e];
        }
        else {
            DDLogWarn(@"Found an item in enchantments that is not a dictionnary. (%@)", item);
        }
    }
    return newEnchantments;
}

- (LOOEnchantment*)createEnchantmentFromJSonDictionary:(NSDictionary*) dict
{
    LOOEnchantment *e;
    
    if ([dict[@"type"] isEqualToString:@"solid"]) {
        LOOSolidColorEnchantment *solid = [[LOOSolidColorEnchantment alloc] init];
        
        NSAssert(dict[@"color"], @"Missing required parameters color");

        solid.solidColor = [UIColor colorFromHexString:dict[@"color"]];
        e = solid;
    }
    else if ([dict[@"type"] isEqualToString:@"gradient"]) {
        LOOGradientColorEnchantment *gradient = [[LOOGradientColorEnchantment alloc] init];

        NSAssert(dict[@"startColor"] && dict[@"endColor"], @"Missing required parameters startColor and endColor");
        
        gradient.startColor = [UIColor colorFromHexString:dict[@"startColor"]];
        gradient.endColor = [UIColor colorFromHexString:dict[@"endColor"]];
        e = gradient;
    }
    else if ([dict[@"type"] isEqualToString:@"sequence"]) {
        LOOSequenceEnchantment *sequence = [[LOOSequenceEnchantment alloc] init];
        
        NSAssert(dict[@"sequence"], @"Missing required parameter sequence");
        
        if (dict[@"sequence"])
            sequence.enchantments = [self createEnchantmentsFromJSonArray:dict[@"sequence"]];
        e = sequence;
    }
    else if ([dict[@"type"] isEqualToString:@"storyboard"]) {
        LOOStoryboardEnchantment *storyboardEnchantment = [[LOOStoryboardEnchantment alloc] init];
        
        if (dict[@"segue-name"])
            storyboardEnchantment.segueName = dict[@"segue-name"];
        e = storyboardEnchantment;
    }
    else {
        NSAssert(false, @"Unknown enchantment type: %@", dict[@"type"]);
    }
    
    if (dict[@"name"])
        e.name = dict[@"name"];
    if (dict[@"image"])
        e.image = [UIImage imageNamed:dict[@"image"]];
    if (dict[@"duration"])
        e.duration = [dict[@"duration"] floatValue];
    if (dict[@"repeat"])
        e.repeat  = [dict[@"repeat"] boolValue];
    return e;
}

- (NSArray*)generateEnchantmentsJsonArray:(NSArray*) enchantments
{
    NSMutableArray *jsonArray = [[NSMutableArray alloc] initWithCapacity:[self.enchantments count]];
    
    for (LOOEnchantment *e in self.enchantments) {
        // We only support writing LOOGradientColorEnchantment for now
        if ([e isKindOfClass:[LOOGradientColorEnchantment class]]) {
            LOOGradientColorEnchantment *ge = (LOOGradientColorEnchantment*) e;
            NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
            d[@"type"] = @"gradient";
            d[@"duration"] = [NSNumber numberWithFloat:ge.duration];
            d[@"startColor"] = [ge.startColor colorInHexString];
            d[@"endColor"] = [ge.endColor colorInHexString];
            
            [jsonArray addObject:d];
        }
    }
    return jsonArray;
}

- (BOOL)writeEnchantmentsToFile:(NSString*)filePath
{
    NSMutableDictionary *jsonBook = [[NSMutableDictionary alloc] init];
    jsonBook[@"title"] = [NSString stringWithFormat:@"Saved enchantment on %@", [NSDate date]];
    jsonBook[@"author"] = [NSString stringWithFormat:@"%@ %@(%@)",
                           [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"],
                           [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"],
                           [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    jsonBook[@"enchantments"] = [self generateEnchantmentsJsonArray:self.enchantments];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonBook options:0 error:&error];
    if (jsonData == nil) {
        DDLogWarn(@"Unable to prepare json data: %@", error);
        return NO;
    }

    DDLogVerbose(@"Writing json data: %@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    [jsonData writeToFile:filePath atomically:YES];
    
    return YES;
}


@end
