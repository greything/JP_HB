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
    
    UIImageView * bg_a = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,1024,768)];
    bg_a.image = [UIImage imageNamed:@"HB_Background_FPO.jpg"];
    
    [self.view addSubview:bg_a];
    
    
    counter = 0;
    displayLink = [CADisplayLink displayLinkWithTarget:self 
											  selector:@selector(update:)]; [displayLink addToRunLoop:[NSRunLoop mainRunLoop] 
																							  forMode:NSRunLoopCommonModes];
	[displayLink setFrameInterval:1];
    
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], @"synth1.wav" ]];
    time_track = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    time_track.numberOfLoops = -1;
    time_track.delegate = self;
    NSTimeInterval now = time_track.deviceCurrentTime;
    
    

    HouseBandTracks = [[NSMutableArray alloc] init];
    //initialize tracks
    HouseBandTrack * temp_t = [HouseBandTrack alloc];    
    for(int i = 0; i < 5; i++){
        temp_t = [HouseBandTrack alloc];
        [HouseBandTracks addObject:temp_t];
    }
    
    [[HouseBandTracks objectAtIndex:0] initTracks:@"vocals" at:now];
    [[HouseBandTracks objectAtIndex:1] initTracks:@"drums" at:now];
    [[HouseBandTracks objectAtIndex:2] initTracks:@"perc" at:now];
    [[HouseBandTracks objectAtIndex:3] initTracks:@"synth" at:now];
    [[HouseBandTracks objectAtIndex:4] initTracks:@"bass" at:now];

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
    
    [Families addObject:[[characters objectAtIndex:0] large_image]];
    [Families addObject:[[characters objectAtIndex:4] large_image]];
    [Families addObject:[[characters objectAtIndex:8] large_image]];
    [Families addObject:[[characters objectAtIndex:12] large_image]];
    [Families addObject:[[characters objectAtIndex:16] large_image]];
    
   //[self setCharacter:0];
   // [self setCharacter:4];
   // [self setCharacter:8];
   // [self setCharacter:12];
   // [self setCharacter:16];
    
    [self clearAll];
    

    [super viewDidLoad];
}

-(void) createCharacters{
    
    NSMutableArray* character_names = [[NSMutableArray alloc] init];
    
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
        [temp_char initWithPrefix:[character_names objectAtIndex:i]];
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

    
    
    [[Families objectAtIndex:family] removeFromSuperview];
    [Families replaceObjectAtIndex:family withObject:[[characters objectAtIndex:track] large_image]];
    [self.view insertSubview:[Families objectAtIndex:family] belowSubview:buttons];    
    
    
    [[HouseBandTracks objectAtIndex:family] doLoop:family_track];
    
    
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
        
        for(int i = 0; i < [HouseBandTracks count]; i++){
            [[HouseBandTracks objectAtIndex:i] stop];
        }
    }
    
}


-(void) clearAll:(id)sender{
    
    [self clearAll];
    
}

-(void) clearAll{
    
    playing = YES;

    
    for(int i = 0; i < [Families count]; i++){
        
        [[Families objectAtIndex:i] removeFromSuperview];
        [[HouseBandTracks objectAtIndex:i] muteAll];
        
    }
    
    for(int i = 0; i < [characters count]; i++){
        
        [[buttons viewWithTag:i] setAlpha:1];
        
    }
    [self stopAll];

    
    [self playAll];
}

-(void)playAll:(id)sender{
  
    [self playAll];
}

-(void)playAll{
    NSLog(@"play all action!");

    if(!playing)
    {
        playing = YES;
        
        NSTimeInterval now = time_track.deviceCurrentTime;
        
        for(int i = 0; i < [HouseBandTracks count]; i++){
            [[HouseBandTracks objectAtIndex:i] playAt:now];
        }
    }
}

-(void)playAction:(id)sender {
    
    NSLog(@"play sfx action!");
    if(one_shot_track){
        [one_shot_track stop];
        one_shot_track.currentTime = 0;
        [one_shot_track play];
    }
    
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

    [self lowerTracks];

    [recordButton setBackgroundColor:[UIColor yellowColor]];

    [self startRecording];
    NSTimer* my_timer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                     target:self
                                   selector:@selector(stopAction:)
                                   userInfo:nil
                                    repeats:NO];
    }
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
            if([touch view] == [Families objectAtIndex:i]){
                
                int ct = [[HouseBandTracks objectAtIndex:i] current_track];
                [[HouseBandTracks objectAtIndex:i] doLoop:ct];
                    
            }
        }
        
    }
}


- (void) update:(CADisplayLink*)displayLink {
    
    float track0_vol = [[HouseBandTracks objectAtIndex:0] getCurrentVol];
    float track1_vol = [[HouseBandTracks objectAtIndex:1] getCurrentVol];
    float track2_vol = [[HouseBandTracks objectAtIndex:2] getCurrentVol];
    float track3_vol = [[HouseBandTracks objectAtIndex:3] getCurrentVol];
    float track4_vol = [[HouseBandTracks objectAtIndex:4] getCurrentVol];

    CGPoint q1_center = CGPointMake(130 + track0_vol, 500);
    CGPoint q2_center = CGPointMake(600, 610 + track1_vol);
    CGPoint q3_center = CGPointMake(620 - track2_vol, 400);
    CGPoint q4_center = CGPointMake(520 - track3_vol, 200);
    CGPoint q5_center = CGPointMake(870 + track4_vol, 400);

    UIImageView * temp_view = [Families objectAtIndex:0];
    temp_view.center = q1_center;
    
    temp_view = [Families objectAtIndex:1];
    
    temp_view.center = q2_center;
    
    temp_view = [Families objectAtIndex:2];
    temp_view.center = q3_center;
    
    temp_view = [Families objectAtIndex:3];
    temp_view.center = q4_center;
    
    temp_view = [Families objectAtIndex:4];
    temp_view.center = q5_center;

    
    float rest_opacity = .5;
    float neg_scale = 50.0;

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
