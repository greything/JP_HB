//
//  HouseBand_devViewController.m
//  HouseBand_dev
//
//  Created by Marilys Ernst on 10/3/11.
//  Copyright 2011 MI Artbox, Incorporated. All rights reserved.
// Some changes

#import "HouseBand_devViewController.h"

@implementation HouseBand_devViewController
@synthesize remoteIOUnit;


- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


OSStatus DalekVoiceRenderCallback (
								   void *							inRefCon,
								   AudioUnitRenderActionFlags *	ioActionFlags,
								   const AudioTimeStamp *			inTimeStamp,
								   UInt32							inBusNumber,
								   UInt32							inNumberFrames,
								   AudioBufferList *				ioData) {
	
	EffectState *effectState = (EffectState*) inRefCon;
	AudioUnit rioUnit = effectState->rioUnit;
	AudioStreamBasicDescription asbd = effectState->asbd;//karl, this is dif
	OSStatus renderErr = noErr;
	UInt32 bus1 = 1;
	
    
    //get sampleStep (will be an array eventually)
    //I want to write to the sampler and loop playback
    
	// just copy samples
	renderErr = AudioUnitRender(rioUnit,
								ioActionFlags,
								inTimeStamp,
								bus1,
								inNumberFrames,
								ioData);
	
	// walk the samples
	AudioSampleType sample = 0;
    AudioSampleType outsample = 0;
    AudioSampleType outsample_1 = 0;
    AudioSampleType outsample_2 = 0;
    
    bool someone_is_recording = NO; 
        
	for (int bufCount=0; bufCount<ioData->mNumberBuffers; bufCount++) {
		AudioBuffer buf = ioData->mBuffers[bufCount];
		// AudioSampleType* bufferedSample = (AudioSampleType*) &buf.mData;
		int currentFrame = 0;
		while ( currentFrame < inNumberFrames ) {
			// copy sample to buffer, across all channels
			//for (int currentChannel=0; currentChannel<buf.mNumberChannels; currentChannel++) {
            for (int currentChannel=0; currentChannel<1; currentChannel++) {
                
                memcpy(&sample,
                       buf.mData + (currentFrame * 2) + (currentChannel*2),
                       sizeof(AudioSampleType));
                
                for(int s = 0; s < effectState->num_tracks; s++){ 
                    
                    if(currentChannel == 0){
                        
                        /*
                         recording block:
                         write_pos travels up the line, recording. 
                         Start recording by setting write_pos to 0
                         */
                        
                        if(effectState->sampleSteps[s].write_pos < effectState->step_buffer_size){
                            
                            someone_is_recording = YES;
                            
                            effectState->sampleSteps[s].recording = YES;
                            effectState->sampleSteps[s].buffer[effectState->sampleSteps[s].write_pos] = sample;
                            effectState->sampleSteps[s].write_pos++;
                            if(effectState->sampleSteps[s].write_pos < effectState->step_buffer_size){
                                
                                effectState->stepNeedsWaveform[s] = YES;
                                
                            }
                        }
                        else{
                            effectState->sampleSteps[s].recording = NO;
                        }
                        
                        
                        /* 
                         Positioning steps
                         */
                        
                        int measure_step = s % 16;
                        
                        //sample at which playing starts for this step
                        int mpos_begin = effectState->step_size * measure_step;    
                        
                        
                        //swing by delaying odd steps 1,3,5 etc
                        if(measure_step % 2 == 1){
                            
                            mpos_begin = mpos_begin + ((float)effectState->step_size * effectState->swing);
                            
                        }
                        
                        /*
                        if(effectState->mpos > mpos_begin && effectState->mpos < mpos_begin + (effectState->step_size * 1) ){
                            
                            effectState->sampleSteps[s].playing = YES;
                            effectState->sampleSteps[s].in_step = YES;
                            
                            
                        }
                        */

                        
                                                
                        if(effectState->sampleSteps[s].playing){
                            
                            effectState->sampleSteps[s].read_pos =((2 * effectState->spm) + effectState->mpos - effectState->sampleSteps[s].playback_offset) % effectState->spm;
                            
                            int time_in = effectState->sampleSteps[s].read_pos;
                            int till_end = effectState->step_buffer_size - time_in;
                            
                            if(time_in < 100){
                                effectState->sampleSteps[s].windower = (float)time_in / 100.000;
                            }
                            else if(till_end < 100){
                                effectState->sampleSteps[s].windower = ((float)till_end / 100.000);
                            }
                            else{
                                effectState->sampleSteps[s].windower = 1;
                            }
                            
                            effectState->sampleSteps[s].read_pos++;
                            
                            //envelope
                            float float_pos = (float)effectState->sampleSteps[s].read_pos / effectState->step_buffer_size;
                            
                            
                            // tune attack sustain and release to add to one at max
                            float env = 0;
                            
                            float attack; 
                            float sustain;
                            float release;
                            
                            
                            if(s < 16){//if using envelope 1
                                
                                attack = effectState->e_attack_1; //attack is position in buffer (out of 1) at which 
                                sustain = attack + effectState->e_sustain_1;  
                                release = sustain + effectState->e_release_1;
                                
                            }
                            else{ // if using envelope 2
                                attack = effectState->e_attack_2; //attack is position in buffer (out of 1) at which 
                                sustain = attack + effectState->e_sustain_2;  
                                release = sustain + effectState->e_release_2;
                            }
                            
                            
                            if(release > 1.0){
                                
                                release = 1.0;
                                
                            }
                            
                            if(sustain > 1.0){
                                
                                sustain = 1.0;
                                
                            }
                            
                            if(float_pos < attack){
                                
                                env = float_pos / attack;
                                
                            }
                            else if(float_pos < sustain){
                                
                                env = 1.00;
                                
                            }
                            else if(float_pos < release){
                                
                                env = 1 - ((float_pos - sustain) / (release - sustain));
                                
                            }
                            
                            effectState->sampleSteps[s].envelope = env;
                            
                            
                        }
                        
                        if(effectState->sampleSteps[s].read_pos >= effectState->step_size){
                            
                            effectState->sampleSteps[s].in_step = NO;
                        }
                        
                        if(effectState->sampleSteps[s].read_pos >= effectState->step_buffer_size){
                            
                            effectState->sampleSteps[s].playing = NO;
                            effectState->sampleSteps[s].read_pos = 0;
                        }
                        
                        //read_pos is modded by buffersize, return to zero once its 
                        //effectState->sampleSteps[s].read_pos = effectState->sampleSteps[s].read_pos % 22050;
                        
                    }
                    else{
                        outsample = effectState->sampleSteps[s].buffer[effectState->sampleSteps[s].read_pos - 1]; //hack!!! so I don't deal with multiple channels. making it mono
                    }
                    
                }
                
                //this is where you create sample
                outsample_1 = 0;
                outsample_2 = 0;
                outsample = 0;
                
                for(int s = 0; s < effectState->num_tracks; s++){ 
                    float level = 0;
                    if(effectState->sampleSteps[s].playing && !effectState->sampleSteps[s].cleared){
                        if(s < 16){
                            //levels for channel 1
                            level = effectState->level1;
                            
                            outsample_1 = TPMixSamples(outsample_1, (effectState->sampleSteps[s].buffer[effectState->sampleSteps[s].read_pos]) * level * effectState->sampleSteps[s].windower * effectState->sampleSteps[s].envelope);
                            
                        }
                        else{
                            //levels for channel 2
                            level = effectState->level2;
                            
                            outsample_2 = TPMixSamples(outsample_2, (effectState->sampleSteps[s].buffer[effectState->sampleSteps[s].read_pos]) * level * effectState->sampleSteps[s].windower * effectState->sampleSteps[s].envelope);
                            
                        }
                        
                    }
				}
                
                
                //mix the two channels
                // outsample = outsample_1 + outsample_2;
                
                outsample = TPMixSamples(outsample_1, outsample_2);
                
                //calculate delayTime from desired delayTime
                
                if(effectState->desiredDelayTime != effectState->delayTime){
                    
                    //lets say each delay update comes one 60th of a second apart
                    //then we should expect to get to the new value in that long
                    
                    //44100 / 60 = 735 ... so take 735 samples to get to next value
                    
                    float difference = effectState->desiredDelayTime - effectState->delayTime;
                    float step_for_delay = difference / 735.000;
                    effectState->delayTime += (int)step_for_delay;
                    
                }
                
                
                //find position for reading from delay buffer
                int read_from = ((effectState->delayPos) - effectState->delayTime + effectState->delaySize) % effectState->delaySize;
                
                //mix in the delay
                AudioSampleType from_delay = (effectState->delayBuffer[read_from] * effectState->delayFeedback);
                
                outsample = TPMixSamples(outsample, from_delay);
                
                if(someone_is_recording){
                    
                    outsample = outsample * 0.5;
                }
                
                //now write that sample we just played back into the delaybuffer as far away as it can be
                
                AudioSampleType to_delay = 0;
                
                if(effectState->delay_1_on){
                    to_delay = TPMixSamples(to_delay, outsample_1);
                }
                if(effectState->delay_2_on){
                    to_delay = TPMixSamples(to_delay, outsample_2);
                }
                
                to_delay = TPMixSamples(to_delay, from_delay);
                
                
                
                effectState->delayBuffer[effectState->delayPos] = to_delay; // store sample
                
                if(currentChannel == 0){
                    
                    effectState->delayPos = (effectState->delayPos + 1) % effectState->delaySize;
                    
                }
                
                
				memcpy(buf.mData + (currentFrame * 2) + (currentChannel*2),
					   &outsample,
					   sizeof(AudioSampleType));
                
                //memcpy(buf.mData + (currentFrame * 2) + (1*2),&outsample,sizeof(AudioSampleType));
				
                
                
                if(currentChannel == 0){
                    
                    
                    
                    //probably need to do this in a more oranized fashion but keep track of sample position in measure here:
                    if(effectState->playing){
                        effectState->mpos++;
                        effectState->mpos = effectState->mpos % effectState->spm;
                    }
                    
                }
                
			}	
			currentFrame++;
		}
	}
	return noErr;
}

inline AudioSampleType TPMixSamples(AudioSampleType a, AudioSampleType b) {
    return  
    // If both samples are negative, mixed signal must have an amplitude between the lesser of A and B, and the minimum permissible negative amplitude
    a < 0 && b < 0 ?
    ((int)a + (int)b) - (((int)a * (int)b)/INT16_MIN) :
    
    // If both samples are positive, mixed signal must have an amplitude between the greater of A and B, and the maximum permissible positive amplitude
    ( a > 0 && b > 0 ?
     ((int)a + (int)b) - (((int)a * (int)b)/INT16_MAX)
     
     // If samples are on opposite sides of the 0-crossing, mixed signal should reflect that samples cancel each other out somewhat
     :
     a + b);
}

#pragma mark direct RIO use
#pragma mark - View lifecycle
- (void) setUpAudioSession {
    
    
    
	NSLog(@"setUpAudioSession");
	OSStatus setupAudioSessionErr=
	AudioSessionInitialize (
							NULL, // default run loop
							NULL, // default run loop mode
							// MyInterruptionHandler, // interruption callback
							nil, // interruption callback
							self); // client callback data
	NSAssert (setupAudioSessionErr == noErr, @"Couldn't initialize audio session");
	
	UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
	AudioSessionSetProperty 
	(kAudioSessionProperty_AudioCategory,
	 sizeof (sessionCategory),
	 &sessionCategory 
	 ); 	
	NSAssert (setupAudioSessionErr == noErr, @"Couldn't set audio session property");
	
	UInt32 f64PropertySize = sizeof (Float64);
	OSStatus setupErr = 
	AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareSampleRate,
							&f64PropertySize,
							&hardwareSampleRate);
	NSAssert (setupErr == noErr, @"Couldn't get current hardware sample rate");
	NSLog (@"current hardware sample rate = %f", hardwareSampleRate);
    
    // from http://www.politepix.com/forums/topic/keep-system-sounds-while-listening/
    UInt32 bluetoothInput = 1;
    OSStatus bluetoothInputStatus = AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryEnableBluetoothInput,sizeof (bluetoothInput), &bluetoothInput);
    if (bluetoothInputStatus != 0) {
        //OpenEarsLog(@"Error %d: Unable to set bluetooth input.", (int)bluetoothInputStatus);
    }
    
    UInt32 overrideCategoryDefaultToSpeaker = 1; // Re-route sound output to the main speaker.
    OSStatus overrideCategoryDefaultToSpeakerError = AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof (overrideCategoryDefaultToSpeaker), &overrideCategoryDefaultToSpeaker);
    if (overrideCategoryDefaultToSpeakerError != 0) {
        // OpenEarsLog(@"Error %d: Unable to override the default speaker.", (int)overrideCategoryDefaultToSpeakerError);
    }
    
    UInt32 allowMixing = true;
    OSStatus playbackMixStatus = AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(allowMixing), &allowMixing);
    if (playbackMixStatus != 0) {
        //OpenEarsLog(@"Error %d: Unable to set playback mix.", (int)playbackMixStatus);
    } 
    
    // end of http://www.politepix.com/forums/topic/keep-system-sounds-while-listening/
	
	// is audio input available?
	UInt32 ui32PropertySize = sizeof (UInt32);
	UInt32 inputAvailable;
	setupErr = 
	AudioSessionGetProperty(kAudioSessionProperty_AudioInputAvailable,
							&ui32PropertySize,
							&inputAvailable);
	NSAssert (setupErr == noErr, @"Couldn't get current audio input available prop");
	// NSLog (@"audio input is %@", (inputAvailable ? @"available" : @"not available"));
	if (! inputAvailable) {
		UIAlertView *noInputAlert =
		[[UIAlertView alloc] initWithTitle:@"No audio input"
								   message:@"No audio input device is currently attached"
								  delegate:nil
						 cancelButtonTitle:@"OK"
						 otherButtonTitles:nil];
		[noInputAlert show];
		[noInputAlert release];
	}
	
	/*
     // listen for changes in mic status
     setupErr = AudioSessionAddPropertyListener (
     kAudioSessionProperty_AudioInputAvailable,
     MyInputAvailableListener,
     self);
     NSAssert (setupAudioSessionErr == noErr, @"Couldn't setup audio input available prop listener");
     */
	
	setupErr = AudioSessionSetActive(true);
    NSAssert (setupAudioSessionErr == noErr, @"Couldn't set audio session active");
	
	
}

- (void) setUpAUConnectionsWithRenderCallback {
	OSStatus setupErr = noErr;
	
	// describe unit
	AudioComponentDescription audioCompDesc;
	audioCompDesc.componentType = kAudioUnitType_Output;
	audioCompDesc.componentSubType = kAudioUnitSubType_RemoteIO;
	audioCompDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
	audioCompDesc.componentFlags = 0;
	audioCompDesc.componentFlagsMask = 0;
	
	// get rio unit from audio component manager
	AudioComponent rioComponent = AudioComponentFindNext(NULL, &audioCompDesc);
	setupErr = AudioComponentInstanceNew(rioComponent, &remoteIOUnit);
	NSAssert (setupErr == noErr, @"Couldn't get RIO unit instance");
	
	// set up the rio unit for playback
	UInt32 oneFlag = 1;
	AudioUnitElement bus0 = 0;
	setupErr = 
	AudioUnitSetProperty (remoteIOUnit,
						  kAudioOutputUnitProperty_EnableIO,
						  kAudioUnitScope_Output,
						  bus0,
						  &oneFlag,
						  sizeof(oneFlag));
	NSAssert (setupErr == noErr, @"Couldn't enable RIO output");
	
	// enable rio input
	AudioUnitElement bus1 = 1;
	setupErr = AudioUnitSetProperty(remoteIOUnit,
									kAudioOutputUnitProperty_EnableIO,
									kAudioUnitScope_Input,
									bus1,
									&oneFlag,
									sizeof(oneFlag));
	NSAssert (setupErr == noErr, @"couldn't enable RIO input");
	
	/*
	 // debug - investigate the input asbd
	 AudioStreamBasicDescription hwInASBD;
	 UInt32 asbdSize = sizeof (hwInASBD);
	 setupErr = 
	 AudioUnitGetProperty(remoteIOUnit,
	 kAudioUnitProperty_StreamFormat,
	 kAudioUnitScope_Input,
	 bus1,
	 &hwInASBD,
	 &asbdSize);
	 NSLog (@"inspected input ASBD");
	 */
	
	// setup an asbd in the iphone canonical format
	AudioStreamBasicDescription myASBD;
	memset (&myASBD, 0, sizeof (myASBD));
	// myASBD.mSampleRate = 22050;
	myASBD.mSampleRate = hardwareSampleRate;
    NSLog(@"sample rate %f", hardwareSampleRate);
	myASBD.mFormatID = kAudioFormatLinearPCM;
	myASBD.mFormatFlags = kAudioFormatFlagsCanonical;
	myASBD.mBytesPerPacket = 2;
	myASBD.mFramesPerPacket = 1;
	myASBD.mBytesPerFrame = 2;
	myASBD.mChannelsPerFrame = 1;
	myASBD.mBitsPerChannel = 16;
	
	/*
	 // set format for output (bus 0) on rio's input scope
	 */
	setupErr =
	AudioUnitSetProperty (remoteIOUnit,
						  kAudioUnitProperty_StreamFormat,
						  kAudioUnitScope_Input,
						  bus0,
						  &myASBD,
						  sizeof (myASBD));
	NSAssert (setupErr == noErr, @"Couldn't set ASBD for RIO on input scope / bus 0");
	
	
	// set asbd for mic input
	setupErr =
	AudioUnitSetProperty (remoteIOUnit,
						  kAudioUnitProperty_StreamFormat,
						  kAudioUnitScope_Output,
						  bus1,
						  &myASBD,
						  sizeof (myASBD));
	NSAssert (setupErr == noErr, @"Couldn't set ASBD for RIO on output scope / bus 1");
	
	// more info on ring modulator and dalek voices at:
	// // http://homepage.powerup.com.au/~spratleo/Tech/Dalek_Voice_Primer.html
	effectState.rioUnit = remoteIOUnit;
	effectState.asbd = myASBD;
    
    //
    
    
    tempo = 93.0000;
    effectState.spm = (myASBD.mSampleRate * 60 / tempo) * 16.0000;
    
    NSLog(@"SPM is %i", effectState.spm);
    
    effectState.step_size = effectState.spm / 16.0000;
    effectState.mpos = 0; //initialize position 
    
    effectState.level1 = 1; //initialize position 
    effectState.level2 = 1; //initialize position 
    
    effectState.e_attack_1 = 0;
    effectState.e_sustain_1 = 1;
    effectState.e_release_1 = 0.01;
    
    effectState.e_attack_2 = 0;
    effectState.e_sustain_2 = 1;
    effectState.e_release_2 = 0.01;
    
    effectState.swing = 0.000; //initialize position 
    
    effectState.delayPos = 0;
    effectState.delaySize = 132300;// needs to be same as bufferLength
    effectState.delayTime = 22050;
    effectState.desiredDelayTime = 22050;
    
    effectState.step_buffer_size = (sizeof(effectState.sampleSteps[0].buffer) / sizeof(AudioSampleType));
    
    effectState.delayFeedback = 0.5;
    
    
    effectState.num_tracks = 25;
    
    
    
    //set all steps to have write_pos beyond recording
    for(int s = 0; s < effectState.num_tracks; s++){ 
        effectState.sampleSteps[s].cleared = NO;
        effectState.sampleSteps[s].read_pos = 0;
        effectState.sampleSteps[s].playback_offset = 0;
        effectState.sampleSteps[s].write_pos = effectState.step_buffer_size;
    }
    
    
    NSLog(@"Step size is %i", effectState.step_size);
    
	// set callback method
	AURenderCallbackStruct callbackStruct;
	callbackStruct.inputProc = DalekVoiceRenderCallback; // callback function
	callbackStruct.inputProcRefCon = &effectState;
	
	setupErr = 
	AudioUnitSetProperty(remoteIOUnit, 
						 kAudioUnitProperty_SetRenderCallback,
						 kAudioUnitScope_Global,
						 bus0,
						 &callbackStruct,
						 sizeof (callbackStruct));
	NSAssert (setupErr == noErr, @"Couldn't set RIO render callback on bus 0");
	
	
	setupErr =	AudioUnitInitialize(remoteIOUnit);
	NSAssert (setupErr == noErr, @"Couldn't initialize RIO unit");
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    
    //[self setUpDirectory];
    
    UIImageView * bg_a = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,1024,768)];
    bg_a.image = [UIImage imageNamed:@"HB_Background_FPO.jpg"];
    
    [self.view addSubview:bg_a];
    
    
    counter = 0;

    
    /*
    
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], @"synth1.wav" ]];
    time_track = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    time_track.numberOfLoops = -1;
    time_track.delegate = self;
    NSTimeInterval now = time_track.deviceCurrentTime;
    
    */

    
    /*
    HouseBandTracks = [[NSMutableArray alloc] init];
    //initialize tracks
    HouseBandTrack * temp_t = [HouseBandTrack alloc];    
    for(int i = 0; i < 5; i++){
        temp_t = [HouseBandTrack alloc];
        [HouseBandTracks addObject:temp_t];
    }
    */
    
    //[[HouseBandTracks objectAtIndex:0] initTracks:@"vocals" at:now];
    //[[HouseBandTracks objectAtIndex:1] initTracks:@"drums" at:now];
    //[[HouseBandTracks objectAtIndex:2] initTracks:@"perc" at:now];
    //[[HouseBandTracks objectAtIndex:3] initTracks:@"synth" at:now];
    //[[HouseBandTracks objectAtIndex:4] initTracks:@"bass" at:now];

    playing = YES;
    
    UIButton *clearAllButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    clearAllButton.frame = CGRectMake(20.0, 190.0, 70.0, 60.0);
    [clearAllButton setBackgroundColor:[UIColor purpleColor]];
    [clearAllButton setTitle:@"clear" forState:UIControlStateNormal];
    [clearAllButton addTarget:self action:@selector(clearAll:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clearAllButton];  
    
    
    UIButton *playButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    playButton.frame = CGRectMake(380.0, 190.0, 70.0, 60.0);
    [playButton setBackgroundColor:[UIColor purpleColor]];
    [playButton setTitle:@"SFX" forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playButton];  
    
    UIButton *playAllButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    playAllButton.frame = CGRectMake(300.0, 190.0, 70.0, 60.0);
    [playAllButton setBackgroundColor:[UIColor greenColor]];
    [playAllButton setTitle:@"Play" forState:UIControlStateNormal];
    [playAllButton addTarget:self action:@selector(playAll:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playAllButton];  
    
    UIButton *stopButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    stopButton.frame = CGRectMake(220.0, 190.0, 70.0, 60.0);
    [stopButton setBackgroundColor:[UIColor blueColor]];
    [stopButton setTitle:@"Stop" forState:UIControlStateNormal];
    [stopButton addTarget:self action:@selector(stopAll:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:stopButton]; 
    
    recordButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    
    recordButton.frame = CGRectMake(140.0, 190.0, 70.0, 60.0);
    [recordButton setBackgroundColor:[UIColor redColor]];
    [recordButton setTitle:@"Record" forState:UIControlStateNormal];
    [recordButton addTarget:self action:@selector(startAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recordButton]; 
        
    [self createCharacters];

    [self createButtons];
    
    
    Families = [[NSMutableArray alloc] init];
    
    [Families addObject:[characters objectAtIndex:0]];
    [Families addObject:[characters objectAtIndex:4]];
    [Families addObject:[characters objectAtIndex:8]];
    [Families addObject:[characters objectAtIndex:12]];
    [Families addObject:[characters objectAtIndex:16]];
    
    
   // [self clearAll];
    
	[self setUpAudioSession];
	[self setUpAUConnectionsWithRenderCallback];
    
    OSStatus startErr = noErr;
	startErr = AudioOutputUnitStart (remoteIOUnit);
	
	NSAssert (startErr == noErr, @"Couldn't start RIO unit");
	
	NSLog (@"Started RIO unit");
    
    NSLog(@"start tapped");
    effectState.mpos = 0;
    effectState.playing = YES;
    
    [self readFile:@"drums1" toTrack:0];
    [self readFile:@"drums2" toTrack:1];
    [self readFile:@"drums3" toTrack:2];
    [self readFile:@"drums3" toTrack:3];
    
    [self readFile:@"perc1" toTrack:4];
    [self readFile:@"perc2" toTrack:5];
    [self readFile:@"perc3" toTrack:6];
    [self readFile:@"perc3" toTrack:7];
    
    [self readFile:@"synth1" toTrack:8];
    [self readFile:@"synth2" toTrack:9];
    [self readFile:@"synth3" toTrack:10];
    [self readFile:@"synth3" toTrack:11];
    
    [self readFile:@"vocals1" toTrack:12];
    [self readFile:@"vocals2" toTrack:13];
    [self readFile:@"vocals3" toTrack:14];
    [self readFile:@"vocals3" toTrack:15];
    
    [self readFile:@"perc1" toTrack:16];
    [self readFile:@"perc2" toTrack:17];
    [self readFile:@"perc3" toTrack:18];
    [self readFile:@"perc3" toTrack:19];
    
    displayLink = [CADisplayLink displayLinkWithTarget:self 
											  selector:@selector(update:)]; [displayLink addToRunLoop:[NSRunLoop mainRunLoop] 
																							  forMode:NSRunLoopCommonModes];
	[displayLink setFrameInterval:1];
    
    [super viewDidLoad];
}

static void CheckResult(OSStatus error, const char *operation)
{
	if (error == noErr) return;
	char errorString[20]; 
	// See if it appears to be a 4-char-code 
	*(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(error); 
	if (isprint(errorString[1]) && isprint(errorString[2]) && 
		isprint(errorString[3]) && isprint(errorString[4])) { 
		errorString[0] = errorString[5] = '\''; 
		errorString[6] = '\0';
	} else 
		// No, format it as an integer 
		sprintf(errorString, "%d", (int)error);
    
	fprintf(stderr, "Error: %s (%s)\n", operation, errorString); 
	exit(1);
}




-(void) readFile:(NSString*)name toTrack:(int)track {
    
	// 1) Open an Extended Audio File
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:name ofType:@"wav"];  
    
    NSLog(@"%@", filePath);
    
	CFURLRef inputFileURL = (CFURLRef)[NSURL fileURLWithPath:filePath];
    
    
	ExtAudioFileRef fileRef;
    
	CheckResult(ExtAudioFileOpenURL(inputFileURL,
                                    &fileRef), 
				"ExtAudioFileOpenURL failed");
    
	// 2) Set up audio format
	AudioStreamBasicDescription audioFormat;
	audioFormat.mSampleRate = 44100;
	audioFormat.mFormatID = kAudioFormatLinearPCM;
	audioFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger;
	audioFormat.mBitsPerChannel = sizeof(AudioSampleType) * 8;
	audioFormat.mChannelsPerFrame = 1; // set this to 2 for stereo
	audioFormat.mBytesPerFrame = audioFormat.mChannelsPerFrame * sizeof(AudioSampleType);
	audioFormat.mFramesPerPacket = 1;
	audioFormat.mBytesPerPacket = audioFormat.mFramesPerPacket * audioFormat.mBytesPerFrame;
    
	// 3) Apply audio format to my Extended Audio File
	CheckResult(ExtAudioFileSetProperty(fileRef,
                                        kExtAudioFileProperty_ClientDataFormat, 
                                        sizeof (AudioStreamBasicDescription),
                                        &audioFormat), 
				"Couldn't set client data format on input ext file");
    
    
	// 4) Set up an AudioBufferList
	UInt32 outputBufferSize = effectState.step_buffer_size * sizeof(AudioSampleType);
    
    
	UInt32 sizePerPacket = audioFormat.mBytesPerPacket; 
	UInt32 packetsPerBuffer = outputBufferSize / sizePerPacket;
	UInt8 *outputBuffer = (UInt8 *)malloc(sizeof(UInt8 *) * outputBufferSize); 
    
	AudioBufferList* convertedData = (AudioBufferList*)malloc(sizeof(AudioBufferList)); 
    
	convertedData->mNumberBuffers = 1; 
	convertedData->mBuffers[0].mNumberChannels = audioFormat.mChannelsPerFrame; 
	convertedData->mBuffers[0].mDataByteSize = outputBufferSize;
	convertedData->mBuffers[0].mData = outputBuffer;
    
	// 5) Read Extended Audio File into AudioBufferList with ExtAudioFileRead()
	UInt32 frameCount = packetsPerBuffer;
    
    NSLog(@"About to read file, %i", (int)packetsPerBuffer);
    
    
    
    //for(int step = 0; step < 16; step++){
        
        /*
        SInt64 inFrameOffset = sizeof(AudioSampleType) * 2755 * step;
        ExtAudioFileSeek(fileRef, inFrameOffset);
        */
        
        CheckResult(ExtAudioFileRead(fileRef,
                                     &frameCount,
                                     convertedData), 
                    "ExtAudioFileRead failed");
        int b_p = 0;
        
        // 6) Log float values of AudioBufferList
        for( int y=0; y<convertedData->mNumberBuffers; y++ )
        {
            NSLog(@"buffer# %u", y);
            AudioBuffer audioBuffer = convertedData->mBuffers[y];
            int bufferSize = audioBuffer.mDataByteSize / sizeof(AudioSampleType);
            AudioSampleType *frame = audioBuffer.mData;
            for( int i=0; i<bufferSize; i++ ) {
                    
                    AudioSampleType currentSample = frame[i];
                    
                    //NSLog(@"printing sample data %d", currentSample);
                    effectState.sampleSteps[track].buffer[b_p] = currentSample;
                    
                    b_p++;
            }
        }
   // }
    
}





-(void) createCharacters{
    
    NSMutableArray* character_names = [[NSMutableArray alloc] init];
    CGPoint character_centers[] = {
    
        CGPointMake(150,500), //0
        CGPointMake(150,500), //1
        CGPointMake(150,600), //2
        CGPointMake(150,600), //3
        
        CGPointMake(600,610), //4
        CGPointMake(600,610), //5
        CGPointMake(600,610), //6
        CGPointMake(600,610), //7
        
        CGPointMake(620,400), //8
        CGPointMake(620,400), //9
        CGPointMake(620,380), //10
        CGPointMake(620,350), //11
        
        CGPointMake(520,200), //12
        CGPointMake(520,200), //13
        CGPointMake(520,200), //14
        CGPointMake(520,200), //15
        
        CGPointMake(870,430), //16
        CGPointMake(890,530), //17
        CGPointMake(870,490), //18
        CGPointMake(880,550) //19

    
    };

    
    [character_names addObject:@"Q1_Dad"]; 
    [character_names addObject:@"Q1_Mom"]; 
    [character_names addObject:@"Q1_Girl"]; 
    [character_names addObject:@"Q1_Boy"]; 
    
    [character_names addObject:@"Q2_Dishwasher"]; 
    [character_names addObject:@"Q2_Dryer"]; 
    [character_names addObject:@"Q2_Vaccum"]; 
    [character_names addObject:@"Q2_Washer"];     
    
    [character_names addObject:@"Q3_Computer"]; 
    [character_names addObject:@"Q3_Kettle"]; 
    [character_names addObject:@"Q3_Toaster"]; 
    [character_names addObject:@"Q3_TV"]; 
    
    [character_names addObject:@"Q4_BlowDryer"]; 
    [character_names addObject:@"Q4_Iron"]; 
    [character_names addObject:@"Q4_Ketchup"]; 
    [character_names addObject:@"Q4_SodaCan"]; 
    
    [character_names addObject:@"Q5_Fridge"]; 
    [character_names addObject:@"Q5_Garbage"]; 
    [character_names addObject:@"Q5_Oven"]; 
    [character_names addObject:@"Q5_Toilet"]; 

    characters = [[NSMutableArray alloc] init];  
    
    HouseCharacter* temp_char;
    
    for(int i = 0; i < [character_names count]; i++){
        
        temp_char = [HouseCharacter alloc];
        [temp_char initWithPrefix:[character_names objectAtIndex:i] andCenter:CGPointMake(character_centers[i].x, character_centers[i].y)];
        [characters addObject:temp_char]; 
        
    }
    
    
    NSLog(@"%i", [characters count]);

    
}

-(void) createButtons{
    
    buttons = [[UIView alloc] initWithFrame:CGRectMake(10,10,10,10)];
    buttons.tag = -1;
    [self moveButtonsTo:0];
    
    buttons.backgroundColor = [UIColor redColor];
    
    UIButton * temp_char;// = [[UIImageView alloc] initWithFrame:CGRectMake(20,20,20,20)];
    
    int new_x = 50;
    
    for(int i = 0; i < [characters count]; i++){
        
        temp_char = [[characters objectAtIndex:i] thumb];
        
        temp_char.tag = i;
        
        [temp_char addTarget:self action:@selector(chooseCharacter:) forControlEvents:UIControlEventTouchUpInside];

        temp_char.center = CGPointMake(new_x, 50);
                    
        [buttons addSubview:temp_char];
        
        if(i % 4 == 3){
            
            UIImageView * temp_line = [[UIImageView alloc] 
                                       initWithImage:[UIImage imageNamed:@"HB_Menu_Line_FPO.png"]];
            
            temp_line.center = CGPointMake(new_x + 65, 50);
            
            [buttons addSubview:temp_line];
            
        }
        
        new_x = new_x + 120;
        
    }

    [self.view addSubview:buttons];
    
    [self moveButtonsTo:0];
    
}

-(void) moveButtonsTo:(int)left{
    
    buttons.frame = CGRectMake(left, 0, 2500, 100);
    
}

-(void)chooseCharacter:(id)sender {
    
    int track = ((UIControl *) sender).tag;
    NSLog(@"Choosing character");

    [self setCharacter:track];

}

-(void) setCharacter:(int)track{
    
    
    int family = track / 4;
    int family_track = track - (family * 4);
    
    for(int i = 0; i < 4; i++){
        
        [[buttons viewWithTag:((family * 4) + i)] setAlpha:1];
        
    }
    
    [[buttons viewWithTag:track] setAlpha:0.6];
    NSLog(@"setting track %i to be translucent", track);

    
    
    [[[Families objectAtIndex:family] large_image] removeFromSuperview];
    [Families replaceObjectAtIndex:family withObject:[characters objectAtIndex:track]];
    [self.view insertSubview:[[Families objectAtIndex:family] large_image] belowSubview:buttons];    
    
    
    //[[HouseBandTracks objectAtIndex:family] doLoop:family_track];
    
    effectState.sampleSteps[(4 * family) + 0].playing = NO;
    effectState.sampleSteps[(4 * family) + 1].playing = NO;
    effectState.sampleSteps[(4 * family) + 2].playing = NO;
    effectState.sampleSteps[(4 * family) + 3].playing = NO;
    
    [[Families objectAtIndex:family] setCurrent_track:family_track];

    
    effectState.sampleSteps[(4 * family) + family_track].playing = YES;
    
    NSLog(@"button is saying to go to track %i, family is %i, making family track : %i", track, family, family_track);
    [self playAll];//if not playing, start

}

-(void)stopAll:(id)sender{
    
    [self stopAll];
    
}

-(void) stopAll{
    
    if(playing){
        playing = NO;
        
        NSLog(@"stop all action!");
        
        effectState.playing = NO;
        effectState.mpos = 0;
    }
    
}


-(void) clearAll:(id)sender{
    
    [self clearAll];
    
}

-(void) clearAll{
    
    
    for(int i = 0; i < [Families count]; i++){
        
        [[[Families objectAtIndex:i] large_image] removeFromSuperview];
        
    }
    
    for(int i = 0; i < [characters count]; i++){
        
        [[buttons viewWithTag:i] setAlpha:1];
        
    }
    
    [self muteAll];
    
    [self stopAll];
}

-(void)muteAll{
    
    for(int i = 0; i < [characters count]; i++){
    
        effectState.sampleSteps[i].playing = NO;
    
    }    
}

-(void)playAll:(id)sender{
  
    [self playAll];
}

-(void)playAll{
    NSLog(@"play all action!");

    if(!playing)
    {
        playing = YES;
        
        effectState.playing = YES;
        
        effectState.mpos = 0;
    }
}

-(void)playAction:(id)sender {
    
    NSLog(@"play sfx action!");
   /*
    if(one_shot_track){
        [one_shot_track stop];
        one_shot_track.currentTime = 0;
        [one_shot_track play];
    }
    */
}


/*
lowerTracks and restoreTracks are called to dip the volume and then return it to its previous state during and after recording.
*/
-(void)lowerTracks{
    for(int i = 0; i < [HouseBandTracks count]; i++){
        
        [[HouseBandTracks objectAtIndex:i] lowerVolume];
        
    }
}
-(void)restoreTracks{
    for(int i = 0; i < [HouseBandTracks count]; i++){
        
        [[HouseBandTracks objectAtIndex:i] restoreVolume];
        
    }
}


//Recording. Durration specified here.
-(void)startAction:(id)sender {
    
    
    NSLog(@"start action!");
    
    if(!recording){
        recording = YES;

        //[self lowerTracks];
        
        effectState.sampleSteps[20].playback_offset = effectState.mpos - 100;
        
        effectState.sampleSteps[20].write_pos = 0;
        effectState.sampleSteps[20].playing = NO;
        
        [recordButton setBackgroundColor:[UIColor yellowColor]];

    }
}

-(void)stopRecording{
    
    [recordButton setBackgroundColor:[UIColor redColor]];
    effectState.sampleSteps[20].playing = YES;
    recording = NO;
    
}

//Stop Recording, called by NSTimer in startAction
-(void)stopAction:(id)sender {
    
    [recordButton setBackgroundColor:[UIColor redColor]];

    NSLog(@"stop action!");

    [self stopRecording];
    [self restoreTracks];
    
    recording = NO;

    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	for (UITouch *touch in touches) {
        NSArray *array = touch.gestureRecognizers;
        for (UIGestureRecognizer *gesture in array) {
            if (gesture.enabled && [gesture isMemberOfClass:[UIPinchGestureRecognizer class]]) {
                gesture.enabled = NO;
            }
        }
    }
    
    NSLog(@"there are %i touches", [[event allTouches] count]);

	// get touch event
	//UITouch *touch = [[event allTouches] anyObject];
	
	// get the touch location
	//CGPoint touchLocation = [touch locationInView:self.view];
	
    for (id touch in [event allTouches]) {
        
        if([touch view] == buttons){
            
            NSLog(@"touched buttons");
            buttons_touch = [touch locationInView:self.view];
            buttons_offset = buttons.frame.origin.x;
            
        }
        
    }
	
	    
}


-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
	//[self touchesBegan:touches withEvent:event];
    
    for (id touch in [event allTouches]) {
        
        if([touch view] == buttons){
            
            [self moveButtonsTo: buttons_offset + [touch locationInView:self.view].x - buttons_touch.x];    
            
        }
        
    }
	
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	
    for (id touch in [event allTouches]) {

        for(int i = 0; i < [Families count]; i++){
            if([touch view] == [[Families objectAtIndex:i] large_image]){
                
                int cur_track = [[Families objectAtIndex:i] current_track];
                
                cur_track = (4 * i) + cur_track;
                
                NSLog(@"changing loop %i", cur_track);
                
                
                effectState.sampleSteps[cur_track].playing = playing ? !effectState.sampleSteps[cur_track].playing : YES;
                
            }
        }
        
        [self playAll];
        
    }
}

-(float)volumeOfTrack:(int)t{
    
    Float64 volume = 0;
    
    if(t != -1){
        int mpos = effectState.mpos;
        
        for(int i = mpos; i < mpos + 735; i++){
                
            if(i < effectState.spm){
            
            float sampleValue = (float)effectState.sampleSteps[t].buffer[i];
            
            volume += (sampleValue * sampleValue) * (1.000/735.000);
            }
        }
        
        volume = (float)sqrt((double)volume);
        
        volume = volume / 10000.000;
    }
    
    return(volume);
}

-(int)track_playing_from_family:(int)family{
    
    int track_playing = -1;
    
    for(int i = 0; i < 4; i++){
        
        int track = (4 * family) + i;
        
        if (effectState.sampleSteps[track].playing) {
            track_playing = track;
        }
        
    }
    return(track_playing);
}


- (void) update:(CADisplayLink*)displayLink {
    
    if(recording){
        
        if (effectState.sampleSteps[20].write_pos >= effectState.step_buffer_size) {
            
            NSLog(@"stopping recording");
            [self stopRecording];
        }
        else{
            
           // NSLog(@"Recording at %i", effectState.sampleSteps[20].write_pos );
            
        }
        
        
    }
    
    //NSLog(@"Volume is %f", [self volumeOfTrack:0]);
    
    //bool playing = effectState.sampleSteps[[[Families objectAtIndex:0] current_track]].playing;
    float track0_vol = [self volumeOfTrack:[self track_playing_from_family:0]];
    float track1_vol = [self volumeOfTrack:[self track_playing_from_family:1]];
    float track2_vol = [self volumeOfTrack:[self track_playing_from_family:2]];
    float track3_vol = [self volumeOfTrack:[self track_playing_from_family:3]];
    float track4_vol = [self volumeOfTrack:[self track_playing_from_family:4]];

    
    if(playing){
    
    CGPoint tempp = [[Families objectAtIndex:0] cc];
    CGPoint q1_center = CGPointMake(tempp.x + (track0_vol * 10), tempp.y);
    //
        
    tempp = [[Families objectAtIndex:1] cc];
    CGPoint q2_center = CGPointMake(tempp.x, tempp.y + (track1_vol * 10));
    //600, 610
        
    tempp = [[Families objectAtIndex:2] cc];    
    CGPoint q3_center = CGPointMake(tempp.x - (track2_vol * 10), tempp.y);
    //620, 400
        
    tempp = [[Families objectAtIndex:3] cc];
    CGPoint q4_center = CGPointMake(tempp.x - (track3_vol * 10), tempp.y);
    //520, 200
        
    tempp = [[Families objectAtIndex:4] cc];
    CGPoint q5_center = CGPointMake(tempp.x + (track4_vol * 10), tempp.y);
    //870, 400
    

    UIImageView * temp_view = [[Families objectAtIndex:0] large_image];
    temp_view.layer.transform = CATransform3DMakeRotation(-1 * (track0_vol * 0.1), 1,1, 0);
    temp_view.layer.zPosition = 1000;
    temp_view.center = q1_center;
    
    temp_view = [[Families objectAtIndex:1] large_image];
    
    temp_view.layer.transform = CATransform3DMakeRotation(-1 * (track1_vol * 0.1), .5,.1, 0);
    temp_view.layer.zPosition = 1000;
    temp_view.center = q2_center;
    
    temp_view = [[Families objectAtIndex:2] large_image];
    temp_view.layer.transform = CATransform3DMakeRotation((track2_vol * 0.1), .1,1, 1);
    temp_view.layer.zPosition = 1000;
    temp_view.center = q3_center;
    
    temp_view = [[Families objectAtIndex:3] large_image];
    temp_view.layer.transform = CATransform3DMakeRotation((track3_vol * 0.1), .2,0, .1);
    temp_view.layer.zPosition = 1000;
    temp_view.center = q4_center;
    

    temp_view = [[Families objectAtIndex:4] large_image];
    temp_view.layer.transform = CATransform3DMakeRotation((track4_vol * 0.1), 1,1, 0);
    temp_view.layer.zPosition = 1000;
    temp_view.center = q5_center;

    
    float rest_opacity = .5;
    float neg_scale = 50.0;
    }

    counter = counter + 1;


}

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/jp"]


-(void) setUpDirectory{
    
    NSString *path;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"jp"];
	NSError *error;	
    
	if ([[NSFileManager defaultManager] fileExistsAtPath:path])	//Does directory exist?
	{
		if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error])	//Delete it
		{
			NSLog(@"Delete directory error: %@", error);
		}
	}
    

	if (![[NSFileManager defaultManager] fileExistsAtPath:path])	//Does directory already exist?
	{
		if (![[NSFileManager defaultManager] createDirectoryAtPath:path
									   withIntermediateDirectories:NO
														attributes:nil
															 error:&error])
		{
			NSLog(@"Create directory error: %@", error);
		}
	}
    
    
}


- (void) startRecording{
    /*
    UIBarButtonItem *recordButton = [[UIBarButtonItem alloc] initWithTitle:@"Stop" style:UIBarButtonItemStyleBordered  target:self action:@selector(stopRecording)];
    self.navigationItem.rightBarButtonItem = recordButton;
    [recordButton release];
    */
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    [audioSession setActive:YES error:&err];
    err = nil;
    if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    
    recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey]; 
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    [recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    
    
    
    // Create a new dated file
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString *caldate = [now description];
    recorderFilePath = [[NSString stringWithFormat:@"%@/%@.caf", DOCUMENTS_FOLDER, caldate] retain];
    
    NSLog(recorderFilePath);
    
    NSURL *url = [NSURL fileURLWithPath:recorderFilePath];
    err = nil;
    recorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&err];
    if(!recorder){
        NSLog(@"recorder: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: [err localizedDescription]
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    
    //prepare to record
    [recorder setDelegate:self];
    [recorder prepareToRecord];
    recorder.meteringEnabled = YES;
    
    BOOL audioHWAvailable = audioSession.inputIsAvailable;
    if (! audioHWAvailable) {
        UIAlertView *cantRecordAlert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: @"Audio input hardware not available"
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [cantRecordAlert show];
        [cantRecordAlert release]; 
        return;
    }
    
    // start recording
    [recorder recordForDuration:(NSTimeInterval) 10];
    
}


- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag
{
    NSLog (@"audioRecorderDidFinishRecording:successfully:");
    // your actions here    
}


@end
