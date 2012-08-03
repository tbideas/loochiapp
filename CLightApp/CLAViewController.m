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
    CLATintedView *_crosshairView2;
    
    UITouch *_firstTouch, *_secondTouch;
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
    
    _crosshairView = [[CLATintedView alloc] initWithImage:[UIImage imageNamed:@"crosshair.png"]];
    _crosshairView.bounds = CGRectMake(0, 0, 50, 50);
    _crosshairView.alpha = 0;
    [self.imageView addSubview:_crosshairView];
    
    _crosshairView2 = [[CLATintedView alloc] initWithImage:[UIImage imageNamed:@"crosshair.png"]];
    _crosshairView2.bounds = CGRectMake(0, 0, 50, 50);
    _crosshairView2.alpha = 0;
    [self.imageView addSubview:_crosshairView2];
}

-(void)viewDidUnload
{
    [_crosshairView removeFromSuperview];
    _crosshairView = nil;

    [_crosshairView2 removeFromSuperview];
    _crosshairView2 = nil;
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
    for (UITouch *t in touches) {
        CGPoint viewPoint = [t locationInView:self.imageView];
        // If we dont already have a touch - then the first one will be the ... the firstTouch
        if (_firstTouch == nil) {
            NSLog(@"First touch started");
            _firstTouch = t;
            
            [self beginShowingCrossHairView:_crosshairView atPoint:viewPoint primary:YES];
            [self updateSlidersToCrossHairView:_crosshairView];
        }
        // If we do already have one touch, then the second one will be the secondTouch
        else if (_secondTouch == nil) {
            NSLog(@"And YES! we found a second beginning touch!");
            _secondTouch = t;
            
            [self beginShowingCrossHairView:_crosshairView2 atPoint:viewPoint primary:NO];
        }
        else {
            NSLog(@"Another touch has begun. We wont track this one.");
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *t in touches) {
        CGPoint viewPoint = [t locationInView:self.imageView];
        if (t == _firstTouch) {
            NSLog(@"First touch has moved");
            
            [self updateCrossHairView:_crosshairView toPoint:viewPoint];
            [self updateSlidersToCrossHairView:_crosshairView];
        }
        else if (t == _secondTouch) {
            NSLog(@"Second touch has moved");
            
            [self updateCrossHairView:_crosshairView2 toPoint:viewPoint];
        }
        else {
            NSLog(@"Another (non-tracked) touch has moved");
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *t in touches) {
        if (t == _firstTouch) {
            NSLog(@"Cancelled first touch");
            _firstTouch = nil;
            [self dismissCrossHairView:_crosshairView];
        }
        else if (t == _secondTouch) {
            NSLog(@"Cancelled second touch");
            _secondTouch = nil;
            [self dismissCrossHairView:_crosshairView2];
        }
        else {
            NSLog(@"Cancelled another non-tracked touch");
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{    
    for (UITouch *t in touches) {
        if (t == _firstTouch) {
            NSLog(@"Ended first touch");
            _firstTouch = nil;
            [self dismissCrossHairView:_crosshairView];
        }
        else if (t == _secondTouch) {
            NSLog(@"Ended second touch");
            _secondTouch = nil;
            [self dismissCrossHairView:_crosshairView2];
            
            // If the user drops the second touch after the first one, then
            // we animate from the first one to the second one.
            if (_firstTouch == nil) {
                NSLog(@"Let's party!");
                
            }
        }
        else {
            NSLog(@"Ended another non-tracked touch");
        }
    }
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

#pragma mark Useful functions to manipulate the crosshairs

- (void) beginShowingCrossHairView:(CLATintedView*) crossHairView atPoint:(CGPoint) viewPoint primary:(BOOL)primary
{
    crossHairView.hidden = NO;
    crossHairView.center = viewPoint;
    crossHairView.transform = CGAffineTransformMakeScale(1, 1);
    crossHairView.alpha = 1;
    
    UIColor *color = [self.imageView pixerlColorAtViewLocation:viewPoint];
    if (color) {
        crossHairView.tintColor = color;
    }
    // User has clicked out of the image.
    else {
        crossHairView.tintColor = [UIColor blackColor];
    }

    [UIView beginAnimations:@"crosshairAppears" context:nil];
    [UIView setAnimationDuration:0.2];
    
    CGAffineTransform transformScale;
    if (primary) {
        transformScale = CGAffineTransformMakeScale(3, 3);
    }
    else {
        transformScale = CGAffineTransformMakeScale(2, 2);
    }
    
    crossHairView.transform = CGAffineTransformRotate(transformScale, M_PI * 3);
    
    [UIView commitAnimations];
}

- (void)updateCrossHairView:(CLATintedView*) crossHairView toPoint:(CGPoint) viewPoint
{
    crossHairView.center = viewPoint;

    UIColor *color = [self.imageView pixerlColorAtViewLocation:viewPoint];
    
    if (color) {
        crossHairView.tintColor = color;
    }
}

-(void)dismissCrossHairView:(CLATintedView*)crossHairView
{
    [UIView animateWithDuration:0.5
                     animations:^{
                         crossHairView.transform = CGAffineTransformMakeScale(0.1, 0.1);
                         crossHairView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                     }
     ];

}

-(void)updateSlidersToCrossHairView:(CLATintedView*)crossHairView
{
    float red, green, blue, alpha;
    if ([crossHairView.tintColor getRed:&red green:&green blue:&blue alpha:&alpha]) {
        self.redSlider.value = red;
        self.greenSlider.value = green;
        self.blueSlider.value = blue;
        
        [self rgbValueUpdated:nil];
    }    
}

@end
