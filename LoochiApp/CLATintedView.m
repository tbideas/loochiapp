//
//  CLATintedView.m
//  CLightApp
//
//  Created by Thomas SARLANDIE on 20/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//  Kudos to: http://stackoverflow.com/questions/1117211/how-would-i-tint-an-image-programatically-on-the-iphone

#import "CLATintedView.h"

@implementation CLATintedView

@synthesize image = _image;
@synthesize tintColor = _tintColor;

- (id)initWithImage:(UIImage *)image
{
    self = [super initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    if(self)
    {
        self.image = image;
        
        //set the view to opaque
        self.opaque = NO;
    }
    
    return self;
}

- (void)setTintColor:(UIColor *)color
{
    _tintColor = color;
    
    //update every time the tint color is set
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();    
    
    //resolve CG/iOS coordinate mismatch
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -rect.size.height);
    
    //set the clipping area to the image
    CGContextClipToMask(context, rect, _image.CGImage);
    
    //set the fill color
    CGContextSetFillColor(context, CGColorGetComponents(_tintColor.CGColor));
    CGContextFillRect(context, rect);    
    
    //blend mode overlay
    CGContextSetBlendMode(context, kCGBlendModeOverlay);
    
    //draw the image
    CGContextDrawImage(context, rect, _image.CGImage);    
}

@end
