//
//  UIColor+GPAdditions.h
//  GPSearchDemo
//
//  Created by chen on 16/10/27.
//  Copyright © 2016年 Gorpeln. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface UIColor (GPAdditions)

/**
 Returns the corresponding color according to the hexadecimal string.

 @param hexString   hexadecimal string(eg:@"#ccff88")
 @return new instance of `UIColor` class
 */
+ (instancetype)gp_colorWithHexString:(NSString *)hexString;

/**
  Returns the corresponding color according to the hexadecimal string and alpha.

 @param hexString   hexadecimal string(eg:@"#ccff88")
 @param alpha       alpha
 @return new instance of `UIColor` class
 */
+ (instancetype)gp_colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha;

@end
