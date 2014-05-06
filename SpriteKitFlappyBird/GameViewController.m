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
        SKTransition *transition = [SKTransition fadeWithColor:[UIColor blackColor] duration:1];
        transition.pausesIncomingScene = NO;
        transition.pausesOutgoingScene = NO;
        
        [self.spriteView presentScene:self.menuScene transition:transition];
    } else {
        [self.spriteView presentScene:self.menuScene];
    }
}

- (void)showGame {
    GameScene *gameScene = [[GameScene alloc] initWithSize:CGSizeMake(288, 512)];
    
    SKTransition *transition = [SKTransition fadeWithColor:[UIColor blackColor] duration:1];
    transition.pausesIncomingScene = NO;
    transition.pausesOutgoingScene = NO;
    
    [self.spriteView presentScene:gameScene transition:transition];
    
    gameScene.didPressOk = ^() {
        [self showMenuWithTransition:YES];
    };
    
    self.gameScene = gameScene;
}

- (void)willResignActive:(NSNotification *)notification {
    self.menuScene.paused = YES;
    self.gameScene.paused = YES;
}

- (void)didBecomeActive:(NSNotification *)notification {
    self.menuScene.paused = NO;
    self.gameScene.paused = NO;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSpriteView];
    [self setupSpriteViewDebugInfo];
    [self setupMenuScene];
    
    [self showMenuWithTransition:NO];
    //[self showGame];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
