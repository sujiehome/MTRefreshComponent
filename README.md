# MTRefreshComponent ----UITableView/CollectionView自动刷新加载、空视图显示隐藏组件

### 前言
>为简化业务端代码滚动视图的刷新加载、空视图显示功能。接到需求需要提供一个可以自动完成刷新、加载、空视图控制的组件。刷新控件采用的MJRefresh，如使用此组件，需要自行集成MJRefresh。
要求：
1.无侵入性
2.通用性强
3.集成成本低

### 集成
#### 方式一：
pod方式：
由于目前版本还处于调试阶段，待版本稳定后提供pod方式集成。
#### 方式二：
集成代码方式：
第一步：
将MTRefreshComponent文件夹集成入项目中，并在.pch文件中引入头文件
```
#import "MTRefresh.h"
```
第二步：
组件提供配置文件 MTRefreshConfig，以单例模式存在，可在程序入口或合理位置配置相关默认信息。此文件只需配置一次，即可对项目中所有tableView、collectionView提供默认配置支持，优先级低于对独立视图的单独配置。例：
```
//设置头部刷新控件文案
[MTRefreshConfig shared].headerIdleText = @"默认状态";
[MTRefreshConfig shared].headerTriggerText = @"触发状态";
[MTRefreshConfig shared].headerRefreshingText = @"刷新状态";
[MTRefreshConfig shared].headerFont = [UIFont systemFontOfSize:16];
[MTRefreshConfig shared].headerTextColor = [UIColor grayColor];

//设置尾部刷新控件文案
[MTRefreshConfig shared].footerIdleText = @"默认状态";
[MTRefreshConfig shared].footerTriggerText = @"触发状态";
[MTRefreshConfig shared].footerRefreshingText = @"刷新状态";
[MTRefreshConfig shared].footerNoMoreDataText = @"没有更多数据";
[MTRefreshConfig shared].footerFont = [UIFont systemFontOfSize:16];
[MTRefreshConfig shared].footerTextColor = [UIColor grayColor];

//设置自定义视图
[MTRefreshConfig shared].customTopView = @"CustomRefreshView";
[MTRefreshConfig shared].customNullDataView = @"CustomNullDataView";
```
第三步：
1.设置刷新加载控件
在需要使用的位置调用添加控件方法
```
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
```
>注：目前只支持顶部刷新控件的自定义，并且必须是MTBaseRefreshView的子类，后续会考虑开放底部自定义刷新控件

2.设置空视图
可以在config中配置空视图类，展示时空视图size与滚动视图size相同。
如需对某一个视图单独配置不同的空视图，则可以通过
```
self.tableView.nullDataView = your_custom_view;
self.collectionView.nullDataView = your_custom_view;
```
来单独设置，此项设置优先级高于配置文件中的配置。

第四步：
提供一系列设置和动作方法来辅助使用
```
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

```

### 未完待续
目前该组件还处于初级阶段，可能会有一些问题，会在以后的时间中不断更新完善。
