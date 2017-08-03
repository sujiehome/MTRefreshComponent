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
    
    /**
     此段while解决父类中实现而子类未实现方法的情况下，直接在子类添加方法实现，会造成父类方法不执行。
     在交换方法时循环父类检查是否有实现，如果直到超类也没有实现的话，则正常设置。
     如果父类有实现，则不需要给方法添加实现，让方法自行执行消息转发寻找父类中的实现位置。
     */
    BOOL didAddOriMethod = YES;
    Class tmpClass = oriCls;
    while (tmpClass) {
        didAddOriMethod = class_addMethod(tmpClass, oriSel, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        if (!didAddOriMethod) {
            break;
        }
        tmpClass = class_getSuperclass(tmpClass);
    }
    
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
