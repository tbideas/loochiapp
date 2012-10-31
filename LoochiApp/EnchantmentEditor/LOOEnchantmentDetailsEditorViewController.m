//
//  LOOColorPickerViewController.m
//  Loochi
//
//  Created by Thomas SARLANDIE on 10/30/12.
//
//

#import <QuartzCore/QuartzCore.h>
#import "LOOEnchantmentDetailsEditorViewController.h"

@interface LOOEnchantmentDetailsEditorViewController ()

@end

@implementation LOOEnchantmentDetailsEditorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"low_contrast_linen.png"]];
    
    UIImage *nonResizableBackground = [[UIImage imageNamed:@"hue-scale.png"] resizableImageWithCapInsets:UIEdgeInsetsZero
                                                                                            resizingMode:UIImageResizingModeTile];

    [self addRoundedCornerOnView:self.startColorView];
    [self addRoundedCornerOnView:self.endColorView];
    
    [self.startColorHue setMinimumTrackImage:nonResizableBackground forState:UIControlStateNormal];
    [self.startColorHue setMaximumTrackImage:nonResizableBackground forState:UIControlStateNormal];
}

- (void)addRoundedCornerOnView:(UIView*) view
{
    /* Add A layer to get rounded corner */
    CALayer *layer = [view layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:20.0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setColor:self.enchantment.startColor onRed:self.startColorHue andGreen:self.startColorSaturation andBlue:self.startColorBrightness];
    [self firstColorChanged:self];
    
    [self setColor:self.enchantment.endColor onRed:self.endColorHue andGreen:self.endColorSaturation andBlue:self.endColorBrightness];
    [self secondColorChanged:self];

    self.durationSlider.value = self.enchantment.duration;
    [self durationChanged:self];
}

- (void)setColor:(UIColor*)c onRed:(UISlider*)redSlider andGreen:(UISlider*) greenSlider andBlue:(UISlider*)blueSlider
{
//    float red, green, blue, alpha;
//    [c getRed:&red green:&green blue:&blue alpha:&alpha];
    float hue, saturation, brightness, alpha;
    [c getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    redSlider.value = hue;
    greenSlider.value = saturation;
    blueSlider.value = brightness;
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.enchantment.startColor = self.startColorView.backgroundColor;
    self.enchantment.endColor = self.endColorView.backgroundColor;
    self.enchantment.duration = self.durationSlider.value;
    
    [self.delegate enchantmentDetailsUpdated:self.enchantment];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)firstColorChanged:(id)sender
{
//    UIColor *firstColor = [[UIColor alloc] initWithRed:self.firstColorRed.value
//                                                 green:self.firstColorGreen.value
//                                                  blue:self.firstColorBlue.value
//                                                 alpha:1.0];
    UIColor *firstColor = [[UIColor alloc] initWithHue:self.startColorHue.value
                                            saturation:self.startColorSaturation.value
                                            brightness:self.startColorBrightness.value
                                                 alpha:1.0];
    self.startColorView.backgroundColor = firstColor;
    
    if ([sender isKindOfClass:[UISlider class]])
        [self.lamp setColor:firstColor];
}

-(IBAction)secondColorChanged:(id)sender
{
//    UIColor *secondColor = [[UIColor alloc] initWithRed:self.secondColorRed.value
//                                                  green:self.secondColorGreen.value
//                                                   blue:self.secondColorBlue.value
//                                                  alpha:1.0];
    UIColor *secondColor = [[UIColor alloc] initWithHue:self.endColorHue.value
                                             saturation:self.endColorSaturation.value
                                             brightness:self.endColorBrightness.value
                                                  alpha:1.0];
    self.endColorView.backgroundColor = secondColor;
    
    if ([sender isKindOfClass:[UISlider class]])
        [self.lamp setColor:secondColor];
}

- (IBAction)durationChanged:(id)sender
{
    self.durationLabel.text = [NSString stringWithFormat:@"%3.1fs", self.durationSlider.value];
}

@end
