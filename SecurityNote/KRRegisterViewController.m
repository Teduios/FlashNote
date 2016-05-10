//
//  KRRegisterViewController.m
//  kupao
//
//  Created by xuyao on 16/4/11.
//  Copyright © 2016年 xuyao. All rights reserved.
//

#import "KRRegisterViewController.h"
#import "AFNetworking.h"
#import <BmobSDK/Bmob.h>
#import "MBProgressHUD.h"
#import "UIView+HUD.h"
#import "TCUser.h"
@interface KRRegisterViewController ()
- (IBAction)backBtnClick:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *userRegisterNameFiled;
@property (weak, nonatomic) IBOutlet UITextField *userPwdFiled;
- (IBAction)registerBtn:(id)sender;
@property(copy,nonatomic)NSString *userName;

@property(copy,nonatomic)NSString *userPwd;

@end

@implementation KRRegisterViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon"]];
    
    leftView.frame = CGRectMake(0, 0, 55, 20);
    
    leftView.contentMode = UIViewContentModeCenter;
    self.userRegisterNameFiled.leftViewMode = UITextFieldViewModeAlways;
    self.userRegisterNameFiled.leftView = leftView;
    
    UIImageView *rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lock"]];
    rightView.frame = CGRectMake(0, 0, 55, 20);
    rightView.contentMode = UIViewContentModeCenter;
    self.userPwdFiled.leftViewMode = UITextFieldViewModeAlways;
    self.userPwdFiled.leftView = rightView;
    // Do any additional setup after loading the view.
}




- (IBAction)backBtnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)registerBtn:(id)sender {
    [TCUser signOrLoginInbackgroundWithMobilePhoneNumber:self.userRegisterNameFiled.text SMSCode:self.userPwdFiled.text andPassword:@"123456" block:^(BmobUser *user, NSError *error) {
        [self.view showBusyHUD];
        if (user) {
            
            
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"成功" message:@"注册成功，默认密码为123456，请及时修改密码" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                    
                }];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
                
                [self.view hideBusyHUD];
            });
            
        }else{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [self.view hideBusyHUD];
            });

        }
    }];
    
}


- (IBAction)sendSMS:(id)sender {
    [BmobSMS requestSMSCodeInBackgroundWithPhoneNumber:self.userRegisterNameFiled.text andTemplate:nil resultBlock:^(int number, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
        }else{
            NSLog(@"sms ID :%d",number);
            
        }
        
    }];
}





@end
