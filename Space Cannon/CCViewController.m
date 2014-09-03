//
//  CCViewController.m
//  Space Cannon
//
//  Created by Raghav Mangrola on 5/10/14.
//  Copyright (c) 2014 Raghav Mangrola. All rights reserved.
//

#import "CCViewController.h"
#import "CCMyScene.h"

@implementation CCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Add view controller as observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"hideAd" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"showAd" object:nil];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = NO;
    skView.showsNodeCount = NO;
    
    // Create and configure the scene.
    SKScene * scene = [CCMyScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
    
    adView = [[ADBannerView alloc] initWithFrame:CGRectZero];
    adView.frame = CGRectOffset(adView.frame, 0, 0.0f);
    adView.delegate=self;
    [self.view addSubview:adView];
    
    self.bannerIsVisible = NO;
}

- (void)handleNotification:(NSNotification *)notification
{
    if ([notification.name isEqualToString:@"hideAd"]) {
        [self hidesBanner];
    }else if ([notification.name isEqualToString:@"showAd"]) {
        [self showsBanner];
    }
}

-(void)hidesBanner {
    
//    NSLog(@"HIDING BANNER");
    [adView setAlpha:0];
    self.bannerIsVisible = NO;
}


-(void)showsBanner {
    
//    NSLog(@"SHOWING BANNER");
    [adView setAlpha:1];
    self.bannerIsVisible = YES;
    
}


- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
