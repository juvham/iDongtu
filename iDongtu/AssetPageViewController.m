//
//  AssetPageViewController.m
//  iDongtu
//
//  Created by 迅牛 on 15/11/21.
//  Copyright © 2015年 juvham. All rights reserved.
//

#import "AssetPageViewController.h"
#import "PageFullScreen.h"

@interface AssetPageViewController ()

@end

@implementation AssetPageViewController
- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];

    UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    
    [self.view addGestureRecognizer:gesture];
    
    self.view.userInteractionEnabled = YES;
}

- (void)tapView:(UITapGestureRecognizer *)tap {
    
    [PageFullScreen setFullScreenMode: ![PageFullScreen fullScreenMode]];
    
    [self setNeedsStatusBarAppearanceUpdate];
    UINavigationBar *navibar = self.navigationController.navigationBar;
    
    [UIView animateWithDuration:0.4 animations:^{
        self.view.backgroundColor = [PageFullScreen fullScreenMode] ? [UIColor blackColor] : [UIColor whiteColor];
        [navibar setValue:[PageFullScreen fullScreenMode] ? @(0) : @(1) forKeyPath:@"alpha"];
        
        [self.navigationController.toolbar setAlpha:[PageFullScreen fullScreenMode] ? 0 :1 ];
        
    } completion:^(BOOL finished) {
        
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return  [PageFullScreen fullScreenMode] ? UIStatusBarStyleLightContent: UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
  
    return  (/*[PageFullScreen fullScreenMode] || */(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
