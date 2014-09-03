//
//  CCBall.h
//  Space Cannon
//
//  Created by Raghav Mangrola on 8/10/14.
//  Copyright (c) 2014 Raghav Mangrola. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface CCBall : SKSpriteNode

@property (nonatomic) SKEmitterNode *trail;
@property (nonatomic) int bounces;

-(void)updateTrail;



@end
