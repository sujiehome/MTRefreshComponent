//
//  MTRefreshConfig.m
//  MTRefreshComponent
//
//  Created by suyuxuan on 2017/7/3.
//  Copyright © 2017年 Monk.Tang. All rights reserved.
//

#import "MTRefreshConfig.h"

@interface MTRefreshConfig ()<NSCopying, NSMutableCopying>

@end

@implementation MTRefreshConfig

static MTRefreshConfig *config;

+ (instancetype)shared
{
    return [[self alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (config == nil) {
            config = [super allocWithZone:zone];
        }
    });
    return config;
}

- (id)copyWithZone:(NSZone *)zone
{
    return config;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return config;
}

@end
