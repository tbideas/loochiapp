//
//  LOOScanner.h
//  Illumi
//
//  Created by Thomas SARLANDIE on 10/3/12.
//
//

#import <Foundation/Foundation.h>
#import "LOOUDPLamp.h"

@protocol LOOScannerDelegate

/*
 * Will be called (on the main thread) everytime a new lamp is discovered.
 */
-(void) newLampDetected:(LOOLamp*)light;

@end

@interface LOOScanner : NSObject

@end
