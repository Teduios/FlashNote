//
//  NoteListController.m
//  Voice2Note
//
//  Created by liaojinxing on 14-6-11.
//  Copyright (c) 2014年 jinxing. All rights reserved.
//

#import "NoteListController.h"
#import "NoteManager.h"
#import "NoteDetailController.h"
#import "VNNote.h"
#import "VNConstants.h"
#import "NoteListCell.h"
//#import "MobClick.h"
#import "iflyMSC/IFlyRecognizerView.h"
#import "KRLoginViewController.h"
#import "iflyMSC/IFlySpeechConstant.h"
#import "iflyMSC/IFlyRecognizerView.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "SVProgressHUD.h"
#import "UIColor+VNHex.h"
#import "TCUser.h"
#import "TCMeController.h"
@interface NoteListController ()<IFlyRecognizerViewDelegate>
{
  IFlyRecognizerView *_iflyRecognizerView;
  NSMutableString *_resultString;
}
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation NoteListController

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self setupNavigationBar];
  [self setupVoiceRecognizerView];
  self.view.backgroundColor = [UIColor whiteColor];
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
  self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(reloadData)
                                               name:kNotificationCreateFile
                                             object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    BOOL ret = [[NSUserDefaults standardUserDefaults] boolForKey:@"isLogin"];
    if (ret) {
        [self settingIconImage];
        
    }else{
        [self settingLoginIcon];
        
    }
}
//设置登录小人
- (void)settingLoginIcon{
    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"my"] style:UIBarButtonItemStylePlain target:self action:@selector(login)];
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = leftBar;
}
//设置登录头像
- (void)settingIconImage{
    
    //获取当前的用户
    TCUser *user = (TCUser*)[TCUser getCurrentUser];
    BmobFile *headFile = (BmobFile*)[user objectForKey:@"headImage"];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 40, 40)];
    
    //    设置圆角头像
    imageView.layer.masksToBounds = YES;
    imageView.layer.cornerRadius = imageView.frame.size.width * 0.5;
    imageView.layer.borderWidth = 3.0;
    imageView.layer.borderColor = TCCoror(3, 123, 252).CGColor;
    imageView.contentMode = UIViewContentModeScaleToFill;
    UIBarButtonItem *bar = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    space.width = -10;
    [imageView sd_setImageWithURL:[NSURL URLWithString:headFile.url] placeholderImage:[UIImage imageNamed:@"cluck.jpg"]];
    self.navigationItem.leftBarButtonItems = @[space,bar];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(login)];
    [imageView addGestureRecognizer:tap];
    
    
    
}

//监听login
-(void)login{
    //判断loginState
    BOOL isLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"isLogin"];
    
    
    if (isLogin) {
        //已经登录
        UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        TCMeController *meVC = [storyBoard instantiateViewControllerWithIdentifier:@"me"];
        [self.navigationController pushViewController:meVC animated:YES];
        
        
    }else{
        //未登录
        UIStoryboard *stryBoard=[UIStoryboard storyboardWithName:@"LandR" bundle:nil];
        KRLoginViewController *loginVC = [stryBoard instantiateInitialViewController];
        [self presentViewController:loginVC animated:YES completion:nil];
    }
    
}


- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [IFlySpeechUtility destroy];
}

- (void)setupNavigationBar
{
//  UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"micro_small"]
//                                                           style:UIBarButtonItemStylePlain
//                                                          target:self
//                                                          action:@selector(createVoiceTask)];
//  self.navigationItem.leftBarButtonItem = leftItem;
    
    
  
  UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_add_tab"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(createTask)];
  self.navigationItem.rightBarButtonItem = rightItem;
  self.navigationItem.title = kAppName;
}

- (void)setupVoiceRecognizerView
{
  NSString *initString = [NSString stringWithFormat:@"%@=%@", [IFlySpeechConstant APPID], kIFlyAppID];
  
  [IFlySpeechUtility createUtility:initString];
  _iflyRecognizerView = [[IFlyRecognizerView alloc] initWithCenter:self.view.center];
  _iflyRecognizerView.delegate = self;
  
  [_iflyRecognizerView setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
  [_iflyRecognizerView setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
  [_iflyRecognizerView setParameter:@"plain" forKey:[IFlySpeechConstant RESULT_TYPE]];
  
  _resultString = [NSMutableString string];
}

- (void)reloadData
{
  _dataSource = [[NoteManager sharedManager] readAllNotes];
  [self.tableView reloadData];
}

- (NSMutableArray *)dataSource
{
  if (!_dataSource) {
    _dataSource = [[NoteManager sharedManager] readAllNotes];
  }
  return _dataSource;
}

- (void)createVoiceTask
{
  [_iflyRecognizerView start];
}

#pragma mark IFlyRecognizerViewDelegate

- (void)onResult:(NSArray *)resultArray isLast:(BOOL)isLast
{
  NSMutableString *result = [[NSMutableString alloc] init];
  NSDictionary *dic = [resultArray objectAtIndex:0];
  for (NSString *key in dic) {
    [result appendFormat:@"%@", key];
  }
  [_resultString appendString:result];
  if (isLast && _resultString.length > 0) {
    VNNote *note = [[VNNote alloc] initWithTitle:nil
                                         content:_resultString
                                     createdDate:[NSDate date]
                                      updateDate:[NSDate date]];
    BOOL success = [note Persistence];
    if (success) {
      [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SaveSuccess", @"")];
      [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCreateFile object:nil userInfo:nil];
    } else {
      [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SaveFail", @"")];
    }
    _resultString = [NSMutableString string];
  }
}

- (void)onError:(IFlySpeechError *)error
{
  NSLog(@"errorCode:%@", [error errorDesc]);
}

- (void)createTask
{
//  [MobClick event:kEventAddNewNote];
  NoteDetailController *controller = [[NoteDetailController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
  [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - DataSource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  VNNote *note = [self.dataSource objectAtIndex:indexPath.row];
  return [NoteListCell heightWithNote:note];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NoteListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListCell"];
  if (!cell) {
    cell = [[NoteListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ListCell"];
  }
  VNNote *note = [self.dataSource objectAtIndex:indexPath.row];
  cell.index = indexPath.row;
  [cell updateWithNote:note];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
  VNNote *note = [self.dataSource objectAtIndex:indexPath.row];
  NoteDetailController *controller = [[NoteDetailController alloc] initWithNote:note];
  controller.hidesBottomBarWhenPushed = YES;
  [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - EditMode

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    VNNote *note = [self.dataSource objectAtIndex:indexPath.row];
    [[NoteManager sharedManager] deleteNote:note];
    
    [self.dataSource removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
  }
}

@end
