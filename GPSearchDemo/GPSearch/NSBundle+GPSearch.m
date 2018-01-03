//
//  NSBundle+GPSearch.m
//  GPSearchDemo
//
//  Created by chen on 16/10/27.
//  Copyright © 2016年 Gorpeln. All rights reserved.
//

#import "NSBundle+GPSearch.h"
#import "GPSearchVC.h"

@implementation NSBundle (GPSearch)

+ (NSBundle *)gp_searchBundle
{
    static NSBundle *searchBundle = nil;
    if (nil == searchBundle) {
        //Default use `[NSBundle mainBundle]`.
        searchBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"GPSearch" ofType:@"bundle"]];
        /**
         If you use pod import and configure `use_frameworks` in Podfile, [NSBundle mainBundle] does not load the `GPSearch.fundle` resource file in `GPSearch.framework`.
         */
        if (nil == searchBundle) { // Empty description resource file in `GPSearch.framework`.
            searchBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[GPSearchVC class]] pathForResource:@"GPSearch" ofType:@"bundle"]];
        }
    }
    return searchBundle;
}

+ (NSString *)gp_localizedStringForKey:(NSString *)key;
{
    return [self gp_localizedStringForKey:key value:nil];
}

+ (NSString *)gp_localizedStringForKey:(NSString *)key value:(NSString *)value
{
    static NSBundle *bundle = nil;
    if (nil == bundle) {
        NSString *language = [NSLocale preferredLanguages].firstObject;
        if ([language hasPrefix:@"en"]) language = @"en";
        else if ([language hasPrefix:@"es"]) language = @"es";
        else if ([language hasPrefix:@"fr"]) language = @"fr";
        else if ([language hasPrefix:@"zh"]) {
            if ([language rangeOfString:@"Hans"].location != NSNotFound) {
                language = @"zh-Hans";
            } else {
                language = @"zh-Hant";
            }
        } else {
            language = @"en";
        }
        
        // Find resources from `GPSearch.bundle`
        bundle = [NSBundle bundleWithPath:[[NSBundle gp_searchBundle] pathForResource:language ofType:@"lproj"]];
    }
    value = [bundle localizedStringForKey:key value:value table:nil];
    return [[NSBundle mainBundle] localizedStringForKey:key value:value table:nil];
}
    
+ (UIImage *)gp_imageNamed:(NSString *)name
{
    CGFloat scale = [[UIScreen mainScreen] scale];
    name = 3.0 == scale ? [NSString stringWithFormat:@"%@@3x.png", name] : [NSString stringWithFormat:@"%@@2x.png", name];
    UIImage *image = [UIImage imageWithContentsOfFile:[[[NSBundle gp_searchBundle] resourcePath] stringByAppendingPathComponent:name]];
    return image;
}

@end
