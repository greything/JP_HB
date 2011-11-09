//
//  HouseBand_devViewController.h
//  HouseBand_dev
//
//  Created by Marilys Ernst on 10/3/11.
//  Copyright 2011 MI Artbox, Incorporated. All rights reserved.
// a change

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#include <AudioToolbox/AudioToolbox.h>

#import "HouseBandTrack.h";
#import "HouseCharacter.h";

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface HouseBand_devViewController : UIViewController <AVAudioPlayerDelegate> {
	CADisplayLink *displayLink;
    
    HouseBandTrack* track_a;
    HouseBandTrack* track_b;
    HouseBandTrack* track_c;
    HouseBandTrack* track_d;
    HouseBandTrack* track_e;
    
    AVAudioPlayer *one_shot_track;
    
    int counter;
    
    UIButton *recordButton;
    
    NSMutableArray *characters;  
    
    NSMutableArray *HouseBandTracks;       
    
    NSMutableArray *Families;                                                        


    
    NSMutableDictionary* recordSetting;
    NSString* recorderFilePath;
    AVAudioRecorder* recorder;
    
    AVAudioPlayer* time_track;
    
    UIView* buttons;
    
    bool recording;
    
    CGPoint buttons_touch;
    int buttons_offset;
}

@property (nonatomic, retain) AVAudioPlayer *one_shot_track;
- (void) startRecording;
- (void) stopRecording;
-(void) stopAll:(id)sender;
- (void) chooseCharacter:(id)sender;


@end
