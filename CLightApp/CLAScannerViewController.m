//
//  CLAScannerViewController.m
//  CLightApp
//
//  Created by Thomas SARLANDIE on 16/06/12.
//
//

#import "CLAScannerViewController.h"
#import "CLAScanner.h"
#import "CLAViewController.h"

@interface CLAScannerViewController ()
{
    CLAScanner *_scanner;
    NSMutableArray *_lights;
}

@property (weak) IBOutlet UITableView *tableView;
@property (weak) IBOutlet UISwitch *scanningSwitch;

@end

@implementation CLAScannerViewController

@synthesize tableView;
@synthesize scanningSwitch;

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _lights = [NSMutableArray array];
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated
{
    if (!self.scanningSwitch.on) {
        [self.scanningSwitch setOn:YES animated:animated];
        [self updateScanningSwitch:self.scanningSwitch];
    }
}

-(IBAction)updateScanningSwitch:(id)sender
{
    if (_scanner == nil) {
        _scanner = [[CLAScanner alloc] init];
        _scanner.delegate = self;
    }
    
    if (scanningSwitch.on) {
        [_scanner startScanning];
    }
    else {
        [_scanner stopScanning];
    }
}

-(void) newClightDetected:(CLALight *)light
{
    [_lights addObject:light];
    [self.tableView reloadData];
    NSLog(@"Added one light. Number of lights: %i", _lights.count);
}

#pragma UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _lights.count;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"clightCell"];
    
    CLALight *l = [_lights objectAtIndex:indexPath.row];
    cell.textLabel.text = l.host;

    return cell;
}

#pragma UIViewController

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([@"switch" isEqualToString:segue.identifier]) {
        CLAViewController *vc = (CLAViewController*)segue.destinationViewController;
        
        vc.clight = [_lights objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    }
    else {
        NSLog(@"Should not happen. Unrecognized segue: %@", segue.identifier);
    }
}

@end
