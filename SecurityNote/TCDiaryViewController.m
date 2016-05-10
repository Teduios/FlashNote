//
//  TCDiaryViewController.m
//  SecurityNote
//
//  Created by joonsheng on 14-8-15.
//  Copyright (c) 2014年 JoonSheng. All rights reserved.
//

#import "TCDiaryViewController.h"
#import "KRLoginViewController.h"
#import "TCMeController.h"
#import "TCAddDiaryViewController.h"
#import "TCDiary.h"
#import "TCDatePickerView.h"
#import "TCEditDiaryView.h"
#import "TCDiaryTool.h"
#import "TCUser.h"
@interface TCDiaryViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>

//主表格
@property (nonatomic, weak) UITableView * diaryTable;

//全部数据库条数
@property (nonatomic, strong) NSMutableArray * diaryLists;

//一条TCDiary数据
@property (nonatomic, strong) TCDiary * diaryNote;

//增加按钮
@property (nonatomic, weak) UIButton * addBtn;

//dispaly
@property (nonatomic, strong)UISearchDisplayController *display;

//搜索结果
@property (nonatomic, strong)NSMutableArray *allResults;

@end

@implementation TCDiaryViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    UITableView * dairyTab = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height) style:UITableViewStylePlain];
    dairyTab.separatorColor = [UIColor colorWithRed:0/255.0 green:122/255.0 blue:252/255.0 alpha:1];
    dairyTab.rowHeight = 60;
    
    dairyTab.delegate = self;
    dairyTab.dataSource = self;
    
    self.diaryTable = dairyTab;
    [self.view addSubview:dairyTab];
    
    
    //增加navigation rightBtn
    UIBarButtonItem *button = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"ic_add_tab"] style:UIBarButtonItemStylePlain target:self action:@selector(addNewDiaryNote)];
    
    self.navigationItem.rightBarButtonItem = button;
    
    
    self.diaryLists = [self.diaryNote queryWithNote];
    //搜索框的设置
    UISearchBar *bar = [[UISearchBar alloc]init];
    bar.frame=CGRectMake(0, 0, 300, 44);
    bar.delegate =self;
    self.display = [[UISearchDisplayController alloc]initWithSearchBar:bar contentsController:self];
    self.display.searchResultsDataSource = self;
    self.display.searchResultsDelegate = self;
    self.display.delegate = self;
    self.diaryTable.tableHeaderView = bar;
    
    
    
}
#pragma mark-搜索框的代理方法
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.allResults = [TCDiaryTool queryWithKeywords:searchText];
    
         //刷新表格
    [self.display.searchResultsTableView reloadData];
    
}
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(nullable NSString *)searchString
{
    return YES;
}
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    return YES;
}

//懒加载
-(NSMutableArray *)allResults{
    if (!_allResults) {
        _allResults = [NSMutableArray array];
    }
    return _allResults;
}
-(TCDiary *)diaryNote
{
    if (_diaryNote == nil)
    {
        _diaryNote = [[TCDiary alloc]init];
    }
    
    return _diaryNote;
}


//保存新建的简记后，重新刷新数据
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    //必须重新查询数据库更新数据
    self.diaryLists = [self.diaryNote queryWithNote];
    [self.diaryTable reloadData];
    
    
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

-(void)addNewDiaryNote{
    TCAddDiaryViewController *toAddController = [[TCAddDiaryViewController alloc]init];
    
    [self presentViewController:toAddController animated:YES completion:nil];

}

//列表数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.diaryTable) {
        
        return [self.diaryLists count];
    }else{
        NSLog(@"%ld",self.allResults.count);
        return self.allResults.count;
    }
}


//cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == self.diaryTable) {
        static NSString * diaryID = @"diaryID";
        UITableViewCell * cell  = [tableView dequeueReusableCellWithIdentifier:diaryID];
        
        if (cell == nil)
        {
            cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1
                                        reuseIdentifier:diaryID];
            
        }
        
        
        //cell被选中的颜色
        cell.selectedBackgroundView = [[UIView alloc]initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = TCCoror(51, 149, 253);
        //右侧的指示
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        //当前分区的数据
        self.diaryNote = self.diaryLists[[indexPath row]];
        
        cell.textLabel.text = self.diaryNote.title;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:23];
        
        //判断时间，如果是今年，那么只显示月日; 如果不是，显示年份
        NSString * times = [self.diaryNote.time substringToIndex:4];
        NSString * detailContent;
        if ([times isEqualToString:[TCDatePickerView getNowDateFormat:@"yyyy"]])
        {
            detailContent = [NSString stringWithFormat:@"%@", [self.diaryNote.time substringFromIndex:5]];
        }
        
        
        else
        {
            detailContent = [NSString stringWithFormat:@"%@",self.diaryNote.time];
        }
        
        
        cell.detailTextLabel.text = detailContent;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        
        
        return cell;
        
    }else{
        UITableViewCell * cell  = [tableView dequeueReusableCellWithIdentifier:@"result"];
        
        if (cell == nil)
        {
            cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1
                                        reuseIdentifier:@"result"];
            
        }

        TCDiary *t = self.allResults[indexPath.row];
        cell.textLabel.text = t.title;
        NSLog(@"%@",t.title);
        //判断时间，如果是今年，那么只显示月日; 如果不是，显示年份
        NSString * times = [self.diaryNote.time substringToIndex:4];
        NSString * detailContent;
        if ([times isEqualToString:[TCDatePickerView getNowDateFormat:@"yyyy"]])
        {
            detailContent = [NSString stringWithFormat:@"%@", [self.diaryNote.time substringFromIndex:5]];
        }
        
        
        else
        {
            detailContent = [NSString stringWithFormat:@"%@",self.diaryNote.time];
        }
        
        
        cell.detailTextLabel.text = detailContent;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        
        
        return cell;
    }
    
}



//编辑状态
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        self.diaryNote = [self.diaryLists objectAtIndex:[indexPath row]];
        
        [self.diaryNote deleteNote:self.diaryNote.ids];
        
        [self.diaryLists removeObjectAtIndex:[indexPath row]];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
    
}



//选择的列表
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.diaryTable) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        TCEditDiaryView * editController = [[TCEditDiaryView alloc]init];
        
        self.diaryNote = self.diaryLists[[indexPath row]];
        
        editController.ids = self.diaryNote.ids;
        
        
        self.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:editController animated:YES];
        
        self.hidesBottomBarWhenPushed = NO;
    }else{
        TCEditDiaryView * editController = [[TCEditDiaryView alloc]init];
        
        self.diaryNote = self.allResults[[indexPath row]];
        
        editController.ids = self.diaryNote.ids;
        
        
        self.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:editController animated:YES];
        
        self.hidesBottomBarWhenPushed = NO;

    }
    
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{

    self.addBtn.hidden = YES;
    return @"删除";
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    self.addBtn.hidden = NO;
    
    return YES;
}


@end
