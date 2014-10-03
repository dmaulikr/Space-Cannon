//
//  CCAppDelegate.m
//  Space Cannon
//
//  Created by Raghav Mangrola on 5/10/14.
//  Copyright (c) 2014 Raghav Mangrola. All rights reserved.
//

#import "CCAppDelegate.h"
#import "CCMyScene.h"
#import <SpriteKit/SpriteKit.h>
#import "Crittercism.h"

@implementation CCAppDelegate

-(SKView*)getSKViewSubview{
    for (UIView* s in self.window.rootViewController.view.subviews) {
        if ([s isKindOfClass:[SKView class]]) {
            return (SKView*)s;
        }
    }
    return nil;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [Crittercism enableWithAppID:@"542c24c6d478bc076d000004"];
    [self startAudio];
    return YES;
    
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    SKView *view = (SKView*)self.window.rootViewController.view;
    
//    SKView* view = [self getSKViewSubview];
    ((CCMyScene*)view.scene).gamePaused = YES;
    
    // Prevent Audio Crash

//    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    
//    SKView *view = (SKView*)self.window.rootViewController.view;
//    view.paused = YES;
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

//    SKView* view = [self getSKViewSubview];
    SKView *view = (SKView*)self.window.rootViewController.view;
    ((CCMyScene*)view.scene).gamePaused = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    // Prevent Audio Crash
//    [self deactivateAudioSession];
    
//    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    
//    SKView *view = (SKView*)self.window.rootViewController.view;
//    view.paused = YES;
    


    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
//    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [self activateAudioSession];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    SKView *view = (SKView*)self.window.rootViewController.view;
//    view.paused = YES;
//    [[AVAudioSession sharedInstance] setActive:YES error:nil];

    

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
//    [self activateAudioSession];
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self stopAudio];
}


// Flag that informs if SpriteKit should play sounds
static BOOL isAudioSessionActive = NO;

- (void)startAudio {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error = nil;
    
//    NSLog(@"%s isOtherAudioPlaying: %d, oldCategory: %@ withOptions: %d", __FUNCTION__, audioSession.otherAudioPlaying, audioSession.category, audioSession.categoryOptions);
    
    [audioSession setCategory:AVAudioSessionCategoryAmbient error:&error];
    
    if (!error) {
        [self activateAudioSession];
    } else {
//        NSLog(@"%s setCategory Error: %@", __FUNCTION__, error);
    }
    
    if (isAudioSessionActive) {
        [self observeAudioSessionNotifications:YES];
    }
}

// Class method that informs if other app(s) makes sounds
+ (BOOL)isOtherAudioPlaying {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    return audioSession.otherAudioPlaying;
}

- (void)activateAudioSession {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error = nil;
    
    [audioSession setActive:YES error:&error];
    
//    NSLog(@"%s [Main:%d] isActive: %d, isOtherAudioPlaying: %d, AVAudioSession Error: %@", __FUNCTION__, [NSThread isMainThread], isAudioSessionActive, audioSession.isOtherAudioPlaying, error);
    
    if (error) {
        // It's not enough to setActive:YES
        // We have to deactivate it effectively (without that error),
        // so try again (and again... until success).
        isAudioSessionActive = NO;
        [self activateAudioSession];
        return;
    }
    
    if (!error) {
        // We have to set this flag at the end of activation attempt to avoid playing any sound before.
        isAudioSessionActive = YES;
    } else {
        // Activation failure
        isAudioSessionActive = NO;
    }
    
//    NSLog(@"%s isActive: %d, AVAudioSession Activated with category: %@ Error: %@", __FUNCTION__, isAudioSessionActive, [audioSession category], error);
}

// Informs if SpriteKit should play sounds (SpriteKit BUG)
+ (BOOL)isAudioSessionActive {
    return isAudioSessionActive;
}

- (void)stopAudio {
    if (!isAudioSessionActive) {
        // Prevent background apps from duplicate entering if terminating an app.
        return;
    }
    
    // Start deactivation process
    [self deactivateAudioSession];
    
    // Remove observers
    [self observeAudioSessionNotifications:NO];
}

- (void)deactivateAudioSession {
    if (isAudioSessionActive) {
        // We have to set this flag before any deactivation attempt to avoid trying playing any sound underway.
        isAudioSessionActive = NO;
    }
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error = nil;
    
    //[audioSession setActive:NO error:&error];
    [audioSession setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    
//    NSLog(@"%s isActive: %d, AVAudioSession Error: %@", __FUNCTION__, isAudioSessionActive, error);
    
    if (error) {
        // It's not enough to setActive:NO
        // We have to deactivate it effectively (without that error),
        // so try again (and again... until success).
        [self deactivateAudioSession];
        return;
    } else {
        // Success
    }
}

- (void)observeAudioSessionNotifications:(BOOL)observe {
//    NSLog(@"%s YES: %d", __FUNCTION__, observe);
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    if (observe) {
        [center addObserver:self selector:@selector(handleAudioSessionInterruption:) name:AVAudioSessionInterruptionNotification object:audioSession];
        [center addObserver:self selector:@selector(handleAudioSessionRouteChange:) name:AVAudioSessionRouteChangeNotification object:audioSession];
        [center addObserver:self selector:@selector(handleAudioSessionMediaServicesWereLost:) name:AVAudioSessionMediaServicesWereLostNotification object:audioSession];
        [center addObserver:self selector:@selector(handleAudioSessionMediaServicesWereReset:) name:AVAudioSessionMediaServicesWereResetNotification object:audioSession];
    } else {
        [center removeObserver:self name:AVAudioSessionInterruptionNotification object:audioSession];
        [center removeObserver:self name:AVAudioSessionRouteChangeNotification object:audioSession];
        [center removeObserver:self name:AVAudioSessionMediaServicesWereLostNotification object:audioSession];
        [center removeObserver:self name:AVAudioSessionMediaServicesWereResetNotification object:audioSession];
    }
}

- (void)handleAudioSessionInterruption:(NSNotification *)notification {
    AVAudioSession *audioSession = (AVAudioSession *)notification.object;
    
    AVAudioSessionInterruptionType interruptionType =
    (AVAudioSessionInterruptionType)[[notification.userInfo objectForKey:AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    
    AVAudioSessionInterruptionOptions interruptionOption =
    (AVAudioSessionInterruptionOptions)[[notification.userInfo objectForKey:AVAudioSessionInterruptionOptionKey] unsignedIntegerValue];
    
    BOOL isAppActive = ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)?YES:NO;
    
    switch (interruptionType) {
        case AVAudioSessionInterruptionTypeBegan: {
            [self deactivateAudioSession];
            break;
        }
            
        case AVAudioSessionInterruptionTypeEnded: {
            [self activateAudioSession];
            if (interruptionOption == AVAudioSessionInterruptionOptionShouldResume) {
                // Do your resume routine
            }
            break;
        }
            
        default:
            break;
    }
    
//    NSLog(@"%s [Main:%d] [Active: %d] AVAudioSession Interruption: %@ withInfo: %@", __FUNCTION__, [NSThread isMainThread], isAppActive, notification.object, notification.userInfo);
}

- (void)handleAudioSessionRouteChange:(NSNotification*)notification {
    
    AVAudioSessionRouteChangeReason routeChangeReason =
    (AVAudioSessionRouteChangeReason)[[notification.userInfo objectForKey:AVAudioSessionRouteChangeReasonKey] unsignedIntegerValue];
    
    AVAudioSessionRouteDescription *routeChangePreviousRoute =
    (AVAudioSessionRouteDescription *)[notification.userInfo objectForKey:AVAudioSessionRouteChangePreviousRouteKey];
    
//    NSLog(@"%s routeChangePreviousRoute: %@", __FUNCTION__, routeChangePreviousRoute);
    
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonUnknown:
//            NSLog(@"%s routeChangeReason: AVAudioSessionRouteChangeReasonUnknown", __FUNCTION__);
            break;
            
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            // e.g. a headset was added or removed
//            NSLog(@"%s routeChangeReason: AVAudioSessionRouteChangeReasonNewDeviceAvailable", __FUNCTION__);
            break;
            
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            // e.g. a headset was added or removed
//            NSLog(@"%s routeChangeReason: AVAudioSessionRouteChangeReasonOldDeviceUnavailable", __FUNCTION__);
            break;
            
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
//            NSLog(@"%s routeChangeReason: AVAudioSessionRouteChangeReasonCategoryChange", __FUNCTION__);
            break;
            
        case AVAudioSessionRouteChangeReasonOverride:
//            NSLog(@"%s routeChangeReason: AVAudioSessionRouteChangeReasonOverride", __FUNCTION__);
            break;
            
        case AVAudioSessionRouteChangeReasonWakeFromSleep:
//            NSLog(@"%s routeChangeReason: AVAudioSessionRouteChangeReasonWakeFromSleep", __FUNCTION__);
            break;
            
        case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory:
//            NSLog(@"%s routeChangeReason: AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory", __FUNCTION__);
            break;
            
        case AVAudioSessionRouteChangeReasonRouteConfigurationChange:
//            NSLog(@"%s routeChangeReason: AVAudioSessionRouteChangeReasonRouteConfigurationChange", __FUNCTION__);
            break;
            
        default:
            break;
    }
}

-(void)handleAudioSessionMediaServicesWereReset:(NSNotification *)notification {
//    NSLog(@"%s [Main:%d] Object: %@ withInfo: %@", __FUNCTION__, [NSThread isMainThread], notification.object, notification.userInfo);
}

-(void)handleAudioSessionMediaServicesWereLost:(NSNotification *)notification {
//    NSLog(@"%s [Main:%d] Object: %@ withInfo: %@", __FUNCTION__, [NSThread isMainThread], notification.object, notification.userInfo);
}


@end
