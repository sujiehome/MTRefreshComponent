//
//  UITableView+MTRefresh.m
//  MTRefreshComponent
//
//  Created by suyuxuan on 2017/7/3.
//  Copyright © 2017年 Monk.Tang. All rights reserved.
//

#import "UITableView+MTRefresh.h"
#import <MJRefresh/MJRefresh.h>
#import <objc/message.h>
#import "MTRefreshConfig.h"
#import "MTMethodSwizzled.h"

static char kUnrealizedSection;
static char kUnrealizedSectionHeader;
static char kUnrealizedSectionFooter;

@implementation UITableView (MTRefresh)

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
    }
    
    if (self.mj_footer.state != MJRefreshStateNoMoreData) {
        [self.mj_footer endRefreshing];
    }
    
    self.showNullDataView = YES;
    
    [self hook_reloadData];
}

- (void)hook_layoutSubviews
{
    [self hook_layoutSubviews];
    
    CGSize size = CGSizeMake(self.bounds.size.width, self.bounds.size.height - self.tableHeaderView.frame.size.height - self.tableFooterView.frame.size.height);
    self.nullDataView.frame = CGRectMake(0, self.tableHeaderView.frame.size.height, size.width, size.height);
}

- (void)hook_setDataSource:(id<UITableViewDataSource>)dataSource
{
    [MTMethodSwizzled exchangeImpWithOriginalClass:[dataSource class]
                                       originalSel:@selector(tableView:numberOfRowsInSection:)
                                            tmpSel:@selector(tmp_tableView:numberOfRowsInSection:)
                                     swizzledClass:[self class]
                                       swizzledSel:@selector(hook_tableView:numberOfRowsInSection:)
                                   msgForwardClass:nil
                                     msgForwardSel:nil];
    
    [MTMethodSwizzled exchangeImpWithOriginalClass:[dataSource class]
                                       originalSel:@selector(numberOfSectionsInTableView:)
                                            tmpSel:@selector(tmp_numberOfSectionsInTableView:)
                                     swizzledClass:[self class]
                                       swizzledSel:@selector(hook_numberOfSectionsInTableView:)
                                   msgForwardClass:[self class]
                                     msgForwardSel:@selector(msgForward_numberOfSectionsInTableView)];
    
    [self hook_setDataSource:dataSource];
}

- (void)hook_setDelegate:(id<UITableViewDelegate>)delegate
{
    [MTMethodSwizzled exchangeImpWithOriginalClass:[delegate class]
                                       originalSel:@selector(tableView:heightForHeaderInSection:)
                                            tmpSel:@selector(tmp_tableView:heightForHeaderInSection:)
                                     swizzledClass:[self class]
                                       swizzledSel:@selector(hook_tableView:heightForHeaderInSection:)
                                   msgForwardClass:[self class]
                                     msgForwardSel:@selector(msgForward_heightForHeaderInSection)];
    
    [MTMethodSwizzled exchangeImpWithOriginalClass:[delegate class]
                                       originalSel:@selector(tableView:heightForFooterInSection:)
                                            tmpSel:@selector(tmp_tableView:heightForFooterInSection:)
                                     swizzledClass:[self class]
                                       swizzledSel:@selector(hook_tableView:heightForFooterInSection:)
                                   msgForwardClass:[self class]
                                     msgForwardSel:@selector(msgForward_heightForFooterInSection)];
    
    [self hook_setDelegate:delegate];
}

#pragma mark - UITableViewDataSource
- (NSInteger)hook_tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger row = [self tmp_tableView:tableView numberOfRowsInSection:section];
    
    //    if (tableView.showNullDataView) {
    //        tableView.showNullDataView = row == 0;
    //    }
    //    tableView.nullDataView.hidden = tableView.showNullDataView;
    
    //由于跨类swizzled导致此时self为table的持有者，而showNullDataView与nullDataView属性持有者并不一定知道，所以将上述代码采用runtime机制实现
    BOOL b = ((BOOL (*)(id, SEL))objc_msgSend)(tableView, @selector(showNullDataView));
    if (b) {
        ((void (*)(id, SEL, BOOL))objc_msgSend)(tableView, @selector(setShowNullDataView:), row == 0);
    }
    
    UIView *nullDataView = (((UIView * (*)(id, SEL))objc_msgSend)(tableView, @selector(nullDataView)));
    BOOL isShow = ((BOOL (*)(id, SEL))objc_msgSend)(tableView, @selector(showNullDataView));
    nullDataView.hidden = !isShow;
    
    return row;
}

- (NSInteger)hook_numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger section = [self tmp_numberOfSectionsInTableView:tableView];
    
    NSNumber *unrealized = objc_getAssociatedObject(self, &kUnrealizedSection);
    if ([unrealized boolValue]) {
        return 1;
    }
    
    if (section == 0) {
        ((void (*)(id, SEL, BOOL))objc_msgSend)(tableView, @selector(setShowNullDataView:), YES);
        UIView *nullDataView = (((UIView *(*)(id, SEL))objc_msgSend)(tableView, @selector(nullDataView)));
        BOOL isShow = ((BOOL (*)(id, SEL))objc_msgSend)(tableView, @selector(showNullDataView));
        nullDataView.hidden = !isShow;
    }
    return section;
}

- (NSInteger)tmp_tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (NSInteger)tmp_numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}

#pragma mark - UITableViewDelegate
- (CGFloat)hook_tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = [self tmp_tableView:tableView heightForHeaderInSection:section];
    
    NSNumber *unrealized = objc_getAssociatedObject(self, &kUnrealizedSectionHeader);
    if ([unrealized boolValue]) {
        return 0;
    }
    
    //高度小于0.1时显示 主要针对一些使用group分组类型而又不想显示组头组尾的视图 通常会设置为0.001
    //    if (tableView.showNullDataView) {
    //        tableView.showNullDataView = height < 0.1;
    //    }
    //原理同numberOfRows
    BOOL b = ((BOOL (*)(id, SEL))objc_msgSend)(tableView, @selector(showNullDataView));
    if (b) {
        ((void (*)(id, SEL, BOOL))objc_msgSend)(tableView, @selector(setShowNullDataView:), height < 0.1);
    }
    
    return height;
}

- (CGFloat)hook_tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat height = [self tmp_tableView:tableView heightForFooterInSection:section];
    
    NSNumber *unrealized = objc_getAssociatedObject(self, &kUnrealizedSectionFooter);
    if ([unrealized boolValue]) {
        return 0;
    }
    
    //如果实现heightForFooterInSection:并且高度为0，则显示
    //    if (tableView.showNullDataView) {
    //        tableView.showNullDataView = height < 0.1;
    //    }
    //原理同numberOfRows
    BOOL b = ((BOOL (*)(id, SEL))objc_msgSend)(tableView, @selector(showNullDataView));
    if (b) {
        ((void (*)(id, SEL, BOOL))objc_msgSend)(tableView, @selector(setShowNullDataView:), height < 0.1);
    }
    
    return height;
}

- (CGFloat)tmp_tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.f;
}

- (CGFloat)tmp_tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.f;
}

#pragma mark - Swizzled
- (void)msgForward_numberOfSectionsInTableView
{
    objc_setAssociatedObject(self, &kUnrealizedSection, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)msgForward_heightForHeaderInSection
{
    objc_setAssociatedObject(self, &kUnrealizedSectionHeader, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)msgForward_heightForFooterInSection
{
    objc_setAssociatedObject(self, &kUnrealizedSectionFooter, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
        if ([MTRefreshConfig shared].customNullDataView) {
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
