//
//  HouseBand_devViewController.h
//  HouseBand_dev
//
//  Created by Marilys Ernst on 10/3/11.
//  Copyright 2011 MI Artbox, Incorporated. All rights reserved.
// a change

#import <UIKit/UIKit.h>
//#import <AVFoundation/AVFoundation.h>
#include <AudioToolbox/AudioToolbox.h>

#import "HouseBandTrack.h";
#import "HouseCharacter.h";

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

typedef struct {
    int write_pos;//array index writing. set to zero for auto record
    int read_pos;
    bool recording;//booleans for states
    bool playing;
    bool in_step;
    
    bool cleared;
    
    float envelope;
    float windower;//float that windows the start and end of the buffer
    
    int playback_offset;
        
    AudioSampleType buffer[455300];//sample buffer should equal step buffer size
} SampleStep;

typedef struct {
	AudioUnit rioUnit;
	AudioStreamBasicDescription asbd;
    
    int spm; //total samples (mono for 4/4 tempo)
    int mpos; //position in playback of measure (use this for exact timing);
    int step_size;
    
    //Global envelopes, maybe make struct later
    float e_attack_1;
    float e_sustain_1;
    float e_release_1;
    
    float e_attack_2;
    float e_sustain_2;
    float e_release_2; //not yet used
    
    //Need a more elegant solution
    float level1;//level of left side
    float level2;//level of right side
    
    //Boolean states for delay or not
    bool delay_1_on;
    bool delay_2_on;
    
    bool playing;//transport playback
    
    float swing; //between 0 and 1 for min to max swing.
    
    AudioSampleType delayBuffer[132300];
    int delayPos;
    int delaySize;
    int delayTime;
    
    bool tempoSync;
    
    int desiredDelayTime;
    
    float delayFeedback;
    SampleStep sampleSteps[32];
    
    bool stepNeedsWaveform[32];
    
    int num_tracks;
    int step_buffer_size;
    
    
    
    
} EffectState;

AudioSampleType TPMixSamples(AudioSampleType a, AudioSampleType b);

@interface HouseBand_devViewController : UIViewController <AVAudioPlayerDelegate> {
	CADisplayLink *displayLink;
    
   // HouseBandTrack* track_a;
   // HouseBandTrack* track_b;
   // HouseBandTrack* track_c;
   // HouseBandTrack* track_d;
   // HouseBandTrack* track_e;
    
   // AVAudioPlayer *one_shot_track;
    
    int counter;
    
    UIButton *recordButton;
    
    NSMutableArray *characters;  
    
    NSMutableArray *HouseBandTracks;       
    
    NSMutableArray *Families;                                                        


    
    NSMutableDictionary* recordSetting;
    NSString* recorderFilePath;
    AVAudioRecorder* recorder;
    
    //AVAudioPlayer* time_track;
    
    UIView* buttons;
    
    bool recording;
    bool playing;
    
    CGPoint buttons_touch;
    int buttons_offset;
    
    
    //audio stuff
	AUGraph auGraph;
	AudioUnit remoteIOUnit;
	Float64 hardwareSampleRate;
	EffectState effectState;
    Float64 tempo;
    
    
    IBOutlet UILabel* tempo_label;
    
    
    IBOutlet UISlider* delayTime;
    
    
    bool edit_mode;
    
    NSMutableArray *stepButtons;   


}

@property (nonatomic, retain) AVAudioPlayer *one_shot_track;
- (void) startRecording;
- (void) stopRecording;
-(void) stopAll:(id)sender;
- (void) chooseCharacter:(id)sender;
@property (nonatomic) AudioUnit	remoteIOUnit;
-(void) readFile:(NSString*)name toTrack:(int)track;

@end
