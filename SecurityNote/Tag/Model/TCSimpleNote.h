//
//  TCSimpleNote.h
//  SecurityNote
//
//  Created by HTC on 14-9-22.
//  Copyright (c) 2014年 JoonSheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCSimpleNote : NSObject


@property (nonatomic, assign) int ids;

@property (nonatomic, assign) int count;

@property (nonatomic, strong)NSString *title;
@property (nonatomic, strong) NSMutableArray * datas;


-(NSMutableArray *)queryWithData;

-(void)upDateString:(NSString *)string forRowAtIndexPathRow:(NSInteger)row forRowAtIndexPathSection:(NSInteger)section;

-(void)insertDatas:(TCSimpleNote *)addNote;

-(void)deleteString:(TCSimpleNote *)deleteStr;

-(void)upDateInsert:(TCSimpleNote *)upDateInsert;

-(void)deleteAll:(TCSimpleNote*)TheNote;
@end