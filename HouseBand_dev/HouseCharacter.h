//
//  HouseCharacter.h
//  HouseBand_dev
//
//  Created by Karl Scholz on 11/7/11.
//  Copyright (c) 2011 MI Artbox, Incorporated. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HouseCharacter : UIViewController{

    UIImageView * small_image;
    UIImageView * large_image;
    UIButton * thumb;
    
}
@property (retain, nonatomic) UIImageView * large_image;
@property (retain, nonatomic) UIImageView * small_image;
@property (retain, nonatomic) UIButton * thumb;

-(void)initWithPrefix:(NSString*)prefix;

@end
