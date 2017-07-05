//
//  MTBaseRefreshView.m
//  MTRefreshComponent
//
//  Created by suyuxuan on 2017/7/3.
//  Copyright © 2017年 Monk.Tang. All rights reserved.
//

#import "MTBaseRefreshView.h"

@implementation MTBaseRefreshView

- (void)idle
{
    NSLog(@"idle");
}

- (void)pulling:(float)y
{
    NSLog(@"%f", y);
}

- (void)trigger
{
    NSLog(@"trigger");
}

- (void)refreshing
{
    NSLog(@"refreshing");
}

- (void)completion
{
    NSLog(@"completion");
}

@end
