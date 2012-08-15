//
//  CLALight.h
//  CLightApp
//
//  Created by Thomas SARLANDIE on 16/06/12.
//
//

#import <Foundation/Foundation.h>

typedef enum
{
    CLALightNotConnected,
    CLALightConnecting,
    CLALightConnected,
    CLALightError
} CLALightStatus;

@interface CLALight : NSObject
{
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
}

- (id) initWithHost:(NSString*)host;
- (void) setRed:(float)red green:(float)green blue:(float) blue;
- (void) setColor:(UIColor*) color;

- (void) cleanStreams;

@property (readonly) NSString *host;
@property int status;

@end
