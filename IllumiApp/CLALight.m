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

- (BOOL) sendCommand:(NSString*) command;
{
    switch (status) {
        case CLALightNotConnected:
            NSLog(@"Connecting...");
            [self connect];
            break;
        case CLALightError:
            NSLog(@"Re-Connecting");
            [self connect];
            break;
        case CLALightConnecting:
            NSLog(@"Already connecting. Doing nothing.");
            break;
        case CLALightConnected:{
            const char *commandBytes = (const char*)[command cStringUsingEncoding:NSUTF8StringEncoding];
            NSLog(@"Writing to stream... (%s)", commandBytes);
            if (CFWriteStreamWrite(writeStream, (const UInt8 *)commandBytes, strlen(commandBytes)) < 0) {
                CFStreamError error = CFWriteStreamGetError(writeStream);
                NSLog(@"Unable to write - Domain: %ld Error: %ld", error.domain, error.error);
            }
            break;
        }
        default:
            NSLog(@"Something weird happening here... %i", status);
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
                NSLog(@"Server has data to read!");
                NSLog(@">> %s", buf);
            }
            break;
        }
        case kCFStreamEventErrorOccurred:
            NSLog(@"A Read Stream Error Has Occurred!");
        case kCFStreamEventEndEncountered:
            NSLog(@"A Read Stream Event End!");
        default:
            break;
    }
    
}

void socketWriteCallback(CFWriteStreamRef stream, CFStreamEventType event, void *myPtr)
{
    CLALight *l = (__bridge CLALight*) myPtr;
    
    switch(event) {
        case kCFStreamEventOpenCompleted:{
            NSLog(@"Open completed.");
            l.status = CLALightConnected;
            break;
        }
        case kCFStreamEventCanAcceptBytes:{
            NSLog(@"Can accept bytes.");
            break;
        }
        case kCFStreamEventErrorOccurred:
            NSLog(@"A write Stream Error Has Occurred!");
            l.status = CLALightError;
            [l cleanStreams];
            break;
        case kCFStreamEventEndEncountered:
            NSLog(@"A write Stream Event End!");
            l.status = CLALightError;
            [l cleanStreams];
            break;
        default:
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
        NSLog(@"Error while opening streams");
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
