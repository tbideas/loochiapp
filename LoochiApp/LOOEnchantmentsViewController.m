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
#import "ILFireScene.h"
#import "LOOEnchantmentBook.h"
#import "UIColor+ILColor.h"
#import "LOOStoryboardEnchantment.h"


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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id targetViewController = segue.destinationViewController;
    
    if ([targetViewController isKindOfClass:[UINavigationController class]])
        targetViewController = ((UINavigationController*)targetViewController).topViewController;
    
    if ([targetViewController respondsToSelector:@selector(setLamp:)]) {
        [targetViewController setLamp:self.lamp];
    }
}

#pragma mark UICollectionViewDatasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
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
    
    label.text = enchantment.name;
    imageView.image = enchantment.image;
    
    return cell;
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    LOOEnchantment *enchantment = (LOOEnchantment*) self.enchantments[indexPath.row];
    
    if ([enchantment isKindOfClass:[LOOStoryboardEnchantment class]]) {
        [self.magicWand dispellEnchantment];
        LOOStoryboardEnchantment *storyboardEnchantment = (LOOStoryboardEnchantment*) enchantment;
        [self performSegueWithIdentifier:storyboardEnchantment.segueName sender:nil];
    }
    else {
        [self.magicWand castEnchantment:enchantment onLamp:self.lamp];
    }
}

#pragma mark Where we cook the enchantments

- (NSArray*) createSceneEnchantments {
    NSMutableArray *scenes = [[NSMutableArray alloc] initWithCapacity:10];
    
    LOOEnchantmentBook *book = [[LOOEnchantmentBook alloc] init];
    [book readEnchantmentsFromFile:[[NSBundle mainBundle] pathForResource:@"enchantments" ofType:@"json"]];
    [scenes addObjectsFromArray:book.enchantments];

    [scenes addObject:[[ILFireScene alloc] init]];
    
    return scenes;
}

@end
