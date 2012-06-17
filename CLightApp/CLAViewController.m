//
//  CLAViewController.m
//  CLightApp
//
//  Created by Thomas SARLANDIE on 01/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CLAViewController.h"
#import "UIImageView+ColorPicker.h"
#import "UIImageView+GeometryConversion.h"

@interface CLAViewController ()

@property (weak) IBOutlet UISlider *redSlider;
@property (weak) IBOutlet UISlider *greenSlider;
@property (weak) IBOutlet UISlider *blueSlider;
@property (weak) IBOutlet UIImageView *imageView;

@end

@implementation CLAViewController

@synthesize clight;
@synthesize lampSwitch;

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title = clight.host;
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

-(IBAction) imageTapped:(UIGestureRecognizer*) gestureRecognizer
{
    CGPoint viewPoint = [gestureRecognizer locationInView:self.imageView];
    CGPoint imagePoint = [self.imageView convertPoint:viewPoint toView:self.imageView];
    CGPoint hackedPoint = [self.imageView convertPointFromView:viewPoint];
    
    NSLog(@"View: %f/%f\nImage: %f/%fHacked: %f/%f", viewPoint.x, viewPoint.y, imagePoint.x, imagePoint.y,
          hackedPoint.x, hackedPoint.y);

    /*
    UIColor *color = [self.imageView pixelColorAtLocation:viewPoint];
    
    float red, green, blue, alpha;
    if ([color getRed:&red green:&green blue:&blue alpha:&alpha]) {
        NSLog(@"Successful conversion: %f %f %f", red, green, blue);
        self.redSlider.value = red;
        self.greenSlider.value = green;
        self.blueSlider.value = blue;
    }
    else {
        NSLog(@"Unable to convert color to rgb. Color=%@", color);
    }*/
}

-(IBAction) imageLongTapped:(UIGestureRecognizer*) gestureRecognizer
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
//    imagePicker.mediaTypes = @[kUTTypeImage];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.allowsEditing = NO;
    imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:
                              UIImagePickerControllerSourceTypeSavedPhotosAlbum];

    imagePicker.delegate = self;
    [self presentModalViewController:imagePicker animated:YES];
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
    
    [self dismissModalViewControllerAnimated: YES];
}


@end
