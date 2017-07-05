//
//  CollectionViewCustomController.m
//  MTRefreshComponentExample
//
//  Created by suyuxuan on 2017/7/4.
//  Copyright © 2017年 Monk.Tang. All rights reserved.
//

#import "CollectionViewCustomController.h"
#import "CustomRefreshView.h"
#import "CustomNullDataView.h"

@interface CollectionViewCustomController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UICollectionView *collection;

@end

@implementation CollectionViewCustomController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Collection Custom";
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"清空" style:UIBarButtonItemStylePlain target:self action:@selector(clearClick)];
    self.navigationItem.rightBarButtonItem = item;
    
    self.dataArray = [@[] mutableCopy];
    for (int i = 0; i < 20; i++) {
        [self.dataArray addObject:@""];
    }
    
    self.collection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    self.collection.delegate = self;
    self.collection.dataSource = self;
    [self.collection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    self.collection.backgroundColor = [UIColor whiteColor];
    
    CustomNullDataView *nullDataView = [[CustomNullDataView alloc] init];
    nullDataView.backgroundColor = [UIColor greenColor];
    self.collection.nullDataView = nullDataView;
    
    CustomRefreshView *view = [[CustomRefreshView alloc] init];
    view.frame = CGRectMake(0, 0, self.collection.bounds.size.width, 40);
    
    __weak typeof(self) wself = self;
    [self.collection addTopRefreshCustomView:view withTriggerBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [wself.dataArray removeAllObjects];
            for (int i = 0; i < 20; i++) {
                [wself.dataArray addObject:@""];
            }
            
            [wself.collection resetNoMoreData];
            [wself.collection reloadData];
            
            NSLog(@"刷新");
        });
    }];
    
    [self.collection addBottomRefreshWithAutoRefresh:NO triggerBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (wself.dataArray.count >= 30) {
                [wself.collection noMoreData];
            }else {
                for (int i = 0; i< 10; i++) {
                    [wself.dataArray addObject:@""];
                }
            }
            [wself.collection reloadData];
            
            NSLog(@"加载");
        });
    }];
    
    [self.view addSubview:self.collection];
}

#pragma mark - Action
- (void)clearClick
{
    [self.dataArray removeAllObjects];
    [self.collection reloadData];
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource & UICollectionViewDelegateFlowLayout
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor greenColor];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(40, 40);
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
//{
//    return CGSizeMake(100, 30);
//}

@end
