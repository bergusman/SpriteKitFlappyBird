//
//  GameScene.m
//  SpriteKitFlappyBird
//
//  Created by Vitaly Berg on 02/05/14.
//  Copyright (c) 2014 Vitaly Berg. All rights reserved.
//

#import "GameScene.h"

#import "ButtonNode.h"

#define FLOOR_SPEED_MULTIPLIER 2

typedef NS_ENUM(NSInteger, GameState) {
    GameStateReady,
    GameStateGame,
    GameStateGameOver
};

typedef NS_OPTIONS(NSInteger, GameNodeGategory) {
    BirdCategory = 1 << 0,
    PointPipeCategory = 1 << 1,
    PipeCategory = 1 << 2,
    FloorCategory = 1 << 3
};

// 288 x 512
@interface GameScene () <SKPhysicsContactDelegate>

@property (assign, nonatomic) GameState state;

@property (strong, nonatomic) SKNode *readyNode;
@property (strong, nonatomic) SKNode *tutorialNode;

@property (strong, nonatomic) SKNode *birdNode;

@property (assign, nonatomic) BOOL gameOver;

@property (strong, nonatomic) NSTimer *pipesTimer;

@property (assign, nonatomic) BOOL up;

@property (strong, nonatomic) SKAction *pipesMoveAction;

@property (assign, nonatomic) NSInteger points;

@property (strong, nonatomic) SKEmitterNode *floorNode;

@property (strong, nonatomic) NSMutableArray *pipes;

@property (assign, nonatomic) BOOL startDown;

@property (assign, nonatomic) BOOL loaded;

@end

@implementation GameScene

#pragma mark - Setups

- (void)setupBackground {
    SKSpriteNode *backgroundNode = [[SKSpriteNode alloc] initWithImageNamed:@"bg"];
    backgroundNode.size = self.size;
    backgroundNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:backgroundNode];
}

- (void)setupFloor {
    SKTexture *floorTexture = [SKTexture textureWithImageNamed:@"floor"];
    
    SKEmitterNode *floorNode = [[SKEmitterNode alloc] init];
    floorNode.position = CGPointMake(self.size.width + floorTexture.size.width / 2, floorTexture.size.height / 2);
    
    floorNode.particleTexture = floorTexture;
    floorNode.particleBirthRate = 1.0 / FLOOR_SPEED_MULTIPLIER;
    floorNode.particleSpeed = floorTexture.size.width / FLOOR_SPEED_MULTIPLIER;
    floorNode.particleLifetime = 10;
    floorNode.emissionAngle = M_PI;
    [floorNode advanceSimulationTime:10];
    
    floorNode.zPosition = 100;
    
    [self addChild:floorNode];
    
    self.floorNode = floorNode;
    
    //////////
    
    SKNode *node = [SKNode node];
    node.position = CGPointMake(self.size.width / 2, 112 / 2);
    
    node.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(288, 112)];
    node.physicsBody.dynamic = NO;
    node.physicsBody.categoryBitMask = FloorCategory;
    node.physicsBody.collisionBitMask = 0;
    
    [self addChild:node];
}

- (void)setupBird {
    SKNode *birdNode = [SKNode node];
    birdNode.name = @"bird";
    birdNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(36, 26)];
    
    SKSpriteNode *birdSpriteNode = [SKSpriteNode node];
    birdSpriteNode.name = @"bird_sprite";
    birdSpriteNode.size = CGSizeMake(48, 48);
    
    NSArray *birdTextures = @[
                              [SKTexture textureWithImageNamed:@"bird_0"],
                              [SKTexture textureWithImageNamed:@"bird_1"],
                              [SKTexture textureWithImageNamed:@"bird_2"],
                              [SKTexture textureWithImageNamed:@"bird_1"],
                              ];
    
    SKAction *birdAnimationAction = [SKAction animateWithTextures:birdTextures timePerFrame:0.1];
    [birdSpriteNode runAction:[SKAction repeatActionForever:birdAnimationAction] withKey:@"fly"];
    
    [birdNode addChild:birdSpriteNode];
    
    birdNode.position = CGPointMake(90, 280);
    
    birdNode.physicsBody.affectedByGravity = NO;
    
    birdNode.physicsBody.categoryBitMask = BirdCategory;
    birdNode.physicsBody.collisionBitMask = FloorCategory;
    birdNode.physicsBody.contactTestBitMask = FloorCategory | PointPipeCategory | PipeCategory;
    birdNode.physicsBody.allowsRotation = NO;
    
    [self addChild:birdNode];
    
    self.birdNode = birdNode;
    
    self.birdNode.zPosition = 50;
}

- (void)setupPipesMoveAction {
    self.pipesMoveAction = [SKAction moveByX:-340 y:0 duration:3];
}

#pragma mark - Content

- (void)startGetReady {
    self.tutorialNode = [SKSpriteNode spriteNodeWithImageNamed:@"tutorial"];
    [self addChild:self.tutorialNode];
    
    self.tutorialNode.position = CGPointMake(168, 240);
    
    self.readyNode = [SKSpriteNode spriteNodeWithImageNamed:@"text_ready"];
    self.readyNode.position = CGPointMake(144, 380);
    [self addChild:self.readyNode];
  
    SKAction *moveUpAction = [SKAction moveByX:0 y:4 duration:0.35];
    moveUpAction.timingMode = SKActionTimingEaseInEaseOut;
    
    SKAction *moveDownAction = [SKAction moveByX:0 y:-4 duration:0.35];
    moveDownAction.timingMode = SKActionTimingEaseInEaseOut;
    
    SKAction *movesAction = [SKAction repeatActionForever:[SKAction sequence:@[moveUpAction, moveDownAction]]];
  
    [self.birdNode runAction:movesAction withKey:@"moves"];
}

- (void)hideReady {
    SKAction *fadeAction = [SKAction fadeOutWithDuration:0.3];
    [self.tutorialNode runAction:fadeAction];
    [self.readyNode runAction:fadeAction];
}

- (void)pushUpBird {
    [self playWingSound];
    self.birdNode.physicsBody.velocity = CGVectorMake(0, 0);
    [self.birdNode.physicsBody applyImpulse:CGVectorMake(0, 10)];
}

- (void)startPipesTimer {
    self.pipesTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(didFirePipesTimer:) userInfo:nil repeats:YES];
}

- (void)stopPipesTimer {
    [self.pipesTimer invalidate];
    self.pipesTimer = nil;
}

- (void)didFirePipesTimer:(NSTimer *)timer {
    [self generatePipes];
}

- (void)generatePipes {
    [self generateDownPipe];
    [self generatePointPipe];
    [self generateUpPipe];
}

- (void)generateUpPipe {
    SKSpriteNode *pipe = [SKSpriteNode spriteNodeWithImageNamed:@"pipe_up"];
    
    pipe.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipe.size];
    pipe.physicsBody.dynamic = NO;
    pipe.physicsBody.categoryBitMask = PipeCategory;
    pipe.physicsBody.collisionBitMask = 0;
    
    pipe.physicsBody.contactTestBitMask = 0;
    
    pipe.position = CGPointMake(self.size.width + 20, 40);
    
    [self addChild:pipe];
    
    [pipe runAction:self.pipesMoveAction];
    
    pipe.name = @"pipe";
}

- (void)generateDownPipe {
    SKSpriteNode *pipe = [SKSpriteNode spriteNodeWithImageNamed:@"pipe_down"];
    
    pipe.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipe.size];
    pipe.physicsBody.dynamic = NO;
    pipe.physicsBody.categoryBitMask = PipeCategory;
    pipe.physicsBody.collisionBitMask = 0;
    pipe.physicsBody.contactTestBitMask = 0;
    //pipe.physicsBody.contactTestBitMask = BirdCategory;
    
    pipe.position = CGPointMake(self.size.width + 20, 400);
    
    [self addChild:pipe];
    
    [pipe runAction:self.pipesMoveAction];
    
    pipe.name = @"pipe";
}

- (void)generatePointPipe {
    SKNode *pointPipeNode = [SKNode node];
    pointPipeNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(40, 512)];
    pointPipeNode.position = CGPointMake(self.size.width + 20, CGRectGetMidY(self.frame));
    pointPipeNode.physicsBody.dynamic = NO;
    pointPipeNode.physicsBody.categoryBitMask = PointPipeCategory;
    pointPipeNode.physicsBody.collisionBitMask = 0;
    //pointPipeNode.physicsBody.contactTestBitMask = BirdCategory;
    
    
    [self addChild:pointPipeNode];
    
    [pointPipeNode runAction:self.pipesMoveAction];
}

- (void)showHit {
    NSLog(@"%s", __func__);
    
    [self playHitSound];
    self.floorNode.paused = YES;
    
    if (self.birdNode.physicsBody.velocity.dy > 0) {
        self.birdNode.physicsBody.velocity = CGVectorMake(0, 0);
    }
    
    [self stopPipesTimer];
    
    [self enumerateChildNodesWithName:@"pipe" usingBlock:^(SKNode *node, BOOL *stop) {
        node.paused = YES;
    }];
    
    self.birdNode.physicsBody.restitution = 0.0;
    
    SKNode *birdSpriteNode = [self.birdNode childNodeWithName:@"bird_sprite"];
    [birdSpriteNode removeActionForKey:@"fly"];
    
    self.birdNode.physicsBody.contactTestBitMask = 0;
}

- (void)showGameOver {
    SKSpriteNode *gameOverNode = [SKSpriteNode spriteNodeWithImageNamed:@"text_game_over"];
    [self addChild:gameOverNode];
    
    gameOverNode.position = CGPointMake(self.size.width / 2, 300);
    
    [gameOverNode runAction:[SKAction sequence:@[[SKAction moveByX:0 y:2 duration:0.06],
                                                 [SKAction moveByX:0 y:-4 duration:0.16]]]];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        
        [self showOkButton];
    });
}

- (void)showOkButton {
    SKSpriteNode *startButtonSpriteNode = [SKSpriteNode spriteNodeWithImageNamed:@"button_ok"];
    startButtonSpriteNode.name = @"button_ok";
    //startButtonSpriteNode.position = CGPointMake(self.size.width / 2, 140);
    //[self addChild:startButtonSpriteNode];
    
    ButtonNode *buttonNode = [[ButtonNode alloc] init];
    [buttonNode addChild:startButtonSpriteNode];
    
    buttonNode.position = CGPointMake(self.size.width / 2, 140);
    
    [self addChild:buttonNode];
    
    buttonNode.userInteractionEnabled = YES;
    
    buttonNode.action = ^() {
        self.userInteractionEnabled = NO;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.didPressOk) {
                self.didPressOk();
            }
        });
        
    };
}

#pragma mark - SKScene

- (void)didMoveToView:(SKView *)view {
    if (self.loaded) {
        return;
    }
    
    self.loaded = YES;
    
    [self setupBackground];
    [self setupFloor];
    [self setupBird];
    [self setupPipesMoveAction];
    
    self.physicsWorld.gravity = CGVectorMake(0, -3);
    self.physicsWorld.contactDelegate = self;
    
    [self startGetReady];
}

/////////////////////////


- (void)didSimulatePhysics {
    SKSpriteNode *spriteNode = (SKSpriteNode *)[self.birdNode childNodeWithName:@"bird_sprite"];
    
    if (self.state == GameStateGameOver) {
        if (!self.startDown) {
            self.startDown = YES;
            
            [spriteNode removeActionForKey:@"rotation"];
            
            
            SKAction *rotateAction = [SKAction rotateToAngle:-M_PI / 2 duration:1];
            rotateAction.timingMode = SKActionTimingEaseIn;
            [spriteNode runAction:rotateAction withKey:@"rotation"];
        }
        return;
    }
    
    if (self.birdNode.physicsBody.velocity.dy > 0) {
        if (!self.up) {
            self.up = YES;
            

            
            [spriteNode removeActionForKey:@"rotation"];
            
            SKAction *rotateAction = [SKAction rotateToAngle:M_PI / 4 duration:0.1];
            
            [spriteNode runAction:rotateAction withKey:@"rotation"];
            //spriteNode.zRotation = M_PI / 4;
            
            
        }
    } else {
        if (self.up) {
            self.up = NO;
            
            [spriteNode removeActionForKey:@"rotation"];
            
            SKAction *rotateAction = [SKAction rotateToAngle:-M_PI / 2 duration:1];
            
            rotateAction.timingMode = SKActionTimingEaseIn;
            
            [spriteNode runAction:rotateAction withKey:@"rotation"];
            

            
            //spriteNode.zRotation = -M_PI / 4;
        }
    }
}

/*

- (void)didMoveToView:(SKView *)view {
    [self setupBackground];
    
    SKNode *birdNode = [SKNode node];
    
    SKSpriteNode *birdSpriteNode = [[SKSpriteNode alloc] init];
    birdSpriteNode.size = CGSizeMake(36, 36);
    
    [birdNode addChild:birdSpriteNode];
    
    birdNode.zPosition = 1000;
    
    NSArray *textures = @[[SKTexture textureWithImageNamed:@"bird1"],
                          [SKTexture textureWithImageNamed:@"bird2"],
                          [SKTexture textureWithImageNamed:@"bird3"],
                          [SKTexture textureWithImageNamed:@"bird2"]
                          ];
    
    SKAction *birdTextureAnimation = [SKAction animateWithTextures:textures timePerFrame:0.08];
    
    birdSpriteNode.name = @"bird_sprite";
    
    [birdSpriteNode runAction:[SKAction repeatActionForever:birdTextureAnimation]];
    
    birdNode.physicsBody.allowsRotation = NO;
    
    birdNode.position = CGPointMake(100, 300);
    [self addChild:birdNode];
    
    birdNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(36, 36)];
    
    self.physicsWorld.gravity = CGVectorMake(0, -3);
    
    self.birdNode = birdNode;
    
    SKEmitterNode *floor = [[SKEmitterNode alloc] init];
    
    SKTexture *floorTexture = [SKTexture textureWithImageNamed:@"floor"];
    
    NSLog(@"%@", NSStringFromCGSize(floorTexture.size));
    
    CGFloat s = 1.5;
    
    floor.xScale = 1.2;
    floor.yScale = 0.8;
    
    floor.particleTexture = floorTexture;
    floor.particleBirthRate = 1 / s;
    floor.particleSpeed = 336 / s;
    floor.particleLifetime = 10;
    floor.emissionAngle = M_PI;

    
    [self addChild:floor];

    
    floor.position = CGPointMake(320 + 160, 100);
    

    
    
    SKNode *floorNode = [SKNode node];
    floorNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(320, 50)];
    floorNode.physicsBody.dynamic = NO;
    floorNode.position = CGPointMake(160, 100);
    

    [self addChild:floorNode];
    
    self.physicsWorld.contactDelegate = self;
    
    ///////////////////
    
    NSLog(@"%u", self.birdNode.physicsBody.categoryBitMask);
    NSLog(@"%u", self.birdNode.physicsBody.collisionBitMask);
    NSLog(@"%u", self.birdNode.physicsBody.contactTestBitMask);
    
    self.birdNode.physicsBody.categoryBitMask = 1;
    self.birdNode.physicsBody.collisionBitMask = 2 | 5;
    self.birdNode.physicsBody.contactTestBitMask = 2;
    
    floorNode.physicsBody.categoryBitMask = 2;
    floorNode.physicsBody.collisionBitMask = 1;
    
    self.pipesTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(didFirePipesTimer:) userInfo:nil repeats:YES];
}
 
 */

- (void)didFirePipesTimer2:(NSTimer *)timer {
    NSLog(@"%@", timer);
    
    
    SKNode *pointPipe = [SKNode node];
    
    
    pointPipe.position = CGPointMake(320, 568/2);
    SKAction *moveAction = [SKAction moveByX:-360 y:0 duration:2];
    
    [pointPipe runAction:moveAction];
    
    
    pointPipe.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(100, 568)];
    pointPipe.physicsBody.affectedByGravity = NO;
    pointPipe.physicsBody.categoryBitMask = 4;
    pointPipe.physicsBody.collisionBitMask = 0;
    pointPipe.physicsBody.contactTestBitMask = 1;
    
    [self addChild:pointPipe];
    
    
    SKSpriteNode *topPipeNode = [[SKSpriteNode alloc] initWithImageNamed:@"top_pipe"];
    topPipeNode.size = CGSizeMake(52, 320);
    
    topPipeNode.position = CGPointMake(320, 500);
    
    [self addChild:topPipeNode];
    
    
    SKSpriteNode *bottomPipeNode = [[SKSpriteNode alloc] initWithImageNamed:@"bottom_pipe"];
    bottomPipeNode.size = CGSizeMake(52, 320);
    
    bottomPipeNode.position = CGPointMake(320, 0);
    
    [self addChild:bottomPipeNode];
    
    bottomPipeNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(52, 320)];
    bottomPipeNode.physicsBody.affectedByGravity = NO;
    //bottomPipeNode.physicsBody.dynamic = NO;
    bottomPipeNode.physicsBody.categoryBitMask = 5;
    bottomPipeNode.physicsBody.collisionBitMask = 0;
    bottomPipeNode.physicsBody.contactTestBitMask = 1;
    
    topPipeNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(52, 320)];
    topPipeNode.physicsBody.affectedByGravity = NO;
    //topPipeNode.physicsBody.dynamic = NO;
    topPipeNode.physicsBody.categoryBitMask = 5;
    topPipeNode.physicsBody.collisionBitMask = 0;
    topPipeNode.physicsBody.contactTestBitMask = 1;
    
    [topPipeNode runAction:moveAction];
    [bottomPipeNode runAction:moveAction];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    if (self.state != GameStateGame && self.state != GameStateReady) {
        return;
    }
    
    if (self.state == GameStateReady) {
        self.state = GameStateGame;
        [self.birdNode removeActionForKey:@"moves"];
        self.birdNode.physicsBody.affectedByGravity = YES;
        [self startPipesTimer];
        [self hideReady];
    }
    
    [self pushUpBird];
    
    /*
    
    
     */
    
}

- (void)playPointSound {
    SKAction *pointSoundAction = [SKAction playSoundFileNamed:@"sfx_point.caf" waitForCompletion:YES];
    [self runAction:pointSoundAction];
}

- (void)playHitSound {
    SKAction *hit = [SKAction playSoundFileNamed:@"sfx_hit.caf" waitForCompletion:YES];
    [self runAction:hit];
}

- (void)playWingSound {
    SKAction *wing = [SKAction playSoundFileNamed:@"sfx_wing.caf" waitForCompletion:YES];
    [self runAction:wing];
}

- (void)pause {
    
    SKShapeNode *dimNode = [[SKShapeNode alloc] init];
    dimNode.path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 288, 512)].CGPath;
    dimNode.fillColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    [self addChild:dimNode];
    
    [self stopPipesTimer];
    
    
    self.birdNode.paused = YES;
    self.floorNode.paused = YES;
}

- (void)resume {
    
}

#pragma mark - SKPhysicsContactDelegate

- (void)didBeginContact:(SKPhysicsContact *)contact {
    NSLog(@"%s", __func__);
    
    NSLog(@"%@ %@", contact.bodyA.node, contact.bodyB.node);
    
    if (self.state != GameStateGame) {
        return;
    }
    
    if (contact.bodyA.categoryBitMask == PointPipeCategory || contact.bodyB.categoryBitMask == PointPipeCategory) {
        
        if (contact.bodyA.categoryBitMask == PointPipeCategory) {
            [contact.bodyA.node removeFromParent];
        }
        
        if (contact.bodyB.categoryBitMask == PointPipeCategory) {
            [contact.bodyB.node removeFromParent];
        }
        
        [self playPointSound];
        self.points++;
        return;
    }
    
    if (contact.bodyA.categoryBitMask == FloorCategory || contact.bodyB.categoryBitMask == FloorCategory) {
        self.state = GameStateGameOver;
        [self showHit];
        [self showGameOver];
        return;
    }
    
    if (contact.bodyA.categoryBitMask == PipeCategory || contact.bodyB.categoryBitMask == PipeCategory) {
        self.state = GameStateGameOver;
        [self showHit];
        [self showGameOver];
        return;
    }
}

@end
