//
//  LOOEnchantmentEditorViewController.m
//  Loochi
//
//  Created by Thomas SARLANDIE on 10/30/12.
//
//

#import "DDLog.h"
#import "LOOEnchantmentEditorViewController.h"
#import "LOOEnchantment.h"
#import "LOOSequenceEnchantment.h"
#import "LOOGradientColorEnchantment.h"
#import "LOOSolidColorEnchantment.h"
#import "LOOMagicWand.h"
#import "LOOEnchantmentDetailsEditorViewController.h"
#import "LOOEnchantmentBook.h"

@interface LOOEnchantmentEditorViewController ()

@property LOOSequenceEnchantment *sequenceEnchantment;
@property LOOMagicWand *magicWand;

@end

@implementation LOOEnchantmentEditorViewController

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

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

    LOOEnchantmentBook *book = [[LOOEnchantmentBook alloc] init];
    
    if ([book readEnchantmentsFromFile:[self pathOfSavedEnchantment]] && book.enchantments != nil) {
        self.enchantments = [[NSMutableArray alloc] initWithArray:book.enchantments];
    }
    else {
        self.enchantments = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"low_contrast_linen.png"]];
    self.enchantmentsTableView.backgroundColor = [UIColor clearColor];
    self.enchantmentsTableView.opaque = NO;
    self.enchantmentsTableView.backgroundView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    LOOEnchantmentBook *book = [[LOOEnchantmentBook alloc] init];
    book.enchantments = self.enchantments;
    [book writeEnchantmentsToFile:[self pathOfSavedEnchantment]];
}

- (NSString*)pathOfSavedEnchantment
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];

    NSString *filePath =  [libraryDirectory stringByAppendingPathComponent:@"animeditor.json"];
    return filePath;
}

#pragma mark IBActions

- (IBAction)doneButton:(id) sender
{
    // Stop any ongoing animation
    [self.magicWand dispellEnchantment];

    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addButton:(id) sender
{
    LOOGradientColorEnchantment *e = [[LOOGradientColorEnchantment alloc] init];
    
    if ([self.enchantments count] == 0) {
        e.startColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
        e.duration = 10;
    }
    else {
        LOOGradientColorEnchantment *lastEnchantment = (LOOGradientColorEnchantment*)[self.enchantments lastObject];
        e.startColor = lastEnchantment.endColor;
        e.duration = lastEnchantment.duration;
    }
    
    e.endColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    
    [self.enchantments addObject:e];
    [self.enchantmentsTableView reloadData];
}

- (IBAction)editButton:(id)sender
{
    if (self.enchantmentsTableView.editing) {
        [self.enchantmentsTableView setEditing:NO animated:YES];
    }
    else {
        [self.enchantmentsTableView setEditing:YES animated:YES];
    }
}

- (IBAction)playButton:(id)sender
{
    if (self.magicWand == nil)
        self.magicWand = [[LOOMagicWand alloc] init];
    if (self.sequenceEnchantment == nil)
        self.sequenceEnchantment = [[LOOSequenceEnchantment alloc] init];
    
    
    if (self.magicWand.castedEnchantment != nil) {
        DDLogVerbose(@"Canceling preview of enchantment");
        [self.magicWand dispellEnchantment];
    }
    else {
        DDLogVerbose(@"Starting preview of enchantment");
        self.sequenceEnchantment.enchantments = self.enchantments;
        [self.magicWand castEnchantment:self.sequenceEnchantment onLamp:self.lamp];
    }
}

- (IBAction)shareButton:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share this animation"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Share on Loochi.com", @"Share by email", nil];
    [actionSheet showFromBarButtonItem:sender animated:YES];
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.enchantments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"enchantment"];
    
    UIImageView *enchantmentImageView = (UIImageView*)[cell viewWithTag:1];
    
    LOOEnchantment *e = (LOOEnchantment*)self.enchantments[indexPath.row];
    
    if ([e isKindOfClass:[LOOSolidColorEnchantment class]]) {
        LOOSolidColorEnchantment *solidEnchantment = (LOOSolidColorEnchantment*)e;
        enchantmentImageView.image = nil;
        enchantmentImageView.backgroundColor = solidEnchantment.solidColor;
    }
    else if ([e isKindOfClass:[LOOGradientColorEnchantment class]]) {
        LOOGradientColorEnchantment *gradientEnchantment = (LOOGradientColorEnchantment*)e;

        enchantmentImageView.backgroundColor = nil;
        enchantmentImageView.image = [self gradientImageWithColorA:gradientEnchantment.startColor
                                                         andColorB:gradientEnchantment.endColor
                                                         andBounds:enchantmentImageView.bounds];
    }
    
    return cell;
}

- (UIImage*) gradientImageWithColorA:(UIColor*) colorA andColorB:(UIColor*) colorB andBounds:(CGRect) bounds
{
    bounds = CGRectMake(0, 0, 100, 20);
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
    {
        UIGraphicsBeginImageContextWithOptions(bounds.size, NO, [UIScreen mainScreen].scale);
    }
    else
        UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGGradientRef gradient;
    CGColorSpaceRef colorspace;
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8];
    
    [colorA getRed:&(components[0]) green:&(components[1]) blue:&(components[2]) alpha:&(components[3])];
    [colorB getRed:&(components[4]) green:&(components[5]) blue:&(components[6]) alpha:&(components[7])];
    
    colorspace = CGColorSpaceCreateDeviceRGB();
    gradient = CGGradientCreateWithColorComponents(colorspace, components, locations, num_locations);
    
    CGPoint startPoint = CGPointMake(CGRectGetMinX(bounds), CGRectGetMidY(bounds));
    CGPoint endPoint = CGPointMake(CGRectGetMaxX(bounds), CGRectGetMidY(bounds));
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    
    UIImage *gradientImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return gradientImage;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.enchantments removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"pick-color" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Stop any ongoing animation
    [self.magicWand dispellEnchantment];
    
    if ([segue.identifier isEqualToString:@"pick-color"]) {
        LOOEnchantmentDetailsEditorViewController *colorPickerViewController = segue.destinationViewController;
        colorPickerViewController.enchantment = self.enchantments[self.enchantmentsTableView.indexPathForSelectedRow.row];
        colorPickerViewController.delegate = self;
        colorPickerViewController.lamp = self.lamp;
    }
}

#pragma LOOEnchantmentDetailsEditorDelegate

- (void)enchantmentDetailsUpdated:(LOOGradientColorEnchantment*) gradientColorEnchantment
{
    DDLogVerbose(@"Enchantment details updated: startColor=%@ endColor=%@ duration=%f", gradientColorEnchantment.startColor, gradientColorEnchantment.endColor, gradientColorEnchantment.duration);
    self.enchantments[self.enchantmentsTableView.indexPathForSelectedRow.row] = gradientColorEnchantment;
    [self.enchantmentsTableView reloadData];
}

@end
