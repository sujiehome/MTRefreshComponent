//
//  UICollectionView+MTRefresh.h
//  MTRefreshComponent
//
//  Created by suyuxuan on 2017/7/3.
//  Copyright © 2017年 Monk.Tang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICollectionView (MTRefresh)

/**
 是否显示空视图
 */
@property (nonatomic, assign, setter=showNullDataView:, getter=showNullDataView) BOOL isShowNullDataView;

/**
 空视图
 */
@property (nonatomic, strong) UIView *nullDataView;

@end
