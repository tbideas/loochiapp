//
//  LOOColorPickerViewController.h
//  Loochi
//
//  Created by Thomas SARLANDIE on 10/30/12.
//
//

#import <UIKit/UIKit.h>
#import "LOOGradientColorEnchantment.h"
#import "LOOLightClient.h"

@protocol LOOEnchantmentDetailsEditorDelegate <NSObject>

- (void)enchantmentDetailsUpdated:(LOOGradientColorEnchantment*) gradientColorEnchantment;

@end

@interface LOOEnchantmentDetailsEditorViewController : UIViewController<LOOLightClient>

@property (weak)   id<LOOEnchantmentDetailsEditorDelegate> delegate;

@property (strong) LOOGradientColorEnchantment *enchantment;
@property (strong) LOOLamp *lamp;

@property (weak) IBOutlet UIView *startColorView;
@property (weak) IBOutlet UIView *endColorView;

@property (weak) IBOutlet UILabel *durationLabel;
@property (weak) IBOutlet UISlider *durationSlider;

@property (weak) IBOutlet UISlider *startColorHue;
@property (weak) IBOutlet UISlider *startColorSaturation;
@property (weak) IBOutlet UISlider *startColorBrightness;

@property (weak) IBOutlet UISlider *endColorHue;
@property (weak) IBOutlet UISlider *endColorSaturation;
@property (weak) IBOutlet UISlider *endColorBrightness;


- (IBAction)firstColorChanged:(id)sender;
- (IBAction)secondColorChanged:(id)sender;
- (IBAction)durationChanged:(id)sender;

@end
