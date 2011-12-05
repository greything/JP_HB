//
//  HouseCharacter.m
//  HouseBand_dev
//
//  Created by Karl Scholz on 11/7/11.
//  Copyright (c) 2011 MI Artbox, Incorporated. All rights reserved.
//

#import "HouseCharacter.h"


@implementation HouseCharacter

@synthesize small_image;
@synthesize large_image;
@synthesize image_frame;

@synthesize cc;

@synthesize current_track;

@synthesize thumb;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)initWithPrefix:(NSString*)prefix andCenter:(CGPoint)xy{
    
    cc = CGPointMake(xy.x, xy.y);
    
    NSLog(prefix);
    
    NSString * small_image_name = [NSString stringWithFormat:@"%@%@%@", @"HB_", prefix, @"_Thumb_FPO.png"];
    small_image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:small_image_name]];
    
    NSLog(@"created small image from %@", small_image_name);

    NSString * large_image_name = [NSString stringWithFormat:@"%@%@%@", @"HB_", prefix, @"_FPO.png"];
    large_image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:large_image_name]];
    large_image.userInteractionEnabled = YES;
    
    NSLog(@"created large image from %@", large_image_name);

    thumb = [UIButton buttonWithType:UIButtonTypeCustom];
    [thumb setImage:small_image.image forState:UIControlStateNormal];
    
    image_frame = large_image.frame;
    
    thumb.frame = small_image.frame;
    
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
