//
//  ViewController.m
//  MTRefreshComponentExample
//
//  Created by suyuxuan on 2017/7/4.
//  Copyright © 2017年 Monk.Tang. All rights reserved.
//

#import "ViewController.h"
#import "TableViewDefaultController.h"
#import "TableViewCustomController.h"
#import "CollectionViewDefaultController.h"
#import "CollectionViewCustomController.h"

@interface ViewController ()

@property (nonatomic, copy) NSArray *titleArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    for (int i = 0; i < self.titleArray.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 64 + 100 * i, 200, 80);
        button.backgroundColor = [UIColor greenColor];
        button.center = CGPointMake(self.view.frame.size.width / 2, button.center.y);
        button.tag = 10000 + i;
        [button setTitle:self.titleArray[i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(testClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (void)testClick:(UIButton *)button
{
    switch (button.tag) {
        case 10000:
        {
            TableViewDefaultController *controller = [[TableViewDefaultController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case 10001:
        {
            TableViewCustomController *controller = [[TableViewCustomController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case 10002:
        {
            CollectionViewDefaultController *controller = [[CollectionViewDefaultController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case 10003:
        {
            CollectionViewCustomController *controller = [[CollectionViewCustomController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Getter
- (NSArray *)titleArray
{
    if (!_titleArray) {
        _titleArray = @[@"table 默认", @"table 自定义", @"collection 默认", @"collection 自定义"];
    }
    return _titleArray;
}

@end
