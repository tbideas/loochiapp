//
//  UDPThread.m
//  Illumi
//
//  Created by Thomas SARLANDIE on 8/24/12.
//
//

#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>

#import "LOOUDPThread.h"

static const int ddLogLevel = LOG_LEVEL_WARN;

@implementation LOOUDPThread

- (void) main
{
    struct sockaddr_in si_addr;
    int s, slen = sizeof(si_addr);
    
    DDLogVerbose(@"Starting network thread");
    
    if ((s = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) == -1)
    {
        DDLogWarn(@"Unable to open socket %i", errno);
        return;
    }
    
    memset((char*) &si_addr, 0, sizeof(si_addr));
    si_addr.sin_family = AF_INET;
    si_addr.sin_port = htons(self.port);
    if (inet_aton([self.host cStringUsingEncoding:NSASCIIStringEncoding], &si_addr.sin_addr) == 0) {
        DDLogWarn(@"inet_aton failed");
        return;
    }
    
    // We should not need this because we close the socket everytime the app is resign'd active
    // which should help us make sure iOS does not close the socket on us.
    //setsockopt(s, SOL_SOCKET, SO_NOSIGPIPE, &(int){ 1 }, sizeof(int));
    
    NSString *lastCommand;
    while (1) {
        if ([self isCancelled]) {
            continue;
        }
        
        NSString *cmd;
        cmd = [self.nextCommand copy];
        if (cmd && ![cmd isEqualToString:lastCommand])
        {
            DDLogVerbose(@"Sending command: %@", cmd);
            const char *commandBytes = (const char*)[cmd cStringUsingEncoding:NSUTF8StringEncoding];
            lastCommand = cmd;
            sendto(s, commandBytes, strlen(commandBytes), 0, (struct sockaddr*)&si_addr, slen);
        }
        // Send one command every 33ms max - That's 30 cmd/s which should be enough for most purpose
        // and also seems to be pretty close to the Wifly limit
        //usleep(33000);
        
        [NSThread sleepForTimeInterval:0.033];
    }
    
    DDLogVerbose(@"Terminating thread");
    // Close the socket and terminate thread
    close(s);
}

@end
