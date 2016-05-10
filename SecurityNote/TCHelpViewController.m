//
//  TCHelpViewController.m
//  SecurityNote
//
//  Created by HTC on 14-10-2.
//  Copyright (c) 2014年 JoonSheng. All rights reserved.
//

#import "TCHelpViewController.h"

@interface TCHelpViewController ()<UIActionSheetDelegate>

@end

@implementation TCHelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"帮助";
    
    UIImageView * logoV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logoabout.png"]];
    logoV.center = CGPointMake(self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.21);
    logoV.bounds = CGRectMake(0, 0, 100, 100);
    [self.view addSubview:logoV];
    
    
    UILabel * name = [[UILabel alloc]init];
    name.center = CGPointMake(self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.33);
    name.bounds = CGRectMake(0, 0, 500, 80);
    name.text = @"Flash Note";
    name.textAlignment = NSTextAlignmentCenter;
    name.font = [UIFont boldSystemFontOfSize:25];
    [self.view addSubview:name];
    
    
    UILabel * thank = [[UILabel alloc]init];
    thank.center = CGPointMake(self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.45);
    thank.bounds = CGRectMake(0, 0,480, 80);
    thank.text = @"真诚的感谢您使用Flash Note！";
    thank.textAlignment = NSTextAlignmentCenter;
    thank.font = [UIFont systemFontOfSize:21];
    [self.view addSubview:thank];
    
    
    UILabel * user = [[UILabel alloc]init];
    user.center = CGPointMake(self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.55);
    user.bounds = CGRectMake(0, 0,280, 80);
    user.numberOfLines = 0;
    user.text = @"如果您在使用过程中，有任何疑问或者意见，欢迎访问搜索引擎";
    user.textAlignment = NSTextAlignmentCenter;
    user.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:user];
    
    
    UIButton * goUrl = [[UIButton alloc]init];
    goUrl.center = CGPointMake(self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.7);
    goUrl.bounds = CGRectMake(0, 0,200, 30);
    [goUrl setTitle:@"访问百度" forState:UIControlStateNormal];
    [goUrl setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [goUrl setTitleColor:TCCoror(186, 186, 192) forState:UIControlStateDisabled];
    goUrl.adjustsImageWhenHighlighted = NO;
    [goUrl addTarget:self action:@selector(goWeb) forControlEvents:UIControlEventTouchUpInside];
    goUrl.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    goUrl.layer.cornerRadius = 3.5;
    goUrl.layer.masksToBounds = YES;
    goUrl.backgroundColor = [UIColor colorWithRed:0/255.0 green:122/255.0 blue:252/255.0 alpha:1];
    [self.view addSubview:goUrl];

    
    
    UILabel * htc = [[UILabel alloc]init];
    htc.center = CGPointMake(self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.96);
    htc.bounds = CGRectMake(0, 0, 250, 80);
    htc.text = @"许耀 版权所有";
    htc.textAlignment = NSTextAlignmentCenter;
    htc.textColor = TCCoror(147, 147, 147);
    htc.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:htc];
    
    
    UILabel * rights = [[UILabel alloc]init];
    rights.center = CGPointMake(self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.98);
    rights.bounds = CGRectMake(0, 0, 250, 80);
    rights.text = @"© 2015-2016 xuyao All rights reserved";
    rights.textAlignment = NSTextAlignmentCenter;
    rights.textColor = TCCoror(147, 147, 147);
    rights.font = [UIFont systemFontOfSize:11];
    [self.view addSubview:rights];

}


-(void)goWeb
{
    UIActionSheet * sheets = [[UIActionSheet alloc]initWithTitle:@"通过Safari,选择您想要访问的网页" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"搜狗一下",@"百度一下", nil];
    
    sheets.actionSheetStyle = UIActionSheetStyleAutomatic;
    
    [sheets showInView:self.view];

}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        NSURL * url = [NSURL URLWithString:@"http://sougou.com"];
        
        [[UIApplication sharedApplication] openURL:url];
       
    }
    else if(buttonIndex == 1)
    {
        NSURL * url = [NSURL URLWithString:@"http://baidu.com"];
        
        [[UIApplication sharedApplication] openURL:url];
        
    }

    


}

@end
