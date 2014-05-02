//
//  GameScene.m
//  SpriteKitFlappyBird
//
//  Created by Vitaly Berg on 02/05/14.
//  Copyright (c) 2014 Vitaly Berg. All rights reserved.
//

#import "GameScene.h"

@interface GameScene () <SKPhysicsContactDelegate>

@property (strong, nonatomic) SKNode *birdNode;

@property (assign, nonatomic) BOOL gameOver;

@property (strong, nonatomic) NSTimer *pipesTimer;

@property (assign, nonatomic) BOOL up;

@end

@implementation GameScene

- (void)setupBackground {
    SKTexture *bg = [SKTexture textureWithImage:[UIImage imageNamed:@"bg"]];
    
    SKSpriteNode *spriteNode = [[SKSpriteNode alloc] init];
    spriteNode.texture = bg;
    spriteNode.position = CGPointMake(self.size.width / 2, self.size.height / 2);
    spriteNode.size = self.size;
    spriteNode.name = @"background";
    [self addChild:spriteNode];
}

- (void)setupBird {
    

    
}

- (void)didSimulatePhysics {
    SKSpriteNode *spriteNode = (SKSpriteNode *)[self.birdNode childNodeWithName:@"bird_sprite"];
    
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
            
            SKAction *rotateAction = [SKAction rotateToAngle:-M_PI / 2 duration:0.6];
            
            rotateAction.timingMode = SKActionTimingEaseIn;
            
            [spriteNode runAction:rotateAction withKey:@"rotation"];
            

            
            //spriteNode.zRotation = -M_PI / 4;
        }
    }
}

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

- (void)didFirePipesTimer:(NSTimer *)timer {
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
    
    SKAction *wing = [SKAction playSoundFileNamed:@"sfx_wing.caf" waitForCompletion:YES];
    [self runAction:wing];
    
    self.birdNode.physicsBody.velocity = CGVectorMake(0, 0);
    [self.birdNode.physicsBody applyImpulse:CGVectorMake(0, 10)];
    
    
}

#pragma mark - SKPhysicsContactDelegate

- (void)didBeginContact:(SKPhysicsContact *)contact {
    NSLog(@"%s", __func__);
    if (contact.bodyA == self.birdNode.physicsBody || contact.bodyB == self.birdNode.physicsBody) {
        if (contact.bodyA.categoryBitMask == 4 || contact.bodyB.categoryBitMask == 4) {
            
            SKAction *pointSoundAction = [SKAction playSoundFileNamed:@"sfx_point.caf" waitForCompletion:NO];
            [self runAction:pointSoundAction];
            
            if (contact.bodyA.categoryBitMask == 4) {
                [contact.bodyA.node removeFromParent];
            }
            if (contact.bodyB.categoryBitMask == 4) {
                [contact.bodyB.node removeFromParent];
            }
            
            return;
        }
        
        
        
        if (!self.gameOver) {
            self.gameOver = YES;
            SKAction *hit = [SKAction playSoundFileNamed:@"sfx_hit.caf" waitForCompletion:YES];
            [self runAction:hit];
        }
        
    }
}

- (void)didEndContact:(SKPhysicsContact *)contact {
    
}

@end
