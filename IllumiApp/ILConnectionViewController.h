//
//  ILConnectionViewController.h
//  Illumi
//
//  Created by Thomas SARLANDIE on 03/08/12.
//
//

#import <UIKit/UIKit.h>
#import "CLAScanner.h"

@protocol ILConnectionDelegate <NSObject>

-(void) selectedIllumi:(CLALight*)illumi;

@end

@interface ILConnectionViewController : UIViewController<CLAScannerDelegate>

@property (weak, nonatomic) id<ILConnectionDelegate> delegate;
@property (strong, nonatomic) CLALight *selectedLamp;

-(IBAction)useADemoIllumi:(id)sender;

@end
