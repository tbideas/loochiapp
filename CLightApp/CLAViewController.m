//
//  CLAViewController.m
//  CLightApp
//
//  Created by Thomas SARLANDIE on 01/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CLAViewController.h"
#import "UIImageView+ColorPicker.h"
#import "CLATintedView.h"

@interface CLAViewController ()
{
    UIPopoverController *_popoverController;
    CLATintedView *_crosshairView;
}

@property (weak) IBOutlet UISlider *redSlider;
@property (weak) IBOutlet UISlider *greenSlider;
@property (weak) IBOutlet UISlider *blueSlider;
@property (weak) IBOutlet UIImageView *imageView;

@end

@implementation CLAViewController

@synthesize clight;
@synthesize lampSwitch;

@synthesize redSlider;
@synthesize greenSlider;
@synthesize blueSlider;
@synthesize imageView;

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title = clight.host;
}

-(void)viewDidLoad
{
    UIGestureRecognizer *gestureLongTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(imageLongTapped:)];
    [imageView addGestureRecognizer:gestureLongTap];

    UIGestureRecognizer *gestureSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(imageSwiped:)];
    [imageView addGestureRecognizer:gestureSwipe];
}

-(void)viewDidUnload
{
    [_crosshairView removeFromSuperview];
    _crosshairView = nil;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark Methods for UI elements

- (IBAction)toggleLamp:(id)sender
{
    [clight setLed:lampSwitch.on];
}

- (IBAction)rgbValueUpdated:(id)sender
{
    [clight setRed:self.redSlider.value
             green:self.greenSlider.value
              blue:self.blueSlider.value];
}

#pragma mark Gesture recognizers

-(void) imageLongTapped:(UIGestureRecognizer*) gestureRecognizer
{
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.allowsEditing = NO;
    imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:
                              UIImagePickerControllerSourceTypeSavedPhotosAlbum];

    imagePicker.delegate = self;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentModalViewController:imagePicker animated:YES];
    }
    else {
        // This should not really happen but you never know ...
        if (_popoverController != nil) {
            [_popoverController dismissPopoverAnimated:YES];
            _popoverController = nil;
        }
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        
        CGPoint touchPoint = [gestureRecognizer locationInView:imageView];
        CGRect popopOrigin = CGRectMake(touchPoint.x, touchPoint.y, 44, 44);
        
        [popover presentPopoverFromRect:popopOrigin inView:imageView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        _popoverController = popover;
    }
    
}

-(void)imageSwiped:(UIGestureRecognizer*) gestureRecognizer
{
    imageView.contentMode++;
    if (imageView.contentMode == UIViewContentModeRedraw) 
        imageView.contentMode = UIViewContentModeScaleToFill;
}

#pragma mark Touch event handlers

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_crosshairView == nil) {
        _crosshairView = [[CLATintedView alloc] initWithImage:[UIImage imageNamed:@"crosshair.png"]];
        _crosshairView.bounds = CGRectMake(0, 0, 50, 50);
        [self.imageView addSubview:_crosshairView];
    }
    UITouch *aTouch = [touches anyObject];
    CGPoint viewPoint = [aTouch locationInView:self.imageView];

    _crosshairView.hidden = NO;
    _crosshairView.center = viewPoint;
    _crosshairView.transform = CGAffineTransformMakeScale(1, 1);
    _crosshairView.alpha = 1;
    
    [UIView beginAnimations:@"crosshairAppears" context:nil];
    [UIView setAnimationDuration:0.2];
    
    CGAffineTransform transformScale = CGAffineTransformMakeScale(3, 3);    
    _crosshairView.transform = CGAffineTransformRotate(transformScale, M_PI * 3);
    
    [UIView commitAnimations];
    
    [self updateRgbWithColorAtPoint:viewPoint];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *aTouch = [touches anyObject];
    CGPoint viewPoint = [aTouch locationInView:self.imageView];
    
    _crosshairView.center = viewPoint;
    
    [self updateRgbWithColorAtPoint:viewPoint];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    _crosshairView.hidden = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{    
    [UIView animateWithDuration:0.5
                     animations:^{
                         _crosshairView.transform = CGAffineTransformMakeScale(0.1, 0.1);
                         _crosshairView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                     }
     ];
}

#pragma mark UIImagePickerControllerDelegate

- (void) imagePickerController: (UIImagePickerController *) picker didFinishPickingMediaWithInfo: (NSDictionary *) info
{
    UIImage *originalImage, *editedImage, *imageToUse;
    
    editedImage = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
    originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
        
    if (editedImage) {
        imageToUse = editedImage;
    } else {
        imageToUse = originalImage;
    }
    self.imageView.image = imageToUse;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self dismissModalViewControllerAnimated: YES];
    }
    else {
        [_popoverController dismissPopoverAnimated:YES];
        _popoverController = nil;
    }
}

#pragma mark Useful private functions

- (void)updateRgbWithColorAtPoint:(CGPoint) viewPoint
{
    UIColor *color = [self.imageView pixerlColorAtViewLocation:viewPoint];
    
    if (color) {
        float red, green, blue, alpha;
        if ([color getRed:&red green:&green blue:&blue alpha:&alpha]) {
            self.redSlider.value = red;
            self.greenSlider.value = green;
            self.blueSlider.value = blue;
            
            [self rgbValueUpdated:nil];
        }
        
        if (_crosshairView) {
            _crosshairView.tintColor = color;
        }
    }
}

@end
