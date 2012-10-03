//
//  ILConnectionViewController.m
//  Illumi
//
//  Created by Thomas SARLANDIE on 03/08/12.
//
//

#import "LOOConnectionViewController.h"
#import "TestFlight.h"
#import "LOOUDPScanner.h"

@interface LOOConnectionViewController ()
{
    LOOUDPScanner *_scanner;
}

@end

@implementation LOOConnectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _scanner = [[LOOUDPScanner alloc] init];
    _scanner.delegate = self;
    [_scanner startScanning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [_scanner stopScanning];
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


#pragma mark CLAScannerDelegate

-(void) newLampDetected:(LOOLamp *)light
{
    self.selectedLamp = light;

    [self.delegate selectedIllumi:self.selectedLamp];
}

-(IBAction)useADemoIllumi:(id)sender
{
    [TestFlight passCheckpoint:@"DEMO"];

    [self.delegate selectedIllumi:nil];
}

@end
