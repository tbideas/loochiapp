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

-(void) newClightDetected:(CLALight*)light;

@end

@interface CLAScanner : NSObject

@property (weak) id<CLAScannerDelegate> delegate;

-(void) startScanning;
-(void) stopScanning;

@end
