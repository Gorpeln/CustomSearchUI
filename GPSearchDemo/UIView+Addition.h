//
//  UIView+Addition.h
//  Gorpeln
//
//  Created by chen on 16/11/1.
//  Copyright © 2016年 Gorpeln. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Addition)


@property(nonatomic ,assign) CGFloat left;          //左边距
@property(nonatomic ,assign) CGFloat top;           //上边距
@property(nonatomic ,assign) CGFloat right;         //右边距
@property(nonatomic ,assign) CGFloat bottom;        //下边距
@property(nonatomic ,assign) CGFloat width;         //宽度
@property(nonatomic ,assign) CGFloat height;        //高度
@property(nonatomic ,assign) CGFloat centerX;       //中心点x值
@property(nonatomic ,assign) CGFloat centerY;       //中心点y值
@property(nonatomic ,assign) CGPoint origin;        //原点
@property(nonatomic ,assign) CGSize  size;           //大小

- (void)setOriginY:(CGFloat)originY;                //设置原点y值
- (void)setOriginX:(CGFloat)originX;                //设置原点X值
- (void)removeAllSubviews;                          //移除所有子视图
- (void)removeSubview:(UIView *)view;               //移除子视图
- (NSUInteger)getSubviewIndex;                      //当前视图在父视图中的索引
- (void)bringToFront;                               //将view显示在最前面
- (void)sendToBack;                                 //将view显示在最后面
- (void)bringOneLevelUp;                            //将view向上移动一个图层
- (void)sendOneLevelDown;                           //将view向下移动一个图层
- (BOOL)isInFront;                                  //view是否在最上面
- (BOOL)isAtBack;                                   //view是否在最下面
- (void)swapDepthsWithView:(UIView*)swapView;       //view互换图层

@end
