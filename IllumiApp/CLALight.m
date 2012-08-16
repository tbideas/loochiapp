//
//  CLALight.m
//  CLightApp
//
//  Created by Thomas SARLANDIE on 16/06/12.
//
//

#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>
#import "CLALight.h"
#import "DDLog.h"

#define CLAMP_PORT 2000

@interface CLALight ()

@property NSThread *thread;
@property NSString *nextCommand;

@end

@implementation CLALight

static const int ddLogLevel = LOG_LEVEL_WARN;

@synthesize host;
@synthesize status;

- (id) initWithHost:(NSString*)hostname
{
    self = [super init];
    if (self) {
        host = hostname;
        status = CLALightNotConnected;
    }
    return self;
}

-(void) setRed:(float)red green:(float)green blue:(float) blue
{
    NSString *command = [NSString stringWithFormat:@"RGB%02X%02X%02X\n",
                         (int)(red * 255),
                         (int)(green * 255),
                         (int)(blue * 255)
                         ];
    
    [self sendCommand:command];
}

- (void) setColor:(UIColor*) color
{
    float red, green, blue, alpha;
    
    [color getRed:&red green:&green blue:&blue alpha:&alpha];

    [self setRed:red green:green blue:blue];
}

- (void) startThread
{
    self.thread = [[NSThread alloc] initWithTarget:self selector:@selector(communicate:) object:nil];
    [self.thread setThreadPriority:1.0];
    [self.thread start];
}

#define BUFLEN 200

- (void) communicate:(id) object
{
    struct sockaddr_in si_addr;
    int s, slen = sizeof(si_addr);

    if ((s = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) == -1)
    {
        DDLogWarn(@"Unable to open socket %i", errno);
        return;
    }
    
    memset((char*) &si_addr, 0, sizeof(si_addr));
    si_addr.sin_family = AF_INET;
    si_addr.sin_port = htons(CLAMP_PORT);
    if (inet_aton([self.host cStringUsingEncoding:NSASCIIStringEncoding], &si_addr.sin_addr) == 0) {
        DDLogWarn(@"inet_aton failed");
        return;
    }
    
    NSString *lastCommand;
    while (1) {
        NSString *cmd;
        @synchronized(self) {
            cmd = [self.nextCommand copy];
        }
        if (cmd && ![cmd isEqualToString:lastCommand])
        {
            DDLogVerbose(@"Sending command: %@", cmd);
            const char *commandBytes = (const char*)[cmd cStringUsingEncoding:NSUTF8StringEncoding];
            lastCommand = cmd;
            sendto(s, commandBytes, strlen(commandBytes), 0, (struct sockaddr*)&si_addr, slen);
        }
        // Send one command every 33ms max - That's 30 cmd/s which should be enough for most purpose
        // and also seems to be pretty close to the Wifly limit
        usleep(33000);
    }
}

- (BOOL) sendCommand:(NSString*) command;
{
    
    if (self.thread == nil)
        [self startThread];
    
    @synchronized(self) {
        self.nextCommand = command;
    }
    return YES;
}

#pragma mark Override isEqual and hash to avoid creating the same light twice

-(BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]]) {
        CLALight *otherLight = (CLALight*) object;
        return [otherLight.host isEqual:self.host];
    }
    else {
        return NO;
    }
}

-(NSUInteger)hash
{
    return [self.host hash];
}

@end
