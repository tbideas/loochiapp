//
//  CLAScanner.h
//  CLightApp
//
//  Created by Thomas SARLANDIE on 16/06/12.
//
//

#import <Foundation/Foundation.h>
#import "LOOUDPLamp.h"

@protocol LOOUDPScannerDelegate

/*
 * Will be called (on the main thread) everytime a new lamp is discovered.
 */
-(void) newLampDetected:(LOOUDPLamp*)light;

@end

@interface LOOUDPScanner : NSObject

@property (weak) id<LOOUDPScannerDelegate> delegate;

-(void) startScanning;
-(void) stopScanning;

@end
