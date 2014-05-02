//
//  ButtonNode.h
//  SpriteKitFlappyBird
//
//  Created by Vitaly Berg on 02/05/14.
//  Copyright (c) 2014 Vitaly Berg. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface ButtonNode : SKNode

@property (copy, nonatomic) void (^action)();

@end
