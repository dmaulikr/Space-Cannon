//
//  CCAppDelegate.h
//  Space Cannon
//
//  Created by Raghav Mangrola on 5/10/14.
//  Copyright (c) 2014 Raghav Mangrola. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface CCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (BOOL)isAudioSessionActive; // Informs if SpriteKit should play sounds (SpriteKit BUG)
+ (BOOL)isOtherAudioPlaying; // Informs if other app makes sounds

@end
