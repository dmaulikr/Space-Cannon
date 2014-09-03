//
//  SKAction+ATWSound.m
//  Space Cannon
//
//  Created by Raghav Mangrola on 8/30/14.
//  Copyright (c) 2014 Raghav Mangrola. All rights reserved.
//

#import "SKAction+ATWSound.h"
#import "CCAppDelegate.h"

@implementation SKAction (ATWSound)

+ (NSData *)atwDataFromSoundFileNamed:(NSString *)fileNameWithExtention {
    if (fileNameWithExtention == nil) return nil;
    
    NSData *soundData = nil;
    NSString *soundFile = [[NSBundle mainBundle] pathForResource:fileNameWithExtention ofType:nil];
    
    NSAssert(soundFile, @"No such file in mainBundle: %@", fileNameWithExtention);
    soundData = [[NSData alloc] initWithContentsOfFile:soundFile];
    
    return soundData;
}

static NSMutableSet *sATWAudioPlayersCache; // It's our cache
static dispatch_queue_t sATWAudioPlayersCacheQueue; // It's our concurrent queue of audioPlayers that are playing

+ (void)atwCacheAudioPlayer:(AVAudioPlayer *)audioPlayer {
    
    // Init cache for the first time
    if (sATWAudioPlayersCache == nil) {
        sATWAudioPlayersCache = [[NSMutableSet alloc] initWithCapacity:1];
        sATWAudioPlayersCacheQueue = dispatch_queue_create("com.AppThatWorks.SKAction+ATWSound.sATWAudioPlayersCacheQueue", DISPATCH_QUEUE_SERIAL);
    }
    
    if (audioPlayer == nil) return;
    
    // Write audioPlayer to concurrently modified cache with barrier to ensure exclusive access to the cache while the block runs.
    // Not only does it exclude all other writes to the cache while it runs, but it also excludes all other reads, making the modification safe.
    // We can skip barriers if our queue is serial (dispatch_queue_create("queue.name", DISPATCH_QUEUE_SERIAL)).
    // More about barriers in a concurrent env: https://www.mikeash.com/pyblog/friday-qa-2011-10-14-whats-new-in-gcd.html
    dispatch_barrier_async(sATWAudioPlayersCacheQueue, ^{
        [sATWAudioPlayersCache addObject:audioPlayer];
    });
    
    // Set delayed cache clear event for that audioPlayer (with barrier also to ensure exclusive access)
    double delay = [audioPlayer duration]+0.1; // +0.1 second buffer for safe sound end; adjust it/decrease if it takes too much memory for you
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(popTime, sATWAudioPlayersCacheQueue, ^(void){
        dispatch_barrier_async(sATWAudioPlayersCacheQueue, ^{
            // For safety sake, stop audioPlayer to avoid potential bad access while removing/autoreleasing.
            // It could happen if delay was nearly equal to [audioPlayer duration] (i.e. released while stopping).
            [audioPlayer stop];
            [sATWAudioPlayersCache removeObject:audioPlayer];
            NSLog(@"%s Removed: %@ , Cache: %lu", __PRETTY_FUNCTION__, audioPlayer, (unsigned long)[sATWAudioPlayersCache count]);
        });
    });
}

+ (SKAction *)atwPlaySoundWithData:(NSData *)soundData {
    // If AVAudioSession is inactive do not make any sound
    if ([CCAppDelegate isAudioSessionActive] == NO) {
        return [SKAction runBlock:^{}];
    } else {
        // Create playSoundAction which starts on concurrent queue to gain speed
        return [SKAction runBlock:^{
            NSError *error;
            AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithData:soundData error:&error];
            
            if (!error) {
                audioPlayer.numberOfLoops = 0;
                [audioPlayer play];
                
                // Cache audioPlayer to avoid autoreleasing before play end
                [SKAction atwCacheAudioPlayer:audioPlayer];
            }
            NSLog(@"%s  Added: %@ withError: %@, Cache: %lu", __PRETTY_FUNCTION__, audioPlayer, error, (unsigned long)[sATWAudioPlayersCache count]);
        } queue:sATWAudioPlayersCacheQueue];
    }
}

@end