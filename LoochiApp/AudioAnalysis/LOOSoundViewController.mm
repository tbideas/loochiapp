//
//  LOOSoundViewController.m
//  Illumi
//
//  Created by Thomas SARLANDIE on 8/30/12.
//
//

#import <AudioToolbox/AudioToolbox.h>

#import "LOOSoundViewController.h"
#import "CAStreamBasicDescription.h"
#import "CAXException.h"
#import "DCRejectionFilter.h"
#import "FFTBufferManager.h"

@interface LOOSoundViewController ()
{
    AURenderCallbackStruct      inputProc;
	CAStreamBasicDescription	thruFormat;
    CAStreamBasicDescription    drawFormat;
    
    AudioConverterRef           audioConverter;
    
    AudioBufferList*            drawABL;
	int32_t*					l_fftData;
    
    SInt32*						fftData;
	NSUInteger					fftLength;

    DCRejectionFilter*          dcFilter;
    FFTBufferManager*			fftBufferManager;
    
    NSTimer *drawTimer;
}

@end

int SetupRemoteIO (AudioUnit& inRemoteIOUnit, AURenderCallbackStruct inRenderProc, CAStreamBasicDescription& outFormat);
void rioInterruptionListener(void *inClientData, UInt32 inInterruption);
void propListener(	void *                  inClientData,
                  AudioSessionPropertyID	inID,
                  UInt32                  inDataSize,
                  const void *            inData);

@implementation LOOSoundViewController

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"low_contrast_linen.png"]]];
    [self audioInit];
    
    drawTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateSpectrum) userInfo:nil repeats:YES];
}

- (void)updateSpectrum
{
    if (fftBufferManager->HasNewAudioData())
	{
		if (fftBufferManager->ComputeFFT(l_fftData))
		{
			[self setFFTData:l_fftData length:fftBufferManager->GetNumberFrames() / 2];

            UISlider *sliders[] = { self.slider1, self.slider2, self.slider3, self.slider4, self.slider5, self.slider6 };
            NSInteger frequencies[] = { 0, 500, 1000, 1500, 2000, 2500, 3000 };
            for (int i = 0; i < 6; i ++) {
                sliders[i].value = [self computeAverageFFTMagnitudeBetween:frequencies[i] andMaxFrequency:frequencies[i + 1]];
            }
            UIColor *color = [UIColor colorWithRed:sliders[2].value green:sliders[1].value blue:sliders[0].value alpha:1.0];
            [self.lamp setColor:color];
        }
		else
        {
            DDLogWarn(@"Error computing fft data");
        }
	}
}

- (CGFloat) computeAverageFFTMagnitudeBetween:(NSInteger)minFrequency andMaxFrequency:(NSInteger)maxFrequency
{
    NSInteger minIndex, maxIndex;
    CGFloat magnitude = 0;
    
    minIndex = (CGFloat)minFrequency / 22050 * fftLength;
    maxIndex = (CGFloat)maxFrequency / 22050 * fftLength;

    for (NSInteger i = minIndex; i < maxIndex; i++) {
        SInt8 fft_l, fft_r;
        CGFloat fft_l_fl, fft_r_fl;
        CGFloat interpVal;
        
        fft_l = (fftData[(int)i*2] & 0xFF000000) >> 24;
        fft_r = (fftData[(int)i*2 + 1] & 0xFF000000) >> 24;
        fft_l_fl = (CGFloat)(fft_l + 80) / 64.;
        fft_r_fl = (CGFloat)(fft_r + 80) / 64.;
        interpVal = fft_l_fl * 0.5 + fft_r_fl * 0.5;
        
        interpVal = CLAMP(0., interpVal, 1.);
        
        magnitude += interpVal;
    }
    
    magnitude /= maxIndex - minIndex;
    
    //DDLogVerbose(@"Magnitude between %i and %i - %.3f", minFrequency, maxFrequency, magnitude);
    return magnitude;
}


- (void)setFFTData:(int32_t *)FFTDATA length:(NSUInteger)LENGTH
{
	if (LENGTH != fftLength)
	{
		fftLength = LENGTH;
		fftData = (SInt32 *)(realloc(fftData, LENGTH * sizeof(SInt32)));
	}
	memmove(fftData, FFTDATA, fftLength * sizeof(Float32));
}


#pragma mark Audio management

int SetupRemoteIO (AudioUnit& inRemoteIOUnit, AURenderCallbackStruct inRenderProc, CAStreamBasicDescription& outFormat)
{
	try {
		// Open the output unit
		AudioComponentDescription desc;
		desc.componentType = kAudioUnitType_Output;
		desc.componentSubType = kAudioUnitSubType_RemoteIO;
		desc.componentManufacturer = kAudioUnitManufacturer_Apple;
		desc.componentFlags = 0;
		desc.componentFlagsMask = 0;
		
		AudioComponent comp = AudioComponentFindNext(NULL, &desc);
		
		XThrowIfError(AudioComponentInstanceNew(comp, &inRemoteIOUnit), "couldn't open the remote I/O unit");
        
		UInt32 one = 1;
		XThrowIfError(AudioUnitSetProperty(inRemoteIOUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1, &one, sizeof(one)), "couldn't enable input on the remote I/O unit");
        
		XThrowIfError(AudioUnitSetProperty(inRemoteIOUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &inRenderProc, sizeof(inRenderProc)), "couldn't set remote i/o render callback");
		
        // set our required format - LPCM non-interleaved 32 bit floating point
        outFormat = CAStreamBasicDescription(44100, kAudioFormatLinearPCM, 4, 1, 4, 2, 32, kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked | kAudioFormatFlagIsFloat | kAudioFormatFlagIsNonInterleaved);
		XThrowIfError(AudioUnitSetProperty(inRemoteIOUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &outFormat, sizeof(outFormat)), "couldn't set the remote I/O unit's output client format");
		XThrowIfError(AudioUnitSetProperty(inRemoteIOUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &outFormat, sizeof(outFormat)), "couldn't set the remote I/O unit's input client format");
        
		XThrowIfError(AudioUnitInitialize(inRemoteIOUnit), "couldn't initialize the remote I/O unit");
	}
	catch (CAXException &e) {
		char buf[256];
		fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
		return 1;
	}
	catch (...) {
		fprintf(stderr, "An unknown error occurred\n");
		return 1;
	}
	
	return 0;
}

-(void) audioInit
{
    inputProc.inputProc = PerformThru;
	inputProc.inputProcRefCon = (__bridge void *)(self);

	try {
        XThrowIfError(AudioSessionInitialize(NULL, NULL, rioInterruptionListener, (__bridge void *)(self)), "couldn't initialize audio session");
        
        // We dont play but we need this to be able to set kAudioSessionProperty_OverrideCategoryMixWithOthers
        UInt32 audioCategory = kAudioSessionCategory_PlayAndRecord;
        XThrowIfError(AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(audioCategory), &audioCategory), "couldn't set audio category");
        UInt32 mixWithOthersProperty = 1;
        XThrowIfError(AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(mixWithOthersProperty), &mixWithOthersProperty), "couldn't set audio property mixWithOthers");

        XThrowIfError(AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, propListener, (__bridge void *)(self)), "couldn't set property listener");
        
        Float32 preferredBufferSize = .005;
        XThrowIfError(AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, sizeof(preferredBufferSize), &preferredBufferSize), "couldn't set i/o buffer duration");
        
        Float64 hwSampleRate;
        UInt32 size = sizeof(hwSampleRate);
        XThrowIfError(AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareSampleRate, &size, &hwSampleRate), "couldn't get hw sample rate");
        
        XThrowIfError(AudioSessionSetActive(true), "couldn't set audio session active\n");
        
        XThrowIfError(SetupRemoteIO(rioUnit, inputProc, thruFormat), "couldn't setup remote i/o unit");

        drawFormat.SetAUCanonical(2, false);
        drawFormat.mSampleRate = 44100;
        
        XThrowIfError(AudioConverterNew(&thruFormat, &drawFormat, &audioConverter), "couldn't setup AudioConverter");
        
        dcFilter = new DCRejectionFilter[thruFormat.NumberChannels()];
        
        UInt32 maxFPS;
        size = sizeof(maxFPS);
        XThrowIfError(AudioUnitGetProperty(rioUnit, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maxFPS, &size), "couldn't get the remote I/O unit's max frames per slice");
        
        fftBufferManager = new FFTBufferManager(maxFPS);
        l_fftData = new int32_t[maxFPS/2];
        
        drawABL = (AudioBufferList*) malloc(sizeof(AudioBufferList) + sizeof(AudioBuffer));
        drawABL->mNumberBuffers = 2;
        for (UInt32 i=0; i<drawABL->mNumberBuffers; ++i)
        {
            drawABL->mBuffers[i].mData = (SInt32*) calloc(maxFPS, sizeof(SInt32));
            drawABL->mBuffers[i].mDataByteSize = maxFPS * sizeof(SInt32);
            drawABL->mBuffers[i].mNumberChannels = 1;
        }
        
        XThrowIfError(AudioOutputUnitStart(rioUnit), "couldn't start remote i/o unit");
        
        size = sizeof(thruFormat);
        XThrowIfError(AudioUnitGetProperty(rioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &thruFormat, &size), "couldn't get the remote I/O unit's output client format");
        
        DDLogVerbose(@"Audio initialized successfully.");
    }
	catch (CAXException &e) {
		char buf[256];
		fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
		if (dcFilter) delete[] dcFilter;
        if (drawABL)
        {
            for (UInt32 i=0; i<drawABL->mNumberBuffers; ++i)
                free(drawABL->mBuffers[i].mData);
            free(drawABL);
            drawABL = NULL;
        }
	}
	catch (...) {
		fprintf(stderr, "An unknown error occurred\n");
		if (dcFilter) delete[] dcFilter;
        if (drawABL)
        {
            for (UInt32 i=0; i<drawABL->mNumberBuffers; ++i)
                free(drawABL->mBuffers[i].mData);
            free(drawABL);
            drawABL = NULL;
        }
	}
}

#pragma mark Audio callbacks

void rioInterruptionListener(void *inClientData, UInt32 inInterruption)
{
    DDLogCVerbose(@"Audio Session interruption: %lu", inInterruption);

/*    try {
        printf("Session interrupted! --- %s ---", inInterruption == kAudioSessionBeginInterruption ? "Begin Interruption" : "End Interruption");
        
        aurioTouchAppDelegate *THIS = (aurioTouchAppDelegate*)inClientData;
        
        if (inInterruption == kAudioSessionEndInterruption) {
            // make sure we are again the active session
            XThrowIfError(AudioSessionSetActive(true), "couldn't set audio session active");
            XThrowIfError(AudioOutputUnitStart(THIS->rioUnit), "couldn't start unit");
        }
        
        if (inInterruption == kAudioSessionBeginInterruption) {
            XThrowIfError(AudioOutputUnitStop(THIS->rioUnit), "couldn't stop unit");
        }
    } catch (CAXException e) {
        char buf[256];
        fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
    }
 */
}

#pragma mark -Audio Session Property Listener

void propListener(	void *                  inClientData,
                  AudioSessionPropertyID	inID,
                  UInt32                  inDataSize,
                  const void *            inData)
{
    DDLogCVerbose(@"Audio Session Property change: id=%lu", inID);
    
    //LOOSoundViewController *THIS = (__bridge LOOSoundViewController *)inClientData;

	if (inID == kAudioSessionProperty_AudioRouteChange)
	{
        /*
		try {
            UInt32 isAudioInputAvailable;
            UInt32 size = sizeof(isAudioInputAvailable);
            XThrowIfError(AudioSessionGetProperty(kAudioSessionProperty_AudioInputAvailable, &size, &isAudioInputAvailable), "couldn't get AudioSession AudioInputAvailable property value");
            
            if(THIS->unitIsRunning && !isAudioInputAvailable)
            {
                XThrowIfError(AudioOutputUnitStop(THIS->rioUnit), "couldn't stop unit");
                THIS->unitIsRunning = false;
            }
            
            else if(!THIS->unitIsRunning && isAudioInputAvailable)
            {
                XThrowIfError(AudioSessionSetActive(true), "couldn't set audio session active\n");
                
                if (!THIS->unitHasBeenCreated)	// the rio unit is being created for the first time
                {
                    XThrowIfError(SetupRemoteIO(THIS->rioUnit, THIS->inputProc, THIS->thruFormat), "couldn't setup remote i/o unit");
                    THIS->unitHasBeenCreated = true;
                    
                    THIS->dcFilter = new DCRejectionFilter[THIS->thruFormat.NumberChannels()];
                    
                    UInt32 maxFPS;
                    size = sizeof(maxFPS);
                    XThrowIfError(AudioUnitGetProperty(THIS->rioUnit, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maxFPS, &size), "couldn't get the remote I/O unit's max frames per slice");
                    
                    THIS->fftBufferManager = new FFTBufferManager(maxFPS);
                    THIS->l_fftData = new int32_t[maxFPS/2];
                    
                    THIS->oscilLine = (GLfloat*)malloc(drawBufferLen * 2 * sizeof(GLfloat));
                }
                
                XThrowIfError(AudioOutputUnitStart(THIS->rioUnit), "couldn't start unit");
                THIS->unitIsRunning = true;
            }
            
			// we need to rescale the sonogram view's color thresholds for different input
			CFStringRef newRoute;
			size = sizeof(CFStringRef);
			XThrowIfError(AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &size, &newRoute), "couldn't get new audio route");
			if (newRoute)
			{
				CFShow(newRoute);
				if (CFStringCompare(newRoute, CFSTR("Headset"), NULL) == kCFCompareEqualTo) // headset plugged in
				{
					colorLevels[0] = .3;
					colorLevels[5] = .5;
				}
				else if (CFStringCompare(newRoute, CFSTR("Receiver"), NULL) == kCFCompareEqualTo) // headset plugged in
				{
					colorLevels[0] = 0;
					colorLevels[5] = .333;
					colorLevels[10] = .667;
					colorLevels[15] = 1.0;
					
				}
				else
				{
					colorLevels[0] = 0;
					colorLevels[5] = .333;
					colorLevels[10] = .667;
					colorLevels[15] = 1.0;
					
				}
			}
		} catch (CAXException e) {
			char buf[256];
			fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
		}
		*/
	}
}

#pragma mark -RIO Render Callback

static OSStatus	PerformThru(
							void						*inRefCon,
							AudioUnitRenderActionFlags 	*ioActionFlags,
							const AudioTimeStamp 		*inTimeStamp,
							UInt32 						inBusNumber,
							UInt32 						inNumberFrames,
							AudioBufferList 			*ioData)
{
    //DDLogCVerbose(@"performThru - timestamp=%f numberFrames=%lu", inTimeStamp->mSampleTime, inNumberFrames);
    
    LOOSoundViewController *THIS = (__bridge LOOSoundViewController *)inRefCon;
	OSStatus err = AudioUnitRender(THIS->rioUnit, ioActionFlags, inTimeStamp, 1, inNumberFrames, ioData);
	if (err) { printf("PerformThru: error %d\n", (int)err); return err; }
	
		
    if (THIS->fftBufferManager->NeedsNewAudioData())
        THIS->fftBufferManager->GrabAudioData(ioData);
	
	return 0;
}


@end
