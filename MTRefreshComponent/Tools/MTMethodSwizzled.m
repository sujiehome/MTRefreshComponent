//
//  MTMethodSwizzled.m
//  MTRefreshComponent
//
//  Created by suyuxuan on 2017/7/3.
//  Copyright © 2017年 Monk.Tang. All rights reserved.
//

#import "MTMethodSwizzled.h"
#import <objc/runtime.h>

@implementation MTMethodSwizzled

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
+ (void)exchangeImpWithOriginalClass:(Class)oriCls
                         originalSel:(SEL)oriSel
                              tmpSel:(SEL)tmpSel
                       swizzledClass:(Class)swiCls
                         swizzledSel:(SEL)swiSel
                     msgForwardClass:(Class)forwardCls
                       msgForwardSel:(SEL)msgForwardSel
{
    //增加原始方法
    Method originalMethod = class_getInstanceMethod(oriCls, oriSel);
    BOOL didAddOriMethod = class_addMethod(oriCls, oriSel, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    if (didAddOriMethod) {
        originalMethod = class_getInstanceMethod(oriCls, oriSel);
        IMP handleIMP;
        if (forwardCls) {
            SEL handleSel = msgForwardSel ? : @selector(msgForwardHandle);
            handleIMP = class_getMethodImplementation(forwardCls, handleSel);
        }else {
            handleIMP = class_getMethodImplementation(self, @selector(msgForwardHandle));
        }
        method_setImplementation(originalMethod, handleIMP);
    }
    
    //增加临时中转方法
    class_addMethod(oriCls, tmpSel, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    
    
    Method swizzledMethod = class_getInstanceMethod(swiCls, swiSel);
    class_replaceMethod(oriCls, oriSel, method_getImplementation(swizzledMethod), method_getTypeEncoding(originalMethod));
    
}

- (void)msgForwardHandle
{
    /**
     备用方法，防止原类中没有实现需要交换的方法，导致交换后执行消息转发最终没有处理导致crash。
     后续可以在做底层安全时，做到相应处理类中。
     */
}

@end
