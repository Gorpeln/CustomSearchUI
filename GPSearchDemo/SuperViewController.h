//
//  SuperViewController.h
//  TakeAway
//
//  Created by chen on 2017/3/6.
//  Copyright © 2017年 Gorpeln. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SuperViewController : UIViewController

- (UIWindow *)keyWindow;

/**
 导航栏标题
 **/
- (void)initTitle:(NSString *)title;

/**
 自定义导航栏返回按钮
 **/
- (void)initLeftBarButtonItem;

/**
 定义返回事件
 **/
-(void)lBarBtnPressed:(id)sender;

/**
 定义导航栏右侧按钮名字
 **/
- (void)initRightBarButtonItemWithTitle:(NSString *)string;

/**
 定义导航栏右侧按钮名字
 **/
- (void)initRightBarButtonItemWithImg:(UIImage *)img;

/**
 定义导航栏右侧点击事件
 **/
-(void)rBarBtnPressed:(id)sender;

@end
