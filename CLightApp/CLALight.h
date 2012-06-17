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
- (BOOL) sendCommand:(NSString*) command;

@property (readonly) NSString *host;

@end
