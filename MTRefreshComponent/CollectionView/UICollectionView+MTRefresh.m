//
//  UICollectionView+MTRefresh.m
//  MTRefreshComponent
//
//  Created by suyuxuan on 2017/7/3.
//  Copyright © 2017年 Monk.Tang. All rights reserved.
//

#import "UICollectionView+MTRefresh.h"
#import <MJRefresh/MJRefresh.h>
#import <objc/message.h>
#import "MTRefreshConfig.h"
#import "MTMethodSwizzled.h"

static char kUnrealizedSection;
static char kUnrealizedSectionHeader;
static char kUnrealizedSectionFooter;

@implementation UICollectionView (MTRefresh)

@dynamic isShowNullDataView;
@dynamic nullDataView;

+ (void)load
{
    [MTMethodSwizzled exchangeImpWithClass:self originalSel:@selector(reloadData) swizzledSel:@selector(hook_reloadData)];
    
    [MTMethodSwizzled exchangeImpWithClass:self originalSel:@selector(setDataSource:) swizzledSel:@selector(hook_setDataSource:)];
    
    [MTMethodSwizzled exchangeImpWithClass:self originalSel:@selector(setDelegate:) swizzledSel:@selector(hook_setDelegate:)];
    
    [MTMethodSwizzled exchangeImpWithClass:self originalSel:@selector(layoutSubviews) swizzledSel:@selector(hook_layoutSubviews)];
}

- (void)hook_reloadData
{
    if (self.mj_header) {
        [self.mj_header endRefreshing];
        if (!self.window || self.mj_header.state == MJRefreshStateIdle) {
            [self resetContentInset];
        }
    }
    
    if (self.mj_footer) {
        if (self.mj_footer.state != MJRefreshStateNoMoreData) {
            [self.mj_footer endRefreshing];
            if (!self.window || self.mj_footer.state == MJRefreshStateIdle) {
                [self resetContentInset];
            }
        }
    }
    
    self.showNullDataView = YES;
    
    [self hook_reloadData];
}

- (void)hook_layoutSubviews
{
    [self hook_layoutSubviews];
    
    self.nullDataView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
}

- (void)hook_setDataSource:(id<UICollectionViewDataSource>)dataSource
{
    [MTMethodSwizzled exchangeImpWithOriginalClass:[dataSource class]
                                       originalSel:@selector(collectionView:numberOfItemsInSection:)
                                            tmpSel:@selector(tmp_collectionView:numberOfItemsInSection:)
                                     swizzledClass:[self class]
                                       swizzledSel:@selector(hook_collectionView:numberOfItemsInSection:)
                                   msgForwardClass:nil
                                     msgForwardSel:nil];
    
    [MTMethodSwizzled exchangeImpWithOriginalClass:[dataSource class]
                                       originalSel:@selector(numberOfSectionsInCollectionView:)
                                            tmpSel:@selector(tmp_numberOfSectionsInCollectionView:)
                                     swizzledClass:[self class]
                                       swizzledSel:@selector(hook_numberOfSectionsInCollectionView:)
                                   msgForwardClass:[self class]
                                     msgForwardSel:@selector(msgForward_numberOfSectionsInCollectionView:)];
    
    [self hook_setDataSource:dataSource];
}

- (void)hook_setDelegate:(id<UICollectionViewDelegate>)delegate
{
    [MTMethodSwizzled exchangeImpWithOriginalClass:[delegate class]
                                       originalSel:@selector(collectionView:layout:referenceSizeForHeaderInSection:)
                                            tmpSel:@selector(tmp_collectionView:layout:referenceSizeForHeaderInSection:)
                                     swizzledClass:[self class]
                                       swizzledSel:@selector(hook_collectionView:layout:referenceSizeForHeaderInSection:)
                                   msgForwardClass:[self class]
                                     msgForwardSel:@selector(msgForward_collectionView:layout:referenceSizeForHeaderInSection:)];
    
    [MTMethodSwizzled exchangeImpWithOriginalClass:[delegate class]
                                       originalSel:@selector(collectionView:layout:referenceSizeForFooterInSection:)
                                            tmpSel:@selector(tmp_collectionView:layout:referenceSizeForFooterInSection:)
                                     swizzledClass:[self class]
                                       swizzledSel:@selector(hook_collectionView:layout:referenceSizeForFooterInSection:)
                                   msgForwardClass:[self class]
                                     msgForwardSel:@selector(msgForward_collectionView:layout:referenceSizeForFooterInSection:)];
    
    [self hook_setDelegate:delegate];
}

#pragma mark - Private Method
- (void)resetContentInset
{
    [UIView animateWithDuration:0.3 animations:^{
        if (self.mj_header.scrollViewOriginalInset.top < 0) {
            self.contentOffset = CGPointMake(0, self.contentOffset.y - self.mj_header.mj_h);
        }
        self.contentInset = UIEdgeInsetsMake(self.mj_header.mj_origin.y + self.mj_header.mj_h, 0, 0, 0);
    }];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)hook_collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger item = [self tmp_collectionView:collectionView numberOfItemsInSection:section];
    
    BOOL b = ((BOOL (*)(id, SEL))objc_msgSend)(collectionView, @selector(showNullDataView));
    if (b) {
        ((void (*)(id, SEL, BOOL))objc_msgSend)(collectionView, @selector(setShowNullDataView:), item == 0);
    }
    
    UIView *nullDataView = (((UIView * (*)(id, SEL))objc_msgSend)(collectionView, @selector(nullDataView)));
    BOOL isShow = ((BOOL (*)(id, SEL))objc_msgSend)(collectionView, @selector(showNullDataView));
    nullDataView.hidden = !isShow;
    
    return item;
}

- (NSInteger)hook_numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSInteger section = [self tmp_numberOfSectionsInCollectionView:collectionView];
    
    NSNumber *unrealized = objc_getAssociatedObject(self, &kUnrealizedSection);
    if ([unrealized boolValue]) {
        return 1;
    }
    
    if (section == 0) {
        ((void (*)(id, SEL, BOOL))objc_msgSend)(collectionView, @selector(setShowNullDataView:), YES);
        UIView *nullDataView = (((UIView *(*)(id, SEL))objc_msgSend)(collectionView, @selector(nullDataView)));
        BOOL isShow = ((BOOL (*)(id, SEL))objc_msgSend)(collectionView, @selector(showNullDataView));
        nullDataView.hidden = !isShow;
    }
    return section;
}

- (NSInteger)tmp_collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 0;
}

- (NSInteger)tmp_numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 0;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)hook_collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGSize size = [self tmp_collectionView:collectionView layout:collectionViewLayout referenceSizeForHeaderInSection:section];
    
    NSNumber *unrealized = objc_getAssociatedObject(self, &kUnrealizedSectionHeader);
    if ([unrealized boolValue]) {
        return CGSizeZero;
    }
    
    BOOL b = ((BOOL (*)(id, SEL))objc_msgSend)(collectionView, @selector(showNullDataView));
    if (b) {
        BOOL tmpIsShow = size.width == 0 && size.height == 0;
        ((void (*)(id, SEL, BOOL))objc_msgSend)(collectionView, @selector(setShowNullDataView:), tmpIsShow);
    }
    
    UIView *nullDataView = (((UIView * (*)(id, SEL))objc_msgSend)(collectionView, @selector(nullDataView)));
    BOOL isShow = ((BOOL (*)(id, SEL))objc_msgSend)(collectionView, @selector(showNullDataView));
    nullDataView.hidden = !isShow;
    
    return size;
}

- (CGSize)hook_collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    CGSize size = [self tmp_collectionView:collectionView layout:collectionViewLayout referenceSizeForFooterInSection:section];
    
    NSNumber *unrealized = objc_getAssociatedObject(self, &kUnrealizedSectionFooter);
    if ([unrealized boolValue]) {
        return CGSizeZero;
    }
    
    BOOL b = ((BOOL (*)(id, SEL))objc_msgSend)(collectionView, @selector(showNullDataView));
    if (b) {
        BOOL tmpIsShow = size.width == 0 && size.height == 0;
        ((void (*)(id, SEL, BOOL))objc_msgSend)(collectionView, @selector(setShowNullDataView:), tmpIsShow);
    }
    
    UIView *nullDataView = (((UIView * (*)(id, SEL))objc_msgSend)(collectionView, @selector(nullDataView)));
    BOOL isShow = ((BOOL (*)(id, SEL))objc_msgSend)(collectionView, @selector(showNullDataView));
    nullDataView.hidden = !isShow;
    
    return size;
}

- (CGSize)tmp_collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeZero;
}

- (CGSize)tmp_collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeZero;
}

#pragma mark - Swizzled
- (NSInteger)msgForward_numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    objc_setAssociatedObject(self, &kUnrealizedSection, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return 0;
}

- (CGSize)msgForward_collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    objc_setAssociatedObject(self, &kUnrealizedSectionHeader, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return CGSizeZero;
}

- (CGSize)msgForward_collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    objc_setAssociatedObject(self, &kUnrealizedSectionFooter, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return CGSizeZero;
}

#pragma mark - Setter & Getter
- (void)setShowNullDataView:(BOOL)isShowNullDataView
{
    objc_setAssociatedObject(self, @selector(showNullDataView), @(isShowNullDataView), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)showNullDataView
{
    BOOL b = [objc_getAssociatedObject(self, @selector(showNullDataView)) boolValue];
    return b;
}

- (void)setNullDataView:(UIView *)nullDataView
{
    objc_setAssociatedObject(self, @selector(nullDataView), nullDataView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)nullDataView
{
    UIView *view = objc_getAssociatedObject(self, @selector(nullDataView));
    if (!view) {
        if ([MTRefreshConfig shared].customNullDataView.length > 0) {
            Class class = NSClassFromString([MTRefreshConfig shared].customNullDataView);
            if (class) {
                view = [[class alloc] init];
                view.frame = self.bounds;
                view.hidden = YES;
                [self addSubview:view];
                objc_setAssociatedObject(self, @selector(nullDataView), view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }
    }
    if (!view.superview) {
        [self addSubview:view];
    }
    return view;
}

@end
