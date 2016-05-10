//
//  simpleCell.m
//  SecurityNote
//
//  Created by xuyao on 16/4/18.
//  Copyright © 2016年 JoonSheng. All rights reserved.
//

#import "simpleCell.h"

@implementation simpleCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        CGRect labelRect = CGRectMake(100, 5.0, 50, 50);
        self.headlabel = [[UILabel alloc] init];
        self.headlabel.backgroundColor=[UIColor clearColor];
        [self addSubview:self.headlabel];
        
        CGRect labelRect2 = CGRectMake(20, 5.0, self.contentView.frame.size.width, self.contentView.frame.size.height);
        self.textfiled = [[UITextField alloc] initWithFrame:labelRect2];
        self.textfiled.backgroundColor=[UIColor clearColor];
//        self.textfiled.placeholder =@"在此输入";
        self.textfiled.clearButtonMode = UITextFieldViewModeAlways;
//        self.textfiled.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.textfiled];
    }
    
    
    return self;
    
}
@end
