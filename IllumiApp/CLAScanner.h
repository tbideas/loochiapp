//
//  CLAScanner.h
//  CLightApp
//
//  Created by Thomas SARLANDIE on 16/06/12.
//
//

#import <Foundation/Foundation.h>
#import "CLALight.h"

@protocol CLAScannerDelegate

/*
 * Will be called (on the main thread) everytime a new broadcast packet is
 * received from an Illumi - even if we are already connected to it.
 */
-(void) newClightDetected:(CLALight*)light;

@end

@interface CLAScanner : NSObject

@property (weak) id<CLAScannerDelegate> delegate;

-(void) startScanning;
-(void) stopScanning;

@end
