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

-(void) selectedLamp:(LOOLamp*)lamp;

@end

@interface LOOConnectionViewController : UIViewController<LOOUDPScannerDelegate, CBCentralManagerDelegate, CBPeripheralDelegate>

@property (weak, nonatomic) id<LOOConnectionDelegate> delegate;
@property (weak) CBCentralManager *cbCentralManager;

-(IBAction)useADemoIllumi:(id)sender;

@end
