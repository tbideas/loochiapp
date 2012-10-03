//
//  CLALight.h
//  CLightApp
//
//  Created by Thomas SARLANDIE on 16/06/12.
//
//

#import <Foundation/Foundation.h>
#import "LOOLamp.h"

typedef enum
{
    CLALightNotConnected,
    CLALightConnecting,
    CLALightConnected,
    CLALightError
} CLALightStatus;

@interface LOOUDPLamp : LOOLamp

- (id) initWithHost:(NSString*)host;
- (void) setRed:(float)red green:(float)green blue:(float) blue;
- (void) setColor:(UIColor*) color;

@property (readonly) NSString *host;
@property int status;

@end
