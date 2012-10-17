//
//  CLAScanner.m
//  CLightApp
//
//  Created by Thomas SARLANDIE on 16/06/12.
//
//

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <fcntl.h>
#import "LOOUDPScanner.h"
#import "LOOUDPLamp.h"

#define CLAMP_ADVERTISE_PORT 14484
#define BUF_LEN 1000

@interface LOOUDPScanner ()
{
    CFSocketRef _cfSocket;
}

-(void)readData;

@end

@implementation LOOUDPScanner
{
    NSMutableSet *_foundLights;
}

static const int ddLogLevel = LOG_LEVEL_WARN;

-(id)init
{
    self = [super init];
    if (self) {
        _foundLights = [NSMutableSet set];
    }
    return self;
}

-(void)dealloc
{
    // Make sure to stop scanning and invalidate callback before releasing object
    DDLogVerbose(@"CLAScanner dealloc");
    [self stopScanning];
}

-(void)startScanning
{
    NSError *error;
    assert(_cfSocket == nil);
    
    _cfSocket = [self setupServerSocketOnPort:CLAMP_ADVERTISE_PORT error:&error];
    
    if (_cfSocket == nil) {
        DDLogError(@"An error occured preparing the server socket: %@", error);
    }
}

-(void)stopScanning
{
    if (_cfSocket != nil) {
        DDLogCVerbose(@"Closing server socket");
        // According to the doc, this will close the socket and also invalidate the runloopsource
        CFSocketInvalidate(_cfSocket);
        CFRelease(_cfSocket);
        _cfSocket = nil;
    }
}


-(CFSocketRef)setupServerSocketOnPort:(NSUInteger) port error:(NSError**)errorPtr
{
    // This whole function inspired by the UDPEcho example
    // https://developer.apple.com/library/mac/#samplecode/UDPEcho/Listings/UDPEcho_m.html
    int s;
    int err = 0;
    struct sockaddr_in srv_addr;
    CFSocketRef cfs;
    const CFSocketContext   context = { 0, (__bridge void *)(self), NULL, NULL, NULL };
    CFRunLoopSourceRef      rls;

    
    // Create the socket
    s = socket(PF_INET, SOCK_DGRAM, 0);
    if (s < 0) {
        err = errno;
    }
    
    // Bind the socket to listen
    if (err == 0) {
        memset(&srv_addr, 0, sizeof(srv_addr));
        srv_addr.sin_len = sizeof(srv_addr);
        srv_addr.sin_family = AF_INET;
        srv_addr.sin_port = htons(port);
        srv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
        
        err = bind(s, (const struct sockaddr*)&srv_addr, sizeof(srv_addr));
        if (err < 0) {
            err = errno;
        }
    }
    
    if (err == 0) {
        // Make sure we can reuse the socket after quitting the app/restarting
        if (setsockopt(s, SOL_SOCKET, SO_REUSEADDR, &(int){ 1 }, sizeof(int)) < 0) {
            err = errno;
        }
    }

    // Switch the socket to non-blocking mode
    if (err == 0) {
        int flags = fcntl(s, F_GETFL);
        if (fcntl(s, F_SETFL, flags | O_NONBLOCK) < 0) {
            err = errno;
        }
    }
    
    // Wrap the native socket in a CFSocket
    if (err == 0) {
        cfs = CFSocketCreateWithNative(NULL, s, kCFSocketReadCallBack, SocketReadCallback, &context);
        rls = CFSocketCreateRunLoopSource(NULL, cfs, 0);
        
        CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, kCFRunLoopDefaultMode);
        CFRelease(rls);
    }
    
    
    // Return configured CFSocket or report error.
    if (err == 0) {
        return cfs;
    }
    else {
        if (errorPtr) {
            *errorPtr = [NSError errorWithDomain:NSPOSIXErrorDomain code:err userInfo:nil];
        }
        return nil;
    }
}

/* This C routine is called by CFSocket when there's data waiting on our      *
 * UDP socket.  It just redirects the call to Objective-C code.               */
static void SocketReadCallback(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info)
{
    LOOUDPScanner *obj;
    
    obj = (__bridge LOOUDPScanner *) info;
    assert([obj isKindOfClass:[LOOUDPScanner class]]);
    
    DDLogCVerbose(@"SocketReadCallback");
    [obj readData];
}

/* Called by the C callback when there is data to be read on the socket. */
-(void)readData
{
    DDLogCVerbose(@"readData");
    int s, len;
    char buffer[BUF_LEN];
    struct sockaddr_in remote_addr;
    socklen_t remote_addr_len = sizeof(remote_addr);

    s = CFSocketGetNative(_cfSocket);
    len = recvfrom(s, buffer, BUF_LEN, 0, (struct sockaddr*)&remote_addr, &remote_addr_len);
    
    DDLogVerbose(@"Got %i bytes from %s.", len, inet_ntoa(remote_addr.sin_addr));

    LOOUDPLamp *light = [[LOOUDPLamp alloc] initWithHost:[NSString stringWithCString:inet_ntoa(remote_addr.sin_addr) encoding:NSASCIIStringEncoding]];
    if (![_foundLights member:light]) {
        [_foundLights addObject:light];
        [self.delegate newLampDetected:light];
    }
}

@end
