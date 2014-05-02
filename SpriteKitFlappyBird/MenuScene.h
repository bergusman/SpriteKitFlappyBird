//
//  MenuScene.h
//  SpriteKitFlappyBird
//
//  Created by Vitaly Berg on 02/05/14.
//  Copyright (c) 2014 Vitaly Berg. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface MenuScene : SKScene

@property (copy, nonatomic) void (^didPressStart)();

@end
