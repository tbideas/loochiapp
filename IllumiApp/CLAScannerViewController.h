//
//  CLAScannerViewController.h
//  CLightApp
//
//  Created by Thomas SARLANDIE on 16/06/12.
//
//

#import <UIKit/UIKit.h>
#import "CLAScanner.h"

@interface CLAScannerViewController : UITableViewController<CLAScannerDelegate> 

-(IBAction)updateScanningSwitch:(id)sender;

@end
