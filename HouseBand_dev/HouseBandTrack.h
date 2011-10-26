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
    AVAudioPlayer *track5;
    
}
@property (nonatomic, retain) AVAudioPlayer *track1;
@property (nonatomic, retain) AVAudioPlayer *track2;
@property (nonatomic, retain) AVAudioPlayer *track3;
@property (nonatomic, retain) AVAudioPlayer *track4;
@property (nonatomic, retain) AVAudioPlayer *track5;

-(void)initTracks:(NSString*)prefix at:(NSTimeInterval)now;

-(void)doLoop:(int)track;
-(float)getVol:(int)track;


@end
