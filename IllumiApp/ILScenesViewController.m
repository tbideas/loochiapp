//
//  ILScenesViewController.m
//  Illumi
//
//  Created by Thomas SARLANDIE on 14/08/12.
//
//

#import "ILScenesViewController.h"
#import "ILFireScene.h"
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

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scenes = @[ [[ILFireScene alloc] init] ];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ILLightScene *scene = [_scenes objectAtIndex:indexPath.row];
    [self startScene:scene];
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
    if (scenePosition > currentScene.duration) {
        // If we have reached the end - re-set the beginning date correctly
        sceneStart = [NSDate dateWithTimeInterval:currentScene.duration - scenePosition sinceDate:[NSDate date]];
        
        scenePosition = [[NSDate date] timeIntervalSinceDate:sceneStart];

        DDLogVerbose(@"Looping animation. start=%f position=%f", [sceneStart timeIntervalSinceReferenceDate], scenePosition);
    }

    UIColor *nowColor = [currentScene colorForTime:scenePosition];
    
    float red, green, blue;
    [nowColor getRed:&red green:&green blue:&blue alpha:nil];
    DDLogVerbose(@"Effect '%@' Pos=%2.2f %.2f/%.2f/%.2f", currentScene.description, scenePosition, red, green, blue);
    [self.lamp setRed:red green:green blue:blue];
}

- (void) stopScene
{
    [sceneTimer invalidate];
    sceneTimer = nil;
    [self.lamp setColor:[UIColor blackColor]];
}

@end

