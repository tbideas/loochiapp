//
//  LOOUDPLamp.h
//  Loochi
//
//  Created by Thomas SARLANDIE on 14/08/12.
//
//

#import <Foundation/Foundation.h>
#import "LOOLamp.h"

@protocol LOOLightClient <NSObject>

- (void) setLamp:(LOOLamp*) light;

@end

