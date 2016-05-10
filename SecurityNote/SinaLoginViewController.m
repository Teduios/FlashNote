//
//  SinaLoginViewController.m
//  kupao
//
//  Created by xuyao on 16/4/12.
//  Copyright © 2016年 xuyao. All rights reserved.
//

#import "SinaLoginViewController.h"
#import "KRLoginViewController.h"
#import "AFNetworking.h"

@interface SinaLoginViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)backBtnClick:(id)sender;


@end

@implementation SinaLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    NSString *url = [NSString stringWithFormat:@"https://api.weibo.com/oauth2/authorize?client_id=%@&redirect_uri=%@",APPKEY,REDIRCT_URL];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    self.webView.delegate = self;
}
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSString *str = request.URL.absoluteString;
    NSRange range = [str rangeOfString:[NSString stringWithFormat:@"%@%@",REDIRCT_URL,@"/?code="]];
    NSString *code = nil;
    if (range.length > 0) {
        code = [str substringFromIndex:range.length];
        NSLog(@"%@",code);
        //使用code来获取access_token
        [self getAccess_TokenWithCode:code];
        return NO;
    }
    return YES;
}
- (void)getAccess_TokenWithCode:(NSString*)code{
    
    
}


- (IBAction)backBtnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
