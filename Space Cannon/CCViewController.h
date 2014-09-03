//
//  CCViewController.h
//  Space Cannon
//

//  Copyright (c) 2014 Raghav Mangrola. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <iAd/iAD.h>


@interface CCViewController : UIViewController <ADBannerViewDelegate> {
    
    ADBannerView *adView;
}

@property BOOL bannerIsVisible;

-(void)showsBanner;
-(void)hidesBanner;

@end
