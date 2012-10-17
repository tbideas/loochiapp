//
//  UDPThread.h
//  Illumi
//
//  Created by Thomas SARLANDIE on 8/24/12.
//
//

#import <Foundation/Foundation.h>

@interface LOOUDPThread : NSThread

@property NSString *host;
@property NSUInteger port;
@property (atomic) NSString *nextCommand;

@end
