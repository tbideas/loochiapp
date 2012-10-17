//
//  LOOEnchantmentsViewController.m
//  Illumi
//
//  Created by Thomas SARLANDIE on 10/5/12.
//
//

#import "DDLog.h"
#import "LOOEnchantmentsViewController.h"
#import "LOOMagicWand.h"
#import "LOOSolidColorEnchantment.h"
#import "ILFireScene.h"
#import "ILRainbowScene.h"
#import "UIColor+ILColor.h"

@interface LOOEnchantmentsViewController ()

@property (strong) NSArray *enchantments;
@property (strong) LOOMagicWand *magicWand;
@end

@implementation LOOEnchantmentsViewController

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

- (void)viewDidLoad {
    if (!self.enchantments) {
        self.enchantments = [self createSceneEnchantments];
    }

    if (!self.magicWand) {
        self.magicWand = [[LOOMagicWand alloc] init];
    }
}

#pragma mark UICollectionViewDatasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    // _data is a class member variable that contains one array per section.
    return 1;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.enchantments count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"enchantmentView"
                                                                                 forIndexPath:indexPath];
    
    LOOEnchantment *enchantment = (LOOEnchantment*) self.enchantments[indexPath.row];
    
    UILabel *label = (UILabel*) [cell viewWithTag:1];
    UIImageView *imageView = (UIImageView*) [cell viewWithTag:2];
    
    label.text = enchantment.description;
    imageView.image = enchantment.image;
    
    return cell;
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    LOOEnchantment *enchantment = (LOOEnchantment*) self.enchantments[indexPath.row];
    
    [self.magicWand castEnchantment:enchantment onLamp:self.lamp];
}

#pragma mark Where we cook the enchantments

- (NSArray*) createSceneEnchantments {
    NSMutableArray *scenes = [[NSMutableArray alloc] initWithCapacity:10];
    
    [scenes addObject:[[ILFireScene alloc] init]];
    [scenes addObject:
     [[ILRainbowScene alloc] initWithColors:@[
      [UIColor blackColor],
      [UIColor redColor],
      [UIColor orangeColor],
      [UIColor yellowColor],
      [UIColor greenColor],
      [UIColor blueColor],
      [UIColor colorWithRed:(float)0x4B/0xFF green:0x00/0xFF blue:(float)0x82/0xFF alpha:1],
      [UIColor purpleColor],
      [UIColor blackColor]
      ]
                        andDurationPerColor:1 andDescription:@"Rainbow" andImage:[UIImage imageNamed:@"rainbow.png"] andRepeat:YES] ];
    [scenes addObject:
     [[ILRainbowScene alloc] initWithColors:@[
      [UIColor colorFromHexString:@"#000030"], // blue
      [UIColor colorFromHexString:@"#804000"], // orange
      [UIColor colorFromHexString:@"#808000"], // yellow
      [UIColor colorFromHexString:@"#FFFF33"] // white
      ] andDurationPerColor:30 andDescription:@"Sunrise"  andImage:[UIImage imageNamed:@"sunrise.png"] andRepeat:NO]];
    
    [scenes addObject:
     [[ILRainbowScene alloc] initWithColors:@[
      [UIColor colorFromHexString:@"#FFFF33"],
      [UIColor colorFromHexString:@"#808000"], // yellow
      [UIColor colorFromHexString:@"#804000"], // orange
      [UIColor colorFromHexString:@"#000030"],
      ] andDurationPerColor:30 andDescription:@"Sunset" andImage:[UIImage imageNamed:@"sunset.png"] andRepeat:NO]];
    
    [scenes addObject:
     [[ILRainbowScene alloc] initWithColors:@[
      [UIColor colorFromHexString:@"#A06065"],
      [UIColor blueColor],
      [UIColor colorFromHexString:@"#A06065"],
      ] andDurationPerColor:10 andDescription:@"Love Scene" andImage:[UIImage imageNamed:@"lovescene.png"] andRepeat:YES] ];
    
    [scenes addObject:
     [[ILRainbowScene alloc] initWithColors:@[
      [UIColor blackColor],
      [UIColor colorFromHexString:@"#0000FF"],
      [UIColor blackColor],
      ] andDurationPerColor:0.25 andDescription:@"Boris-Dance Blue!" andImage:[UIImage imageNamed:@"boris-dance-blue.png"] andRepeat:YES] ];
    
    [scenes addObject:
     [[ILRainbowScene alloc] initWithColors:@[
      [UIColor blackColor],
      [UIColor colorFromHexString:@"#FF0000"],
      [UIColor blackColor],
      [UIColor blackColor],
      ] andDurationPerColor:0.1 andDescription:@"Boris-Dance Red!" andImage:[UIImage imageNamed:@"boris-dance-red.png"] andRepeat:YES] ];
    
    [scenes addObject:
     [[ILRainbowScene alloc] initWithColors:@[
      [UIColor blackColor],
      [UIColor colorFromHexString:@"#FFD033"],
      [UIColor blackColor],
      ] andDurationPerColor:0.15 andDescription:@"Boris-Dance White!" andImage:[UIImage imageNamed:@"boris-dance-white.png"] andRepeat:YES] ];
    
    [scenes addObject:
     [[ILRainbowScene alloc] initWithColors:@[
      [UIColor colorFromHexString:@"#000010"], // blue
      [UIColor colorFromHexString:@"#000010"], // blue
      [UIColor colorFromHexString:@"#000010"], // blue
      [UIColor colorFromHexString:@"#000010"], // blue
      [UIColor colorFromHexString:@"#000010"], // blue
      [UIColor colorFromHexString:@"#000010"], // blue
      [UIColor colorFromHexString:@"#000010"], // blue
      [UIColor colorFromHexString:@"#C0C000"], // blue
      [UIColor colorFromHexString:@"#000010"], // blue
      ]
                        andDurationPerColor:0.5
                             andDescription:@"Lighthouse"
                                   andImage:[UIImage imageNamed:@"lighthouse.png"]
                                  andRepeat:YES] ];
    
    [scenes addObject:
     [[ILRainbowScene alloc] initWithColors:@[
      [UIColor redColor],
      [UIColor blueColor],
      [UIColor yellowColor],
      [UIColor purpleColor],
      [UIColor orangeColor],
      [UIColor colorWithRed:(float)0x4B/0xFF green:0x00/0xFF blue:(float)0x82/0xFF alpha:1],
      [UIColor greenColor],
      [UIColor redColor]
      ]
                        andDurationPerColor:0.2
                             andDescription:@"Crazy Colors"
                                   andImage:[UIImage imageNamed:@"crazycolors.png"]
                                  andRepeat:YES] ];
    
    [scenes addObject:
     [[LOOSolidColorEnchantment alloc] initWithColor:[UIColor blackColor]
                                      andDescription:@"Off"
                                            andImage:[UIImage imageNamed:@"off.png"]]];
    
    return scenes;
}
@end
