//
//  ILConnectionViewController.m
//  Illumi
//
//  Created by Thomas SARLANDIE on 03/08/12.
//
//

#import "ILConnectionViewController.h"
#import "TestFlight.h"

@interface ILConnectionViewController ()
{
    CLAScanner *_scanner;
}

@end

@implementation ILConnectionViewController

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
    
    _scanner = [[CLAScanner alloc] init];
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

-(void) newClightDetected:(CLALight*)light
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
