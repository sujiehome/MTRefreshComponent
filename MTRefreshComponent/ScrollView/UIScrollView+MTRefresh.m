//
//  UIScrollView+MTRefresh.m
//  MTRefreshComponent
//
//  Created by suyuxuan on 2017/7/3.
//  Copyright © 2017年 Monk.Tang. All rights reserved.
//

#import "UIScrollView+MTRefresh.h"
#import <MJRefresh/MJRefresh.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import "MTRefreshConfig.h"
#import "MTScrollViewAssist.h"
#import "MTMethodSwizzled.h"

static float const kRefreshTimeout = 3;
static CGFloat const kTopRefreshViewHeight = 40;

@implementation UIScrollView (MTRefresh)

+ (void)load
{
    [MTMethodSwizzled exchangeImpWithClass:self originalSel:@selector(didMoveToSuperview) swizzledSel:@selector(hook_didMoveToSuperview)];
}

- (void)hook_didMoveToSuperview
{
    if ([self isMemberOfClass:[UITableView class]] ||
        [self isMemberOfClass:[UICollectionView class]]) {
        if (self.superview && !objc_getAssociatedObject(self.superview, @selector(addAssist))) {
            [self addAssist];
        }
    }
    [self hook_didMoveToSuperview];
}

#pragma mark - API
- (void)addTopRefreshWithTriggerBlock:(void (^)())triggerBlock
{
    if (!self.mj_header) {
        __weak typeof(self) wself = self;
        
        MJRefreshStateHeader *header = [MJRefreshStateHeader headerWithRefreshingBlock:^{
            triggerBlock();
            
            float timeout = [MTRefreshConfig shared].refreshTimeout > 0 ? [MTRefreshConfig shared].refreshTimeout : kRefreshTimeout;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (wself.mj_header.state == MJRefreshStateRefreshing) {
                    [wself.mj_header endRefreshing];
                    [wself fixContentInsetForIdle];
                }
            });
        }];
        header.lastUpdatedTimeLabel.hidden = YES;
        self.mj_header = header;
        
        if ([MTRefreshConfig shared].customTopView.length > 0) {
            Class className = NSClassFromString([MTRefreshConfig shared].customTopView);
            if (className) {
                MTBaseRefreshView *view = [[className alloc] init];
                if ([view isKindOfClass:[MTBaseRefreshView class]]) {
                    CGFloat tmpHeight = [MTRefreshConfig shared].customTopViewHeight > 0 ? [MTRefreshConfig shared].customTopViewHeight : kTopRefreshViewHeight;
                    view.frame = CGRectMake(0, 0, header.bounds.size.width, tmpHeight);
                    header.stateLabel.hidden = YES;
                    header.endRefreshingCompletionBlock = ^{
                        [view completion];
                    };
                    
                    header.frame = view.frame;
                    [header addSubview:view];
                    
                    objc_setAssociatedObject(self, @selector(refreshView), view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                }else {
                    [self headerViewConfig];
                }
            }else {
                [self headerViewConfig];
            }
        }else {
            [self headerViewConfig];
        }
    }
    
    NSString *(^block)(MTRefreshState) = objc_getAssociatedObject(self, @selector(setTopTipText:));
    if (block) {
        MJRefreshStateHeader *header = (MJRefreshStateHeader *)self.mj_header;
        [header setTitle:block(MTRefreshStateIdle) forState:MJRefreshStateIdle];
        [header setTitle:block(MTRefreshStateTrigger) forState:MJRefreshStatePulling];
        [header setTitle:block(MTRefreshStateRefreshing) forState:MJRefreshStateRefreshing];
    }
}

- (void)addBottomRefreshWithAutoRefresh:(BOOL)isAuto triggerBlock:(void (^)())triggerBlock
{
    if (!self.mj_footer) {
        if (isAuto) {
            __weak typeof(self) wself = self;
            
            self.mj_footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
                triggerBlock();
                
                float timeout = [MTRefreshConfig shared].refreshTimeout > 0 ? [MTRefreshConfig shared].refreshTimeout : kRefreshTimeout;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (wself.mj_footer.state == MJRefreshStateRefreshing) {
                        [wself.mj_footer endRefreshing];
                        [wself fixContentInsetForIdle];
                    }
                });
            }];
        }else {
            __weak typeof(self) wself = self;
            
            self.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
                triggerBlock();
                
                float timeout = [MTRefreshConfig shared].refreshTimeout > 0 ? [MTRefreshConfig shared].refreshTimeout : kRefreshTimeout;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (wself.mj_footer.state == MJRefreshStateRefreshing) {
                        [wself.mj_footer endRefreshing];
                        [wself fixContentInsetForIdle];
                    }
                });
            }];
        }
        [self footerViewConfig];
    }
    
    NSString *(^block)(MTRefreshState) = objc_getAssociatedObject(self, @selector(setBottomTipText:));
    if (block) {
        SEL setTitleSEL = @selector(setTitle:forState:);
        if ([self.mj_footer respondsToSelector:setTitleSEL]) {
            ((void (*)(id, SEL, NSString *, NSInteger))objc_msgSend)(self.mj_footer, setTitleSEL, block(MTRefreshStateIdle), MJRefreshStateIdle);
            ((void (*)(id, SEL, NSString *, NSInteger))objc_msgSend)(self.mj_footer, setTitleSEL, block(MTRefreshStateTrigger), MJRefreshStatePulling);
            ((void (*)(id, SEL, NSString *, NSInteger))objc_msgSend)(self.mj_footer, setTitleSEL, block(MTRefreshStateRefreshing), MJRefreshStateRefreshing);
            ((void (*)(id, SEL, NSString *, NSInteger))objc_msgSend)(self.mj_footer, setTitleSEL, block(MTRefreshStateNoMoreData), MJRefreshStateNoMoreData);
        }
    }
}

- (void)addTopRefreshCustomView:(MTBaseRefreshView *)view withTriggerBlock:(void (^)())triggerBlock
{
    if (!self.mj_header) {
        __weak typeof(self) wself = self;
        MJRefreshStateHeader *header = [MJRefreshStateHeader headerWithRefreshingBlock:^{
            triggerBlock();
            
            float timeout = [MTRefreshConfig shared].refreshTimeout > 0 ? [MTRefreshConfig shared].refreshTimeout : kRefreshTimeout;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (wself.mj_header.state == MJRefreshStateRefreshing) {
                    [wself.mj_header endRefreshing];
                    [wself fixContentInsetForIdle];
                }
            });
        }];
        header.endRefreshingCompletionBlock = ^{
            [view completion];
        };
        header.lastUpdatedTimeLabel.hidden = YES;
        header.stateLabel.hidden = YES;
        self.mj_header = header;
    }
    if (![self refreshView]) {
        self.mj_header.frame = CGRectMake(0, 0, self.mj_header.bounds.size.width, view.bounds.size.height);
        [self.mj_header addSubview:view];
        
        objc_setAssociatedObject(self, @selector(refreshView), view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)noMoreData
{
    if (self.mj_footer) {
        self.mj_footer.state = MJRefreshStateNoMoreData;//此句是为了处理使用back footer时，设置state时机不准确的问题
        [self.mj_footer endRefreshingWithNoMoreData];
        [self fixContentInsetForIdle];
    }
}

- (void)resetNoMoreData
{
    if (self.mj_footer && self.mj_footer.state == MJRefreshStateNoMoreData) {
        [self.mj_footer resetNoMoreData];
    }
}

- (void)setTopTipText:(NSString *(^)(MTRefreshState))block
{
    if (!block) {
        return;
    }
    objc_setAssociatedObject(self, @selector(setTopTipText:), block, OBJC_ASSOCIATION_COPY);
    if (self.mj_header) {
        MJRefreshStateHeader *header = (MJRefreshStateHeader *)self.mj_header;
        [header setTitle:block(MTRefreshStateIdle) forState:MJRefreshStateIdle];
        [header setTitle:block(MTRefreshStateTrigger) forState:MJRefreshStatePulling];
        [header setTitle:block(MTRefreshStateRefreshing) forState:MJRefreshStateRefreshing];
    }
}

- (void)setBottomTipText:(NSString *(^)(MTRefreshState state))block
{
    if (!block) {
        return;
    }
    objc_setAssociatedObject(self, @selector(setBottomTipText:), block, OBJC_ASSOCIATION_COPY);
    if (self.mj_footer) {
        SEL setTitleSEL = @selector(setTitle:forState:);
        if ([self.mj_footer respondsToSelector:setTitleSEL]) {
            ((void (*)(id, SEL, NSString *, NSInteger))objc_msgSend)(self.mj_footer, setTitleSEL, block(MTRefreshStateIdle), MJRefreshStateIdle);
            ((void (*)(id, SEL, NSString *, NSInteger))objc_msgSend)(self.mj_footer, setTitleSEL, block(MTRefreshStateTrigger), MJRefreshStatePulling);
            ((void (*)(id, SEL, NSString *, NSInteger))objc_msgSend)(self.mj_footer, setTitleSEL, block(MTRefreshStateRefreshing), MJRefreshStateRefreshing);
            ((void (*)(id, SEL, NSString *, NSInteger))objc_msgSend)(self.mj_footer, setTitleSEL, block(MTRefreshStateNoMoreData), MJRefreshStateNoMoreData);
        }
    }
}

- (void)topBeginRefresh
{
    if (self.mj_header && self.mj_header.state == MJRefreshStateIdle) {
        [self.mj_header beginRefreshing];
    }
}

- (void)bottomBeginRefresh
{
    if (self.mj_footer && self.mj_footer.state == MJRefreshStateIdle) {
        [self.mj_footer beginRefreshing];
    }
}

#pragma mark - Private Method
- (MTBaseRefreshView *)refreshView
{
    return objc_getAssociatedObject(self, @selector(refreshView));
}

- (void)fixContentInsetForIdle
{
    [UIView animateWithDuration:0.3 animations:^{
        if (self.mj_offsetY == self.mj_header.mj_h) {
            if (self.mj_header.scrollViewOriginalInset.top < 0) {
                UIEdgeInsets inset = self.mj_header.scrollViewOriginalInset;
                inset.top = self.mj_header.scrollViewOriginalInset.top + self.mj_header.mj_h;
                self.contentInset = inset;
                self.contentOffset = CGPointMake(0, self.mj_offsetY - self.mj_header.mj_h);
            }
        }else {
            self.contentInset = self.mj_header.scrollViewOriginalInset;
        }
    }];
}

#pragma mark - Config
- (void)headerViewConfig
{
    MTRefreshConfig *config = [MTRefreshConfig shared];
    MJRefreshStateHeader *header = (MJRefreshStateHeader *)self.mj_header;
    if (config.headerIdleText) {
        [header setTitle:config.headerIdleText forState:MJRefreshStateIdle];
    }
    if (config.headerTriggerText) {
        [header setTitle:config.headerTriggerText forState:MJRefreshStatePulling];
    }
    if (config.headerRefreshingText) {
        [header setTitle:config.headerRefreshingText forState:MJRefreshStateRefreshing];
    }
    if (config.headerFont) {
        header.stateLabel.font = config.headerFont;
    }
    if (config.headerTextColor) {
        header.stateLabel.textColor = config.headerTextColor;
    }
}

- (void)footerViewConfig
{
    MTRefreshConfig *config = [MTRefreshConfig shared];
    SEL setTitleSEL = @selector(setTitle:forState:);
    if ([self.mj_footer respondsToSelector:setTitleSEL]) {
        if (config.footerIdleText) {
            ((void (*)(id, SEL, NSString *, NSInteger))objc_msgSend)(self.mj_footer, setTitleSEL, config.footerIdleText, MJRefreshStateIdle);
        }
        if (config.footerTriggerText) {
            ((void (*)(id, SEL, NSString *, NSInteger))objc_msgSend)(self.mj_footer, setTitleSEL, config.footerTriggerText, MJRefreshStatePulling);
        }
        if (config.footerRefreshingText) {
            ((void (*)(id, SEL, NSString *, NSInteger))objc_msgSend)(self.mj_footer, setTitleSEL, config.footerRefreshingText, MJRefreshStateRefreshing);
        }
        if (config.footerNoMoreDataText) {
            ((void (*)(id, SEL, NSString *, NSInteger))objc_msgSend)(self.mj_footer, setTitleSEL, config.footerNoMoreDataText, MJRefreshStateNoMoreData);
        }
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"]) {
        MTBaseRefreshView *view = [self refreshView];
        if (!view || ![view isKindOfClass:[MTBaseRefreshView class]]) {
            return;
        }
        if (self.contentOffset.y <= 0) {
            switch (self.mj_header.state) {
                case MJRefreshStateIdle:
                    [view idle];
                    [view pulling:self.contentOffset.y];
                    break;
                case MJRefreshStatePulling:
                    [view trigger];
                    [view pulling:self.contentOffset.y];
                    break;
                case MJRefreshStateRefreshing:
                    [view refreshing];
                    break;
                default:
                    break;
            }
        }
    }else if ([keyPath isEqualToString:@"__superview"]) {
        NSLog(@"superview");
    }
}


#pragma mark - Assist
- (void)addAssist
{
    if (!self.superview) {
        return;
    }
    
    MTScrollViewAssist *assist = [[MTScrollViewAssist alloc] initWithDeallocBlock:^{
        //此处必须使用self进行循环引用，否则提前释放会造成KVO没有及时释放而导致crash
        [self removeObserver:self forKeyPath:@"contentOffset"];
    }];
    
    objc_setAssociatedObject(self.superview, @selector(addAssist), assist, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}


@end
