//
//  AppDelegate.h
//  ABDemo
//
//  Created by Tony on 14-8-14.
//  Copyright (c) 2014年 zwy. All rights reserved.
//

#import <UIKit/UIKit.h>
//###### 2引入头文件
#import "MenuProcessor.h"
#import "Address_Book.h"

#import "PublicClassMethod.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (retain, nonatomic) MenuProcessor *menuProcessor;
@property (nonatomic, assign)ABAddressBookRef addressBooks;

+ (AppDelegate *)shareDelegate;
#pragma mark - coredata 相关操作 ###### 3相关数据库的方法
//获取表中数据
-(NSArray *)getEntireFromEntityWithLimt:(NSInteger)limit Name:(NSString *)entityName withSortName:(NSString *)sortName filterPredicate:(NSPredicate *)filterPredicate;
-(NSArray *)ascendinggetEntireFromEntityWithLimt:(NSInteger)limit Name:(NSString *)entityName withSortName:(NSString *)sortName filterPredicate:(NSPredicate *)filterPredicate page:(NSInteger)currentPage;
-(void)clearEntireTableFromEntityName:(NSString *)entityName withSortName:(NSString *)sortName filterPredicate:(NSPredicate *)filterPredicate;
//获取表中数据
-(NSArray *)getEntireFromEntityWithLimt:(NSInteger)limit Name:(NSString *)entityName withSortName:(NSString *)sortName filterPredicate:(NSPredicate *)filterPredicate page:(NSInteger)currentPage;
- (id)getSpecificValueWithEntityName:(NSString *)entityName ColumName:(NSString *)columName  andFunctionName:(NSString *)function attributeType:(NSAttributeType)attributeType filter:(NSPredicate *)filterPredicate;

- (void)insertDataList:(NSArray *)dataList toEntity:(NSString *)entityName saveSyncsizeTimeStamp:(BOOL)saveSyncTimeStamp;
- (void)insertDataList:(NSArray *)dataList toEntity:(NSString *)entityName toObject:(id)toObject saveSyncsizeTimeStamp:(BOOL)saveSyncTimeStamp;
- (void)coreDataSave;

#pragma mark - 
// revert 通讯录 把还没有保存的内部的缓存之类的清楚
-(void)revertAddressBook;
//监测通讯录是否改变
-(BOOL)hasUnsavedChanges;
@end
