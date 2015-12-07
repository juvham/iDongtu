//
//  BaseNavigationViewController.m
//  iDongtu
//
//  Created by 迅牛 on 15/12/4.
//  Copyright © 2015年 juvham. All rights reserved.
//

#import "BaseNavigationViewController.h"
#import "PageFullScreen.h"

@interface BaseNavigationViewController ()

@end

@implementation BaseNavigationViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self.navigationBar setBarStyle:(UIBarStyleBlack)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    
    return self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    
    return self.topViewController;
}

//- (UIStatusBarStyle)preferredStatusBarStyle {
//
//    return  [PageFullScreen fullScreenMode] ? UIStatusBarStyleLightContent: UIStatusBarStyleDefault;
//}
//
//- (BOOL)prefersStatusBarHidden {
//    
//    return  (/*[PageFullScreen fullScreenMode] || */(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])));
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
