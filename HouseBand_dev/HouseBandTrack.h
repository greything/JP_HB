//
//  HouseBandTrack.h
//  HouseBand_dev
//
//  Created by Marilys Ernst on 10/3/11.
//  Copyright 2011 MI Artbox, Incorporated. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface HouseBandTrack : UIViewController {
    AVAudioPlayer *track1;
    AVAudioPlayer *track2;
    AVAudioPlayer *track3;
    AVAudioPlayer *track4;
    
    
    float ftrack1vol;
    float ftrack2vol;
    float ftrack3vol;
    float ftrack4vol;

    
    int current_track;
    bool all_muted;
    
}
@property(assign) int current_track;

@property (nonatomic, retain) AVAudioPlayer *track1;
@property (nonatomic, retain) AVAudioPlayer *track2;
@property (nonatomic, retain) AVAudioPlayer *track3;
@property (nonatomic, retain) AVAudioPlayer *track4;

-(void)initTracks:(NSString*)prefix at:(NSTimeInterval)now;

-(void)doLoop:(int)track;
-(float)getVol:(int)track;
-(float)getCurrentVol;

-(void)stop;
-(void)playAt:(NSTimeInterval)now;

-(void)lowerVolume;
-(void)restoreVolume;

-(void)muteAll;

@end
