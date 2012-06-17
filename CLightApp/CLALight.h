//
//  CLALight.h
//  CLightApp
//
//  Created by Thomas SARLANDIE on 16/06/12.
//
//

#import <Foundation/Foundation.h>

@interface CLALight : NSObject

- (id) initWithHost:(NSString*)host;

-(void) setLed:(BOOL)on;
-(void) setRed:(float)red green:(float)green blue:(float) blue;

@property (readonly) NSString *host;

@end
