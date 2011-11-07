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
    
    [self setUpDirectory];
    
    counter = 0;
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
    
    [track_a initTracks:@"drums" at:now];
    [track_b initTracks:@"perc" at:now];
    [track_c initTracks:@"bass" at:now];
    [track_d initTracks:@"synth" at:now];
    
    [track_a doLoop:0];
    [track_b doLoop:0];
    [track_c doLoop:0];
    [track_d doLoop:0];
    
        
    UIButton *playButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    playButton.frame = CGRectMake(10.0, 360.0, 100.0, 30.0);
    [playButton setBackgroundColor:[UIColor greenColor]];
   // [playButton setBackgroundImage:[UIImage imageNamed:@"211502_801679_5924406_q.jpg"] forState:UIControlStateNormal];
    [playButton setTitle:@"Play" forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playButton];  
    
    recordButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    
    recordButton.frame = CGRectMake(10.0, 460.0, 100.0, 30.0);
    [recordButton setBackgroundColor:[UIColor redColor]];

    [recordButton setTitle:@"Record" forState:UIControlStateNormal];
    [recordButton addTarget:self action:@selector(startAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recordButton]; 
    
    int ui_loop_width = 220;
    int ui_loop_height = 220;
    
    int column_width = 230;
    int column_height = 230;
    
    int button_offset_x = 120;
    int button_offset_y = 34;
    
    int current_column = 0;
    
    int new_x = button_offset_x + (current_column * column_width);
    int new_y = button_offset_y + (0 * column_height);

    
    loop1 = [[UIView alloc] initWithFrame:CGRectMake(new_x,new_y,ui_loop_width,ui_loop_height)];
    loop1.backgroundColor = [UIColor redColor];
    loop1.userInteractionEnabled = YES;
    [self.view addSubview:loop1];
    [loop1 release];
    
    
    new_x = button_offset_x + (current_column * column_width);
    new_y = button_offset_y + (1 * column_height);
    loop2 = [[UIView alloc] initWithFrame:CGRectMake(new_x,new_y,ui_loop_width,ui_loop_height)];
    loop2.backgroundColor = [UIColor blueColor];
    loop2.userInteractionEnabled = YES;
    [self.view addSubview:loop2];
    [loop2 release];
    
    new_x = button_offset_x + (current_column * column_width);
    new_y = button_offset_y + (2 * column_height);
    loop3 = [[UIView alloc] initWithFrame:CGRectMake(new_x,new_y,ui_loop_width,ui_loop_height)];
    loop3.backgroundColor = [UIColor greenColor];
    loop3.userInteractionEnabled = YES;
    [self.view addSubview:loop3];
    [loop3 release];
    
    
    current_column = 1;
    new_x = button_offset_x + (current_column * column_width);
    new_y = button_offset_y + (0 * column_height);
    loop4 = [[UIView alloc] initWithFrame:CGRectMake(new_x,new_y,ui_loop_width,ui_loop_height)];
    loop4.backgroundColor = UIColorFromRGB(0xCECECE);
    loop4.userInteractionEnabled = YES;
    [self.view addSubview:loop4];
    [loop4 release];
    
    new_x = button_offset_x + (current_column * column_width);
    new_y = button_offset_y + (1 * column_height);
    loop5 = [[UIView alloc] initWithFrame:CGRectMake(new_x,new_y,ui_loop_width,ui_loop_height)];
    loop5.backgroundColor = [UIColor blueColor];
    loop5.userInteractionEnabled = YES;
    [self.view addSubview:loop5];
    [loop5 release];
    
    new_x = button_offset_x + (current_column * column_width);
    new_y = button_offset_y + (2 * column_height);
    loop6 = [[UIView alloc] initWithFrame:CGRectMake(new_x,new_y,ui_loop_width,ui_loop_height)];
    loop6.backgroundColor = [UIColor greenColor];
    loop6.userInteractionEnabled = YES;
    [self.view addSubview:loop6];
    [loop6 release];
    
    current_column = 2;
    new_x = button_offset_x + (current_column * column_width);
    new_y = button_offset_y + (0 * column_height);
    loop7 = [[UIView alloc] initWithFrame:CGRectMake(new_x,new_y,ui_loop_width,ui_loop_height)];
    loop7.backgroundColor = [UIColor redColor];
    loop7.userInteractionEnabled = YES;
    [self.view addSubview:loop7];
    [loop7 release];
    
    new_x = button_offset_x + (current_column * column_width);
    new_y = button_offset_y + (1 * column_height);
    loop8 = [[UIView alloc] initWithFrame:CGRectMake(new_x,new_y,ui_loop_width,ui_loop_height)];
    loop8.backgroundColor = [UIColor blueColor];
    loop8.userInteractionEnabled = YES;
    [self.view addSubview:loop8];
    [loop8 release];
    
    new_x = button_offset_x + (current_column * column_width);
    new_y = button_offset_y + (2 * column_height);
    loop9 = [[UIView alloc] initWithFrame:CGRectMake(new_x,new_y,ui_loop_width,ui_loop_height)];
    loop9.backgroundColor = [UIColor greenColor];
    loop9.userInteractionEnabled = YES;
    [self.view addSubview:loop9];
    [loop9 release];

    current_column = 3;
    new_x = button_offset_x + (current_column * column_width);
    new_y = button_offset_y + (0 * column_height);
    loop10 = [[UIView alloc] initWithFrame:CGRectMake(new_x,new_y,ui_loop_width,ui_loop_height)];
    loop10.backgroundColor = [UIColor redColor];
    loop10.userInteractionEnabled = YES;
    [self.view addSubview:loop10];
    [loop10 release];
    
    new_x = button_offset_x + (current_column * column_width);
    new_y = button_offset_y + (1 * column_height);
    loop11 = [[UIView alloc] initWithFrame:CGRectMake(new_x,new_y,ui_loop_width,ui_loop_height)];
    loop11.backgroundColor = [UIColor blueColor];
    loop11.userInteractionEnabled = YES;
    [self.view addSubview:loop11];
    [loop11 release];
    
    new_x = button_offset_x + (current_column * column_width);
    new_y = button_offset_y + (2 * column_height);
    loop12 = [[UIView alloc] initWithFrame:CGRectMake(new_x,new_y,ui_loop_width,ui_loop_height)];
    loop12.backgroundColor = [UIColor greenColor];
    loop12.userInteractionEnabled = YES;
    [self.view addSubview:loop12];
    [loop12 release];
    
    [super viewDidLoad];
}

-(void)playAction:(id)sender {
    
    NSLog(@"play action!");
    if(one_shot_track){
        [one_shot_track stop];
        one_shot_track.currentTime = 0;
        [one_shot_track play];
        
    }
    
}

-(void)startAction:(id)sender {
    NSLog(@"start action!");

    [recordButton setBackgroundColor:[UIColor yellowColor]];

    [self startRecording];
    NSTimer* my_timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                     target:self
                                   selector:@selector(stopAction:)
                                   userInfo:nil
                                    repeats:NO];
    
}

-(void)stopAction:(id)sender {
    
    [recordButton setBackgroundColor:[UIColor redColor]];

    NSLog(@"stop action!");

    [self stopRecording];

    
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
	

	
	    
}


-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
	[self touchesBegan:touches withEvent:event];
	
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	
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

    /*
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
    */
    
    float rest_opacity = .5;
    float neg_scale = 50.0;
    
    
    loop1.alpha = rest_opacity + (loop1level / neg_scale);
    loop2.alpha = rest_opacity + (loop2level / neg_scale);
    loop3.alpha = rest_opacity + (loop3level / neg_scale);
    
    loop4.alpha = rest_opacity + (loop4level / neg_scale);
    loop5.alpha = rest_opacity + (loop5level / neg_scale);
    loop6.alpha = rest_opacity + (loop6level / neg_scale);
    
    loop7.alpha = rest_opacity + (loop7level / neg_scale);
    loop8.alpha = rest_opacity + (loop8level / neg_scale);
    loop9.alpha = rest_opacity + (loop9level / neg_scale);
    
    loop10.alpha = rest_opacity + (loop10level / neg_scale);
    loop11.alpha = rest_opacity + (loop11level / neg_scale);
    loop12.alpha = rest_opacity + (loop12level / neg_scale);
     
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

- (void) stopRecording{
    
    [recorder stop];
    
    NSURL *url = [NSURL fileURLWithPath: recorderFilePath];
    NSError *err = nil;
    NSData *audioData = [NSData dataWithContentsOfFile:[url path] options: 0 error:&err];
    if(!audioData)
        NSLog(@"audio data: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        
   // [editedObject setValue:[NSData dataWithContentsOfURL:url] forKey:editedFieldKey];   
    
    //[recorder deleteRecording];
    
    
  //  NSFileManager *fm = [NSFileManager defaultManager];
    
    err = nil;
    //[fm removeItemAtPath:[url path] error:&err];
    if(err)
        NSLog(@"File Manager: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
    
    
    /*
    UIBarButtonItem *recordButton = [[UIBarButtonItem alloc] initWithTitle:@"Record" style:UIBarButtonItemStyleBordered  target:self action:@selector(startRecording)];
    self.navigationItem.rightBarButtonItem = recordButton;
    [recordButton release];
    */
    
    //if(one_shot_track){
    //[one_shot_track release];
    //}
    NSURL *os_url = [NSURL fileURLWithPath:[url path]];
    one_shot_track = [[AVAudioPlayer alloc] initWithContentsOfURL:os_url error:nil];
    //one_shot_track.numberOfLoops = -1;
    one_shot_track.meteringEnabled = YES;
    one_shot_track.delegate = self;

    [os_url release];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag
{
    NSLog (@"audioRecorderDidFinishRecording:successfully:");
    // your actions here    
}


@end
