//
//  CLAScanner.h
//  CLightApp
//
//  Created by Thomas SARLANDIE on 16/06/12.
//
//

#import <Foundation/Foundation.h>
#import "LOOScanner.h"

@interface LOOUDPScanner : NSObject

@property (weak) id<LOOScannerDelegate> delegate;

-(void) startScanning;
-(void) stopScanning;

@end
