//
//  HouseBandTrack.m
//  HouseBand_dev
//
//  Created by Marilys Ernst on 10/3/11.
//  Copyright 2011 MI Artbox, Incorporated. All rights reserved.
//

#import "HouseBandTrack.h"


@implementation HouseBandTrack

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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


-(void)initTracks:(NSString*)prefix at:(NSTimeInterval)now{
    
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@%@", [[NSBundle mainBundle] resourcePath], prefix, @"1.mp3" ]];
    track1 = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    track1.numberOfLoops = -1;
    track1.meteringEnabled = YES;
    track1.delegate = self;
    
    [url release];
    
    url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@%@", [[NSBundle mainBundle] resourcePath],prefix, @"2.mp3" ]];
    track2 = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    track2.numberOfLoops = -1;
    track2.meteringEnabled = YES;
    track2.delegate = self;
    
    [url release];
    
    url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@%@", [[NSBundle mainBundle] resourcePath],prefix, @"3.mp3" ]];
    track3 = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    track3.numberOfLoops = -1;
    track3.meteringEnabled = YES;
    track3.delegate = self;
    
    NSTimeInterval playbackDelay = 0;              // must be ≥ 0
    
    
    [track1 playAtTime: now + playbackDelay];
    [track2 playAtTime: now + playbackDelay];
    [track3 playAtTime: now + playbackDelay];

}

-(void)doLoop:(int)track{
    switch(track){
        case 0:
            track1.volume = 1;
            track2.volume = 0;
            track3.volume = 0;
            break;
        case 1:
            track1.volume = 0;
            track2.volume = 1;
            track3.volume = 0;
            break;
        case 2:
            track1.volume = 0;
            track2.volume = 0;
            track3.volume = 1;
            break;
    }
    
    NSLog(@"dooooooloop%i", track);
}


-(float)getVol:(int)track{
    
    float level = 0;
    
    switch(track){
        case 0:
            [track1 updateMeters];
            level = [track1 averagePowerForChannel:1] * track1.volume;
            break;
        case 1:
            [track2 updateMeters];
            level = [track2 averagePowerForChannel:1] * track2.volume;
            break;
        case 2:
            [track3 updateMeters];
            level = [track3 averagePowerForChannel:1] * track3.volume;
            break;
    }
    
    return level;
    
}

/*
 
 if(track1 != nil){
 [track1 updateMeters];
 NSLog(@"%f", [track1 averagePowerForChannel:1]);
 
 float level = [track1 averagePowerForChannel:1];
 
 if(current_focus != nil){
 
 current_focus.center = CGPointMake(200 + level, current_focus.center.y);
 
 
 }
 
 }
 */



#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

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

@end
