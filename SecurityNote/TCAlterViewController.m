//
//  TCAlterViewController.m
//  SecurityNote
//
//  Created by xuyao on 16/4/27.
//  Copyright © 2016年 JoonSheng. All rights reserved.
//

#import "TCAlterViewController.h"

@interface TCAlterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *oldPwd;
@property (weak, nonatomic) IBOutlet UITextField *pwd;

@end

@implementation TCAlterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon"]];
    
    leftView.frame = CGRectMake(0, 0, 55, 20);
    
    leftView.contentMode = UIViewContentModeCenter;
    self.oldPwd.leftViewMode = UITextFieldViewModeAlways;
    self.oldPwd.leftView = leftView;
    
    UIImageView *rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lock"]];
    rightView.frame = CGRectMake(0, 0, 55, 20);
    rightView.contentMode = UIViewContentModeCenter;
    self.pwd.leftViewMode = UITextFieldViewModeAlways;
    self.pwd.leftView = rightView;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
   
}
- (IBAction)alter:(id)sender {
    //获取当前的用户
    TCUser *user = (TCUser*)[TCUser getCurrentUser];
    [user updateCurrentUserPasswordWithOldPassword:self.oldPwd.text newPassword:self.pwd.text block:^(BOOL isSuccessful, NSError *error) {
        
        if (isSuccessful) {
            [self.view showWarning:@"修改成功"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
            
        }else{
            [self.view showWarning: @"修改失败"];
        }
        
        
    }];

    
}


@end
