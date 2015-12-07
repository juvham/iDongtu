//
//  LDViewControllerTransitioner.m
//  lingdang2
//
//  Created by AceElvis on 15/4/14.
//  Copyright (c) 2015年 GouMin. All rights reserved.
//

#import "LDViewControllerTransitioner.h"
#import "AAPLAssetGridViewController.h"
@implementation UIView (TransitionShadow)
/**
 *  左边缘部分增加阴影
 */
- (void)addLeftSideShadowWithFading
{
    //    CGFloat shadowWidth = 4.0f;
    //    CGFloat shadowVerticalPadding = -20.0f; // negative padding, so the shadow isn't rounded near the top and the bottom
    //    CGFloat shadowHeight = CGRectGetHeight(self.frame) - 2 * shadowVerticalPadding;
    //    CGRect shadowRect = CGRectMake(-shadowWidth, shadowVerticalPadding, shadowWidth, shadowHeight);
    //    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:shadowRect];
    //    self.layer.shadowPath = [shadowPath CGPath];
    //    self.layer.shadowOpacity = 0.2f;
    //
    //    // fade shadow during transition
    //    CGFloat toValue = 0.0f;
    //    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    //    animation.fromValue = @(self.layer.shadowOpacity);
    //    animation.toValue = @(toValue);
    //    [self.layer addAnimation:animation forKey:nil];
    //    self.layer.shadowOpacity = toValue;
    
    CGFloat shadowWidth = 2.0f;
    CGFloat shadowVerticalPadding = -20.0f;
    CGFloat shadowHeight = CGRectGetHeight(self.frame) - 2 * shadowVerticalPadding;
    CGRect shadowRect = CGRectMake(-shadowWidth, shadowVerticalPadding, shadowWidth, shadowHeight);
    
    self.layer.masksToBounds = NO;
    self.layer.shadowRadius = 5;
    self.layer.shadowOpacity = 0.6;
    
    if (self.layer.shadowPath == NULL) {
        self.layer.shadowPath = [[UIBezierPath bezierPathWithRect:shadowRect] CGPath];
    }
    else{
        CGRect currentPath = CGPathGetPathBoundingBox(self.layer.shadowPath);
        if (CGRectEqualToRect(currentPath, self.bounds) == NO){
            self.layer.shadowPath = [[UIBezierPath bezierPathWithRect:shadowRect] CGPath];
        }
    }
}
@end


@interface LDControllerAnimatedTransitioning ()

@property (weak, nonatomic) UIViewController *toViewController;
@property (weak, nonatomic) UIViewController *fromViewController;

@property (weak, nonatomic) LDNavigationControllerDelegate *transDelegate;

- (instancetype)initWithTransDelegate:(LDNavigationControllerDelegate *)transDelegate;

@property (assign , nonatomic) BOOL isPresentaion;

@end
@implementation LDControllerAnimatedTransitioning
- (instancetype)initWithTransDelegate:(LDNavigationControllerDelegate *)transDelegate {
    
    if (self = [super init]) {
        
        _transDelegate = transDelegate;
    }
    
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    return .3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    UIView *containerView = [transitionContext containerView];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView *fromView = fromViewController.view;
    UIView *toView = toViewController.view;
    
    
    UIImageView *animationView = [[UIImageView alloc] initWithImage:self.transDelegate.animationCell.thumbnailImage];
    animationView.contentMode = UIViewContentModeScaleAspectFill;
    animationView.clipsToBounds = YES;
    
    UIView *coverView = [[UIView alloc] initWithFrame:toView.bounds];
    coverView.backgroundColor = [UIColor whiteColor];
    
    CGRect targetRect = self.transDelegate.targetRect;
    UIView *targeSorceView = (UIView *)self.transDelegate.animationCell;
    
    CGRect targetFrame;
    
    UIView *targetView;
    
    if (self.isPresentaion) {
        
        [containerView insertSubview:toView aboveSubview:fromView];
        animationView.frame = targetRect;
        targetFrame = [self imageSize:animationView.image.size targetFrame:toView.frame];
        targetView = toView;
        
        coverView.alpha = 0;
        
    } else  {
        
        [containerView addSubview:toView];
        animationView.frame = [self imageSize:animationView.image.size targetFrame:toView.frame];
        animationView.center = toView.center;
        targetFrame = targetRect;
        
        coverView.alpha = 1;
    }
    
    targetView.alpha = 0;
    targeSorceView.alpha = 0;
    
    [containerView addSubview:animationView];
    
    
    
    [containerView insertSubview:coverView belowSubview:animationView];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:self.isPresentaion ? 0.8 :1 initialSpringVelocity:15.0 options:(UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        
        animationView.frame = targetFrame;
        
        if (self.isPresentaion) {
            animationView.center = targetView.center;
            
            coverView.alpha = 1;
        } else {
            
            coverView.alpha = 0;
        }

        
    } completion:^(BOOL finished) {
        
        if (![transitionContext transitionWasCancelled])
        {
            
        }
        
        targetView.alpha =  1;
        targeSorceView.alpha = 1;
        
        [animationView removeFromSuperview];
        [coverView removeFromSuperview];
        
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
    
}



- (CGRect)imageSize:(CGSize )size targetFrame:(CGRect )targetViewFrame {
    
    
    CGFloat heightRatio = size.height/targetViewFrame.size.height;
    CGFloat widthRatio = size.width / targetViewFrame.size.width;
    
    CGFloat targetScale = MAX(heightRatio,widthRatio);
    
    return CGRectMake(targetViewFrame.origin.x, targetViewFrame.origin.y, size.width/targetScale,size.height/targetScale);
    
}

- (void)animationEnded:(BOOL)transitionCompleted {
    
    if (!transitionCompleted) {
        _toViewController.view.transform = CGAffineTransformIdentity;
        
//        [_toViewController changeNaviBarAlpha:_fromViewController.navigationBarAlpha] ;
    }
}

@end


@interface LDNavigationControllerDelegate () <UIGestureRecognizerDelegate>
{
    CGFloat currentAlpha ;
    CGFloat preViousAplha ;
}
@property (nonatomic ,assign) UINavigationController *navigationController;
@property (nonatomic ,strong) LDControllerAnimatedTransitioning *animatorTransition;
@property (strong, nonatomic) UIPercentDrivenInteractiveTransition *interactionTransition;
@property(weak, nonatomic) UIViewController *currentViewController; // 当前控制器
@property(weak, nonatomic) UIViewController *previousViewController;//上一控制器

@property (strong , nonatomic) UIPanGestureRecognizer *popGestureRecognizer;

@property (assign ,nonatomic) BOOL isUserInterActive;
@property (nonatomic) BOOL duringAnimation; //动画是否正在进行

@end



@implementation LDNavigationControllerDelegate

- (instancetype)initWithNavigationController:(UINavigationController *)naviController {
    
    if (self = [super init]) {
        //handle navigationController
        self.navigationController = naviController;
        
//        naviController.delegate = self;
        //create Transition
        _animatorTransition = [[LDControllerAnimatedTransitioning alloc] initWithTransDelegate:self];
        
//        self.navigationController.interactivePopGestureRecognizer.enabled 
//        _interactionTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
//        //handle interactivePopGestureRecognize;
//        _popGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
//        _popGestureRecognizer.maximumNumberOfTouches = 1;
//        _popGestureRecognizer.delegate = self;
//        [_popGestureRecognizer addTarget:self action:@selector(popGestureHandle:)];
//        [self.navigationController.view addGestureRecognizer:_popGestureRecognizer];
        
    }
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    
    _currentViewController = fromVC;
    _previousViewController = toVC;
    
    
    //判断是否使用动画
    
    if (operation == UINavigationControllerOperationPop) {
    
        if ([fromVC isKindOfClass:[UIPageViewController class]] && [toVC isKindOfClass:[AAPLAssetGridViewController class]]) {
            
            _animatorTransition.isPresentaion = NO;
            return _animatorTransition;
        }
        
        
        
        
    } else {
        
        if ([toVC isKindOfClass:[UIPageViewController class]] && [fromVC isKindOfClass:[AAPLAssetGridViewController class]]) {
            
            _animatorTransition.isPresentaion = YES;
            return _animatorTransition;
        }

    }
    
    /*!
     @author juvham, 15-04-15 14:04:23
     
     @brief 仅Pop 使用自定义动画;
     
     @since <#version number#>
     */
    return nil;
    
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    
    if (_isUserInterActive == YES) {
        
        return _interactionTransition;
    }
    return nil;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (animated) {
        self.duringAnimation = YES;
    }
    
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    self.duringAnimation = NO;
    
}



- (void)popGestureHandle:(UIPanGestureRecognizer *)gesture {
    
    CGPoint translation = [gesture translationInView:self.navigationController.view];
    
    switch (gesture.state) {
            
        case UIGestureRecognizerStateBegan:
        {
//            currentAlpha = _currentViewController.navigationBarAlpha;
//            preViousAplha = _previousViewController.navigationBarAlpha;
            
            NSLog(@"coming ");
            
            NSInteger direction ;
            CGPoint velocity = [gesture velocityInView:self.navigationController.view.window];
            
            if (fabs(velocity.y) > fabs(velocity.x))
            {
                if (velocity.y > 0)
                {
                    direction = 0;
                }
                else
                {
                    direction = 1;
                }
            }
            else
            {
                if (velocity.x > 0)
                {
                    direction =2 ;
                }
                else {
                    direction =3;
                }
            }
            
            if (direction == 2) {
                
                
                [self.navigationController popViewControllerAnimated:YES];
            }
            
        }
            break;
        case UIGestureRecognizerStateChanged:{
            
            CGFloat percent =  translation.x > 0 ? translation.x / CGRectGetWidth(self.navigationController.view.bounds) : 0;
            [self.interactionTransition updateInteractiveTransition:percent];
            
        }
            break;
        case UIGestureRecognizerStateEnded:{
            
            CGFloat translationThreshold = self.navigationController.topViewController.view.frame.size.width * 0.4;
            //判断方向是否向右并且移动幅度超过1/3个屏幕或者滑动速度大于80
            if ((translation.x > translationThreshold && [gesture velocityInView:self.navigationController.view].x > 0)  || [gesture velocityInView:self.navigationController.view].x > 80 )
            {
                [self.interactionTransition finishInteractiveTransition];
                
                NSLog(@"i am  here");
                //
            }
            else {
                
                [self.interactionTransition cancelInteractiveTransition];
                
                NSLog(@"he is gone");
            }
            self.isUserInterActive = NO;
            self.duringAnimation = NO;
        }
            
            break;
        case UIGestureRecognizerStateCancelled: {
            
            [self.interactionTransition cancelInteractiveTransition];
            [UIView animateWithDuration:0.15 animations:^{
                self.navigationController.navigationBar.alpha = currentAlpha;
            }];
            self.isUserInterActive = NO;
            self.duringAnimation = NO;
            
        }
            break;
        default:
            break;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    //严格判断是否是pop手势；
    if ([gestureRecognizer isEqual:_popGestureRecognizer]) {
        if (self.navigationController.viewControllers.count > 1) {
            if (self.navigationController.interactivePopGestureRecognizer.enabled == YES) {
                
                NSInteger direction ;
                CGPoint velocity = [_popGestureRecognizer velocityInView:self.navigationController.view.window];
                
                if (fabs(velocity.y) > fabs(velocity.x))
                {
                    if (velocity.y > 0)
                    {
                        direction = 0;
                    }
                    else
                    {
                        direction = 1;
                    }
                }
                else
                {
                    if (velocity.x > 0)
                    {
                        direction =2 ;
                    }
                    else {
                        direction =3;
                    }
                }
                
                if (direction == 2) {
                    
                    self.isUserInterActive = YES;
                    return YES;
                }
                
                
            }
        }
    }
    return NO;
}


@end

@implementation LDControllerTransitioningDelegate



@end