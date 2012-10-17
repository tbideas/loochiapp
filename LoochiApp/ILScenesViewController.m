//
//  ILScenesViewController.m
//  Illumi
//
//  Created by Thomas SARLANDIE on 14/08/12.
//
//

#import "ILScenesViewController.h"
#import "ILFireScene.h"
#import "ILRainbowScene.h"
#import "UIColor+ILColor.h"
#import "DDLog.h"
#import "LOOMagicWand.h"

@interface ILScenesViewController ()

@property NSArray *scenes;
@property LOOMagicWand *magicWand;

@end

@implementation ILScenesViewController

static const int ddLogLevel = LOG_LEVEL_WARN;

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"low_contrast_linen.png"]]];
    self.scenesTablesView.backgroundView = nil; // needed on ipads
 
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
                           andDurationPerColor:1 andDescription:@"Rainbow" andImage:nil andRepeat:YES] ];
    [scenes addObject:
     [[ILRainbowScene alloc] initWithColors:@[
        [UIColor colorFromHexString:@"#000030"], // blue
        [UIColor colorFromHexString:@"#804000"], // orange
        [UIColor colorFromHexString:@"#808000"], // yellow
        [UIColor colorFromHexString:@"#FFFF33"] // white
      ] andDurationPerColor:30 andDescription:@"Sunrise"  andImage:nil andRepeat:NO]];

    [scenes addObject:
     [[ILRainbowScene alloc] initWithColors:@[
      [UIColor colorFromHexString:@"#FFFF33"],
      [UIColor colorFromHexString:@"#808000"], // yellow
      [UIColor colorFromHexString:@"#804000"], // orange
      [UIColor colorFromHexString:@"#000030"],
     ] andDurationPerColor:30 andDescription:@"Sunset" andImage:nil andRepeat:NO]];

    [scenes addObject:
     [[ILRainbowScene alloc] initWithColors:@[
      [UIColor colorFromHexString:@"#A06065"],
      [UIColor blueColor],
      [UIColor colorFromHexString:@"#A06065"],
      ] andDurationPerColor:10 andDescription:@"Love Scene" andImage:nil andRepeat:YES] ];

    [scenes addObject:
     [[ILRainbowScene alloc] initWithColors:@[
      [UIColor blackColor],
      [UIColor colorFromHexString:@"#0000FF"],
      [UIColor blackColor],
      ] andDurationPerColor:0.25 andDescription:@"Boris-Dance Blue!" andImage:nil andRepeat:YES] ];

    [scenes addObject:
     [[ILRainbowScene alloc] initWithColors:@[
      [UIColor blackColor],
      [UIColor colorFromHexString:@"#FF0000"],
      [UIColor blackColor],
      [UIColor blackColor],
      ] andDurationPerColor:0.1 andDescription:@"Boris-Dance Red!" andImage:nil andRepeat:YES] ];

    [scenes addObject:
     [[ILRainbowScene alloc] initWithColors:@[
      [UIColor blackColor],
      [UIColor colorFromHexString:@"#FFD033"],
      [UIColor blackColor],
      ] andDurationPerColor:0.15 andDescription:@"Boris-Dance White!" andImage:nil andRepeat:YES] ];

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
      ] andDurationPerColor:0.5 andDescription:@"Lighthouse" andImage:nil andRepeat:YES] ];

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
                        andDurationPerColor:0.2 andDescription:@"Crazy Colors" andImage:nil andRepeat:YES] ];

    self.scenes = scenes;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return YES;
    else
        if (interfaceOrientation == UIInterfaceOrientationPortrait)
            return YES;
        else
            return NO;
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.scenesTablesView reloadData];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self.magicWand dispellEnchantment];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DDLogVerbose(@"numberOfRowsInSection: Number of scenes: %i", [_scenes count]);
    return [_scenes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"sceneCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    LOOEnchantment *enchantment = [_scenes objectAtIndex:indexPath.row];
    cell.textLabel.text  = enchantment.description;
    
    if (self.magicWand.castedEnchantment == enchantment) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.magicWand) {
        self.magicWand = [[LOOMagicWand alloc] init];
    }
    
    LOOEnchantment *enchantment = [_scenes objectAtIndex:indexPath.row];
    [self.magicWand castEnchantment:enchantment onLamp:self.lamp];
    [tableView reloadData];
}

@end

