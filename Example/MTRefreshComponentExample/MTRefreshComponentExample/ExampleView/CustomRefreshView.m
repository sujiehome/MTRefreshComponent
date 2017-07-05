//
//  CustomRefreshView.m
//  MTRefreshComponentExample
//
//  Created by suyuxuan on 2017/7/4.
//  Copyright © 2017年 Monk.Tang. All rights reserved.
//

#import "CustomRefreshView.h"

@interface CustomRefreshView ()

@property (nonatomic, strong) UILabel *tipLabel;

@end

@implementation CustomRefreshView

#pragma mark - Override
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.tipLabel.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
}

- (void)idle
{
    self.tipLabel.text = @"自定义刷新  默认状态";
    self.tipLabel.textColor = [UIColor redColor];
}

- (void)pulling:(float)y
{
    self.tipLabel.text = [NSString stringWithFormat:@"自定义刷新  拉动状态  偏移量:%f", y];
}

- (void)trigger
{
    self.tipLabel.text = @"自定义刷新  触发状态";
    self.tipLabel.textColor = [UIColor greenColor];
}

- (void)refreshing
{
    self.tipLabel.text = @"自定义刷新  刷新中";
    self.tipLabel.textColor = [UIColor blackColor];
}

- (void)completion
{
    [[[UIAlertView alloc] initWithTitle:@"自定义刷新" message:@"刷新完成" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
}

#pragma mark - Getter
- (UILabel *)tipLabel
{
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.textColor = [UIColor redColor];
        _tipLabel.font = [UIFont systemFontOfSize:12];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_tipLabel];
    }
    return _tipLabel;
}

@end
