//
//  CCBall.m
//  Space Cannon
//
//  Created by Raghav Mangrola on 8/10/14.
//  Copyright (c) 2014 Raghav Mangrola. All rights reserved.
//

#import "CCBall.h"

@implementation CCBall

-(void)updateTrail
{
    if (self.trail) {
        self.trail.position = self.position;
    }
}

-(void)removeFromParent
{
    if (self.trail) {
        self.trail.particleBirthRate = 0.0;
        
        SKAction *removeTrail = [SKAction sequence:@[[SKAction waitForDuration:self.trail.particleLifetime +
                                                                               self.trail.particleLifetimeRange],
                                                     [SKAction removeFromParent]]];
    }
    
    [super removeFromParent];
}

@end
