//
//  MTScrollViewAssist.m
//  MTRefreshComponent
//
//  Created by suyuxuan on 2017/7/3.
//  Copyright © 2017年 Monk.Tang. All rights reserved.
//

#import "MTScrollViewAssist.h"

@implementation MTScrollViewAssist

- (instancetype)initWithDeallocBlock:(MTScrollViewAssistDeallocBlock)block
{
    self = [super init];
    if (self) {
        self.block = block;
    }
    return self;
}

- (void)dealloc
{
    if (self.block) {
        self.block();
    }
}


@end
