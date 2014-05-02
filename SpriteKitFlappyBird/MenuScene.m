//
//  MenuScene.m
//  SpriteKitFlappyBird
//
//  Created by Vitaly Berg on 02/05/14.
//  Copyright (c) 2014 Vitaly Berg. All rights reserved.
//

#import "MenuScene.h"

#import "ButtonNode.h"

#define FLOOR_SPEED_MULTIPLIER 2

// 288 x 512
@interface MenuScene ()

@end

@implementation MenuScene

#pragma mark - Setups

- (void)setupBackground {
    SKSpriteNode *backgroundNode = [[SKSpriteNode alloc] initWithImageNamed:@"bg"];
    backgroundNode.size = self.size;
    backgroundNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:backgroundNode];
}

- (void)setupTitle {
    SKNode *titleNode = [[SKNode alloc] init];
    titleNode.position = CGPointMake(self.size.width / 2, 336);
    [self addChild:titleNode];
    
    SKSpriteNode *titleSpriteNode = [SKSpriteNode spriteNodeWithImageNamed:@"title"];
    titleSpriteNode.position = CGPointMake(-22, 0);
    [titleNode addChild:titleSpriteNode];
    
    SKSpriteNode *birdSpriteNode = [SKSpriteNode node];
    birdSpriteNode.size = CGSizeMake(48, 48);
    
    NSArray *birdTextures = @[
                              [SKTexture textureWithImageNamed:@"bird_0"],
                              [SKTexture textureWithImageNamed:@"bird_1"],
                              [SKTexture textureWithImageNamed:@"bird_2"],
                              [SKTexture textureWithImageNamed:@"bird_1"],
                              ];
    
    SKAction *birdAnimationAction = [SKAction animateWithTextures:birdTextures timePerFrame:0.1];
    [birdSpriteNode runAction:[SKAction repeatActionForever:birdAnimationAction]];
    
    [titleNode addChild:birdSpriteNode];
    
    birdSpriteNode.position = CGPointMake(104, 2);
    
    
    SKAction *moveUpAction = [SKAction moveByX:0 y:4 duration:0.35];
    moveUpAction.timingMode = SKActionTimingEaseInEaseOut;
    
    SKAction *moveDownAction = [SKAction moveByX:0 y:-4 duration:0.35];
    moveDownAction.timingMode = SKActionTimingEaseInEaseOut;
    
    SKAction *movesAction = [SKAction repeatActionForever:[SKAction sequence:@[moveUpAction, moveDownAction]]];
    
    [titleNode runAction:movesAction];
}

- (void)setupButtons {
    SKSpriteNode *startButtonSpriteNode = [SKSpriteNode spriteNodeWithImageNamed:@"button_start"];
    startButtonSpriteNode.name = @"button_start";
    //startButtonSpriteNode.position = CGPointMake(self.size.width / 2, 140);
    //[self addChild:startButtonSpriteNode];
    
    
    ButtonNode *buttonNode = [[ButtonNode alloc] init];
    [buttonNode addChild:startButtonSpriteNode];
    
    buttonNode.position = CGPointMake(self.size.width / 2, 140);
    
    [self addChild:buttonNode];
    
    NSLog(@"----------");
    NSLog(@"%@", NSStringFromCGRect(buttonNode.frame));
    NSLog(@"%@", NSStringFromCGRect(startButtonSpriteNode.frame));
    NSLog(@"%@", NSStringFromCGRect([buttonNode calculateAccumulatedFrame]));
    
    
    buttonNode.userInteractionEnabled = YES;
    
    buttonNode.action = ^() {
        if (self.didPressStart) {
            self.didPressStart();
        }
    };
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
    
    [self addChild:floorNode];
}

#pragma mark - SKScene

- (void)didMoveToView:(SKView *)view {
    [self setupBackground];
    [self setupTitle];
    [self setupButtons];
    [self setupFloor];
    
    NSLog(@"%@", NSStringFromCGRect(self.frame));
}

@end
