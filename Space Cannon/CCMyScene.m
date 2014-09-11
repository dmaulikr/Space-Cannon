//
//  CCMyScene.m
//  Space Cannon
//
//  Created by Raghav Mangrola on 5/10/14.
//  Copyright (c) 2014 Raghav Mangrola. All rights reserved.
//

#import "CCMyScene.h"
#import "CCMenu.h"
#import "CCBall.h"
#import <AVFoundation/AVFoundation.h>

@implementation CCMyScene
{
    AVAudioPlayer *_audioPlayer;
    SKNode *_mainLayer;
    CCMenu *_menu;
    SKSpriteNode *_cannon;
    SKSpriteNode *_ammoDisplay;
    SKSpriteNode *_pauseButton;
    SKSpriteNode *_resumeButton;
    SKLabelNode *_scoreLabel;
    SKLabelNode *_pointLabel;
    BOOL _gameOver;
    BOOL _testGame;
    BOOL _didShoot;
    int _killCount;
    NSUserDefaults *_userDefaults;
    NSMutableArray *_shieldPool;
    
}
@synthesize playing;
@synthesize interruptedOnPlayback;
@synthesize soundFileURL;

static const CGFloat kCCShootSpeed = 1000.0f;
static const CGFloat kCCHaloLowAngle = 200.0 * M_PI / 180.0;
static const CGFloat kCCHaloHighAngle = 340.0 * M_PI / 180.0;
static const CGFloat kCCHaloSpeed = 100.0;


static const uint32_t kCCHaloCategory     = 0x1 << 0;
static const uint32_t kCCBallCategory     = 0x1 << 1;
static const uint32_t kCCEdgeCategory     = 0x1 << 2;
static const uint32_t kCCShieldCateogry   = 0x1 << 3;
static const uint32_t kCCLifeBarCategory  = 0x1 << 4;
static const uint32_t kCCShieldUpCategory = 0x1 << 5;
static const uint32_t kCCMultiUpCategory  = 0x1 << 6;

static NSString * const kCCKeyTopScore = @"TopScore";

static NSData __strong *_bounceSoundData = nil;
static NSData __strong *_zapSoundData = nil;
static NSData __strong *_deepExplosionSoundData = nil;
static NSData __strong *_explosionSoundData = nil;
static NSData __strong *_laserSoundData = nil;
static NSData __strong *_shieldUpSoundData = nil;

static inline CGVector radiansToVector(CGFloat radians)
{
    CGVector vector;
    vector.dx = cosf(radians);
    vector.dy = sinf(radians);
    
    return vector;
}

static inline CGFloat randomInRange(CGFloat low, CGFloat high)
{
    // Between 0 and 1
    CGFloat value = arc4random_uniform(UINT32_MAX) / (CGFloat)UINT32_MAX;
    return value * (high - low ) + low;
}

- (void) audioPlayerDidFinishPlaying: (AVAudioPlayer *) _audioPlayer successfully: (BOOL) flag {
    
	playing = NO;
//	[appSoundButton setEnabled: YES];
}

- (void) audioPlayerBeginInterruption: player {
    
	NSLog (@"Interrupted. The system has paused audio playback.");
	
	if (playing) {
        
		playing = NO;
		interruptedOnPlayback = YES;
	}
}

- (void) audioPlayerEndInterruption: player {
    
	NSLog (@"Interruption ended. Resuming audio playback.");
	
	// Reactivates the audio session, whether or not audio was playing
	//		when the interruption arrived.
	[[AVAudioSession sharedInstance] setActive: YES error: nil];
	[_audioPlayer play];
	if (interruptedOnPlayback) {
        
		[_audioPlayer play];
		playing = YES;
		interruptedOnPlayback = NO;
	}
}

- (void) setupApplicationAudio {
	
	// Gets the file system path to the sound to play.
	NSString *soundFilePath = [[NSBundle mainBundle]	pathForResource:	@"ObservingTheStar"
                                                              ofType:				@"caf"];
    
	// Converts the sound's file path to an NSURL object
	NSURL *newURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
	self.soundFileURL = newURL;
    
	// Registers this class as the delegate of the audio session.
	[[AVAudioSession sharedInstance] setActive:YES error:nil];
	
	// The AmbientSound category allows application audio to mix with Media Player
	// audio. The category also indicates that application audio should stop playing
	// if the Ring/Siilent switch is set to "silent" or the screen locks.
	[[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryAmbient error: nil];
    /*
     // Use this code instead to allow the app sound to continue to play when the screen is locked.
     [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
     
     UInt32 doSetProperty = 0;
     AudioSessionSetProperty (
     kAudioSessionProperty_OverrideCategoryMixWithOthers,
     sizeof (doSetProperty),
     &doSetProperty
     );
     */
    
	// Activates the audio session.
	
	NSError *activationError = nil;
	[[AVAudioSession sharedInstance] setActive: YES error: &activationError];
    
	// Instantiates the AVAudioPlayer object, initializing it with the sound
	AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: soundFileURL error: nil];
	self->_audioPlayer = newPlayer;
	
	// "Preparing to play" attaches to the audio hardware and ensures that playback
	//		starts quickly when the user taps Play
	[_audioPlayer play];
	[_audioPlayer setVolume: 1.0];
    _audioPlayer.numberOfLoops = -1;
	[_audioPlayer setDelegate: self];
    _menu.musicPlaying = YES;
}



-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        // Turn off gravity.
        self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
        self.physicsWorld.contactDelegate = self;
        
        
        // Add background
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"Starfield"];
        background.position = CGPointZero;
        background.anchorPoint = CGPointZero;
        
        // Add Edges
        SKNode *leftEdge = [[SKNode alloc] init];
        leftEdge.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointZero toPoint:CGPointMake(0.0, self.size.height)];
        leftEdge.position = CGPointZero;
        leftEdge.physicsBody.categoryBitMask = kCCEdgeCategory;
        [self addChild:leftEdge];
        
        SKNode *rightEdge = [[SKNode alloc] init];
        rightEdge.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointZero toPoint:CGPointMake(0.0, self.size.height)];
        rightEdge.position = CGPointMake(self.size.width, 0);
        rightEdge.physicsBody.categoryBitMask = kCCEdgeCategory;
        [self addChild:rightEdge];
        
//        SKNode *topEdge = [[SKNode alloc] init];
//        topEdge.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointZero toPoint:CGPointMake(self.size.width, 0.0)];
//        topEdge.position = CGPointMake(0.0 , self.size.height);
//        [self addChild:topEdge];
//        
//        SKNode *bottomEdge = [[SKNode alloc] init];
//        bottomEdge.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointZero toPoint:CGPointMake(self.size.width, 0.0)];
//        bottomEdge.position = CGPointMake(0.0, 0.0);
//        [self addChild:bottomEdge];
        
        // Adds efficiency
        background.blendMode = SKBlendModeReplace;
        [self addChild:background];
        
        // Add main layer.
        _mainLayer = [[SKNode alloc] init];
        [self addChild:_mainLayer];
        
        // Add cannon.
        _cannon = [SKSpriteNode spriteNodeWithImageNamed:@"Cannon"];
        _cannon.position = CGPointMake(self.size.width * 0.5, 0.0);
        [self addChild:_cannon];
        
        // Create cannon rotation actions.
        SKAction *rotateCannon = [SKAction sequence:@[[SKAction rotateByAngle:M_PI duration:2],
                                                      [SKAction rotateByAngle:-M_PI duration:2]]];
//        SKAction *firstRotate  = [SKAction rotateByAngle:2.35619449 duration:1];
//        SKAction *rotateCannon = [SKAction sequence:@[[SKAction rotateByAngle:-1.57079633 duration:1],
//                                                      [SKAction rotateByAngle:1.57079633 duration:1]]];
//        [_cannon runAction:firstRotate];
        [_cannon runAction:[SKAction repeatActionForever:rotateCannon]];
        
        // Create spawn halo actions.
        SKAction *spawnHalo = [SKAction sequence:@[[SKAction waitForDuration:2 withRange:1],
                                                   [SKAction performSelector:@selector(spawnHalo) onTarget:self]]];
        [self runAction:[SKAction repeatActionForever:spawnHalo] withKey:@"SpawnHalo"];
        
        // Create spawn shield power up action
        SKAction *spawnShieldPowerUp = [SKAction sequence:@[[SKAction waitForDuration:15 withRange:4],
                                                            [SKAction performSelector:@selector(spawnShieldPowerUp) onTarget:self]]];
        [self runAction:[SKAction repeatActionForever:spawnShieldPowerUp]];
        
        // Setup Ammo.
        _ammoDisplay = [SKSpriteNode spriteNodeWithImageNamed:@"Ammo5"];
        _ammoDisplay.anchorPoint = CGPointMake(0.5, 0.0);
        _ammoDisplay.position = _cannon.position;
        [self addChild:_ammoDisplay];
        
        SKAction *incrementAmmo = [SKAction sequence:@[[SKAction waitForDuration:1],
                                                       [SKAction runBlock:^{
            if (!self.multiMode) {
                self.ammo++;
            }
        }]]];
        [self runAction:[SKAction repeatActionForever:incrementAmmo]];
        
        // Setup shield pool
        _shieldPool = [[NSMutableArray alloc] init];
        
        // Setup shields
        for (int i = 0; i < 6; i++) {
            SKSpriteNode *shield = [SKSpriteNode spriteNodeWithImageNamed:@"Block"];
            shield.name = @"shield";
            shield.position = CGPointMake(35 + (50 *i), 90);
            shield.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(42, 9)];
            shield.physicsBody.categoryBitMask = kCCShieldCateogry;
            shield.physicsBody.collisionBitMask = 0;
            [_shieldPool addObject:shield];
        }
        
        // Setup pause button
        _pauseButton = [SKSpriteNode spriteNodeWithImageNamed:@"PauseButton"];
        _pauseButton.position = CGPointMake(self.size.width - 30, 20);
        [self addChild:_pauseButton];
        
        // Setup resume button
        _resumeButton = [SKSpriteNode spriteNodeWithImageNamed:@"ResumeButton"];
        _resumeButton.position = CGPointMake(self.size.width * 0.5, self.size.height * 0.5);
        [self addChild:_resumeButton];
        
        //Setup score display
        _scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"DIN Alternate"];
        _scoreLabel.position = CGPointMake(15, 10);
        _scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        _scoreLabel.fontSize = 15;
        [self addChild:_scoreLabel];
        
        // Setup point multiplier label
        _pointLabel = [SKLabelNode labelNodeWithFontNamed:@"DIN Alternate"];
        _pointLabel.position = CGPointMake(15, 30);
        _pointLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        _pointLabel.fontSize = 15;
        [self addChild:_pointLabel];
        
        // Setup sounds
        // Best Practice
//        _bounceSound = [SKAction playSoundFileNamed:@"Bounce.caf" waitForCompletion:NO];
//        _deepExplosionSound = [SKAction playSoundFileNamed:@"DeepExplosion.caf" waitForCompletion:NO];
//        _explosionSound = [SKAction playSoundFileNamed:@"Explosion.caf" waitForCompletion:NO];
//        _laserSound = [SKAction playSoundFileNamed:@"Laser.caf" waitForCompletion:NO];
//        _zapSound = [SKAction playSoundFileNamed:@"Zap.caf" waitForCompletion:NO];
//        _shieldUpSound = [SKAction playSoundFileNamed:@"ShieldUp.caf" waitForCompletion:NO];
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _bounceSoundData = [SKAction atwDataFromSoundFileNamed:@"Bounce.caf"];
            _deepExplosionSoundData = [SKAction atwDataFromSoundFileNamed:@"DeepExplosion.caf"];
            _explosionSoundData = [SKAction atwDataFromSoundFileNamed:@"Explosion.caf"];
            _laserSoundData = [SKAction atwDataFromSoundFileNamed:@"Laser.caf"];
            _zapSoundData = [SKAction atwDataFromSoundFileNamed:@"Zap.caf"];
            _shieldUpSoundData = [SKAction atwDataFromSoundFileNamed:@"ShieldUp.caf"];
        });
        
        
        // Setup menu
        _menu = [[CCMenu alloc] init];
        _menu.position = CGPointMake(self.size.width * 0.5, self.size.height - 220);
        [self addChild:_menu];
        
        // Set Initial values
        self.ammo = 5;
        self.score = 0;
        self.pointValue = 1;
        _gameOver = YES;
        _scoreLabel.hidden = YES;
        _pointLabel.hidden = YES;
        _pauseButton.hidden = YES;
        _resumeButton.hidden = YES;
        
        // Load top score
        _userDefaults = [NSUserDefaults standardUserDefaults];
        _menu.topScore = [_userDefaults integerForKey:kCCKeyTopScore];
        
        [self setupApplicationAudio];

        
        
//        // Load music
//        NSURL *url = [[NSBundle mainBundle] URLForResource:@"ObservingTheStar" withExtension:@"caf"];
//        NSError *error = nil;
//        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
//
//        
//        if (!_audioPlayer) {
//            NSLog(@"Error loading audio player: %@", error);
//        }
//        else {
//            _audioPlayer.numberOfLoops = -1;
//            _audioPlayer.volume = 0.8;
//            [_audioPlayer play];
//            _menu.musicPlaying = YES;
//        }

    }

    return self;
}

#pragma mark - Shared Assets

// Method for preloading assets concurrently to speedup start
//+ (void)loadAssets {
//    [super loadAssets];
//    
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        _bounceSoundData = [SKAction atwDataFromSoundFileNamed:@"Bounce.caf"];
//        _zapSoundData = [SKAction atwDataFromSoundFileNamed:@"Zap.caf"];
//
//    });
////    dispatch_once(&onceToken, ^{
////        _zapSoundData = [SKAction atwDataFromSoundFileNamed:@"Zap.caf"];
////    });
//    
//}


- (SKAction *)_bounceSound {
    return [SKAction atwPlaySoundWithData:_bounceSoundData];
}

- (SKAction *)_deepExplosionSound {
    return [SKAction atwPlaySoundWithData:_deepExplosionSoundData];
}

- (SKAction *)_explosionSound {
    return [SKAction atwPlaySoundWithData:_explosionSoundData];
}

- (SKAction *)_laserSound {
    return [SKAction atwPlaySoundWithData:_laserSoundData];
}

- (SKAction *)_zapSound {
    return [SKAction atwPlaySoundWithData:_zapSoundData];
}

- (SKAction *)_shieldUpSound {
    return [SKAction atwPlaySoundWithData:_shieldUpSoundData];
}


-(void)newGame
{
    [_mainLayer removeAllChildren];

    // Add all shields from pool to scene
    while (_shieldPool.count > 0) {
        [_mainLayer addChild:[_shieldPool objectAtIndex:0]];
        [_shieldPool removeObjectAtIndex:0];
    }
    
    // Setup lifebar
    _killCount = 0;
    SKSpriteNode *lifeBar = [SKSpriteNode spriteNodeWithImageNamed:@"BlueBar"];
    lifeBar.position = CGPointMake(self.size.width * 0.5, 70);
    lifeBar.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(-lifeBar.size.width * 0.5,0)
                                                       toPoint:CGPointMake(lifeBar.size.width * 0.5, 0)];
    lifeBar.physicsBody.categoryBitMask = kCCLifeBarCategory;
    [_mainLayer addChild:lifeBar];
    
    // Set initial values
    self.multiMode = NO;
    [self actionForKey:@"SpawnHalo"].speed = 1.0;
    self.ammo = 5;
    self.score = 0;
    self.pointValue = 1;
    _scoreLabel.hidden = NO;
    _pointLabel.hidden = NO;
    _pauseButton.hidden = NO;
     [_menu hide];
    _gameOver = NO;
    
    // Hide iAd
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideAd" object:nil];
   
    
}


-(void)testGame
{
    
    
    [_mainLayer removeAllChildren];
    
    // Add all shields from pool to scene
    while (_shieldPool.count > 0) {
        [_mainLayer addChild:[_shieldPool objectAtIndex:0]];
        [_shieldPool removeObjectAtIndex:0];
    }
    
    
    // Setup lifebar
    _killCount = 0;
    SKSpriteNode *lifeBar = [SKSpriteNode spriteNodeWithImageNamed:@"BlueBar"];
    lifeBar.position = CGPointMake(self.size.width * 0.5, 70);
    lifeBar.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(-lifeBar.size.width * 0.5,0)
                                                       toPoint:CGPointMake(lifeBar.size.width * 0.5, 0)];
    lifeBar.physicsBody.categoryBitMask = kCCLifeBarCategory;
    [_mainLayer addChild:lifeBar];
    
    // Set initial values
    self.multiMode = YES;
    [self actionForKey:@"SpawnHalo"].speed = 10.0;
    self.ammo = 5;
    self.score = 0;
    self.pointValue = 1;
    _scoreLabel.hidden = NO;
    _pointLabel.hidden = NO;
    _pauseButton.hidden = NO;
    [_menu hide];
    _gameOver = NO;
    _testGame = YES;
    
    
    
}

-(void)setAmmo:(int)ammo
{
    if (ammo >= 0 && ammo <= 5) {
        _ammo = ammo;
        _ammoDisplay.texture = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"Ammo%d", ammo]];
    }
}

-(void)setScore:(int)score
{
    _score = score;
    _scoreLabel.text = [NSString stringWithFormat:@"Score: %d", score];
}

-(void)setPointValue:(int)pointValue
{
    _pointValue = pointValue;
    _pointLabel.text = [NSString stringWithFormat:@"Ponts: x%d", pointValue];
}

-(void)setGamePaused:(BOOL)gamePaused
{
    if (!_gameOver) {
        _gamePaused = gamePaused;
        _pauseButton.hidden = gamePaused;
        _resumeButton.hidden = !gamePaused;
        self.paused = gamePaused;
        
 
    }
}


-(void)setMultiMode:(BOOL)multiMode
{
    _multiMode = multiMode;
    if (multiMode) {
        _cannon.texture = [SKTexture textureWithImageNamed:@"GreenCannon"];
    } else {
        _cannon.texture = [SKTexture textureWithImageNamed:@"Cannon"];
    }
}

-(void)shoot
{
    // Create ball node.
    CCBall *ball = [CCBall spriteNodeWithImageNamed:@"Ball"];
    ball.name = @"ball";
    CGVector rotationVector = radiansToVector(_cannon.zRotation);
    ball.position = CGPointMake(_cannon.position.x + (_cannon.size.width * 0.5 * rotationVector.dx),
                                _cannon.position.y + (_cannon.size.width * 0.5 * rotationVector.dy));
    [_mainLayer addChild:ball];
    
    ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:6.0];
    ball.physicsBody.velocity = CGVectorMake(rotationVector.dx * kCCShootSpeed, rotationVector.dy * kCCShootSpeed);
    ball.physicsBody.restitution = 1.0;
    ball.physicsBody.linearDamping = 0.0;
    ball.physicsBody.friction = 0.0;
    ball.physicsBody.categoryBitMask = kCCBallCategory;
    ball.physicsBody.collisionBitMask = kCCEdgeCategory;
    ball.physicsBody.contactTestBitMask = kCCEdgeCategory |  kCCShieldUpCategory | kCCMultiUpCategory;

    [self runAction:[self _laserSound]];
    
    // Create trail.
    NSString *ballTrailPath = [[NSBundle mainBundle] pathForResource:@"BallTrail" ofType:@"sks"];
    SKEmitterNode *ballTrail = [NSKeyedUnarchiver unarchiveObjectWithFile:ballTrailPath];
    ballTrail.targetNode = _mainLayer;
    [_mainLayer addChild:ballTrail];
    ball.trail = ballTrail;
    [ball updateTrail];
}

-(void)spawnHalo
{
    // Increase spawn speed.
    SKAction *spawnHaloAction = [self actionForKey:@"SpawnHalo"];
    if (spawnHaloAction.speed < 1.5) {
        spawnHaloAction.speed += 0.01;
    }
    
    // Create halo node.
    SKSpriteNode *halo = [SKSpriteNode spriteNodeWithImageNamed:@"Halo"];
    halo.name = @"halo";
    halo.position = CGPointMake(randomInRange(halo.size.width * 0.5, self.size.width - (halo.size.width * 0.5)),
                                self.size.height + (halo.size.height * 0.5));
    halo.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:16.0];
    CGVector direction = radiansToVector(randomInRange(kCCHaloLowAngle, kCCHaloHighAngle));
    halo.physicsBody.velocity = CGVectorMake(direction.dx * kCCHaloSpeed, direction.dy * kCCHaloSpeed);
    halo.physicsBody.restitution = 1.0;
    halo.physicsBody.linearDamping = 0.0;
    halo.physicsBody.friction = 0.0;
    halo.physicsBody.categoryBitMask = kCCHaloCategory;
    halo.physicsBody.collisionBitMask = kCCEdgeCategory;
    halo.physicsBody.contactTestBitMask =   kCCBallCategory | kCCShieldCateogry |kCCLifeBarCategory | kCCEdgeCategory;
    
    int haloCount = 0;
    for (SKNode *node in _mainLayer.children) {
        if ([node.name isEqualToString:@"halo"]) {
            haloCount++;
        }
    }
    
    if (haloCount == 4) {
        // Create bomb power up
        halo.texture = [SKTexture textureWithImageNamed:@"HaloBomb"];
        halo.userData = [[NSMutableDictionary alloc] init];
        [halo.userData setValue:@YES forKey:@"Bomb"];
    }else if (!_gameOver &&  arc4random_uniform(6) == 0){
        // Random point multiplier
        halo.texture = [SKTexture textureWithImageNamed:@"HaloX"];
        halo.userData = [[NSMutableDictionary alloc] init];
        [halo.userData setValue:@YES forKey:@"Multiplier"];
    }
    
    
    

    
    [_mainLayer addChild:halo];
}

-(void)spawnShieldPowerUp
{
    if (_shieldPool.count > 0) {
        SKSpriteNode *shieldUp = [SKSpriteNode spriteNodeWithImageNamed:@"Block"];
        shieldUp.name = @"shieldUp";
        shieldUp.position = CGPointMake(self.size.width + shieldUp.size.width, randomInRange(150, self.size.height - 100));
        shieldUp.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(42, 9)];
        shieldUp.physicsBody.categoryBitMask = kCCShieldUpCategory;
        shieldUp.physicsBody.collisionBitMask = 0;
        shieldUp.physicsBody.velocity = CGVectorMake(-100, randomInRange(-40, 40));
        shieldUp.physicsBody.angularVelocity = M_PI;
        shieldUp.physicsBody.linearDamping = 0.0;
        shieldUp.physicsBody.angularDamping = 0.0;
        [_mainLayer addChild:shieldUp];
    }
}

-(void)spawnMultiShotPowerUp
{
    SKSpriteNode *multiUp = [SKSpriteNode spriteNodeWithImageNamed:@"MultiShotPowerUp"];
    multiUp.name = @"multiUp";
    multiUp.position = CGPointMake(-multiUp.size.width, randomInRange(150, self.size.height - 100));
    multiUp.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:12.0];
    multiUp.physicsBody.categoryBitMask = kCCMultiUpCategory;
    multiUp.physicsBody.collisionBitMask = 0;
    multiUp.physicsBody.velocity = CGVectorMake(100, randomInRange(-40, 40));
    multiUp.physicsBody.angularVelocity = M_PI;
    multiUp.physicsBody.linearDamping = 0.0;
    multiUp.physicsBody.angularDamping = 0.0;
    [_mainLayer addChild:multiUp];
}

-(void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody;
    SKPhysicsBody *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if (firstBody.categoryBitMask == kCCHaloCategory && secondBody.categoryBitMask == kCCBallCategory) {
        // Collision between halo and ball.
        self.score += self.pointValue;
        [self addExplosion :firstBody.node.position withName:@"HaloExplosion"];
        [self runAction:[self _explosionSound]];
        
        if ([[firstBody.node.userData valueForKey:@"Multiplier"] boolValue]) {
            self.pointValue++;
        } else if ([[firstBody.node.userData valueForKey:@"Bomb"] boolValue]){
            firstBody.node.name = nil;
            [_mainLayer enumerateChildNodesWithName:@"halo" usingBlock:^(SKNode *node, BOOL *stop) {
                [self addExplosion:node.position withName:@"HaloExplosion"];
                [node removeFromParent];
            }];
        }
        
        _killCount++;
        if (_killCount % 10 == 0) {
            [self spawnMultiShotPowerUp];
        }
        
        [firstBody.node removeFromParent];
        [secondBody.node removeFromParent];
       
        SKAction *incrementAmmo = [SKAction runBlock:^{self.ammo++;}];
        if (!self.multiMode) {
                [self runAction:incrementAmmo];
        }


    }
    
    if (firstBody.categoryBitMask == kCCHaloCategory && secondBody.categoryBitMask == kCCShieldCateogry) {
        // Collision between halo and shield.
        [self addExplosion:firstBody.node.position withName:@"HaloExplosion"];
        [self runAction:[self _explosionSound]];
        
        if ([[firstBody.node.userData valueForKey:@"Bomb"] boolValue]) {
            // Remove all shields
            [_mainLayer enumerateChildNodesWithName:@"shield" usingBlock:^(SKNode *node, BOOL *stop){
                [node removeFromParent];
                [_shieldPool addObject:node];
            }];
        } else {
            [firstBody.node removeFromParent];
            [_shieldPool addObject:secondBody.node];
            [secondBody.node removeFromParent];
        }
    }
    
    if (firstBody.categoryBitMask == kCCHaloCategory && secondBody.categoryBitMask == kCCLifeBarCategory) {
        // Collision between halo and lifebar.
        [self addExplosion:firstBody.node.position withName:@"HaloExplosion"];
        [self addExplosion:secondBody.node.position withName:@"LifeBarExplosion"];
        [self runAction:[self _deepExplosionSound]];
        
        [firstBody.node removeFromParent];
        [secondBody.node removeFromParent];
        [self gameOver];
    }
    if (firstBody.categoryBitMask == kCCBallCategory && secondBody.categoryBitMask == kCCEdgeCategory) {
        [self addExplosion:contact.contactPoint withName:@"CannonBallExplosionSmall"];
    }
    
    if (firstBody.categoryBitMask == kCCHaloCategory && secondBody.categoryBitMask == kCCEdgeCategory) {
        [self runAction:[self _zapSound]];
    }
    
    if (firstBody.categoryBitMask == kCCBallCategory && secondBody.categoryBitMask == kCCEdgeCategory) {
        if ([firstBody.node isKindOfClass:[CCBall class]]) {
            ((CCBall*)firstBody.node).bounces++;
            if (((CCBall*)firstBody.node).bounces > 3 && !_testGame) {
                [firstBody.node removeFromParent];
                self.pointValue = 1;
            }
        }
        
        [self runAction:[self _bounceSound]];
    }
    
    if (firstBody.categoryBitMask == kCCBallCategory && secondBody.categoryBitMask == kCCShieldUpCategory) {
        // Hit a shield power up.
        if (_shieldPool.count > 0) {
            int randomIndex = arc4random_uniform((int)_shieldPool.count);
            [_mainLayer addChild:[_shieldPool objectAtIndex:randomIndex]];
            [_shieldPool removeObjectAtIndex:randomIndex];
            [self runAction:[self _shieldUpSound]];
        }
        [firstBody.node removeFromParent];
        [secondBody.node removeFromParent];
        
    }
    if (firstBody.categoryBitMask == kCCBallCategory && secondBody.categoryBitMask == kCCMultiUpCategory) {
        self.multiMode = YES;
        [self runAction:[self _shieldUpSound]];
        self.ammo = 5;
        [firstBody.node removeFromParent];
        [secondBody.node removeFromParent];
    }
}

-(void)gameOver
{
    [_mainLayer enumerateChildNodesWithName:@"halo" usingBlock:^(SKNode *node, BOOL *stop) {
        [self addExplosion:node.position withName:@"HaloExplosion"];
        [node removeFromParent];
    }];
    
    [_mainLayer enumerateChildNodesWithName:@"ball" usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeFromParent];
    }];
    
    [_mainLayer enumerateChildNodesWithName:@"shield" usingBlock:^(SKNode *node, BOOL *stop) {
        [_shieldPool addObject:node];
        [node removeFromParent];
    }];
    
    [_mainLayer enumerateChildNodesWithName:@"shieldUp" usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeFromParent];
    }];
    
    [_mainLayer enumerateChildNodesWithName:@"multiUp" usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeFromParent];
    }];
    
    _menu.score = self.score;
    if (self.score > _menu.topScore){
        _menu.topScore = self.score;
        [_userDefaults setInteger:self.score forKey:kCCKeyTopScore];
        [_userDefaults synchronize];
    }
    _gameOver = YES;
    _scoreLabel.hidden = YES;
    _pointLabel.hidden = YES;
    _pauseButton.hidden = YES;
    _testGame = NO;
    _multiMode = NO;
    
    [self runAction:[SKAction waitForDuration:1.0] completion:^{
        [_menu show];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showAd" object:nil];
    }];
    
}

-(void)addExplosion:(CGPoint)position withName:(NSString*)name
{
    NSString *explosionPath = [[NSBundle mainBundle] pathForResource:name ofType:@"sks"];
    SKEmitterNode *explosion = [NSKeyedUnarchiver unarchiveObjectWithFile:explosionPath];
    
    explosion.position = position;
    [_mainLayer addChild:explosion];
    
    SKAction *removeExplosion = [SKAction sequence:@[[SKAction waitForDuration:1.5],
                                                     [SKAction removeFromParent]]];
    [explosion runAction:removeExplosion];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        if (!_gameOver && !self.gamePaused) {
            if (![_pauseButton containsPoint:[touch locationInNode:_pauseButton.parent]]) {
                _didShoot = YES;

            }
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        if (_gameOver && _menu.touchable) {
            SKNode *n = [_menu nodeAtPoint:[touch locationInNode:_menu]];
            if ([n.name isEqualToString:@"Play"]) {
                [self newGame];
            }
            
            // Setup Test Game
            if ([n.name isEqualToString:@"Test"]) {
                [self testGame];
            }
            
            // Set up Music Button
            if ([n.name isEqualToString:@"Music"]) {
                _menu.musicPlaying = !_menu.musicPlaying;
                if (_menu.musicPlaying) {
                    [_audioPlayer play];
                } else {
                    [_audioPlayer stop];
                }
            }
        }
        else if (!_gameOver)
        {
            if (self.gamePaused) {
                if ([_resumeButton containsPoint:[touch locationInNode:_resumeButton.parent]]) {
                    self.gamePaused = NO;
                    
//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideAd" object:nil];
                }
            } else {
                if ([_pauseButton containsPoint:[touch locationInNode:_pauseButton.parent]]) {
                    self.gamePaused = YES;
//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showAd" object:nil];
                }
            }
        }
    }
}



// Remove ball after leaving field.

-(void)didSimulatePhysics
{
    
    if (_didShoot) {
        if (self.ammo > 0) {
            if (!_gameOver) {
                self.ammo--;
            }
            
            [self shoot];
            
            if (self.multiMode) {
                for (int i = 1; i < 5; i++) {
                    [self performSelector:@selector(shoot) withObject:nil afterDelay:0.1 * i];
                }
                if (self.ammo == 0) {
                    self.multiMode = NO;
                    self.ammo = 5;
                }
            }
        }
        _didShoot = NO;
    }
    [_mainLayer enumerateChildNodesWithName:@"ball" usingBlock:^(SKNode *node, BOOL *stop) {
        if ([node respondsToSelector:@selector(updateTrail)]) {
            [node performSelector:@selector(updateTrail) withObject:nil afterDelay:0.0];
        }
        
        if (!CGRectContainsPoint(self.frame, node.position)) {
            [node removeFromParent];
//            self.pointValue = 1;
        }
    }];
    
    [_mainLayer enumerateChildNodesWithName:@"shieldUp" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.x + node.frame.size.width < 0) {
            [node removeFromParent];
        }
    }];
    
    [_mainLayer enumerateChildNodesWithName:@"multiUp" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.x - node.frame.size.width > self.size.width) {
            [node removeFromParent];
        }
    }];
    
    [_mainLayer enumerateChildNodesWithName:@"halo" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.y + node.frame.size.height < 0) {
            [node removeFromParent];
        }
    }];
    
}


-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
}

@end
