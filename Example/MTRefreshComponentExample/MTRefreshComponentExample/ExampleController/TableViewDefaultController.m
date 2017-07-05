//
//  TableViewDefaultController.m
//  MTRefreshComponentExample
//
//  Created by suyuxuan on 2017/7/4.
//  Copyright © 2017年 Monk.Tang. All rights reserved.
//

#import "TableViewDefaultController.h"

@interface TableViewDefaultController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UITableView *exampleTableView;

@end

@implementation TableViewDefaultController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Table Default";
    
    
    self.dataArray = [@[] mutableCopy];
    for (int i = 0; i < 20; i++) {
        [self.dataArray addObject:@""];
    }
    
    self.exampleTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    self.exampleTableView.delegate = self;
    self.exampleTableView.dataSource = self;
    [self.view addSubview:self.exampleTableView];
    
    __weak typeof(self) wself = self;
    [self.exampleTableView addTopRefreshWithTriggerBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [wself.exampleTableView reloadData];
        });
        NSLog(@"刷新");
    }];
    [self.exampleTableView addBottomRefreshWithAutoRefresh:YES triggerBlock:^{
        NSLog(@"加载");
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"ExampleCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%ld组 %ld行", indexPath.section, indexPath.row];
    
    return cell;
}

@end
