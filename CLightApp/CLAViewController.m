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
    UIGestureRecognizer *gestureTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    [imageView addGestureRecognizer:gestureTap];
    
    UIGestureRecognizer *gestureLongTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(imageLongTapped:)];
    [imageView addGestureRecognizer:gestureLongTap];

    UIGestureRecognizer *gestureSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(imageSwiped:)];
    [imageView addGestureRecognizer:gestureSwipe];
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
    CGPoint imagePoint = [self.imageView convertPointFromView:viewPoint];
    
    NSLog(@"View: %f/%f", viewPoint.x, viewPoint.y);
    NSLog(@"Image: %f/%f", imagePoint.x, imagePoint.y);

    if (imageView.image &&
        imagePoint.x >= 0 && imagePoint.y >= 0 
        && imagePoint.x < imageView.image.size.width
        && imagePoint.y < imageView.image.size.height)
    {
        UIColor *color = [self.imageView pixelColorAtLocation:imagePoint];
        
        float red, green, blue, alpha;
        if ([color getRed:&red green:&green blue:&blue alpha:&alpha]) {
            UILabel *titleLabel = (UILabel*) self.navigationItem.titleView;
            titleLabel.textColor = color;
            
            //NSLog(@"Successful conversion: %f %f %f", red, green, blue);
            self.redSlider.value = red;
            self.greenSlider.value = green;
            self.blueSlider.value = blue;
            [self rgbValueUpdated:nil];
        }
        else {
            NSLog(@"Unable to convert color to rgb. Color=%@", color);
        }
    }
    else {
        NSLog(@"Tap out of image");
    }
}

-(IBAction) imageLongTapped:(UIGestureRecognizer*) gestureRecognizer
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.allowsEditing = NO;
    imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:
                              UIImagePickerControllerSourceTypeSavedPhotosAlbum];

    imagePicker.delegate = self;
    [self presentModalViewController:imagePicker animated:YES];
}

-(IBAction)imageSwiped:(UIGestureRecognizer*) gestureRecognizer
{
    if (imageView.contentMode == UIViewContentModeBottomRight) 
        imageView.contentMode = UIViewContentModeScaleToFill;
    else
        imageView.contentMode++;
    NSLog(@"imageView contentMode now: %i", imageView.contentMode);
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
