//
//  SKAction+ATWSound.h
//  Space Cannon
//
//  Created by Raghav Mangrola on 8/30/14.
//  Copyright (c) 2014 Raghav Mangrola. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>

@interface SKAction (ATWSound)

// Helper method to create NSData from sound file
+ (NSData *)atwDataFromSoundFileNamed:(NSString *)fileNameWithExtention;

// Method of creating sound action
+ (SKAction *)atwPlaySoundWithData:(NSData *)soundData;

@end