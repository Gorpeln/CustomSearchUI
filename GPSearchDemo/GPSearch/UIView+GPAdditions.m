//
//  UIView+GPAdditions.m
//  GPSearchDemo
//
//  Created by chen on 16/10/27.
//  Copyright © 2016年 Gorpeln. All rights reserved.
//

#import "UIView+GPAdditions.h"

@implementation UIView (GPAdditions)

- (void)setGp_x:(CGFloat)gp_x
{
    CGRect frame = self.frame;
    frame.origin.x = gp_x;
    self.frame = frame;
}

- (CGFloat)gp_x
{
    return self.gp_origin.x;
}

- (void)setGp_centerX:(CGFloat)gp_centerX
{
    CGPoint center = self.center;
    center.x = gp_centerX;
    self.center = center;
}

- (CGFloat)gp_centerX
{
    return self.center.x;
}

-(void)setGp_centerY:(CGFloat)gp_centerY
{
    CGPoint center = self.center;
    center.y = gp_centerY;
    self.center = center;
}

- (CGFloat)gp_centerY
{
    return self.center.y;
}

- (void)setGp_y:(CGFloat)gp_y
{
    CGRect frame = self.frame;
    frame.origin.y = gp_y;
    self.frame = frame;
}

- (CGFloat)gp_y
{
    return self.frame.origin.y;
}

- (void)setGp_size:(CGSize)gp_size
{
    CGRect frame = self.frame;
    frame.size = gp_size;
    self.frame = frame;

}

- (CGSize)gp_size
{
    return self.frame.size;
}

- (void)setGp_height:(CGFloat)gp_height
{
    CGRect frame = self.frame;
    frame.size.height = gp_height;
    self.frame = frame;
}

- (CGFloat)gp_height
{
    return self.frame.size.height;
}

- (void)setGp_width:(CGFloat)gp_width
{
    CGRect frame = self.frame;
    frame.size.width = gp_width;
    self.frame = frame;

}

-(CGFloat)gp_width
{
    return self.frame.size.width;
}

- (void)setGp_origin:(CGPoint)gp_origin
{
    CGRect frame = self.frame;
    frame.origin = gp_origin;
    self.frame = frame;
}

- (CGPoint)gp_origin
{
    return self.frame.origin;
}

@end
