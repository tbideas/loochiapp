//
//  ILConnectionViewController.m
//  Illumi
//
//  Created by Thomas SARLANDIE on 03/08/12.
//
//

#import "ILConnectionViewController.h"
#import "CLAViewController.h"

@interface ILConnectionViewController ()
{
    CLAScanner *_scanner;
    CLALight *_foundLight;
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
    _foundLight = light;
    [self performSegueWithIdentifier:@"display-main" sender:self];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([@"display-main" isEqualToString:segue.identifier]) {
        CLAViewController *vc = (CLAViewController*)segue.destinationViewController;
        vc.clight = _foundLight;
    }
    else {
        NSLog(@"Should not happen. Unrecognized segue: %@", segue.identifier);
    }
}


@end
