//
//  AppDelegate.m
//  ABDemo
//
//  Created by Tony on 14-8-14.
//  Copyright (c) 2014年 zwy. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    //    初始化数据库 ###### 1
    MenuProcessor *menuProcessor1 = [[MenuProcessor alloc] init];
    self.menuProcessor = menuProcessor1;
    [self.menuProcessor menuManagedObjectContext];
    
    [self checkAddressBook];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    // 从后台进到前台 监测通讯录是否改变
//    if ([self hasUnsavedChanges]) {
//        NSLog(@"后台进前台 有改变");
//    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

+ (AppDelegate *)shareDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

// 监测是否授权
- (void)checkAddressBook
{
    self.addressBooks = nil;
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
    {
        self.addressBooks = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAddressBookRegisterExternalChangeCallback(self.addressBooks, ZWYAddressBookExternalChangeCallback, (__bridge void *)(self)); //use the context as a pointer to self
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressBookExternallyChanged:) name:AddressBookExternalChangeNotification object:nil];
        //等待同意后向下执行
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(self.addressBooks, ^(bool granted, CFErrorRef error)
                                                 {
                                                     dispatch_semaphore_signal(sema);
                                                 });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        
    }
}
// 监测通讯录有什么变化的回调方法
void ZWYAddressBookExternalChangeCallback (ABAddressBookRef addressBook, CFDictionaryRef info, void *context ){
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"监测通讯录有什么变化的回调方法");
        [[NSNotificationCenter defaultCenter] postNotificationName:AddressBookExternalChangeNotification object:nil];
    });
}
// revert 通讯录 把还没有保存的内部的缓存之类的清楚
-(void)revertAddressBook
{
    ABAddressBookRevert(self.addressBooks);
}
//监测通讯录是否改变
-(BOOL)hasUnsavedChanges
{
    BOOL result;
    if (self.addressBooks) {
        result = ABAddressBookHasUnsavedChanges(self.addressBooks);
    }
    return result;
}
-(void)addressBookExternallyChanged:(NSNotification*)notification{
    //notification on external changes. (revert if no local changes so always up-to-date)
    if (![self hasUnsavedChanges]){
        [self revertAddressBook];
    } else {
        NSLog(@"Not auto-reverting on notification of external address book changes as we have unsaved local changes.");
    }
    
}
#pragma mark - cleanup TODO
-(void)dealloc {
    //do stuff (even though we are a singleton)
    [self deregisterForAddressBookChanges];
    
    if (self.addressBooks) { CFRelease(self.addressBooks); self.addressBooks = NULL; }
    
}
-(void)deregisterForAddressBookChanges{
    if (self.addressBooks){
        ABAddressBookUnregisterExternalChangeCallback(self.addressBooks,  ZWYAddressBookExternalChangeCallback, (__bridge void *)(self));
    }
    
}


#pragma mark - 数据库操作 ###### 4 实现相关数据库的方法

//获取表中数据
-(NSArray *)getEntireFromEntityWithLimt:(NSInteger)limit Name:(NSString *)entityName withSortName:(NSString *)sortName filterPredicate:(NSPredicate *)filterPredicate
{
    NSArray * List  = nil;
    if (!List) {
        MenuProcessor *processor = self.menuProcessor;//获取左侧大分类列表
        //        [processor menuManagedObjectContext]; //执行一下此语句，确保model
        processor.entityName = entityName;
        processor.sortName = sortName;
        processor.currentPage = 0;
        NSFetchedResultsController *fetch = [processor fetchedResultsController:filterPredicate limit:limit];
        NSError *error = nil;
        [fetch performFetch:&error];
        List = fetch.fetchedObjects;
    }
    return List;
}

//获取表中数据
-(NSArray *)getEntireFromEntityWithLimt:(NSInteger)limit Name:(NSString *)entityName withSortName:(NSString *)sortName filterPredicate:(NSPredicate *)filterPredicate page:(NSInteger)currentPage
{
    NSArray * List  = nil;
    if (!List) {
        MenuProcessor *processor = self.menuProcessor;//获取左侧大分类列表
        //        [processor menuManagedObjectContext]; //执行一下此语句，确保model
        processor.entityName = entityName;
        processor.sortName = sortName;
        processor.currentPage = currentPage;
        NSFetchedResultsController *fetch = [processor fetchedResultsController:filterPredicate limit:limit];
        NSError *error = nil;
        [fetch performFetch:&error];
        List = fetch.fetchedObjects;
    }
    return List;
}
//清除数据库数据
-(void)clearEntireTableFromEntityName:(NSString *)entityName withSortName:(NSString *)sortName filterPredicate:(NSPredicate *)filterPredicate
{
    NSArray * List  = nil;
    if (!List) {
        MenuProcessor *processor = self.menuProcessor;//获取左侧大分类列表
        //        [processor menuManagedObjectContext]; //执行一下此语句，确保model
        processor.entityName = entityName;
        processor.sortName = sortName;
        NSFetchedResultsController *fetch = [processor fetchedResultsController:filterPredicate limit:0];
        NSError *error = nil;
        [fetch performFetch:&error];
        List = fetch.fetchedObjects;
        for (id object in List) {
            [self.menuProcessor.menuManagedObjectContext deleteObject:object];
        }
        [self.menuProcessor.menuManagedObjectContext save:nil];
    }
    NSError *error;
    if (![self.menuProcessor.menuManagedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

-(NSArray *)ascendinggetEntireFromEntityWithLimt:(NSInteger)limit Name:(NSString *)entityName withSortName:(NSString *)sortName filterPredicate:(NSPredicate *)filterPredicate page:(NSInteger)currentPage
{
    NSArray * List  = nil;
    if (!List) {
        MenuProcessor *processor = self.menuProcessor;//获取左侧大分类列表
        //        [processor menuManagedObjectContext]; //执行一下此语句，确保model
        processor.entityName = entityName;
        processor.sortName = sortName;
        processor.currentPage = currentPage;
        NSFetchedResultsController *fetch = [processor ascendingfetchedResultsController:filterPredicate limit:limit];
        NSError *error = nil;
        [fetch performFetch:&error];
        List = fetch.fetchedObjects;
    }
    return List;
}

- (id)getSpecificValueWithEntityName:(NSString *)entityName ColumName:(NSString *)columName  andFunctionName:(NSString *)function attributeType:(NSAttributeType)attributeType filter:(NSPredicate *)filterPredicate
{
    MenuProcessor *processor = self.menuProcessor;
    //        [processor menuManagedObjectContext]; //执行一下此语句，确保model
    processor.entityName = entityName;
    processor.sortName = columName;
    return  [processor getSpecificValueWithColumName:columName andFunctionName:function attributeType:attributeType  filter:filterPredicate];
}


#pragma mark - 插入数据库表
- (void)insertDataList:(NSArray *)dataList toEntity:(NSString *)entityName saveSyncsizeTimeStamp:(BOOL)saveSyncTimeStamp
{
    [dataList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([NSStringFromClass([Address_Book class]) isEqualToString:entityName]) {
            NSString *imtId = [PublicClassMethod changeObject:[obj objectForKey:@"table_Id"]];
            NSArray *filtereds = [self getEntireFromEntityWithLimt:0 Name:entityName withSortName:@"table_Id" filterPredicate:[NSPredicate predicateWithFormat:@"table_Id = %@", imtId]];
            Address_Book *addressBook = nil;
            if (filtereds == nil || [filtereds count] == 0) {
                addressBook = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.menuProcessor.menuManagedObjectContext];
            }
            else {
                addressBook = [filtereds objectAtIndex:0];
            }
            addressBook.table_Id = imtId;
            addressBook.name = [PublicClassMethod changeObject:[obj objectForKey:@"name"]];
            addressBook.telephone = [PublicClassMethod changeObject:[obj objectForKey:@"telephone"]];
            addressBook.pinyin = [PublicClassMethod changeObject:[obj objectForKey:@"pinyin"]];

            addressBook.created_Stamp = [PublicClassMethod changeObject:[obj objectForKey:@"createdStamp"]];
            addressBook.last_Updated_Stamp = [PublicClassMethod changeObject:[obj objectForKey:@"lastUpdatedStamp"]];
        }
        
            }];
    [self coreDataSave];
}

- (void)coreDataSave
{
    NSError *error;
    if (![self.menuProcessor.menuManagedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

//插入到具体对象下
- (void)insertDataList:(NSArray *)dataList toEntity:(NSString *)entityName toObject:(id)toObject saveSyncsizeTimeStamp:(BOOL)saveSyncTimeStamp
{
    
//    if ([NSStringFromClass([Listen_File class]) isEqualToString:entityName])
//    {
//        [dataList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            Listen_File *insertObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.menuProcessor.menuManagedObjectContext];
//            insertObject.attach_File_Type = [TTPublicClassMethod changeObject:[obj objectForKey:@"attachFileType"]];
//            insertObject.file_Type = [TTPublicClassMethod changeObject:[obj objectForKey:@"fileType"]];
//            insertObject.file_URL = [TTPublicClassMethod changeObject:[obj objectForKey:@"fileUrl"]];
//            insertObject.is_Active = [TTPublicClassMethod changeObject:[obj objectForKey:@"isActive"]];
//            insertObject.sequence = [TTPublicClassMethod changeObject:[obj objectForKey:@"sequence"]];
//            insertObject.play_Second = [TTPublicClassMethod changeObject:[obj objectForKey:@"playSecond"]];
//            if (insertObject.file_URL) {
//                NSString *path = [TTPublicClassMethod picturePath];
//                if (insertObject.attach_File_Type) {
//                    if ([insertObject.attach_File_Type isEqualToString:FILE_TYPE_PUBLIC]) {
//                        path = [path stringByAppendingPathComponent:FILE_TYPE_PUBLIC];
//                    }
//                    else if ([insertObject.attach_File_Type isEqualToString:FILE_TYPE_TOPIC_ICON]) {
//                        path = [path stringByAppendingPathComponent:FILE_TYPE_TOPIC_ICON];
//                    }else if ([insertObject.attach_File_Type isEqualToString:FILE_TYPE_TOPIC_BANNER]) {
//                        path = [path stringByAppendingPathComponent:FILE_TYPE_TOPIC_BANNER];
//                    }else if ([insertObject.attach_File_Type isEqualToString:FILE_TYPE_ALBUM_BREVIARY]) {
//                        path = [path stringByAppendingPathComponent:FILE_TYPE_ALBUM_BREVIARY];
//                    }else if ([insertObject.attach_File_Type isEqualToString:FILE_TYPE_ALBUM_COVER]) {
//                        path = [path stringByAppendingPathComponent:FILE_TYPE_ALBUM_COVER];
//                    }else if ([insertObject.attach_File_Type isEqualToString:FILE_TYPE_ALBUM_BANNER]) {
//                        path = [path stringByAppendingPathComponent:FILE_TYPE_ALBUM_BANNER];
//                    }else if ([insertObject.attach_File_Type isEqualToString:FILE_TYPE_STORY_BANNER]) {
//                        path = [path stringByAppendingPathComponent:FILE_TYPE_STORY_BANNER];
//                    }else if ([insertObject.attach_File_Type isEqualToString:FILE_TYPE_STORY_URL]) {
//                        path = [path stringByAppendingPathComponent:FILE_TYPE_STORY_URL];
//                    }
//                }
//                insertObject.pic_Local_Filename1 = [path stringByAppendingPathComponent:[insertObject.file_URL lastPathComponent]];
//            }
//            if (toObject) {
//                [toObject addFilesObject:insertObject];
//            }
            
//        }];
//    }
    [self coreDataSave];
}

@end
