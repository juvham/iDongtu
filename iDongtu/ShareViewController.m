//
//  ShareViewController.m
//  SamplePhotosApp
//
//  Created by 迅牛 on 15/11/10.
//
//

#import "ShareViewController.h"

NSString *const shareViewControllerSegueID = @"showShareViewController";

@interface ShareViewController () <UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation ShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.webView.delegate = self;
     [self.webView loadRequest:[NSURLRequest requestWithURL:self.URL]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

}


- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
   
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    NSLog(@"%@",webView );
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    NSLog(@"%@",error);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    return YES;
}

-(void)webViewDidStartLoad:(UIWebView *)webView {
    
    NSLog(@"%@",webView);
}

- (IBAction)shareGif:(id)sender {
    
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
