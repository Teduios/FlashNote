//
//  ExpandTableViewController.m
//  ExpandTableView
//
//  Created by xuyao on 16/1/8.
//  Copyright © 2016年 xuyao. All rights reserved.
//

#import "ExpandTableViewController.h"
#import "KRLoginViewController.h"
#import "TCAddSimpleNoteViewController.h"
#import "TCMeController.h"
#import "ExpandCell.h"
#import "TCSimpleNote.h"
#import "PopoverView.h"
#import "TCUser.h"
#import "UIScrollView+Refresh.h"
#define kCell_Height 44
#define kStringArray [NSArray arrayWithObjects:@"YES", @"NO", nil]
#define kImageArray [NSArray arrayWithObjects:[UIImage imageNamed:@"success"], [UIImage imageNamed:@"error"], nil]

@interface ExpandTableViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,PopoverViewDelegate>
{
    UITableView         *expandTable;
    NSMutableArray      *dataSource;
    NSMutableArray      *sectionArray;
    NSMutableArray      *stateArray;
    
    PopoverView *pv;
    CGPoint point;
}
@property(nonatomic, strong)TCSimpleNote *note;
@property(nonatomic, assign)NSInteger index;
@property(nonatomic, strong)NSMutableArray *allNotes;
//确定当前所选的IndexPath
@property (nonatomic, strong) NSIndexPath * nowIndexPath;
//手势button
@property (nonatomic, strong)UIButton *currentBtn;
//addBtn
@property (nonatomic, weak) UIButton * addBtn;

@property (nonatomic, copy)NSString *DBstr;
//定时器
@property(nonatomic, strong)NSTimer *timer;
@end

@implementation ExpandTableViewController
- (void)initDataSource
{
    sectionArray  = [NSMutableArray array];
    dataSource = [NSMutableArray array];
    NSMutableArray *array = [self.note queryWithData];
    self.allNotes = array;
    for(TCSimpleNote *n in array){
        
       [sectionArray addObject:n.title];
       [dataSource addObject:n.datas];
    }
    
   
    
    
    stateArray = [NSMutableArray array];
    
    for (int i = 0; i < dataSource.count; i++)
    {
        //所有的分区都是闭合
        [stateArray addObject:@"0"];
    }
}
-(TCSimpleNote *)note{
    if (!_note) {
        _note = [TCSimpleNote new];
    }
    return _note;
}
#pragma mark -- ViewController生命周期
- (void)viewDidLoad {
    
    self.title = @"Tags";
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initDataSource];
    [self initTable];
   
    //
    expandTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addButten];
    
    //
   
    __weak __typeof(expandTable)weakSelf = expandTable;
    
    [expandTable addHeaderRefresh:^{
        // 1.获得沙盒中的数据库文件名
        NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *documentFolderPath = [searchPaths objectAtIndex:0];
        
        NSString *path  = [documentFolderPath stringByAppendingPathComponent:@"SecurityNote.sqlite"];
        //获取当前的用户
        TCUser *user = (TCUser*)[TCUser getCurrentUser];
        BmobFile *file1 = [[BmobFile alloc] initWithFilePath:path];
        if (!user) {
            [weakSelf showWarning:@"请登录，即可云备份数据"];
            [weakSelf endHeaderRefresh];
            return;
        }
        [file1 saveInBackgroundByDataSharding:^(BOOL isSuccessful, NSError *error) {
            if (isSuccessful) {
                NSLog(@"成功");
                
                [user setObject:file1 forKey:@"noteFile"];
                [user updateInBackground];
                
                
            }
            
        } progressBlock:^(CGFloat progress) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                
                
            });
            
            NSLog(@"上传进度%.2f",progress);
        }];

        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf endHeaderRefresh];
            [weakSelf showWarning:@"同步成功"];
        });
        
        
    }];
    
   
    UIImageView *imagev = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cloud2.png"]];
    imagev.frame = CGRectMake(0, 0, 30, 30);
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:imagev];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(asyc)];
    [imagev addGestureRecognizer:tap];
    
    self.navigationItem.rightBarButtonItem = right;
    
    
    
    
}




- (void)getDataBase{
    //获取当前的用户
    TCUser *user = (TCUser*)[TCUser getCurrentUser];
    
    BmobFile *file1 = [user objectForKey:@"noteFile"];
    
    
    if (file1.url) {
        // 1.获得沙盒中的数据库文件名
        NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *documentFolderPath = [searchPaths objectAtIndex:0];
        
        //往应用程序路径中添加数据库文件名称，把它们拼接起来
        NSString *path  = [documentFolderPath stringByAppendingPathComponent:@"SecurityNote.sqlite"];
        
        //2. 创建NSFileManager对象  NSFileManager包含了文件属性的方法
        NSFileManager *fm = [NSFileManager defaultManager];
        
        [fm removeItemAtPath:path error:nil];
        
        
        //服务器有数据
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        
        NSURL *URL = [NSURL URLWithString:file1.url];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
            return [documentsDirectoryURL URLByAppendingPathComponent:@"SecurityNote.sqlite"];
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            
            NSString *pa = filePath.absoluteString;
            NSString *pa2 = [pa substringFromIndex:7];
            
            self.DBstr = pa2;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self initDataSource];
                [expandTable reloadData];
                
                [self.view showWarning:@"云同步成功"];
            });
            
        }];
        [downloadTask resume];
        
    }
    
}

- (void)asyc{
    [self getDataBase];
    NSLog(@"aysc");
    
   
    
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self initDataSource];
    [expandTable reloadData];
    
    BOOL ret = [[NSUserDefaults standardUserDefaults] boolForKey:@"isLogin"];
    if (ret) {
        [self settingIconImage];
        
    }else{
        [self settingLoginIcon];
        
    }
    
//    //定时器
//  self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(settingIconImage) userInfo:nil repeats:YES];
    
}


//设置登录小人
- (void)settingLoginIcon{
    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"my"] style:UIBarButtonItemStylePlain target:self action:@selector(login)];
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = leftBar;
}
//设置登录头像
- (void)settingIconImage{
    NSLog(@"setImage");
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
    
    [imageView sd_setImageWithURL:[NSURL URLWithString:headFile.url] placeholderImage:[UIImage imageNamed:@""]];
    self.navigationItem.leftBarButtonItems = @[space,bar];
   
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(login)];
    [imageView addGestureRecognizer:tap];
    
   
    
}


-(void)addButten
{
    
    UIButton * addBtn =  [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 65, self.view.frame.size.height - 120,  48, 48)];
    [addBtn setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    
    
    UILabel * tagTitle = [[UILabel alloc]initWithFrame:CGRectMake(-13, 40, 80, 35)];
//    tagTitle.text = @"增加一行";
    tagTitle.textColor = [UIColor colorWithRed:0/255.0 green:122/255.0 blue:252/255.0 alpha:1];
    [addBtn addSubview:tagTitle];
    [addBtn addTarget:self action:@selector(addNew) forControlEvents:UIControlEventTouchUpInside];
    
    self.addBtn = addBtn;
    [self.view addSubview:addBtn];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [self.addBtn addGestureRecognizer:pan];
    
}
- (void)panView:(UIPanGestureRecognizer *)pan
{
    
    // 1.在view上面挪动的距离
    CGPoint translation = [pan translationInView:pan.view];
    CGPoint center = pan.view.center;
    center.x += translation.x;
    center.y += translation.y;
    pan.view.center = center;
    
    // 2.清空移动的距离
    [pan setTranslation:CGPointZero inView:pan.view];
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

-(void)addNew{
    TCAddSimpleNoteViewController *vc = [TCAddSimpleNoteViewController new];
    [self presentViewController:vc animated:YES completion:nil];
}

-(void)initTable{
    expandTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    expandTable.dataSource = self;
    expandTable.delegate =  self;
    expandTable.tableFooterView = [UIView new];
    [expandTable registerNib:[UINib nibWithNibName:@"ExpandCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:expandTable];
}
#pragma mark -
#pragma mark - UITableViewDataSource UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([stateArray[section] isEqualToString:@"1"]){
        //如果是展开状态
        NSArray *array = [dataSource objectAtIndex:section];
        
        return array.count;
    }else{
        //如果是闭合，返回0
        return 0;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ExpandCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.listLabel.textAlignment = NSTextAlignmentLeft;
    cell.listLabel.text = (dataSource[indexPath.section])[indexPath.row];
    
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.contentView.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
        return sectionArray[section];
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    [button setTag:section+1];
    button.backgroundColor = [UIColor whiteColor];
    [button setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 60)];
    
    [button addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
    // -1
    UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(0, button.frame.size.height - 1, button.frame.size.width, 1)];
    [line setImage:[UIImage imageNamed:@"line_real"]];
    [button addSubview:line];
    
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, (kCell_Height-22), 22, 22)];
    [imgView setImage:[UIImage imageNamed:@"tag"]];
    [button addSubview:imgView];
    
    UIImageView *_imgView = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width-30, (kCell_Height-6)/2, 10, 6)];
    
    if ([stateArray[section] isEqualToString:@"0"]) {
        _imgView.image = [UIImage imageNamed:@""];
    }else if ([stateArray[section] isEqualToString:@"1"]) {
        _imgView.image = [UIImage imageNamed:@""];
    }
    [button addSubview:_imgView];
    
    UILabel *tlabel = [[UILabel alloc]initWithFrame:CGRectMake(45, (kCell_Height-20), self.view.frame.size.width, 20)];
    [tlabel setBackgroundColor:[UIColor clearColor]];
    [tlabel setFont:[UIFont systemFontOfSize:18]];
    [tlabel setText:sectionArray[section]];
    //
    tlabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:18];
    
    [button addSubview:tlabel];
    //手势
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    swipe.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [button addGestureRecognizer:swipe];
    
    
    //
    [button addTarget:self action:@selector(touchDrag:) forControlEvents:UIControlEventTouchDragInside];
    return button;
}
-(void)touchDrag:(UIButton*)sender{
   
    self.currentBtn = sender;
    self.index =  sender.tag;
    
    
}
-(void)swipe:(UISwipeGestureRecognizer*)sender{
    
    NSLog(@"swipe");
    point = [sender locationInView:self.view];
    [NSThread sleepForTimeInterval:0.1];
    pv = [PopoverView showPopoverAtPoint:point
                                  inView:self.view
                               withTitle:@"确定要删除吗"
                         withStringArray:kStringArray
                                delegate:self];
    
    
    
    
}
#pragma mark - PopoverViewDelegate Methods
- (void)popoverView:(PopoverView *)popoverView didSelectItemAtIndex:(NSInteger)index
{
    if (index == 0) {
        NSLog(@"删除");
        self.note  = self.allNotes[self.index - 1];
        [dataSource removeObjectAtIndex:self.index - 1];
        
        
        //
        [self.note deleteAll:self.note];
        [self initDataSource];
        [expandTable reloadData];
        
    }else{
        
        
        NSLog(@"不删除");
        
    }
    // Figure out which string was selected, store in "string"
    NSString *string = [kStringArray objectAtIndex:index];
    
    // Show a success image, with the string from the array
    [popoverView showImage:[UIImage imageNamed:@"success"] withMessage:string];
    
    // alternatively, you can use
    // [popoverView showSuccess];
    // or
    // [popoverView showError];
    
    // Dismiss the PopoverView after 0.5 seconds
    [popoverView performSelector:@selector(dismiss) withObject:nil afterDelay:0.5f];
}
#pragma mark  -select cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    
}

- (void)buttonPress:(UIButton *)sender//headButton点击
{
    
    //判断状态值
    if ([stateArray[sender.tag - 1] isEqualToString:@"1"]){
        //修改
        [stateArray replaceObjectAtIndex:sender.tag - 1 withObject:@"0"];
    }else{
        [stateArray replaceObjectAtIndex:sender.tag - 1 withObject:@"1"];
    }
    [expandTable reloadSections:[NSIndexSet indexSetWithIndex:sender.tag-1] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCell_Height;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.00001;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 64;
}
//左滑菜单
-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewRowAction *deleteRoWAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        self.note  = self.allNotes[indexPath.section];
        NSMutableArray *array = dataSource[indexPath.section];
        
        [array removeObjectAtIndex:indexPath.row];
        
        
        //删除数据库数据
       [self.note deleteString:self.note];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        

      
    }];
    //此处是iOS8.0以后苹果最新推出的api，UITableViewRowAction，Style是划出的标签颜色等状态的定义，这里也可自行定义
    //    UITableViewRowAction *editRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"删除全部" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
    //        self.note  = self.allNotes[indexPath.section];
    //        [dataSource removeObjectAtIndex:indexPath.section];
    //        //
    //        [self.note deleteAll:self.note];
    //        [expandTable reloadData];
    //    }];
    
    UITableViewRowAction *alterRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"修改" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        self.nowIndexPath = indexPath;
        
        self.note = self.allNotes[[indexPath section]];
        
        UIAlertView * alter = [[UIAlertView alloc]initWithTitle:@"编辑" message:@"请输入内容" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
        alter.alertViewStyle = UIAlertViewStylePlainTextInput;
        
        //拿到当前选中列表的文字
        [alter textFieldAtIndex:0].text = [self.note.datas objectAtIndex:[indexPath row]];
        
        //显示文本框的x
        [alter textFieldAtIndex:0].clearButtonMode =UITextFieldViewModeWhileEditing;
        
        [alter show];
        
        
    }];
//    editRowAction.backgroundColor = [UIColor colorWithRed:0 green:124/255.0 blue:223/255.0 alpha:1];//可以定义RowAction的颜色
    return @[deleteRoWAction, alterRowAction];
}

    
//alertView方法调用,需要实现UIAlertViewDelegate协议
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 0)
    {
        [expandTable deselectRowAtIndexPath:self.nowIndexPath animated:YES];
        NSLog(@"取消");
    }
    
    if (buttonIndex == 1)
    {
        [expandTable deselectRowAtIndexPath:self.nowIndexPath animated:YES];
        
        //拿到当前要编辑的列表的所在分区
        self.note = self.allNotes[[self.nowIndexPath section]];
        
        //更改列表文字
        [self.note.datas replaceObjectAtIndex:(self.nowIndexPath.row) withObject:[alertView textFieldAtIndex:0].text];
        
        //更新数据库
        [self.note upDateString:[alertView textFieldAtIndex:0].text forRowAtIndexPathRow:self.nowIndexPath.row forRowAtIndexPathSection:self.nowIndexPath.section];
        
        //刷新列表
        [expandTable reloadData];
    }
    
}
    
    

@end
