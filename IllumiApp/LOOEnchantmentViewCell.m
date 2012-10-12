//
//  LOOEnchantmentViewCell.m
//  Illumi
//
//  Created by Thomas SARLANDIE on 10/5/12.
//
//

#import <QuartzCore/QuartzCore.h>
#import "LOOEnchantmentViewCell.h"

@implementation LOOEnchantmentViewCell

-(void)awakeFromNib
{
    /* Add A layer to get rounded corner */
    CALayer * l = [self.imageView layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:20.0];
    
    // And a border
    [l setBorderWidth:3.0];
    [l setBorderColor:[[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.2] CGColor]];
    
    //self.contentView.hidden = YES;
    
    UIImage *bgImage = [UIImage imageNamed:@"enchantment-bg-selected.png"];
    self.selectedBackgroundView =
        [[UIImageView alloc] initWithImage:[bgImage stretchableImageWithLeftCapWidth:29 topCapHeight:44]];
}

@end
