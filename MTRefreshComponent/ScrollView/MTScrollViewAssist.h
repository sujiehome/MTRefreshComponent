//
//  MTScrollViewAssist.h
//  MTRefreshComponent
//
//  Created by suyuxuan on 2017/7/3.
//  Copyright © 2017年 Monk.Tang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^MTScrollViewAssistDeallocBlock)();

@interface MTScrollViewAssist : NSObject

@property (nonatomic, copy) MTScrollViewAssistDeallocBlock block;

- (id)initWithDeallocBlock:(MTScrollViewAssistDeallocBlock)block;

@end
