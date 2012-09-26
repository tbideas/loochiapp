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

@interface ILScenesViewController ()
{
    NSTimer *sceneTimer;
    NSDate *sceneStart;
    ILLightScene *currentScene;
}

@property NSArray *scenes;

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
                           andDurationPerColor:1 andDescription:@"Rainbow" andRepeat:YES] ];
    [scenes addObject:
     [[ILRainbowScene alloc] initWithColors:@[
        [UIColor colorFromHexString:@"#000030"], // blue
        [UIColor colorFromHexString:@"#804000"], // orange
        [UIColor colorFromHexString:@"#808000"], // yellow
        [UIColor colorFromHexString:@"#FFFF33"] // white
      ] andDurationPerColor:30 andDescription:@"Sunrise"  andRepeat:NO]];

    [scenes addObject:
     [[ILRainbowScene alloc] initWithColors:@[
      [UIColor colorFromHexString:@"#FFFF33"],
      [UIColor colorFromHexString:@"#808000"], // yellow
      [UIColor colorFromHexString:@"#804000"], // orange
      [UIColor colorFromHexString:@"#000030"],
     ] andDurationPerColor:30 andDescription:@"Sunset" andRepeat:NO]];

    [scenes addObject:
     [[ILRainbowScene alloc] initWithColors:@[
      [UIColor colorFromHexString:@"#A06065"],
      [UIColor blueColor],
      [UIColor colorFromHexString:@"#A06065"],
      ] andDurationPerColor:10 andDescription:@"Love Scene" andRepeat:YES] ];

    [scenes addObject:
     [[ILRainbowScene alloc] initWithColors:@[
      [UIColor blackColor],
      [UIColor colorFromHexString:@"#0000FF"],
      [UIColor blackColor],
      ] andDurationPerColor:0.25 andDescription:@"Boris-Dance Blue!" andRepeat:YES] ];

    [scenes addObject:
     [[ILRainbowScene alloc] initWithColors:@[
      [UIColor blackColor],
      [UIColor colorFromHexString:@"#FF0000"],
      [UIColor blackColor],
      [UIColor blackColor],
      ] andDurationPerColor:0.1 andDescription:@"Boris-Dance Red!" andRepeat:YES] ];

    [scenes addObject:
     [[ILRainbowScene alloc] initWithColors:@[
      [UIColor blackColor],
      [UIColor colorFromHexString:@"#FFD033"],
      [UIColor blackColor],
      ] andDurationPerColor:0.15 andDescription:@"Boris-Dance White!" andRepeat:YES] ];

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
      ] andDurationPerColor:0.5 andDescription:@"Lighthouse" andRepeat:YES] ];

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
                        andDurationPerColor:0.2 andDescription:@"Crazy Colors" andRepeat:YES] ];

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
    [self stopScene];
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

    ILLightScene *scene = [_scenes objectAtIndex:indexPath.row];
    cell.textLabel.text  = scene.description;
    
    if (scene == currentScene) {
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
    ILLightScene *scene = [_scenes objectAtIndex:indexPath.row];
    [self startScene:scene];
    [tableView reloadData];
}

#pragma mark - Animation functions

- (void) startScene:(ILLightScene*) scene
{
    if (sceneTimer != nil) {
        [sceneTimer invalidate];
        sceneTimer = nil;
    }
    
    currentScene = scene;
    sceneTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(animateScene) userInfo:nil repeats:YES];
    sceneStart = [NSDate date];
    DDLogVerbose(@"Starting scene: %@", scene.description);
}

- (void) animateScene
{
    NSTimeInterval scenePosition = [[NSDate date] timeIntervalSinceDate:sceneStart];
    if (scenePosition >= currentScene.duration) {
        if (currentScene.repeat) {
            // If we have reached the end - re-set the beginning date correctly
            sceneStart = [NSDate dateWithTimeInterval:currentScene.duration - scenePosition sinceDate:[NSDate date]];
            
            scenePosition = [[NSDate date] timeIntervalSinceDate:sceneStart];

            DDLogVerbose(@"Looping animation. start=%f position=%f", [sceneStart timeIntervalSinceReferenceDate], scenePosition);
        }
        else {
            [sceneTimer invalidate];
            sceneTimer = nil;
            currentScene = nil;
            return;
        }
    }

    UIColor *nowColor = [currentScene colorForTime:scenePosition];
    
    float red, green, blue;
    [nowColor getRed:&red green:&green blue:&blue alpha:nil];
    DDLogVerbose(@"Effect '%@' Pos=%2.2f %.2f/%.2f/%.2f", currentScene.description, scenePosition, red, green, blue);
    [self.lamp setColor:nowColor];
    [self.colorView setBackgroundColor:nowColor];
}

- (void) stopScene
{
    [sceneTimer invalidate];
    sceneTimer = nil;
    [self.lamp setColor:[UIColor blackColor]];
    currentScene = nil;
}

@end

