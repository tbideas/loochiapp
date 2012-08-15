//
//  ILLampUserProtocol.h
//  Illumi
//
//  Created by Thomas SARLANDIE on 14/08/12.
//
//

#import <Foundation/Foundation.h>
#import "CLALight.h"

@protocol ILLightClient <NSObject>

- (void) setLamp:(CLALight*) light;

@end
