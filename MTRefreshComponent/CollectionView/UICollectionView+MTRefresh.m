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

static char kUnrealizedSection;
static char kUnrealizedSectionHeader;
static char kUnrealizedSectionFooter;

@implementation UICollectionView (MTRefresh)

@dynamic isShowNullDataView;
@dynamic nullDataView;

+ (void)load
{
    [self exchangeImpWithClass:self originalSel:@selector(reloadData) swizzledSel:@selector(hook_reloadData)];
    
    [self exchangeImpWithClass:self originalSel:@selector(setDataSource:) swizzledSel:@selector(hook_setDataSource:)];
    
    [self exchangeImpWithClass:self originalSel:@selector(setDelegate:) swizzledSel:@selector(hook_setDelegate:)];
    
    [self exchangeImpWithClass:self originalSel:@selector(layoutSubviews) swizzledSel:@selector(hook_layoutSubviews)];
}

- (void)hook_reloadData
{
    if (self.mj_header) {
        [self.mj_header endRefreshing];
    }
    
    if (self.mj_footer) {
        if (self.mj_footer.state != MJRefreshStateNoMoreData) {
            [self.mj_footer endRefreshing];
        }
    }
    
    self.showNullDataView = YES;
    
    [self hook_reloadData];
}

- (void)hook_layoutSubviews
{
    [self hook_layoutSubviews];
    
    
}

- (void)hook_setDataSource:(id<UICollectionViewDataSource>)dataSource
{
    [UICollectionView exchangeImpWithOriginalClass:[dataSource class] swizzledClass:[self class] originalSel:@selector(collectionView:numberOfItemsInSection:) swizzledSel:@selector(hook_collectionView:numberOfItemsInSection:) tmpSel:@selector(tmp_collectionView:numberOfItemsInSection:) msgForwardSel:@selector(msgForwardHandle)];
    
    [UICollectionView exchangeImpWithOriginalClass:[dataSource class] swizzledClass:[self class] originalSel:@selector(numberOfSectionsInCollectionView:) swizzledSel:@selector(hook_numberOfSectionsInCollectionView:) tmpSel:@selector(tmp_numberOfSectionsInCollectionView:) msgForwardSel:@selector(msgForward_numberOfSectionsInCollectionView:)];
    
    [self hook_setDataSource:dataSource];
}

- (void)hook_setDelegate:(id<UICollectionViewDelegate>)delegate
{
    [UICollectionView exchangeImpWithOriginalClass:[delegate class] swizzledClass:[self class] originalSel:@selector(collectionView:layout:referenceSizeForHeaderInSection:) swizzledSel:@selector(hook_collectionView:layout:referenceSizeForHeaderInSection:) tmpSel:@selector(tmp_collectionView:layout:referenceSizeForHeaderInSection:) msgForwardSel:@selector(msgForward_collectionView:layout:referenceSizeForHeaderInSection:)];
    
    [UICollectionView exchangeImpWithOriginalClass:[delegate class] swizzledClass:[self class] originalSel:@selector(collectionView:layout:referenceSizeForFooterInSection:) swizzledSel:@selector(hook_collectionView:layout:referenceSizeForFooterInSection:) tmpSel:@selector(tmp_collectionView:layout:referenceSizeForFooterInSection:) msgForwardSel:@selector(msgForward_collectionView:layout:referenceSizeForFooterInSection:)];
    
    [self hook_setDelegate:delegate];
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
+ (void)exchangeImpWithClass:(Class)cls originalSel:(SEL)originalSel swizzledSel:(SEL)swizzledSel
{
    Method originalMethod = class_getInstanceMethod(cls, originalSel);
    Method swizzledMethod = class_getInstanceMethod(cls, swizzledSel);
    
    BOOL didAddMethod = class_addMethod(cls,
                                        originalSel,
                                        method_getImplementation(originalMethod),
                                        method_getTypeEncoding(originalMethod));
    
    if (didAddMethod) {
        //如果add成功，说明原始类并没有实现此方法的imp，为避免调用时执行消息转发，此处做统一处理
        originalMethod = class_getInstanceMethod(cls, originalSel);
        SEL handleSel = @selector(msgForwardHandle);
        IMP handleIMP = class_getMethodImplementation(self, handleSel);
        method_setImplementation(originalMethod, handleIMP);
    }
    
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

//跨类交换方法
+ (void)exchangeImpWithOriginalClass:(Class)oriCls swizzledClass:(Class)swiCls originalSel:(SEL)oriSel swizzledSel:(SEL)swiSel tmpSel:(SEL)tmpSel msgForwardSel:(SEL)msgForwardSel
{
    //增加原始方法
    Method originalMethod = class_getInstanceMethod(oriCls, oriSel);
    BOOL didAddOriMethod = class_addMethod(oriCls, oriSel, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    if (didAddOriMethod) {
        originalMethod = class_getInstanceMethod(oriCls, oriSel);
        SEL handleSel = msgForwardSel;
        IMP handleIMP = class_getMethodImplementation(self, handleSel);
        method_setImplementation(originalMethod, handleIMP);
    }
    
    //增加临时中转方法
    class_addMethod(oriCls, tmpSel, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    
    
    Method swizzledMethod = class_getInstanceMethod(swiCls, swiSel);
    class_replaceMethod(oriCls, oriSel, method_getImplementation(swizzledMethod), method_getTypeEncoding(originalMethod));
    
}

- (void)msgForward_numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    objc_setAssociatedObject(self, &kUnrealizedSection, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)msgForward_collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    objc_setAssociatedObject(self, &kUnrealizedSectionHeader, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)msgForward_collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    objc_setAssociatedObject(self, &kUnrealizedSectionFooter, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)msgForwardHandle
{
    /**
     备用方法，防止原类中没有实现需要交换的方法，导致交换后执行消息转发最终没有处理导致crash。
     后续可以在做底层安全时，做到相应处理类中。
     */
    NSLog(@"%s  ", __FUNCTION__);
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
    return view;
}

@end
