//
//  ILConnectionViewController.m
//  Illumi
//
//  Created by Thomas SARLANDIE on 03/08/12.
//
//

#import "ILConnectionViewController.h"

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
        _scanner = [[CLAScanner alloc] init];
        _scanner.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"low_contrast_linen.png"]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark CLAScannerDelegate

-(void) newClightDetected:(CLALight*)light
{
    [self performSegueWithIdentifier:@"display-main" sender:self];
}

@end
