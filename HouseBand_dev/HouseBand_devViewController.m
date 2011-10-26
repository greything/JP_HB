//
//  HouseBand_devViewController.m
//  HouseBand_dev
//
//  Created by Marilys Ernst on 10/3/11.
//  Copyright 2011 MI Artbox, Incorporated. All rights reserved.
//

#import "HouseBand_devViewController.h"

@implementation HouseBand_devViewController


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

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    displayLink = [CADisplayLink displayLinkWithTarget:self 
											  selector:@selector(update:)]; [displayLink addToRunLoop:[NSRunLoop mainRunLoop] 
																							  forMode:NSRunLoopCommonModes];
	[displayLink setFrameInterval:1];
    
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], @"track1.mp3" ]];
    
    AVAudioPlayer* temp_track = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    temp_track.numberOfLoops = -1;
    temp_track.delegate = self;
    NSTimeInterval now = temp_track.deviceCurrentTime;

    track_a = [HouseBandTrack alloc];
    track_b = [HouseBandTrack alloc];
    track_c = [HouseBandTrack alloc];
    track_d = [HouseBandTrack alloc];
    
    [track_a initTracks:@"track" at:now];
    [track_b initTracks:@"perc" at:now];
    [track_c initTracks:@"bass" at:now];
    [track_d initTracks:@"chords" at:now];
    
    [track_a doLoop:0];
    [track_b doLoop:0];
    [track_c doLoop:0];
    [track_d doLoop:0];
    
    loop1 = [[UIView alloc] initWithFrame:CGRectMake(0,0,80,80)];
    loop1.backgroundColor = [UIColor redColor];
    loop1.userInteractionEnabled = YES;
    [self.view addSubview:loop1];
    [loop1 release];
    
    loop2 = [[UIView alloc] initWithFrame:CGRectMake(0,80,80,80)];
    loop2.backgroundColor = [UIColor blueColor];
    loop2.userInteractionEnabled = YES;
    [self.view addSubview:loop2];
    [loop2 release];
    
    loop3 = [[UIView alloc] initWithFrame:CGRectMake(0,160,80,80)];
    loop3.backgroundColor = [UIColor greenColor];
    loop3.userInteractionEnabled = YES;
    [self.view addSubview:loop3];
    [loop3 release];
    
    loop4 = [[UIView alloc] initWithFrame:CGRectMake(0,300,80,80)];
    loop4.backgroundColor = UIColorFromRGB(0xCECECE);
    loop4.userInteractionEnabled = YES;
    [self.view addSubview:loop4];
    [loop4 release];
    
    loop5 = [[UIView alloc] initWithFrame:CGRectMake(0,380,80,80)];
    loop5.backgroundColor = [UIColor blueColor];
    loop5.userInteractionEnabled = YES;
    [self.view addSubview:loop5];
    [loop5 release];
    
    loop6 = [[UIView alloc] initWithFrame:CGRectMake(0,460,80,80)];
    loop6.backgroundColor = [UIColor greenColor];
    loop6.userInteractionEnabled = YES;
    [self.view addSubview:loop6];
    [loop6 release];
    
    loop7 = [[UIView alloc] initWithFrame:CGRectMake(0,600,80,80)];
    loop7.backgroundColor = [UIColor redColor];
    loop7.userInteractionEnabled = YES;
    [self.view addSubview:loop7];
    [loop7 release];
    
    loop8 = [[UIView alloc] initWithFrame:CGRectMake(0,680,80,80)];
    loop8.backgroundColor = [UIColor blueColor];
    loop8.userInteractionEnabled = YES;
    [self.view addSubview:loop8];
    [loop8 release];
    
    loop9 = [[UIView alloc] initWithFrame:CGRectMake(0,760,80,80)];
    loop9.backgroundColor = [UIColor greenColor];
    loop9.userInteractionEnabled = YES;
    [self.view addSubview:loop9];
    [loop9 release];
    
    loop10 = [[UIView alloc] initWithFrame:CGRectMake(160,0,80,80)];
    loop10.backgroundColor = [UIColor redColor];
    loop10.userInteractionEnabled = YES;
    [self.view addSubview:loop10];
    [loop10 release];
    
    loop11 = [[UIView alloc] initWithFrame:CGRectMake(160,80,80,80)];
    loop11.backgroundColor = [UIColor blueColor];
    loop11.userInteractionEnabled = YES;
    [self.view addSubview:loop11];
    [loop11 release];
    
    loop12 = [[UIView alloc] initWithFrame:CGRectMake(160,160,80,80)];
    loop12.backgroundColor = [UIColor greenColor];
    loop12.userInteractionEnabled = YES;
    [self.view addSubview:loop12];
    [loop12 release];
    
    [super viewDidLoad];
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
        
        if ([touch view] == loop1) {
            [track_a doLoop:0];
        }
        else if ([touch view] == loop2) {
            [track_a doLoop:1];
        }	
        else if ([touch view] == loop3) {
            [track_a doLoop:2];
        }
        
        if ([touch view] == loop4) {
            [track_b doLoop:0];
        }
        else if ([touch view] == loop5) {
            [track_b doLoop:1];
        }	
        else if ([touch view] == loop6) {
            [track_b doLoop:2];
        }
        
        if ([touch view] == loop7) {
            [track_c doLoop:0];
        }
        else if ([touch view] == loop8) {
            [track_c doLoop:1];
        }	
        else if ([touch view] == loop9) {
            [track_c doLoop:2];
        }
        
        if ([touch view] == loop10) {
            [track_d doLoop:0];
        }
        else if ([touch view] == loop11) {
            [track_d doLoop:1];
        }	
        else if ([touch view] == loop12) {
            [track_d doLoop:2];
        }

        
    }
	
	    
}


-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
	[self touchesBegan:touches withEvent:event];
	
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	
	
}


- (void) update:(CADisplayLink*)displayLink {
    
    float loop1level = [track_a getVol:0];
    float loop2level = [track_a getVol:1];
    float loop3level = [track_a getVol:2];
    
    float loop4level = [track_b getVol:0];
    float loop5level = [track_b getVol:1];
    float loop6level = [track_b getVol:2];
    
    float loop7level = [track_c getVol:0];
    float loop8level = [track_c getVol:1];
    float loop9level = [track_c getVol:2];
    
    float loop10level = [track_d getVol:0];
    float loop11level = [track_d getVol:1];
    float loop12level = [track_d getVol:2];

    
    loop1.center = CGPointMake(200 + loop1level, loop1.center.y);
    loop2.center = CGPointMake(200 + loop2level, loop2.center.y);
    loop3.center = CGPointMake(200 + loop3level, loop3.center.y);
    
    loop4.center = CGPointMake(200 + loop4level, loop4.center.y);
    loop5.center = CGPointMake(200 + loop5level, loop5.center.y);
    loop6.center = CGPointMake(200 + loop6level, loop6.center.y);
    
    loop7.center = CGPointMake(200 + loop7level, loop7.center.y);
    loop8.center = CGPointMake(200 + loop8level, loop8.center.y);
    loop9.center = CGPointMake(200 + loop9level, loop9.center.y);
    
    loop10.center = CGPointMake(400 + loop10level, loop10.center.y);
    loop11.center = CGPointMake(400 + loop11level, loop11.center.y);
    loop12.center = CGPointMake(400 + loop12level, loop12.center.y);


}


@end
