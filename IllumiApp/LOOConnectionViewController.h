//
//  ILConnectionViewController.h
//  Illumi
//
//  Created by Thomas SARLANDIE on 03/08/12.
//
//

#import <UIKit/UIKit.h>
#import "LOOScanner.h"

@protocol LOOConnectionDelegate <NSObject>

-(void) selectedIllumi:(LOOLamp*)lamp;

@end

@interface LOOConnectionViewController : UIViewController<LOOScannerDelegate>

@property (weak, nonatomic) id<LOOConnectionDelegate> delegate;
@property (strong, nonatomic) LOOLamp *selectedLamp;

-(IBAction)useADemoIllumi:(id)sender;

@end
