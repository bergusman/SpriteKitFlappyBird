//
//  GameViewController.m
//  SpriteKitFlappyBird
//
//  Created by Vitaly Berg on 02/05/14.
//  Copyright (c) 2014 Vitaly Berg. All rights reserved.
//

#import "GameViewController.h"

#import "MenuScene.h"
#import "GameScene.h"

@interface GameViewController ()

@property (strong, nonatomic) SKView *spriteView;

@property (strong, nonatomic) MenuScene *menuScene;
@property (strong, nonatomic) GameScene *gameScene;

@end

@implementation GameViewController

#pragma mark - Setups

- (void)setupSpriteView {
    self.spriteView = (SKView *)self.view;
}

- (void)setupSpriteViewDebugInfo {
    self.spriteView.showsFPS = YES;
    self.spriteView.showsNodeCount = YES;
    self.spriteView.showsPhysics = YES;
    self.spriteView.showsDrawCount = YES;
}

- (void)setupMenuScene {
    self.menuScene = [[MenuScene alloc] initWithSize:CGSizeMake(288, 512)];
    
    __weak typeof(self) wself = self;
    self.menuScene.didPressStart = ^() {
        [wself showGame];
    };
}

#pragma mark - Content

- (void)showMenuWithTransition:(BOOL)usesTransition {
    if (usesTransition) {
        [self.spriteView presentScene:self.menuScene transition:[SKTransition fadeWithDuration:0.3]];
    } else {
        [self.spriteView presentScene:self.menuScene];
    }
}

- (void)showGame {
    GameScene *gameScene = [[GameScene alloc] initWithSize:CGSizeMake(288, 512)];
    [self.spriteView presentScene:gameScene transition:[SKTransition fadeWithColor:[UIColor blackColor] duration:1]];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSpriteView];
    [self setupSpriteViewDebugInfo];
    [self setupMenuScene];
    
    [self showMenuWithTransition:NO];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
