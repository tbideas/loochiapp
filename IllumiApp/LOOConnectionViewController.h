//
//  ILConnectionViewController.h
//  Illumi
//
//  Created by Thomas SARLANDIE on 03/08/12.
//
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "LOOUDPScanner.h"

@protocol LOOConnectionDelegate <NSObject>

-(void) selectedIllumi:(LOOLamp*)lamp;

@end

@interface LOOConnectionViewController : UIViewController<LOOUDPScannerDelegate, CBCentralManagerDelegate>

@property (weak, nonatomic) id<LOOConnectionDelegate> delegate;
@property (strong, nonatomic) LOOLamp *selectedLamp;
@property (weak) CBCentralManager *cbCentralManager;

-(IBAction)useADemoIllumi:(id)sender;

@end
