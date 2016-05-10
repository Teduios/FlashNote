//
//  TCAddSimpleNoteViewController.m
//  SecurityNote
//
//  Created by joonsheng on 14-8-15.
//  Copyright (c) 2014年 JoonSheng. All rights reserved.
//

#import "TCAddSimpleNoteViewController.h"
#import "TCSimpleNote.h"
#import "simpleCell.h"
@interface TCAddSimpleNoteViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property (nonatomic, weak) UITableView * sTable;

@property (nonatomic, weak) UIButton * addBtn;

@property (nonatomic, strong) NSIndexPath * nowIndexPath;

@property (nonatomic, strong) TCSimpleNote * addNote;

@property (nonatomic, strong) NSMutableArray * noteArray;

@end

@implementation TCAddSimpleNoteViewController


-(NSMutableArray *)noteArray
{
    if (_noteArray == nil) {
        
        _noteArray = [NSMutableArray array];
    }
    
    return _noteArray;
}

-(TCSimpleNote *)addNote
{
    if (_addNote == nil) {
        
        _addNote = [[TCSimpleNote alloc]init];
    }
    
    return _addNote;

}


- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self topColor];
    
    [self backBtn];
    [self saveBtn];

    [self cleateTable];
    [self titleLabel];

    [self addButten];
    
  
}


-(void)topColor
{
    UIView * topColor = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    
    topColor.backgroundColor  = [UIColor colorWithRed:0/255.0 green:122/255.0 blue:252/255.0 alpha:1];
    
    [self.view addSubview:topColor];
    
}

-(void)titleLabel
{
    UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 00, 60, 30)];
    titleLabel.center = CGPointMake(self.view.frame.size.width /2, 40);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"简记";
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.textColor = [UIColor whiteColor];
    
    [self.view addSubview:titleLabel];
}


-(void)addButten
{

    UIButton * addBtn =  [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 65, self.view.frame.size.height - 120,  48, 48)];
    [addBtn setImage:[UIImage imageNamed:@"blue.png"] forState:UIControlStateNormal];
    
    
    UILabel * tagTitle = [[UILabel alloc]initWithFrame:CGRectMake(-13, 40, 80, 35)];
    tagTitle.text = @"增加一行";
    tagTitle.textColor = [UIColor colorWithRed:0/255.0 green:122/255.0 blue:252/255.0 alpha:1];
    [addBtn addSubview:tagTitle];
    [addBtn addTarget:self action:@selector(addRow:) forControlEvents:UIControlEventTouchUpInside];
    
    self.addBtn = addBtn;
    [self.view addSubview:addBtn];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [self.addBtn addGestureRecognizer:pan];

}

-(void)addRow:(UIImageView* )add
{
    [UIView animateWithDuration:0.1 animations:^{
        
        add.layer.transform = CATransform3DMakeScale(1.3, 1.3, 0);
    }
    completion:^(BOOL finished)
     {
         [UIView animateWithDuration:0.1 animations:^{
         add.layer.transform = CATransform3DIdentity;
         add.alpha = 1;
         }];
         
     }];
    
    
    
    [self.noteArray addObject:@"新简记"];
    
    [self.sTable reloadData];

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

-(void)backBtn
{
    UIButton * backBn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [backBn  setFrame:CGRectMake(5, 30, 60, 30)];
    [backBn setTitle:@"取消" forState:UIControlStateNormal];
    backBn.tintColor = [UIColor whiteColor];
    backBn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [backBn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBn];
}


-(void)saveBtn
{
    
    UIButton * saveBn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [saveBn  setFrame:CGRectMake(self.view.frame.size.width - 65 , 30, 60, 30)];
    [saveBn setTitle:@"保存" forState:UIControlStateNormal];
    saveBn.tintColor = [UIColor whiteColor];
    saveBn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [saveBn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveBn];
    
}


-(void)cleateTable
{
    
    
    
    for (int i = 0; i<5; i++)
    {
        NSString * str = [NSString stringWithFormat:@"简记%d",i];
        [self.noteArray addObject:str];
    }

    
    UITableView * sTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    sTable.separatorColor = [UIColor colorWithRed:0/255.0 green:122/255.0 blue:252/255.0 alpha:1];
    sTable.delegate = self;
    sTable.dataSource = self;
    
    self.sTable = sTable;
    [self.sTable registerClass:[simpleCell class] forCellReuseIdentifier:@"simple"];
    [self.view addSubview:sTable];
    
}


-(void)back
{
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        
    }];
    
}



//保存数据
-(void)save:(id)sender
{
    [self.view endEditing:YES];
    self.addNote.title = self.noteArray[0];
    self.addNote.count = (int)([self.noteArray count] - 1);
    self.addNote.datas = self.noteArray;
    [self.addNote.datas removeObjectAtIndex:0];
//  数据库增加操作
    [self.addNote insertDatas:self.addNote];
    
    [self back];
}

#pragma mark UITextFiledDelegate
-(void)textFieldDidEndEditing:(UITextField *)textField{

    [self.noteArray replaceObjectAtIndex:textField.tag withObject:textField.text];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.noteArray count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    simpleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"simple" forIndexPath:indexPath];
    cell.textfiled.delegate = self;
    
    
    cell.selectedBackgroundView.backgroundColor = UITableViewCellSelectionStyleNone;
    
    if (indexPath.row == 0)
    {
        cell.textfiled.font = [UIFont boldSystemFontOfSize:25];
        cell.textfiled.placeholder = @"Tag";
    }
    else
    {
        cell.textfiled.font = [UIFont systemFontOfSize:18];
        cell.textfiled.placeholder = @"line";
    }
    cell.textfiled.tag = indexPath.row;
    return cell;
    
    
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {

        
        [self.noteArray removeObjectAtIndex:[indexPath row]];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
        
        //如果删除的是第一行，重新刷新格式，让第一列大字体
        if ([indexPath row] ==0)
        {
            [tableView reloadData];
        }
    }
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 ) {
        
        return 60;
    }
    return 40;
    
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
