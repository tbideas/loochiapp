//
//  CLAScanner.m
//  CLightApp
//
//  Created by Thomas SARLANDIE on 16/06/12.
//
//

#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import "CLAScanner.h"

#define CLAMP_ADVERTISE_PORT 14484
#define BUF_LEN 1000

@interface CLAScanner ()
{
    BOOL _stopped;
    int _socket;
}

@end

@implementation CLAScanner
{
    NSMutableSet *_foundLights;
}

static const int ddLogLevel = LOG_LEVEL_WARN;

@synthesize delegate;

-(id)init
{
    self = [super init];
    if (self) {
        _stopped = NO;
        _socket = 0;
        _foundLights = [NSMutableSet set];
    }
    return self;
}

-(void)startScanning
{
    // Only start if we are not already running.
    if (_socket <= 0) {
        _stopped = NO;
        [NSThread detachNewThreadSelector:@selector(performScan) toTarget:self withObject:nil];
    }
}

-(void)stopScanning
{
    _stopped = YES;
}

/* 
 * Let's do some old school networking to get UDP Broadcast packet from the lamp.
 */
-(void) performScan
{
    _socket = socket(PF_INET, SOCK_DGRAM, 0);
    struct sockaddr_in srv_addr;
    struct sockaddr_in remote_addr;
    socklen_t remote_addr_len = sizeof(remote_addr);
    
    char buffer[BUF_LEN];
    
    DDLogInfo(@"Starting scan...");
    if (_socket < 0) {
        DDLogError(@"Unable to open socket: %i", _socket);
        return;
    }
    
    srv_addr.sin_family = AF_INET;
    srv_addr.sin_port = htons(CLAMP_ADVERTISE_PORT);
    srv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    
    if (bind(_socket, (const struct sockaddr*)&srv_addr, sizeof(srv_addr)) == -1) {
        DDLogError(@"Unable to bind socket.");
        return;
    }
    
    while(!_stopped) {
        int len = recvfrom(_socket, buffer, BUF_LEN, 0, (struct sockaddr*)&remote_addr, &remote_addr_len);
        
        DDLogVerbose(@"Got %i bytes from %s.", len, inet_ntoa(remote_addr.sin_addr));
        dispatch_async(dispatch_get_main_queue(), ^{
            CLALight *light = [[CLALight alloc] initWithHost:[NSString stringWithCString:inet_ntoa(remote_addr.sin_addr) encoding:NSASCIIStringEncoding]];
            if (![_foundLights member:light]) {
                [_foundLights addObject:light];
                [self.delegate newClightDetected:light];
            }
        });
    }
    
    close(_socket);
    _socket = 0;
    DDLogInfo(@"Stopped scanning.");
}

@end
