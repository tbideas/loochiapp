//
//  CLAViewController.m
//  CLightApp
//
//  Created by Thomas SARLANDIE on 01/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ILColorViewController.h"
#import "UIImageView+ColorPicker.h"
#import "CLATintedView.h"

@interface ILColorViewController ()
{
    UIPopoverController *_popoverController;
    CLATintedView *_crosshairView;
    CLATintedView *_crosshairView2;
    
    UITouch *_firstTouch, *_secondTouch;
    
    NSTimer *animationTimer;
    UIColor *startColor, *endColor;
    NSTimeInterval animationDuration;
    NSTimeInterval animationPosition;
    NSDate *animationStart;
}

@property (weak) IBOutlet UISlider *redSlider;
@property (weak) IBOutlet UISlider *greenSlider;
@property (weak) IBOutlet UISlider *blueSlider;
@property (weak) IBOutlet UIImageView *imageView;

@end

@implementation ILColorViewController

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

#pragma mark - View lifecycle

-(void)viewDidLoad
{
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

- (IBAction)rgbValueUpdated:(id)sender
{
    [_clight setRed:self.redSlider.value
             green:self.greenSlider.value
              blue:self.blueSlider.value];
}

-(IBAction)colorModeChanged:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl*) sender;
    
    if (segmentedControl.selectedSegmentIndex == 0) {
        self.imageView.image = [UIImage imageNamed:@"background-color.png"];
    }
    else {
        self.imageView.image = [UIImage imageNamed:@"background-white.png"];
    }
}

-(IBAction)turnOffTheLight:(id)sender
{
    [self stopAnimation];
    
    self.redSlider.value = 0;
    self.greenSlider.value = 0;
    self.blueSlider.value = 0;
    
    [self rgbValueUpdated:self];
}

#pragma mark Touch event handlers

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self stopAnimation];

    for (UITouch *t in touches) {
        CGPoint viewPoint = [t locationInView:self.imageView];
        // If we dont already have a touch - then the first one will be the ... the firstTouch
        if (_firstTouch == nil) {
            _firstTouch = t;
            
            [self beginShowingCrossHairView:_crosshairView atPoint:viewPoint primary:YES];
            [self updateSlidersToCrossHairView:_crosshairView];
        }
        // If we do already have one touch, then the second one will be the secondTouch
        else if (_secondTouch == nil) {
            _secondTouch = t;
            
            [self beginShowingCrossHairView:_crosshairView2 atPoint:viewPoint primary:NO];
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *t in touches) {
        CGPoint viewPoint = [t locationInView:self.imageView];
        if (t == _firstTouch) {
            [self updateCrossHairView:_crosshairView toPoint:viewPoint];
            [self updateSlidersToCrossHairView:_crosshairView];
        }
        else if (t == _secondTouch) {
            [self updateCrossHairView:_crosshairView2 toPoint:viewPoint];
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *t in touches) {
        if (t == _firstTouch) {
            _firstTouch = nil;
            [self dismissCrossHairView:_crosshairView];
        }
        else if (t == _secondTouch) {
            _secondTouch = nil;
            [self dismissCrossHairView:_crosshairView2];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{    
    for (UITouch *t in touches) {
        if (t == _firstTouch) {
            _firstTouch = nil;
            [self dismissCrossHairView:_crosshairView];
            
            if (_secondTouch != nil) {
                // Keep color of that point as start of animation
                CGPoint viewPoint = [t locationInView:self.imageView];
                startColor = [self.imageView pixerlColorAtViewLocation:viewPoint];
            }
        }
        else if (t == _secondTouch) {
            _secondTouch = nil;
            [self dismissCrossHairView:_crosshairView2];
            
            // If the user drops the second touch after the first one, then
            // we animate from the first one to the second one.
            if (_firstTouch == nil) {
                CGPoint viewPoint = [t locationInView:self.imageView];
                endColor = [self.imageView pixerlColorAtViewLocation:viewPoint];
                
                if (animationTimer) {
                    [animationTimer invalidate];
                    animationTimer = nil;
                }
                animationDuration = 3.0;
                animationPosition = 0.0;
                animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.05
                                                                  target:self
                                                                selector:@selector(updateAnimation:)
                                                                userInfo:nil
                                                                 repeats:YES];
            }
        }
    }
}

- (void) updateAnimation:(id) userInfo
{
    if (animationStart == nil) {
        animationStart = [NSDate date];
    }

    animationPosition = [[NSDate date] timeIntervalSinceDate:animationStart];
    if (animationPosition > animationDuration) {
        // If we have reached the end - re-set the beginning date correctly
        animationStart = [NSDate dateWithTimeInterval:animationDuration - animationPosition sinceDate:[NSDate date]];

        //animationPosition = animationPosition - animationDuration;
        animationPosition = [[NSDate date] timeIntervalSinceDate:animationStart];
        // And inverse the colors
        UIColor *color = endColor;
        endColor = startColor;
        startColor = color;
        DDLogVerbose(@"Looping animation. start=%f position=%f", [animationStart timeIntervalSinceReferenceDate], animationPosition);
    }

    CGFloat redA, greenA, blueA;
    CGFloat redB, greenB, blueB;
    CGFloat alpha;
    
    [startColor getRed:&redA green:&greenA blue:&blueA alpha:&alpha];
    [endColor getRed:&redB green:&greenB blue:&blueB alpha:&alpha];
    
    CGFloat red, green, blue;
    
    red = redA * (animationDuration - animationPosition) / (animationDuration)
    + redB * (animationPosition) / animationDuration;
    
    green = greenA * (animationDuration - animationPosition) / (animationDuration)
    + greenB * (animationPosition) / animationDuration;

    blue = blueA * (animationDuration - animationPosition) / (animationDuration)
    + blueB * (animationPosition) / animationDuration;
    
    DDLogVerbose(@"Animating to color: %0.2f %0.2f %0.2f - Position:%.1f Duration:%.1f (%f%%)",
          red, green, blue, animationPosition, animationDuration, (animationDuration - animationPosition) / animationDuration * 100);
    
    self.redSlider.value = red;
    self.greenSlider.value = green;
    self.blueSlider.value = blue;
    [self rgbValueUpdated:self];
}

- (void) stopAnimation
{
    if (animationTimer) {
        [animationTimer invalidate];
        animationTimer = nil;
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
