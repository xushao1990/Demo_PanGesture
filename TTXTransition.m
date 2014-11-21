//
//  TTXTransition.m
//  TTXTransition
//
//  Created by molon on 7/8/14.
//  Copyright (c) 2014 molon. All rights reserved.
//

#import "TTXTransition.h"
#import <objc/runtime.h>
#import <dlfcn.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface PrivatePanGestureRecognizer : UIPanGestureRecognizer
@property (readonly, nonatomic) UIEvent *event;
- (CGPoint)beganLocationInView:(UIView *)view;
@end

@interface PrivatePanGestureRecognizer ()
@property (assign, nonatomic) CGPoint beganLocation;
@property (strong, nonatomic) UIEvent *event;
@property (assign, nonatomic) NSTimeInterval beganTime;
@end

@implementation PrivatePanGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    self.beganLocation = [touch locationInView:self.view];
    self.event = event;
    self.beganTime = event.timestamp;
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.state == UIGestureRecognizerStatePossible && event.timestamp - self.beganTime > 0.3) {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    [super touchesMoved:touches withEvent:event];
}

- (void)reset
{
    self.beganLocation = CGPointZero;
    self.event = nil;
    self.beganTime = 0;
    [super reset];
}

- (CGPoint)beganLocationInView:(UIView *)view
{
    return [view convertPoint:self.beganLocation fromView:self.view];
}

@end


#pragma mark - hook大法
//静态就交换静态，实例方法就交换实例方法
void TTXTransition_Swizzle(Class c, SEL origSEL, SEL newSEL)
{
    //获取实例方法
    Method origMethod = class_getInstanceMethod(c, origSEL);
    Method newMethod = nil;
	if (!origMethod) {
        //获取静态方法
		origMethod = class_getClassMethod(c, origSEL);
        newMethod = class_getClassMethod(c, newSEL);
    }else{
        newMethod = class_getInstanceMethod(c, newSEL);
    }
    
    if (!origMethod||!newMethod) {
        return;
    }
    
    //自身已经有了就添加不成功，直接交换即可
    if(class_addMethod(c, origSEL, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))){
        //添加成功一般情况是因为，origSEL本身是在c的父类里。这里添加成功了一个继承方法。
        class_replaceMethod(c, newSEL, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    }else{
        method_exchangeImplementations(origMethod, newMethod);
	}
}

@interface NSString (__TTXTransition_Encrypt)

- (NSString *)__mlEncryptString;
- (NSString *)__mlDecryptString;

@end

@implementation NSString (__TTXTransition_Encrypt)

- (NSString *)__mlRot13
{
    const char *source = [self cStringUsingEncoding:NSASCIIStringEncoding];
    char *dest = (char *)malloc((self.length + 1) * sizeof(char));
    if (!dest) {
        return nil;
    }
    
    NSUInteger i = 0;
    for ( ; i < self.length; i++) {
        char c = source[i];
        if (c >= 'A' && c <= 'Z') {
            c = (c - 'A' + 13) % 26 + 'A';
        }
        else if (c >= 'a' && c <= 'z') {
            c = (c - 'a' + 13) % 26 + 'a';
        }
        dest[i] = c;
    }
    dest[i] = '\0';
    
    NSString *result = [[NSString alloc] initWithCString:dest encoding:NSASCIIStringEncoding];
    free(dest);
    
    return result;
}

- (NSString *)__mlEncryptString
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64 = [data base64EncodedStringWithOptions:0];
    return [base64 __mlRot13];
}

- (NSString *)__mlDecryptString
{
    NSString *rot13 = [self __mlRot13];
    NSData *data = [[NSData alloc] initWithBase64EncodedString:rot13 options:0];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end

#pragma mark - UIView category implementation
NSString * const kTTXTransition_UIView_DisableTTXTransition = @"__TTXTransition_UIView_DisableTTXTransition";
@implementation UIView(__TTXTransition)

- (BOOL)disableTTXTransition
{
	return [objc_getAssociatedObject(self, &kTTXTransition_UIView_DisableTTXTransition) boolValue];
}

- (void)setDisableTTXTransition:(BOOL)disableTTXTransition
{
    [self willChangeValueForKey:kTTXTransition_UIView_DisableTTXTransition];
	objc_setAssociatedObject(self, &kTTXTransition_UIView_DisableTTXTransition, @(disableTTXTransition), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:kTTXTransition_UIView_DisableTTXTransition];
}

@end

#pragma mark - UIGestureRecognizer category interface
@interface UIGestureRecognizer(__TTXTransition)

@property (nonatomic, assign) UINavigationController *__TTXTransition_NavController;

@end

#pragma mark - UIGestureRecognizer category implementation
NSString * const kTTXTransition_NavController_OfPan = @"__TTXTransition_NavController_OfPan";

@implementation UIGestureRecognizer(__TTXTransition)

- (void)set__TTXTransition_NavController:(UINavigationController *)__TTXTransition_NavController
{
    [self willChangeValueForKey:kTTXTransition_NavController_OfPan];
	objc_setAssociatedObject(self, &kTTXTransition_NavController_OfPan, __TTXTransition_NavController, OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:kTTXTransition_NavController_OfPan];
}

- (UIViewController *)__TTXTransition_NavController
{
	return objc_getAssociatedObject(self, &kTTXTransition_NavController_OfPan);
}

@end

#pragma mark - UIPercentDrivenInteractiveTransition category
@interface UIPercentDrivenInteractiveTransition(__TTXTransition)

@end

@implementation UIPercentDrivenInteractiveTransition(__TTXTransition)

- (void)handleNavigationTransition:(UIPanGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        //做个样子,也用来防止如果这个api系统改了名字，我们这边还是可用的。
        [recognizer.__TTXTransition_NavController popViewControllerAnimated:YES];
    }
}

@end

#pragma mark - UINavigationController category interface
@interface UINavigationController(__TTXTransition)<UIGestureRecognizerDelegate>

/**
 *  每个导航器都添加一个拖动手势
 */
@property (nonatomic, strong) PrivatePanGestureRecognizer *__TTXTransition_panGestureRecognizer;

- (void)__TTXTransition_Hook_ViewDidLoad;

@end

#pragma mark - UINavigationController category implementation
NSString * const k__TTXTransition_GestureRecognizer = @"__TTXTransition_GestureRecognizer";

@implementation UINavigationController(__TTXTransition)

#pragma mark getter and setter
- (void)set__TTXTransition_panGestureRecognizer:(UIPanGestureRecognizer *)__TTXTransition_panGestureRecognizer
{
    [self willChangeValueForKey:k__TTXTransition_GestureRecognizer];
	objc_setAssociatedObject(self, &k__TTXTransition_GestureRecognizer, __TTXTransition_panGestureRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:k__TTXTransition_GestureRecognizer];
}

- (UIPanGestureRecognizer *)__TTXTransition_panGestureRecognizer
{
	return objc_getAssociatedObject(self, &k__TTXTransition_GestureRecognizer);
}

#pragma mark hook
- (void)__TTXTransition_Hook_ViewDidLoad
{
    [self __TTXTransition_Hook_ViewDidLoad];
    
    //初始化拖返手势
    if (!self.__TTXTransition_panGestureRecognizer&&[self.interactivePopGestureRecognizer.delegate isKindOfClass:[UIPercentDrivenInteractiveTransition class]]) {
#define kHandleNavigationTransitionKey [@"nTShMTkyGzS2nJquqTyioyElLJ5mnKEco246" __mlDecryptString]
        PrivatePanGestureRecognizer *gestureRecognizer = [[PrivatePanGestureRecognizer alloc] initWithTarget:self.interactivePopGestureRecognizer.delegate action:NSSelectorFromString(kHandleNavigationTransitionKey)];
        gestureRecognizer.delegate = self;
        gestureRecognizer.__TTXTransition_NavController = self;
        
        self.__TTXTransition_panGestureRecognizer = gestureRecognizer;
        
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
    [self.view addGestureRecognizer:self.__TTXTransition_panGestureRecognizer];
}

#pragma mark GestureRecognizer delegate
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)recognizer
{
    UINavigationController *navVC = self;
    if ([navVC.transitionCoordinator isAnimated]||
        navVC.viewControllers.count < 2) {
        return NO;
    }
    
    UIView* view = recognizer.view;
    CGPoint loc = [recognizer locationInView:view];
    UIView* subview = [view hitTest:loc withEvent:nil];
    if (subview.disableTTXTransition){ //这个view忽略了拖返
        return NO;
    }
    
    //普通拖曳模式，如果开始方向不对即不启用
    CGPoint velocity = [recognizer velocityInView:navVC.view];
    if(velocity.x<=0) {
        //NSLog(@"不是右滑的");
        return NO;
    }
    
    CGPoint translation = [recognizer translationInView:navVC.view];
    translation.x = translation.x==0?0.00001f:translation.x;
    CGFloat ratio = (fabs(translation.y)/fabs(translation.x));
    //因为上滑的操作相对会比较频繁，所以角度限制少点
    if ((translation.y>0&&ratio>0.618f)||(translation.y<0&&ratio>0.2f)) {
        //NSLog(@"右滑角度不在范围内");
        return NO;
    }
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [[otherGestureRecognizer view] isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)[otherGestureRecognizer view];
        if (scrollView.contentOffset.x == 0 && [scrollView.panGestureRecognizer velocityInView:scrollView].x > 0) {
            [self cancelOtherGestureRecognizer:otherGestureRecognizer];
            return YES;
        }
    }
    return NO;
}

- (void)cancelOtherGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    NSSet *touchs = [self.__TTXTransition_panGestureRecognizer.event touchesForGestureRecognizer:otherGestureRecognizer];
    [otherGestureRecognizer touchesCancelled:touchs withEvent:(self.__TTXTransition_panGestureRecognizer.event)];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return ![self.transitionCoordinator isAnimated];
}

@end

@implementation UINavigationController(DisableTTXTransition)

#pragma mark - outcall
- (void)enabledTTXTransition:(BOOL)enabled
{
    self.__TTXTransition_panGestureRecognizer.enabled = enabled;
}

@end

@implementation TTXTransition

+ (void)validatePanBackGesture
{
    //IOS7以下不可用
    if ([[[UIDevice currentDevice] systemVersion]floatValue]<7.0) {
        return;
    }
    
    //启用hook，自动对每个导航器开启拖返功能，整个程序的生命周期只允许执行一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //执行hook
        
        TTXTransition_Swizzle([UINavigationController class],@selector(viewDidLoad),@selector(__TTXTransition_Hook_ViewDidLoad));
    });
}

@end


#pragma mark - UIScrollView category ，可让scrollView在一个良好的关系下并存
@interface UIScrollView(__MLTransistion)

@end

@implementation UIScrollView(__MLTransistion)

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer isEqual:self.panGestureRecognizer]) {
        //如果此scrollView有横向滚动的可能当然就需要忽略了。
        if (CGAffineTransformEqualToTransform(CGAffineTransformMakeRotation(-M_PI*0.5),self.transform)||CGAffineTransformEqualToTransform(CGAffineTransformMakeRotation(M_PI*0.5),self.transform)) {
                return NO;
        }else{
            if (self.contentSize.width>self.frame.size.width) {
                return NO;
            }
        }
        if (otherGestureRecognizer.__TTXTransition_NavController) {
            //说明这玩意是我们的手势
            return YES;
        }
    }
    return NO;
}

@end


