//
//  CLATintedView.h
//  CLightApp
//
//  Created by Thomas SARLANDIE on 20/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLATintedView : UIView

- (id)initWithImage:(UIImage *)image;

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UIColor *tintColor;

@end
