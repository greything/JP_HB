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

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface HouseBand_devViewController : UIViewController <AVAudioPlayerDelegate> {
	CADisplayLink *displayLink;
    
    HouseBandTrack* track_a;
    HouseBandTrack* track_b;
    HouseBandTrack* track_c;
    HouseBandTrack* track_d;
    
    AVAudioPlayer *one_shot_track;

    UIView* loop1;
    UIView* loop2;
    UIView* loop3;
    UIView* loop4;
    UIView* loop5;
    UIView* loop6;
    UIView* loop7;
    UIView* loop8;
    UIView* loop9;
    UIView* loop10;
    UIView* loop11;
    UIView* loop12;
    
    int counter;
    
    UIButton *recordButton;

    
    NSMutableDictionary* recordSetting;
    NSString* recorderFilePath;
    AVAudioRecorder* recorder;
}

@property (nonatomic, retain) AVAudioPlayer *one_shot_track;
- (void) startRecording;
- (void) stopRecording;

@end
