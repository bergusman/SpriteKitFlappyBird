//
//  ButtonNode.m
//  SpriteKitFlappyBird
//
//  Created by Vitaly Berg on 02/05/14.
//  Copyright (c) 2014 Vitaly Berg. All rights reserved.
//

#import "ButtonNode.h"

#define TOUCH_DOWN_RANGE 1

@implementation ButtonNode

#pragma mark - Content

- (void)touchUp {
    for (SKNode *node in self.children) {
        [node runAction:[SKAction moveByX:0 y:TOUCH_DOWN_RANGE duration:0]];
    }
}

- (void)touchDown {
    for (SKNode *node in self.children) {
        [node runAction:[SKAction moveByX:0 y:-TOUCH_DOWN_RANGE duration:0]];
    }
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    NSLog(@"%s", __func__);
    
    [self touchDown];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    NSLog(@"%s", __func__);
    
    UITouch *touch = [touches anyObject];
    
    CGPoint location = [touch locationInNode:self.parent];
    
    if (!CGRectContainsPoint([self calculateAccumulatedFrame], location)) {
        [self touchDown];
        
        if (self.action) {
            self.action();
        }
    }
    
    
    
    //NSLog(@"%@", NSStringFromCGPoint(location));
    //NSLog(@"%@", NSStringFromCGRect(self.frame));
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    NSLog(@"%s", __func__);
    [self touchUp];
    
    if (self.action) {
        self.action();
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    NSLog(@"%s", __func__);
    [self touchUp];
}

@end
