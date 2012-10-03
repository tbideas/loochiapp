//
//  CLALight.m
//  CLightApp
//
//  Created by Thomas SARLANDIE on 16/06/12.
//
//

#import "LOOUDPLamp.h"
#import "DDLog.h"
#import "LOOUDPThread.h"

#define CLAMP_PORT 2000

@interface LOOUDPLamp ()

@property LOOUDPThread *thread;
@property NSString *nextCommand;

@end

@implementation LOOUDPLamp

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

-(void) dealloc
{
    [self stopThread];
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

-(void) startThread
{
    if (self.thread == nil || [self.thread isFinished]) {
        self.thread = [[LOOUDPThread alloc] init];
        self.thread.host = self.host;
        self.thread.port = CLAMP_PORT;

        [self.thread setThreadPriority:1.0];
        [self.thread start];
    }
}

-(void) stopThread
{
    [self.thread cancel];
}

#define BUFLEN 200


- (BOOL) sendCommand:(NSString*) command;
{
    if (self.thread == nil || [self.thread isFinished])
        [self startThread];
    
    self.thread.nextCommand = command;
    return YES;
}

#pragma mark Override isEqual and hash to avoid creating the same light twice

-(BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]]) {
        LOOUDPLamp *otherLight = (LOOUDPLamp*) object;
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
