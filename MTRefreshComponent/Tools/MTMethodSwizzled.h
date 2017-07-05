//
//  MTMethodSwizzled.h
//  MTRefreshComponent
//
//  Created by suyuxuan on 2017/7/3.
//  Copyright © 2017年 Monk.Tang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTMethodSwizzled : NSObject

/**
 原类/类别中交换方法

 @param cls 所属类
 @param originalSel 原始方法
 @param swizzledSel 交换方法
 */
+ (void)exchangeImpWithClass:(Class)cls originalSel:(SEL)originalSel swizzledSel:(SEL)swizzledSel;


/**
 跨类交换方法

 @param oriCls 原始方法所在类
 @param oriSel 原始方法
 @param tmpSel 中转方法
 @param swiCls 交换方法所在类
 @param swiSel 交换方法
 @param forwardCls 消息转发方法所在类 非必传(当传nil时，msgForwardSel无效，会走默认安全防护方法)
 @param msgForwardSel 消息转发方法 非必传
 */
+ (void)exchangeImpWithOriginalClass:(Class)oriCls
                         originalSel:(SEL)oriSel
                              tmpSel:(SEL)tmpSel
                       swizzledClass:(Class)swiCls
                         swizzledSel:(SEL)swiSel
                     msgForwardClass:(Class)forwardCls
                       msgForwardSel:(SEL)msgForwardSel;

@end
