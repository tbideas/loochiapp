//
//  CLALight.m
//  CLightApp
//
//  Created by Thomas SARLANDIE on 16/06/12.
//
//

#import "CLALight.h"

#define CLAMP_PORT 2000

void socketReadCallback(CFReadStreamRef stream, CFStreamEventType event, void *myPtr);
void socketWriteCallback(CFWriteStreamRef stream, CFStreamEventType event, void *myPtr);


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

- (BOOL) sendCommand:(NSString*) command;
{
    switch (status) {
        case CLALightNotConnected:
            DDLogVerbose(@"Connecting...");
            [self connect];
            break;
        case CLALightError:
            DDLogVerbose(@"Re-Connecting");
            [self connect];
            break;
        case CLALightConnecting:
            DDLogVerbose(@"Already connecting. Doing nothing.");
            break;
        case CLALightConnected:{
            const char *commandBytes = (const char*)[command cStringUsingEncoding:NSUTF8StringEncoding];
            DDLogVerbose(@"Writing to stream... (%s)", commandBytes);
            if (CFWriteStreamWrite(writeStream, (const UInt8 *)commandBytes, strlen(commandBytes)) < 0) {
                CFStreamError error = CFWriteStreamGetError(writeStream);
                DDLogWarn(@"Unable to write - Domain: %ld Error: %ld", error.domain, error.error);
            }
            break;
        }
        default:
            DDLogWarn(@"Something weird happening here... %i (lost in switch statement)", status);
            break;
    }
    return YES;
}


#define BUFSIZE 1024

void socketReadCallback(CFReadStreamRef stream, CFStreamEventType event, void *myPtr)
{
    switch(event) {
        case kCFStreamEventHasBytesAvailable:{
            UInt8 buf[BUFSIZE];
            CFIndex bytesRead = CFReadStreamRead(stream, buf, BUFSIZE - 1);
            if (bytesRead > 0) {
                buf[bytesRead] = 0;
                DDLogCVerbose(@"Server has data to read!");
                DDLogCVerbose(@">> %s", buf);
            }
            break;
        }
        case kCFStreamEventErrorOccurred:
            DDLogCWarn(@"A Read Stream Error Has Occurred!");
            break;
        case kCFStreamEventEndEncountered:
            DDLogCWarn(@"A Read Stream Event End!");
            break;
    }
    
}

void socketWriteCallback(CFWriteStreamRef stream, CFStreamEventType event, void *myPtr)
{
    CLALight *l = (__bridge CLALight*) myPtr;
    
    switch(event) {
        case kCFStreamEventOpenCompleted:{
            DDLogCVerbose(@"Open completed.");
            l.status = CLALightConnected;
            break;
        }
        case kCFStreamEventCanAcceptBytes:{
            DDLogCVerbose(@"Can accept bytes.");
            break;
        }
        case kCFStreamEventErrorOccurred:
            DDLogCWarn(@"A write Stream Error Has Occurred!");
            l.status = CLALightError;
            [l cleanStreams];
            break;
        case kCFStreamEventEndEncountered:
            DDLogCWarn(@"A write Stream Event End!");
            l.status = CLALightError;
            [l cleanStreams];
            break;
    }
    
}


- (void) connect
{
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                       (__bridge CFStringRef)host,
                                       CLAMP_PORT,
                                       &readStream, &writeStream);
    
    //CFStreamClientContext myContext = { 0, NULL, NULL, NULL, NULL };
    CFStreamClientContext myContext = {
        0,
        (__bridge void*)self,
        (void *(*)(void *info))CFRetain,
        (void (*)(void *info))CFRelease,
        (CFStringRef (*)(void *info))CFCopyDescription
    };
    
    CFOptionFlags registeredEvents = kCFStreamEventOpenCompleted
                                    | kCFStreamEventCanAcceptBytes
                                    | kCFStreamEventHasBytesAvailable
                                    | kCFStreamEventErrorOccurred
                                    | kCFStreamEventEndEncountered;
    
    if (CFReadStreamSetClient(readStream, registeredEvents, socketReadCallback, &myContext))
    {
        CFReadStreamScheduleWithRunLoop(readStream, CFRunLoopGetCurrent(),
                                        kCFRunLoopCommonModes);
    }
    
    if (CFWriteStreamSetClient(writeStream, registeredEvents, socketWriteCallback, &myContext))
    {
        CFWriteStreamScheduleWithRunLoop(writeStream, CFRunLoopGetCurrent(),
                                        kCFRunLoopCommonModes);
    }
    status = CLALightConnecting;
    if (!CFReadStreamOpen(readStream) || !CFWriteStreamOpen(writeStream))
    {
        DDLogWarn(@"Error while opening streams");
        status = CLALightNotConnected;
        [self cleanStreams];
    }
}

- (void) cleanStreams
{
    CFReadStreamClose(readStream);
    CFRelease(readStream);
    CFWriteStreamClose(writeStream);
    CFRelease(writeStream);
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
