//
//  CCMyScene.h
//  Space Cannon
//

//  Copyright (c) 2014 Raghav Mangrola. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "SKAction+ATWSound.h"
#import "CCAppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>

@interface CCMyScene : SKScene <SKPhysicsContactDelegate, AVAudioPlayerDelegate>{
    
    CCAppDelegate *applicationDelegate;
    BOOL playing ;
    BOOL interruptedOnPlayback;
    NSURL *soundFileURL;

}



@property (nonatomic) int ammo;
@property (nonatomic) int score;
@property (nonatomic) int pointValue;
@property (nonatomic) BOOL multiMode;
@property (nonatomic) BOOL gamePaused;
@property (nonatomic) BOOL paused;
@property (readwrite) BOOL playing;
@property (readwrite) BOOL interruptedOnPlayback;
@property (nonatomic, retain) NSURL *soundFileURL;



@end
