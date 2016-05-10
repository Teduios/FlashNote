//
//  TCMeController.m
//  SecurityNote
//
//  Created by joonsheng on 14-8-12.
//  Copyright (c) 2014年 JoonSheng. All rights reserved.
//

#import "TCMeController.h"
#import <MessageUI/MessageUI.h>
#import "MBProgressHUD+MJ.h"
#import "TCAbutSNoteViewController.h"
#import "TCHelpViewController.h"
#import <BmobSDK/Bmob.h>
#import "TCUser.h"
#import "UINavigationController+SGProgress.h"
#import "UIView+HUD.h"
@interface TCMeController ()<UITableViewDataSource,UITableViewDelegate,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate,UIActionSheetDelegate,UIAlertViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>


@property (weak, nonatomic) IBOutlet UIButton *subscribe;

@property (weak, nonatomic) IBOutlet UILabel *moonLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageHead;

@property (weak, nonatomic) IBOutlet UITableViewCell *imageCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *textCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *helpCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *feedBackCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *recommed;
@property (weak, nonatomic) IBOutlet UITableViewCell *aboutSnot;
@property (weak, nonatomic) IBOutlet UITableViewCell *alterPassword;
@property (weak, nonatomic) IBOutlet UITableViewCell *logout;
@property (weak, nonatomic) IBOutlet UILabel *currentUser;

@end

@implementation TCMeController

NSTimer * timer;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    
   
    
    self.tableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
    
    self.imageCell.selectedBackgroundView = [[UIView alloc]initWithFrame:self.imageCell.frame];
    self.imageCell.selectedBackgroundView.backgroundColor = TCCoror(3, 123, 252);
    
    self.textCell.selectedBackgroundView = [[UIView alloc]initWithFrame:self.textCell.frame];
    self.textCell.selectedBackgroundView.backgroundColor = TCCoror(3, 123, 252);
    
    self.helpCell.selectedBackgroundView = [[UIView alloc]initWithFrame:self.helpCell.frame];
    self.helpCell.selectedBackgroundView.backgroundColor = TCCoror(3, 123, 252);
    
    self.feedBackCell.selectedBackgroundView = [[UIView alloc]initWithFrame:self.feedBackCell.frame];
    self.feedBackCell.selectedBackgroundView.backgroundColor = TCCoror(3, 123, 252);
    
    self.recommed.selectedBackgroundView = [[UIView alloc]initWithFrame:self.recommed.frame];
    self.recommed.selectedBackgroundView.backgroundColor = TCCoror(3, 123, 252);
    
    self.aboutSnot.selectedBackgroundView = [[UIView alloc]initWithFrame:self.aboutSnot.frame];
    self.aboutSnot.selectedBackgroundView.backgroundColor = TCCoror(3, 123, 252);
    
    self.logout.selectedBackgroundView = [[UIView alloc]initWithFrame:self.logout.frame];
    self.logout.selectedBackgroundView.backgroundColor = TCCoror(3, 123, 252);
    
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //获取当前的用户
    TCUser *user = (TCUser*)[TCUser getCurrentUser];
    
    
    self.currentUser.text = user.username;
 

    //设置文字
    
    NSString *moonText = [user objectForKey:@"BbNumber"];
    
    //判断是否有存储帐号，如果有，就显示出来
    if(moonText){
        self.moonLabel.text = moonText;
        
    }
    
    //设置头像属性
    //设置圆角头像
    self.imageHead.layer.masksToBounds = YES;
    self.imageHead.layer.cornerRadius = self.imageHead.frame.size.width * 0.5;
    self.imageHead.layer.borderWidth = 3.0;
    self.imageHead.layer.borderColor = TCCoror(3, 123, 252).CGColor;
    self.imageHead.contentMode = UIViewContentModeScaleToFill;
    
    
    
    /*读取入图片*/
    BmobFile *headFile = (BmobFile*)[user objectForKey:@"headImage"];
    [self.imageHead sd_setImageWithURL:[NSURL URLWithString:headFile.url] placeholderImage:[UIImage imageNamed:@""]];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 25;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    //设置照片
    if ([indexPath section] == 0 && [indexPath row] == 0)
    {
        UIActionSheet * sheets = [[UIActionSheet alloc]initWithTitle:@"选择更换您头像的方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册选择",@"选择默认头像", nil];
        
        sheets.actionSheetStyle = UIActionSheetStyleAutomatic;
        
        //帮定tag
        sheets.tag = 1;
        
        [sheets showInView:self.view];
    }
    
    //设置文字
    if ([indexPath section] == 0 && [indexPath row] == 1)
    {
        UIAlertView * alter = [[UIAlertView alloc]initWithTitle:@"编辑" message:@"请输入你的密语" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
        alter.alertViewStyle = UIAlertViewStylePlainTextInput;
        
        //拿到当前选中列表的文字
        [alter textFieldAtIndex:0].text = self.moonLabel.text;
        
        //显示文本框的x
        [alter textFieldAtIndex:0].clearButtonMode =UITextFieldViewModeWhileEditing;
        
        [alter show];
    }
    
    //帮助
    if ([indexPath section] == 1 && [indexPath row] == 0)
    {
       
        TCHelpViewController * helpV = [[TCHelpViewController alloc]init];
        
        self.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:helpV animated:YES];
        
        self.hidesBottomBarWhenPushed = NO;
        
    }
    
    
    //反馈，通过邮件
    if ([indexPath section] == 1 && [indexPath row] == 1)
    {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];

        // 设置邮件主题
        [mail setSubject:@"Feeds and Suggestions"];
        
        // 设置邮件内容
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        
        NSString * messBody = [NSString stringWithFormat:@"我使用的当前版本:%@,%@,OS %@\n我的反馈和建议：\n1、\n2、\n3、",[infoDictionary objectForKey:@"CFBundleShortVersionString"],[[UIDevice currentDevice] model],[[UIDevice currentDevice] systemVersion]];

        [mail setMessageBody:messBody isHTML:NO];
        
        
        // 设置收件人列表
        [mail setToRecipients:@[@"530893875@qq.com"]];
        
        

        
        // 设置代理
        mail.mailComposeDelegate = self;
        // 显示控制器
        [self presentViewController:mail animated:YES completion:nil];
        
    }
    
    //推荐好友
    if ([indexPath section] == 1 && [indexPath row] == 2)
    {
        UIActionSheet * sheet = [[UIActionSheet alloc]initWithTitle:@"选择推荐给好友的方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"短信",@"邮件", nil];
        
        sheet.actionSheetStyle = UIActionSheetStyleAutomatic;
        
        //帮定tag
        sheet.tag = 2;
        
        [sheet showInView:self.view];
        
    }
    
    //关于密记
    if ([indexPath section] == 1 && [indexPath row] == 3)
    {
        
        TCAbutSNoteViewController * about = [[TCAbutSNoteViewController alloc]init];
       
        self.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:about animated:YES];
        
        self.hidesBottomBarWhenPushed = NO;
        
    }
    
    if ([indexPath section] == 1 && [indexPath row] == 4) {
        
        
        
        
        // 1.获得沙盒中的数据库文件名
        NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *documentFolderPath = [searchPaths objectAtIndex:0];

        NSString *path  = [documentFolderPath stringByAppendingPathComponent:@"SecurityNote.sqlite"];
        //获取当前的用户
        TCUser *user = (TCUser*)[TCUser getCurrentUser];
        
        
        BmobFile *file1 = [[BmobFile alloc] initWithFilePath:path];
        
        [file1 saveInBackgroundByDataSharding:^(BOOL isSuccessful, NSError *error) {
            if (isSuccessful) {
                NSLog(@"成功");
                [user setObject:file1 forKey:@"noteFile"];
                [user updateInBackground];
                
            }
            
        } progressBlock:^(CGFloat progress) {
            [self.navigationController showSGProgressWithMaskAndDuration:4 andTitle:@"同步中.."];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.view showWarning:@"同步成功"];
                
                
            });
            
            NSLog(@"上传进度%.2f",progress);
        }];
    }
    
    if ([indexPath section] == 2 && [indexPath row] == 1){
        UIActionSheet * sheet = [[UIActionSheet alloc]initWithTitle:@"确定要退出吗" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"退出" otherButtonTitles: nil];
        
        sheet.actionSheetStyle = UIActionSheetStyleAutomatic;
        [sheet showInView:self.view];
        sheet.tag = 3;
        
        
        
    }



}


//alertView方法调用,需要实现UIAlertViewDelegate协议
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 0)
    {

    }
    
    //确定按钮
    if (buttonIndex == 1)
    {
        self.moonLabel.text = [alertView textFieldAtIndex:0].text;
        
        
        //上传到服务器
        //获取当前的用户
        TCUser *user = (TCUser*)[TCUser getCurrentUser];
        
        [user setObject:[alertView textFieldAtIndex:0].text forKey:@"BbNumber"];
        [user updateInBackground];
        //存入沙盒 userDeafaults
        NSUserDefaults * defaults =[NSUserDefaults standardUserDefaults];
        [defaults setValue:self.moonLabel.text forKey:@"textView"];
        [defaults synchronize];

    }
    
}


//处理Sheet
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //点击了头像
    if (actionSheet.tag == 1 && buttonIndex == 0)
    {
        //拍照
        UIImagePickerController * camera = [[UIImagePickerController alloc]init];
        
        camera.sourceType = UIImagePickerControllerSourceTypeCamera;
        camera.allowsEditing = YES;
        camera.delegate = self;
        
        [self presentViewController:camera animated:YES completion:^{
            
            
        }];
        
        
    }
    else if(actionSheet.tag == 1 && buttonIndex == 1)
    {
        //从相册
        UIImagePickerController * photo = [[UIImagePickerController alloc]init];
        
        photo.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        photo.allowsEditing = YES;
        photo.delegate = self;
        
        [self presentViewController:photo animated:YES completion:^{
            
        
        }];
        
    }
    else if(actionSheet.tag == 1 && buttonIndex == 2)
    {
        //默认头像
        
        UIImage *oldImage = [UIImage imageNamed:@"cluck.jpg"];
        
        UIImage *newImage = [oldImage imageCompressForSize:oldImage targetSize:CGSizeMake(30, 30)];
        
        
        [self.imageHead setImage:newImage];
        
        //存储头像图片
        //Document
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        
        /*写入图片*/
        //帮文件起个名
        NSString *uniquePath=[[paths objectAtIndex:0] stringByAppendingPathComponent:@"image.png"];
        //将图片写到Documents文件中
        [UIImagePNGRepresentation(newImage) writeToFile:uniquePath atomically:YES];
        
        //将图片上传到bmob后台
        
        BmobFile *file1 = [[BmobFile alloc] initWithFilePath:uniquePath];
        
        TCUser *user = (TCUser*)[TCUser getCurrentUser];
        
        [file1 saveInBackgroundByDataSharding:^(BOOL isSuccessful, NSError *error) {
            
            if (isSuccessful) {
                NSLog(@"成功");
                
                [user setObject:file1 forKey:@"headImage"];
                [user updateInBackground];
            }else{
                NSLog(@"失败%@",error);
            }
            
        }];
        
    }
    
    
    //点击了好友推荐
    if (actionSheet.tag == 2 && buttonIndex == 0)
    {
        //发短信
        MFMessageComposeViewController *mess = [[MFMessageComposeViewController alloc] init];
        
        // 设置短信内容
        mess.body = @"亲，我现在使用密记，这款应用非常棒！记列表，写日记，备忘录，非常实用的功能，并且整个界面很简洁，你也快来下载试试用啊！包你惊喜！";
        
        // 设置收件人列表
        //mess.recipients = @[@"joonsheng.htc@icloud.com"];
        
        // 设置代理
        mess.messageComposeDelegate = self;
        
        // 显示控制器
        [self presentViewController:mess animated:YES completion:nil];
    }
    else if(actionSheet.tag == 2 &&buttonIndex == 1)
    {
        // 不能发邮件
        //if (![MFMailComposeViewController canSendMail]) return;
        
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        
        // 设置邮件主题
        [mail setSubject:@"亲，快来下载密记试试啊！"];
        // 设置邮件内容
        [mail setMessageBody:@"亲，我现在使用密记，这款应用非常棒！记列表，写日记，备忘录，非常实用的功能，并且整个界面很简洁，你也快来下载试试用啊！包你惊喜！" isHTML:NO];
        
        // 设置代理
        mail.mailComposeDelegate = self;
        // 显示控制器
        [self presentViewController:mail animated:YES completion:nil];
    
    }
    
    
    if (actionSheet.tag == 3 && buttonIndex == 0) {
        
        //修改userinfo状态
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isLogin"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
       
        [TCUser logout];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}



//处理头像
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
     [picker dismissViewControllerAnimated:YES completion:^{
         
     }];
    
    [self.view showBusyHUD];
    UIImage * oldimage = info[UIImagePickerControllerEditedImage];
    //生成缩略图
    UIImage *image = [oldimage imageCompressForSize:oldimage targetSize:CGSizeMake(30, 30)];
    [self.imageHead setImage:image];
    
    //存储头像图片
    //Document
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);

    /*写入图片*/
    //帮文件起个名
    NSString *uniquePath=[[paths objectAtIndex:0] stringByAppendingPathComponent:@"image.png"];
    //将图片写到Documents文件中
    [UIImagePNGRepresentation(image) writeToFile:uniquePath atomically:YES];
    //将图片上传到bmob后台
    
    BmobFile *file1 = [[BmobFile alloc] initWithFilePath:uniquePath];
    
    TCUser *user = (TCUser*)[TCUser getCurrentUser];
    
    [file1 saveInBackgroundByDataSharding:^(BOOL isSuccessful, NSError *error) {
       
        if (isSuccessful) {
            NSLog(@"成功");
            
            [user setObject:file1 forKey:@"headImage"];
            [user updateInBackground];
            [self.view hideBusyHUD];
            
        }else{
            NSLog(@"失败%@",error);
        }
        
    }];
    
    
}


//处理短信
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    // 关闭短信界面
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    if (result == MessageComposeResultCancelled)
    {
        //NSLog(@"取消发送");
        [MBProgressHUD showSuccess:@"已取消发送"];
        
    }
    else if (result == MessageComposeResultSent)
    {
        //NSLog(@"已经发出");
        [MBProgressHUD showSuccess:@"发送成功"];
        
    } else
    {
        //NSLog(@"发送失败");
        [MBProgressHUD showError:@"发送失败"];
    }
    
    
    //定时器关闭提示
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(didhideHUD) userInfo:nil repeats:NO];
}



//处理邮件
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    // 关闭邮件界面
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    if (result == MFMailComposeResultCancelled)
    {
        [MBRoundProgressView setAnimationDelay:1];
        //NSLog(@"取消发送");
        [MBProgressHUD showSuccess:@"已取消发送"];
        
    } else if (result == MFMailComposeResultSent)
    {
        //NSLog(@"已经发出");
        [MBProgressHUD showSuccess:@"发送成功"];
        
    } else
    {
        //NSLog(@"发送失败");
        [MBProgressHUD showError:@"发送失败"];
    }
    
    //定时器关闭提示
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(didhideHUD) userInfo:nil repeats:NO];
}


//隐藏提示框
-(void)didhideHUD
{
    
    [MBProgressHUD hideHUD];
    
}

- (IBAction)Btnclick:(id)sender {
    
    [self.subscribe setImage:[UIImage imageNamed:@"bigtag"] forState:UIControlStateNormal];
    
}




@end
