//
//  CCMenu.h
//  Space Cannon
//
//  Created by Raghav Mangrola on 7/14/14.
//  Copyright (c) 2014 Raghav Mangrola. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface CCMenu : SKNode

@property (nonatomic) int score;
@property (nonatomic) int topScore;
@property (nonatomic) BOOL touchable;
@property (nonatomic) BOOL musicPlaying;
-(void)hide;
-(void)show;

@end
