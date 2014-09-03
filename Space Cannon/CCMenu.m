//
//  CCMenu.m
//  Space Cannon
//
//  Created by Raghav Mangrola on 7/14/14.
//  Copyright (c) 2014 Raghav Mangrola. All rights reserved.
//

#import "CCMenu.h"

@implementation CCMenu
{
    SKLabelNode *_scoreLabel;
    SKLabelNode *_topScoreLabel;
    SKSpriteNode *_title;
    SKSpriteNode *_scoreboard;
    SKSpriteNode *_playButton;
    SKSpriteNode *_testButton;
    SKSpriteNode *_musicButton;
}

- (id) init
{
    self = [super init];
    if (self) {
        _title = [SKSpriteNode spriteNodeWithImageNamed:@"Title"];
        _title.position = CGPointMake(0, 140);
        [self addChild:_title];
        
        _scoreboard = [SKSpriteNode spriteNodeWithImageNamed:@"ScoreBoard"];
        _scoreboard.position = CGPointMake(0, 70);
        [self addChild:_scoreboard];
        
        _playButton = [SKSpriteNode spriteNodeWithImageNamed:@"PlayButton"];
        _playButton.name = @"Play";
        _playButton.position = CGPointMake(0, 0);
        [self addChild:_playButton];
        
        _musicButton = [SKSpriteNode spriteNodeWithImageNamed:@"MusicOnButton"];
        _musicButton.name = @"Music";
        _musicButton.position = CGPointMake(90, 0);
        [self addChild:_musicButton];
        
//        _testButton = [SKSpriteNode spriteNodeWithImageNamed:@"NewEasyButtonAlt"];
//        _testButton.name = @"Test";
//        _testButton.position = CGPointMake(0, -50);
//        [self addChild:_testButton];
        
        _scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"DIN Alternate"];
        _scoreLabel.fontSize = 30;
        _scoreLabel.position = CGPointMake(-52, -20);
        [_scoreboard addChild:_scoreLabel];
        
        _topScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"DIN Alternate"];
        _topScoreLabel.fontSize = 30;
        _topScoreLabel.position = CGPointMake(48, -20);
        [_scoreboard addChild:_topScoreLabel];
        
        self.score = 0;
        self.topScore = 0;
        self.touchable = YES;
    }
    return self;
}



-(void)hide
{
    self.touchable = NO;
    
    SKAction *animateMenu = [SKAction scaleTo:0.0 duration:0.5];
    animateMenu.timingMode = SKActionTimingEaseIn;
    [self runAction:animateMenu completion:^{
        self.hidden = YES;
        self.xScale = 1.0;
        self.yScale = 1.0;
    }];
}

-(void)show
{
    self.hidden = NO;
    self.touchable = NO;
    
    SKAction *fadeIn = [SKAction fadeInWithDuration:0.5];
    
    _title.position = CGPointMake(0, 280);
    _title.alpha = 0;
    SKAction *animateTitle = [SKAction group:@[[SKAction moveToY:140 duration:0.5],
                                               fadeIn]];
    animateTitle.timingMode = SKActionTimingEaseOut;
    [_title runAction:animateTitle];
    
    _scoreboard.xScale = 4.0;
    _scoreboard.yScale = 4.0;
    _scoreboard.alpha = 0;
    SKAction *animateScoreBoard = [SKAction group:@[[SKAction scaleTo:1.0 duration:0.5], fadeIn]];
    animateScoreBoard.timingMode = SKActionTimingEaseOut;
    [_scoreboard runAction:animateScoreBoard];
    
    _playButton.alpha = 0.0;
    SKAction *animatePlayButton = [SKAction fadeInWithDuration:2.0];
    animatePlayButton.timingMode = SKActionTimingEaseIn;
    [_playButton runAction:animatePlayButton completion:^{
        self.touchable = YES;
    }];
    
    _testButton.alpha = 0.0;
    [_testButton runAction:animatePlayButton];
    
    _musicButton.alpha = 0.0;
    [_musicButton runAction:animatePlayButton];
    
    
    self.touchable = YES;
    
}

-(void)setMusicPlaying:(BOOL)musicPlaying
{
    _musicPlaying = musicPlaying;
    if (_musicPlaying) {
        _musicButton.texture = [SKTexture textureWithImageNamed:@"MusicOnButton"];
    } else {
        _musicButton.texture = [SKTexture textureWithImageNamed:@"MusicOffButton"];
    }
}

-(void)setScore:(int)score
{
    _score = score;
    _scoreLabel.text = [[NSNumber numberWithInt:score] stringValue];
}

-(void)setTopScore:(int)topScore
{
    _topScore = topScore;
    _topScoreLabel.text = [[NSNumber numberWithInt:topScore] stringValue];
}

@end
