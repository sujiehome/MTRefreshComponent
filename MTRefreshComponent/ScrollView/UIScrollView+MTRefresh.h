//
//  UIScrollView+MTRefresh.h
//  MTRefreshComponent
//
//  Created by suyuxuan on 2017/7/3.
//  Copyright © 2017年 Monk.Tang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTBaseRefreshView.h"

typedef enum : NSUInteger {
    MTRefreshStateIdle,         //闲置状态          默认 下拉刷新/上拉加载更多
    MTRefreshStateTrigger,      //松开即可触发刷新    默认 松开刷新/松开加载
    MTRefreshStateRefreshing,   //刷新中            默认 刷新中/加载中
    MTRefreshStateNoMoreData    //没有更多数据       默认 没有更多数据
} MTRefreshState;//刷新/加载状态

@interface UIScrollView (MTRefresh)

#pragma mark - 添加控件
/**
 添加默认顶部刷新控件
 如在LPRefreshConfig中已配置，则添加配置视图
 
 @param triggerBlock 触发回调
 */
- (void)addTopRefreshWithTriggerBlock:(void (^)())triggerBlock;

/**
 添加默认底部刷新控件
 
 @param isAuto 是否自动刷新
 @param triggerBlock 触发回调
 */
- (void)addBottomRefreshWithAutoRefresh:(BOOL)isAuto triggerBlock:(void (^)())triggerBlock;

/**
 添加自定义顶部刷新控件
 
 @param view 自定义控件
 @param triggerBlock 触发回调
 */
- (void)addTopRefreshCustomView:(MTBaseRefreshView *)view withTriggerBlock:(void (^)())triggerBlock;

#pragma mark - 设置状态
/**
 设置没有更多数据
 */
- (void)noMoreData;

/**
 重置没有更多数据状态
 */
- (void)resetNoMoreData;

/**
 设置默认顶部刷新控件不同状态下的文案   对自定义视图无效
 
 @param block 传递状态，返回对应文案
 */
- (void)setTopTipText:(NSString *(^)(MTRefreshState state))block;

/**
 设置底部刷新控件不同状态下的文案
 
 @param block 传递状态，返回对应文案
 */
- (void)setBottomTipText:(NSString *(^)(MTRefreshState state))block;

#pragma mark - 主动刷新
/**
 顶部控件执行刷新
 */
- (void)topBeginRefresh;

/**
 底部控件执行刷新
 */
- (void)bottomBeginRefresh;

@end
