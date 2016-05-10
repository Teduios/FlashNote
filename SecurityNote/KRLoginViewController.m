//
//  KRLoginViewController.m
//  kupao
//
//  Created by xuyao on 16/4/8.
//  Copyright © 2016年 xuyao. All rights reserved.
//

#import "KRLoginViewController.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import <BmobSDK/Bmob.h>
#import "UIView+HUD.h"
#import "ExpandTableViewController.h"
#import "TCUser.h"
@interface KRLoginViewController ()
/** 用户名 */
@property (weak, nonatomic) IBOutlet UITextField *userNameFiled;
/** 密码 */
@property (weak, nonatomic) IBOutlet UITextField *pwdFiled;
- (IBAction)loginBtnClick:(id)sender;


@end

@implementation KRLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon"]];
    
    leftView.frame = CGRectMake(0, 0, 55, 20);
    
    leftView.contentMode = UIViewContentModeCenter;
    self.userNameFiled.leftViewMode = UITextFieldViewModeAlways;
    self.userNameFiled.leftView = leftView;
    
    UIImageView *rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lock"]];
    rightView.frame = CGRectMake(0, 0, 55, 20);
    rightView.contentMode = UIViewContentModeCenter;
    self.pwdFiled.leftViewMode = UITextFieldViewModeAlways;
    self.pwdFiled.leftView = rightView;
    
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backClick)];
    
    self.navigationItem.leftBarButtonItem = leftBtn;
    // Do any additional setup after loading the view.
}

- (void)backClick{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


- (IBAction)loginBtnClick:(id)sender {
     [self.view showBusyHUD];
    
    [TCUser loginWithUsernameInBackground:self.userNameFiled.text password:self.pwdFiled.text block:^(BmobUser *user, NSError *error) {
        if (user) {
            //修改userinfo
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLogin"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                UIStoryboard *stryBoard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
                ExpandTableViewController *tagVC = [stryBoard instantiateInitialViewController];
                [self presentViewController:tagVC animated:YES completion:nil];
                [self.view hideBusyHUD];
                
                //
                
                
                
                
            });
        }else{
            
            [self.view showWarning:@"用户名或密码错误"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [self.view hideBusyHUD];
            });
            
        }
        
    }];
    
    
   
    
}


@end
