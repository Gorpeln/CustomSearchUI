//
//  NSBundle+GPSearch.h
//  GPSearchDemo
//
//  Created by chen on 16/10/27.
//  Copyright © 2016年 Gorpeln. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSBundle (GPSearch)

/**
 Get the localized string

 @param key     key for localized string
 @return a localized string
 */
+ (NSString *)gp_localizedStringForKey:(NSString *)key;

/**
 Get the path of `GPSearch.bundle`.

 @return path of the `GPSearch.bundle`
 */
+ (NSBundle *)gp_searchBundle;

/**
 Get the image in the `GPSearch.bundle` path

 @param name name of image
 @return a image
 */
+ (UIImage *)gp_imageNamed:(NSString *)name;

@end
