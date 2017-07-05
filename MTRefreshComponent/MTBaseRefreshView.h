//
//  MTBaseRefreshView.h
//  MTRefreshComponent
//
//  Created by suyuxuan on 2017/7/3.
//  Copyright © 2017年 Monk.Tang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTBaseRefreshView : UIView

/**
 空闲状态
 */
- (void)idle;

/**
 拖动过程
 
 @param y 偏移量
 */
- (void)pulling:(float)y;

/**
 松手即触发状态
 */
- (void)trigger;

/**
 刷新中状态
 */
- (void)refreshing;

/**
 刷新完成
 */
- (void)completion;

@end
