//
//  MTRefreshConfig.h
//  MTRefreshComponent
//
//  Created by suyuxuan on 2017/7/3.
//  Copyright © 2017年 Monk.Tang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MTRefreshConfig : NSObject

/** 获取实例 */
+ (instancetype)shared;

#pragma mark - 默认属性配置
/** 刷新超时时长 */
@property (nonatomic, assign) float refreshTimeout;

#pragma mark - 默认顶部刷新控件配置 已配置自定义视图则无效
/** 闲置状态 */
@property (nonatomic, copy) NSString *headerIdleText;
/** 触发状态 */
@property (nonatomic, copy) NSString *headerTriggerText;
/** 刷新中 */
@property (nonatomic, copy) NSString *headerRefreshingText;

/** 字号 */
@property (nonatomic, strong) UIFont *headerFont;
/** 颜色 */
@property (nonatomic, strong) UIColor *headerTextColor;


#pragma mark - 底部刷新控件配置
/** 闲置状态 */
@property (nonatomic, copy) NSString *footerIdleText;
/** 触发状态 */
@property (nonatomic, copy) NSString *footerTriggerText;
/** 刷新中 */
@property (nonatomic, copy) NSString *footerRefreshingText;
/** 没有更多 */
@property (nonatomic, copy) NSString *footerNoMoreDataText;

/** 字号 */
@property (nonatomic, strong) UIFont *footerFont;
/** 颜色 */
@property (nonatomic, strong) UIColor *footerTextColor;


#pragma mark - 自定义视图配置
/** 自定义顶部刷新视图 必须继承LPBaseRefreshView */
@property (nonatomic, copy) NSString *customTopView;
/** 自定义空数据视图 */
@property (nonatomic, copy) NSString *customNullDataView;

@end
