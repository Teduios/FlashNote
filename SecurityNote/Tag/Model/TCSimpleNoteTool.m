//
//  TCSimpleNoteTool.m
//  SecurityNote
//
//  Created by HTC on 14-9-22.
//  Copyright (c) 2014年 JoonSheng. All rights reserved.
//


#import "TCSimpleNoteTool.h"
#import "TCSimpleNote.h"
#import <sqlite3.h>
@implementation TCSimpleNoteTool

static sqlite3 *_db;

+ (void)initialize
{

    
}

+ (void)openDataBase{
    
    // 1.获得沙盒中的数据库文件名
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentFolderPath = [searchPaths objectAtIndex:0];
    
    //往应用程序路径中添加数据库文件名称，把它们拼接起来
    NSString *path  = [documentFolderPath stringByAppendingPathComponent:@"SecurityNote.sqlite"];
    
    //2. 创建NSFileManager对象  NSFileManager包含了文件属性的方法
    NSFileManager *fm = [NSFileManager defaultManager];
    
    //3. 通过 NSFileManager 对象 fm 来判断文件是否存在，存在 返回YES  不存在返回NO
    BOOL isExist = [fm fileExistsAtPath:path];
    //- (BOOL)fileExistsAtPath:(NSString *)path;
    
    //如果不存在 isExist = NO，拷贝工程里的数据库到Documents下
    if (!isExist)
    {
        //拷贝数据库
        
        //获取工程里，数据库的路径,因为我们已在工程中添加了数据库文件，所以我们要从工程里获取路径
        NSString *backupDbPath = [[NSBundle mainBundle]pathForResource:@"SecurityNote.sqlite" ofType:nil];
        
        //这一步实现数据库的添加，
        // 通过NSFileManager 对象的复制属性，把工程中数据库的路径拼接到应用程序的路径上
        [fm copyItemAtPath:backupDbPath toPath:path error:nil];
        
        
    }
    _db = NULL;
    int ret = sqlite3_open([path cStringUsingEncoding:NSUTF8StringEncoding], &_db);
    if (ret != SQLITE_OK) {
        NSLog(@"创建数据库文件失败:%s", sqlite3_errmsg(_db));
    }else{
        NSLog(@"success");
    }
    
    
    

}

//查询
+(NSMutableArray *)queryWithSql
{
    [self openDataBase];
    
    
    // 1.定义数组
    NSMutableArray *dictArray = nil;
    
        // 创建数组
        dictArray = [NSMutableArray array];
    
    const char *selectRecord = "select * from simplenote";
    sqlite3_stmt *stmt;
    
    int ret = sqlite3_prepare_v2(_db, selectRecord, -1, &stmt, NULL);
    if (ret == SQLITE_OK) {
        //查询成功; 循环取出相应记录的四个值
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            TCSimpleNote * datanote = [TCSimpleNote new];
            datanote.ids = sqlite3_column_int(stmt, 0);
            datanote.count = sqlite3_column_int(stmt, 1);
            datanote.title =[NSString stringWithUTF8String:(char*)sqlite3_column_text(stmt, 2)];
            
            NSMutableArray *a = [NSMutableArray array];
            for (int i = 0; i < datanote.count; i++) {
                [a addObject:[[NSString alloc] initWithCString:(char*)sqlite3_column_text(stmt, i+3) encoding:NSUTF8StringEncoding]];
                
            }
            datanote.datas = a;
            [dictArray addObject:datanote];
        }
        
    }
    //收尾工作:释放stmt内存+关闭数据库(断开连接close connection)
//    sqlite3_finalize(stmt);
//    sqlite3_close(_db);
    // 3.返回数据
  
    sqlite3_close(_db);
    
    NSLog(@"%@",dictArray);
    return dictArray;
}
//删除
+(void)deleteString:(TCSimpleNote *)deleteStr{
    
    [self openDataBase];
    
    char *error = NULL;
    NSArray *array = deleteStr.datas;
    NSLog(@"数组%@",array);
    
    NSString *deleteLastObj = [NSString stringWithFormat:@"update simplenote set count = %ld , tc%ld = null where ids = %d", deleteStr.datas.count ,deleteStr.datas.count + 1 ,deleteStr.ids];
    
    int ret1 = sqlite3_exec(_db, deleteLastObj.UTF8String, NULL, NULL, &error);
    if (ret1) {
        NSLog(@"%s",deleteLastObj.UTF8String);
        NSLog(@"%s",error);
    }

    
   
   for (int i = 1; i < deleteStr.datas.count + 1; i ++) {
     NSString *update = [NSString stringWithFormat:@"update simplenote set tc%d = '%@' where ids = %d",i,deleteStr.datas[i-1],deleteStr.ids];
     const char *selectRecord = update.UTF8String;
     int ret = sqlite3_exec(_db, selectRecord, NULL, NULL, &error);
       if (ret) {
           NSLog(@"1更新成功");
       }
   }
    
    
    sqlite3_close(_db);
}
+(void)deleteAll:(TCSimpleNote *)theNote{
    
    [self openDataBase];
    NSLog(@"删除全部");
    char *error = NULL;
    NSString *delete = [NSString stringWithFormat:@"delete from simplenote where ids = %d",theNote.ids];
    
    int ret = sqlite3_exec(_db, delete.UTF8String, NULL, NULL, &error);
    if (ret == SQLITE_OK) {
        NSLog(@"删除成功");
    }
    
    
    
    
    //先查询数据库有几组数据
    int counts = 0;
    const char* a = "select count(*) from simplenote";
    sqlite3_stmt *stmt;
    int ret2 = sqlite3_prepare_v2(_db, a, -1, &stmt, NULL);
    //sqlite3_column_int(stmt, 0)
    
    if (ret2 == SQLITE_OK){
        while (sqlite3_step(stmt) == SQLITE_ROW){
            
            counts = sqlite3_column_int(stmt, 0);
            
        }
    }
    
    //关闭stmt
    sqlite3_finalize(stmt);
    
    
    
    //重新排列ids顺序
    for (int i = 0; i < counts - theNote.ids ; i++)
    {
        //        [db executeUpdate:@"update simplenote set ids = ? where ids = ?", [NSNumber numberWithInt:(deleteStr.ids + i)],[NSNumber numberWithInt:(deleteStr.ids + i + 1)]];
        NSString *abc = [NSString stringWithFormat:@"update simplenote set ids = %d where ids = %d",theNote.ids + i,(theNote.ids + i + 1)];
        sqlite3_exec(_db, abc.UTF8String, NULL, NULL, &error);
        
    }
   
sqlite3_close(_db);
}

//增加数据
+(void)insertDatas:(TCSimpleNote *)addNote{
    [self openDataBase];
    //先查询数据库有几组数据
    int counts = 0;
    const char* a = "select count(*) from simplenote";
     sqlite3_stmt *stmt;
    int ret = sqlite3_prepare_v2(_db, a, -1, &stmt, NULL);
    //sqlite3_column_int(stmt, 0)
    
    if (ret == SQLITE_OK){
        while (sqlite3_step(stmt) == SQLITE_ROW){
            
            counts = sqlite3_column_int(stmt, 0);
            
        }
        
        
    }
    
    //关闭stmt
    sqlite3_finalize(stmt);
    
    //存储数据
    NSLog(@"增加数据");
    char *error = NULL;
    NSString *add = [NSString stringWithFormat:@"insert into simplenote(ids,count,title) values(%d,%d,'%@')",counts,addNote.count,addNote.title];
    int rets = sqlite3_exec(_db, add.UTF8String, NULL, NULL, &error);
    if (rets == SQLITE_OK) {
        
        NSLog(@"增加title成功");
    }
    NSLog(@"%ld",addNote.datas.count);
    
    
    for (int i = 1; i <= addNote.count; i ++) {
            NSString *ns = [NSString stringWithFormat:@"update simplenote set tc%d = '%@' where ids = %d",i,addNote.datas[i - 1],counts];
            sqlite3_exec(_db, ns.UTF8String, NULL, NULL, &error);
        
        }
    
        sqlite3_close(_db);
}


//更新
+ (void)upDateString:(NSString *)string forRowAtIndexPathRow:(NSInteger)row forRowAtIndexPathSection:(NSInteger)section
{
    [self openDataBase];
    
     NSString * upDate = [NSString stringWithFormat:@"update simplenote set tc%ld = '%@' WHERE ids = %ld;",row + 1,string,section];
    
    char *error = NULL;
    
   int ret  = sqlite3_exec(_db, upDate.UTF8String, NULL, NULL, &error);
    if (ret == SQLITE_OK) {
        NSLog(@"更新成功");
    }
    
   sqlite3_close(_db);
}
@end
