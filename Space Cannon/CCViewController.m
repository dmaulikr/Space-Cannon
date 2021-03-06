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

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"Main Screen";
}


- (void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    
    _adBanner = [[ADBannerView alloc] initWithFrame:CGRectZero];
    _adBanner.delegate = self;
    _adBanner.hidden = NO;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!_bannerIsVisible)
    {
        // If banner isn't part of view hierarchy, add it
        if (_adBanner.superview == nil)
        {
            [self.view addSubview:_adBanner];
        }
        
        _bannerIsVisible = YES;
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"Failed to retrieve ad");
    
    if (_bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        [UIView commitAnimations];
        
        
        
        _bannerIsVisible = NO;
    }
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
    
    NSLog(@"HIDING BANNER");
    [UIView beginAnimations:nil context:NULL];//initiate the animation
    [UIView setAnimationDuration:1];//make an animation 1 second long
    [_adBanner setAlpha:0];//disable the ad by making it invisible
    [UIView commitAnimations];//do the animation above
}


-(void)showsBanner {
    
    NSLog(@"SHOWING BANNER");
    [UIView beginAnimations:nil context:NULL];//initiate the animation
    [UIView setAnimationDuration:1];//make an animation 1 second long
    [_adBanner setAlpha:1];//enable the ad by making it visible
    [UIView commitAnimations];//do the animation above
    
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
