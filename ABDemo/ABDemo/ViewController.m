//
//  ViewController.m
//  ABDemo
//
//  Created by Tony on 14-8-14.
//  Copyright (c) 2014年 zwy. All rights reserved.
//

#import "ViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "pinyin.h"

#import "AppDelegate.h"
#import "MBProgressHUD.h"

#define SearchBarRect1 CGRectMake(0, -45, kScreenWidth, 45)
#define SearchBarRect2 CGRectMake(0, 20, kScreenWidth, 45)
@interface ViewController ()
@property (nonatomic, assign)ABAddressBookRef addressBooks;
@property (nonatomic, retain)NSMutableArray *personalArray;// 联系人列表

@property (nonatomic, retain)MBProgressHUD *HUD;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"通讯录";
    [self createAddressBook];
    
    [self createTableView];
    [self creatNav];
    [self createSearchBar];
//    [self insertMuchPerson];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)creatNav
{
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add)];
    UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(search)];
    UIBarButtonItem *delete = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(delete)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:search,add,delete, nil];
    
    self.navigationController.navigationBar.barTintColor = [UIColor yellowColor];
    

}

- (void)delete
{
    NSLog(@"delete");
    [self deleteAddressBook];
}

- (void)add
{
    NSLog(@"add");
    [self insertMuchPerson];
}

- (void)search
{
    NSLog(@"search");
    _searchBar.frame = SearchBarRect2;
    [_searchBar becomeFirstResponder];
}

- (void)createSearchBar
{
    _searchBar = [[UISearchBar alloc] initWithFrame:SearchBarRect1];
    _searchBar.placeholder = @"搜索成员";
    _searchBar.barTintColor = [UIColor yellowColor];
    _searchBar.delegate = self;
    _searchController =
    [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    
    //为搜索控制器里的tableView设置数据源和代理
    _searchController.delegate = self;
    _searchController.searchResultsDataSource = self;
    _searchController.searchResultsDelegate = self;
    
    [self.navigationController.view addSubview:_searchBar];
}
#pragma mark - UISearchBarDelegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    _searchBar.frame = SearchBarRect1;
    [searchBar resignFirstResponder];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    return YES;
}

#pragma mark - UISearchDisplayController delegate methods
- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText {
}

- (void)searchDisplayController:(UISearchDisplayController *)controller
  didShowSearchResultsTableView:(UITableView *)tableView {
    NSLog(@"table from is %@", NSStringFromCGRect(tableView.frame));
}

#pragma mark - tableView
- (void)createTableView
{
    _tableView = [[UITableView alloc]
                  initWithFrame:CGRectMake(0, 0, kScreenWidth,kScreenHeight)
                  style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
//    _tableView.editing = YES;
    [self getDataSoure];
    [self.view addSubview:_tableView];
}
- (void)getDataSoure
{
    // TODO 获取要显示的信息
    self.personalArray = (NSMutableArray *)[[AppDelegate shareDelegate] getEntireFromEntityWithLimt:0 Name:NSStringFromClass([Address_Book class]) withSortName:@"table_Id" filterPredicate:nil];
}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.personalArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = @"cellId";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:cellId];
    }
    Address_Book *addressBook = [self.personalArray objectAtIndex:indexPath.row];
    cell.textLabel.text = addressBook.name;
    cell.detailTextLabel.text = addressBook.telephone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self changeAddressBookWithIndex:indexPath.row];
    
//    [self deleteAddressBook];
//    if (indexPath.row%2 == 1) {
//        [self deleteAddressBook];
//    }
//    else
//    {
//        [self insertMuchPerson];
//    }
    
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{

        return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"delete");
    }
}

#pragma mark - 通讯录
// creat 跟通讯录相关的操作
- (void)createAddressBook
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressBookChanged:) name:AddressBookExternalChangeNotification object:nil];
    // Create addressbook data model
    _addressBooks = [AppDelegate shareDelegate].addressBooks;
    
    if (ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusAuthorized) {
        NSLog(@"没有通讯录授权");
        [self alertWithTitle:@"读取通讯录失败！"
                         msg:@"读取通讯录失败，请到 " @"设置->隐私->"
         @"通讯录，中开启常联系访问通讯录功能"];
        
    }
    else if (_addressBooks==nil) {
        NSLog(@"没有通讯录");
    }
    else
    {
        //获取本地数据库中的通讯录信息
        NSArray *myIphoneContactList = [self coreDateAddressbookArray];//[[AppDelegate shareDelegate] getEntireFromEntityWithLimt:0 Name:NSStringFromClass([Address_Book class]) withSortName:@"table_Id" filterPredicate:nil];
        if ([myIphoneContactList count] > 0) {
            // 本地数据库有通讯录的数据 则与通讯录里的数据进行对比
            NSMutableArray *iphoneContactList = [self locaAddressBookArray];
            
            //对比得出 要上传的数组
            BOOL isUpLoad = [self isUpLoadingAddressBookWithNewArray:iphoneContactList oldArray:myIphoneContactList];
            
            if (isUpLoad) {
                NSLog(@"上传");
                [self upLodaAddressBookWithAddressBookArray:iphoneContactList];
            }
            else
            {
                NSLog(@"不上传");
            }
            // 得到要上传服务器的数据 上传
            
        }
        else
        {
            // 数据库没有数据  则把通讯录里的全部插入数据库
            NSMutableArray *iphoneContactList = [self locaAddressBookArray];
            if (iphoneContactList) {
                [[AppDelegate shareDelegate] insertDataList:iphoneContactList toEntity:NSStringFromClass([Address_Book class]) saveSyncsizeTimeStamp:NO];
            }
            
            // 得到要上传服务器的数据 上传
        }
    }
}

//获取数据库里存储的通讯录的数据
- (NSArray *)coreDateAddressbookArray
{
    NSArray *myIphoneContactList = [[AppDelegate shareDelegate] getEntireFromEntityWithLimt:0 Name:NSStringFromClass([Address_Book class]) withSortName:@"table_Id" filterPredicate:nil];
    return myIphoneContactList;
}
// 获取 通讯录的数据
- (NSMutableArray *)locaAddressBookArray
{
    NSLog(@"读取通讯录");
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(_addressBooks);
    CFIndex nPeople = ABAddressBookGetPersonCount(_addressBooks);
    
    NSMutableArray *iphoneContactList = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (NSInteger  i = 0; i < nPeople; i++)
    {
        
        ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);//取出某一个人的信息
        NSInteger lookupforkey =(NSInteger)ABRecordGetRecordID(person);//读取通讯录中联系人的唯一标识
        NSString *contactName = @"";
        //读取联系人姓名属性
        if (ABRecordCopyValue(person, kABPersonLastNameProperty)&&(ABRecordCopyValue(person, kABPersonFirstNameProperty))== nil) {
            contactName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
        }else if (ABRecordCopyValue(person, kABPersonLastNameProperty) == nil&&(ABRecordCopyValue(person, kABPersonFirstNameProperty))){
            contactName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        }else if (ABRecordCopyValue(person, kABPersonLastNameProperty)&&(ABRecordCopyValue(person, kABPersonFirstNameProperty))){
            
            NSString *first =(__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
            NSString *last = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
            contactName = [NSString stringWithFormat:@"%@%@",last,first];
        }
        
        //读取联系人姓名的第一个汉语拼音，用于排序，调用此方法需要在程序中加载pingyin.h pingyin.c,如有需要请给我联系。
        // 这儿的判断很可能会出错 姓名里很可能有一些不知名的符号 请注意
//        NSString *pinyin =[[NSString stringWithFormat:@"%c",pinyinFirstLetter([contactName characterAtIndex:0])] uppercaseString];
        
        
        //读取电话信息，和emial类似，也分为工作电话，家庭电话，工作传真，家庭传真。。。。
        NSString *phoneStr = @"";
        
        ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
        
        if ((phone != nil)&&ABMultiValueGetCount(phone)>0) {
            
            for (int m = 0; m < ABMultiValueGetCount(phone); m++) {
                NSString * aPhone = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phone, m) ;
                //                    NSString * aLabel = (__bridge NSString *)ABMultiValueCopyLabelAtIndex(phone, m);
                // TODO 去除空格啊 之类的
                
                if ([aPhone hasPrefix:@"+86"]) {
                    NSRange range = [aPhone rangeOfString:@"+86"];
                    if (range.location != NSNotFound) {
                        aPhone = [aPhone substringFromIndex:range.length];
                    }
                    
                }
                aPhone = [aPhone stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                aPhone = [aPhone stringByReplacingOccurrencesOfString:@"-" withString:@""];
                
//                NSString * MOBILE = @"^1(3[0-9]*|5[0-9]*|8[0-9]*)";
//                //                     NSString * MOBILE = @"^1*";
//                NSPredicate * regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",MOBILE];
//                if([regextestmobile evaluateWithObject:phone] == NO){
//                    continue;
//                }
                
                
                if (aPhone.length > 0) {
                    phoneStr = aPhone;
                }
                
            }
        }
        
        //
        NSDate * createDate = (__bridge NSDate *)ABRecordCopyValue(person, kABPersonCreationDateProperty);// 读取通讯录中联系人的创建日期
        NSDate * lastUpdateDate = (__bridge NSDate *)ABRecordCopyValue(person, kABPersonModificationDateProperty);// 读取通讯录中联系人的最后修改日期
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:0];
        [dic setObject:[NSString stringWithFormat:@"%ld",(long)lookupforkey] forKey:@"table_Id"];
        [dic setObject:contactName forKey:@"name"];
        [dic setObject:phoneStr forKey:@"telephone"];
//        [dic setObject:pinyin forKey:@"pinyin"];
        [dic setObject:createDate forKey:@"createdStamp"];
        [dic setObject:lastUpdateDate forKey:@"lastUpdatedStamp"];
        [iphoneContactList addObject:dic];
    }
    
    CFRelease(allPeople);
//    CFRelease(_addressBooks);
    
    NSLog(@"读取通讯录完毕");
    return iphoneContactList;
    
}
//通讯录 和数据库里的对比 是否需要上传 aNewArray:从通讯录获取的数组 aOldArray：数据库存的数组
- (BOOL)isUpLoadingAddressBookWithNewArray:(NSArray *)aNewArray oldArray:(NSArray *)aOldArray
{
    
    // 得到要删除的数组 那些在就的
    NSMutableArray *newArrayId = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSDictionary *dic in aNewArray) {
        [newArrayId addObject:[dic objectForKey:@"table_Id"]];
    }
    NSArray *hasOldArray = [aOldArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"table_Id IN %@ ",newArrayId]];
//    [newArrayId removeObjectsInArray:deleteOldArray];
    NSLog(@"开始检测");
    BOOL isUpLoad = NO;
    if ([aNewArray count] != [aOldArray count]) {
        isUpLoad = YES;
    }
    else
    {
        for (NSDictionary *dic in aNewArray) {
            NSString *tableId = [dic objectForKey:@"table_Id"];
            NSDate *lastUpdate = [dic objectForKey:@"lastUpdatedStamp"];
            
            NSArray *oldAddressBook = [hasOldArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"table_Id = %@ AND last_Updated_Stamp != %@",tableId,lastUpdate]];
            if ([oldAddressBook count] > 0) {
//                Address_Book *addressBook = [oldAddressBook objectAtIndex:0];
//                NSDate *oldLastUpdate = addressBook.last_Updated_Stamp;
//                if (lastUpdate && oldLastUpdate && [lastUpdate isEqualToDate:oldLastUpdate]) {
//                    isUpLoad = NO;
//                }
//                else
//                {
//                    isUpLoad = YES;
//                    break;
//                }
                isUpLoad = YES;
                break;
            }
            else
            {
                isUpLoad = YES;
                break;
            }
        }
    }
    NSLog(@"检测完毕");
    return isUpLoad;
}

// TODO 通讯录 和数据库里的对比  得出想要的数组


// 通讯录有了变化之后 AddressBookArray:本地通讯录的数组
- (void)upLodaAddressBookWithAddressBookArray:(NSArray *)aArray
{
    // TODO 得到上传的数组
    
    
    
    //插入本地数据库 ######注意本地删除的数组在本地数据库里是要删除的
    // 得到要更新的数组 和要删除的
    // TODO
    NSLog(@"开始更新本地通讯录的数据");
    // 逻辑是先删掉本地数据库里的 在的到没有变化的以此得到有变化的
    [self locaAddressBookDeleteArrayWithNewArray:aArray];
    [self locaAddressBookUpdateArrayWithNewArray:aArray];
    NSLog(@"结束更新本地通讯录的数据");
}
//aNewArray:从通讯录获取的数组 aOldArray：数据库存的数组
- (void)locaAddressBookDeleteArrayWithNewArray:(NSArray *)aNewArray
{
    NSLog(@"开始删除本地通讯录的数据");
    //获取本地数据库中的通讯录信息
    NSArray *aOldArray = [self coreDateAddressbookArray];
    // 要删除的数组
    NSMutableArray *deleteArray = [[NSMutableArray alloc] initWithArray:aOldArray];
    
    // 得到要删除的数组 那些在就的
    NSMutableArray *newArrayId = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSDictionary *dic in aNewArray) {
        [newArrayId addObject:[dic objectForKey:@"table_Id"]];
    }
    NSArray *hasOldArray = [aOldArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"table_Id IN %@ ",newArrayId]];
    // 去掉有的数组 得到被删除的数组
    [deleteArray removeObjectsInArray:hasOldArray];
    if ([deleteArray count] > 0) {
        for (Address_Book * addressBook in deleteArray) {
            [[AppDelegate shareDelegate].menuProcessor.menuManagedObjectContext deleteObject:addressBook];
        }
        [[AppDelegate shareDelegate] coreDataSave];
    }
    NSLog(@"结束删除本地通讯录的数据");
}
//aNewArray:从通讯录获取的数组 aOldArray：数据库存的数组
- (void)locaAddressBookUpdateArrayWithNewArray:(NSArray *)aNewArray
{
    NSLog(@"开始修改或插入本地通讯录的数据");
    //获取本地数据库中的通讯录信息
    NSArray *aOldArray = [self coreDateAddressbookArray];
    
    // 对比得到没有变化过的数组
    NSMutableArray *noChangeArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (Address_Book *addressBook in aOldArray) {
        NSArray *noChangeObjectArray = [aNewArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"table_Id = %@ AND lastUpdatedStamp = %@",addressBook.table_Id,addressBook.last_Updated_Stamp]];
        if ([noChangeObjectArray count]>0) {
            [noChangeArray addObject:noChangeObjectArray];
        }
    }
    // 要更新的数组
    NSMutableArray *updateArray = [[NSMutableArray alloc] initWithArray:aNewArray];
    if ([noChangeArray count] > 0) {
        [updateArray removeObjectsInArray:noChangeArray];
    }
    
    // 本地数据库 插入 更新数组
    [[AppDelegate shareDelegate] insertDataList:updateArray toEntity:NSStringFromClass([Address_Book class]) saveSyncsizeTimeStamp:NO];
    NSLog(@"结束修改或插入本地通讯录的数据");
}


// 改变一条数据 写通讯录操作
- (void)changeAddressBookWithIndex:(NSInteger)index
{
    Address_Book *addressBook = [self.personalArray objectAtIndex:index];
    NSInteger recordID = [addressBook.table_Id integerValue];
    ABRecordRef record = ABAddressBookGetPersonWithRecordID(self.addressBooks, recordID);
    // 电话号码数组
    long long phoneInt = [addressBook.telephone longLongValue] + 1;
    
    NSArray *phones = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%lld",phoneInt],nil];
    // 电话号码对应的名称
    NSArray *labels = [NSArray arrayWithObjects:@"iphone",nil];
    // ABMultiValueRef类似是Objective-C中的NSMutableDictionary
    ABMultiValueRef mv =ABMultiValueCreateMutable(kABMultiStringPropertyType);
    // 添加电话号码与其对应的名称内容
    for (int i = 0; i < [phones count]; i ++) {
        ABMultiValueIdentifier mi = ABMultiValueAddValueAndLabel(mv,(__bridge CFStringRef)[phones objectAtIndex:i], (__bridge CFStringRef)[labels objectAtIndex:i], &mi);
    }
    // 设置phone属性
    ABRecordSetValue(record, kABPersonPhoneProperty, mv, NULL);
    // 释放该数组
    if (mv) {
        CFRelease(mv);
    }
    // 保存修改的通讯录对象
    ABAddressBookSave(self.addressBooks, NULL);
    [[NSNotificationCenter defaultCenter] postNotificationName:AddressBookExternalChangeNotification object:nil];
}

// test 插入1000条数据测试一下
- (void)insertMuchPerson
{
    if (self.HUD == nil) {
        self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:self.HUD];
    }
    
    self.HUD.labelText = @"请稍等";
    [self.HUD  show:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"开始插入");
        
        
        for (int i = 0; i < 10; i++) {
            ABRecordRef person = ABPersonCreate();
            NSString *firstName = [NSString stringWithFormat:@"%d",i];
            NSString *lastName = @"李";
            // 电话号码数组
            long long phoneNumber = 15100000000 + i;
            
            NSArray *phones = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%lld",phoneNumber],nil];
            // 电话号码对应的名称
            NSArray *labels = [NSArray arrayWithObjects:@"iphone",nil];
            // 保存到联系人对象中，每个属性都对应一个宏，例如：kABPersonFirstNam
            // 设置firstName属性
            ABRecordSetValue(person, kABPersonFirstNameProperty,(__bridge CFStringRef)firstName, NULL);
            // 设置lastName属性
            ABRecordSetValue(person, kABPersonLastNameProperty, (__bridge CFStringRef)lastName, NULL);
            // ABMultiValueRef类似是Objective-C中的NSMutableDictionary
            ABMultiValueRef mv =ABMultiValueCreateMutable(kABMultiStringPropertyType);
            // 添加电话号码与其对应的名称内容
            for (int i = 0; i < [phones count]; i ++) {
                ABMultiValueIdentifier mi = ABMultiValueAddValueAndLabel(mv,(__bridge CFStringRef)[phones objectAtIndex:i], (__bridge CFStringRef)[labels objectAtIndex:i], &mi);
            }
            // 设置phone属性
            ABRecordSetValue(person, kABPersonPhoneProperty, mv, NULL);
            // 释放该数组
            if (mv) {
                CFRelease(mv);
            }
            // 将新建的联系人添加到通讯录中
            ABAddressBookAddRecord(self.addressBooks, person, NULL);
            
        }
        // 保存通讯录数据
        ABAddressBookSave(self.addressBooks, NULL);
        NSLog(@"结束插入");
        //    [[NSNotificationCenter defaultCenter] postNotificationName:AddressBookExternalChangeNotification object:nil];
//        [self addressBookChanged:nil];
        [self.HUD hide:NO];
    });
    
}

// test 删除通讯录
- (void)deleteAddressBook
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // 获取通讯录中所有的联系人
        NSLog(@"开始删除");
        NSArray *array = (__bridge NSArray*)ABAddressBookCopyArrayOfAllPeople(self.addressBooks);
        // 遍历所有的联系人并删除(这里只删除姓名为张三的)
        for (id obj in array) {
            ABRecordRef people = (__bridge ABRecordRef)obj;
            
            //        NSString *lastName = (__bridge NSString*)ABRecordCopyValue(people, kABPersonLastNameProperty);
            //        if ([lastName isEqualToString:@"李"]) {
            ABAddressBookRemoveRecord(self.addressBooks, people,NULL);
            //        }
        }
        // 保存修改的通讯录对象
        ABAddressBookSave(self.addressBooks, NULL);
        NSLog(@"结束删除");
//        [self addressBookChanged:nil];
        // 不知道为什么删除之后没有检测到变化
        [[NSNotificationCenter defaultCenter] postNotificationName:AddressBookExternalChangeNotification object:nil];
    });
    
}
#pragma mark - 通知
-(void)addressBookChanged:(NSNotification*)notification{
    NSLog(@"通知 有变化");
    // TODO 检测有什么通讯录的变变化
//    [[AppDelegate shareDelegate] revertAddressBook];
    
    NSArray *cantactArray = [self locaAddressBookArray];
    [self upLodaAddressBookWithAddressBookArray:cantactArray];
    [self getDataSoure];
    [self.tableView reloadData];
}

#pragma mark - AlertView
- (void) alertWithTitle:(NSString *)title msg:(NSString *)msg {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"确定", nil];
    alert.tag = 10000;
    [alert show];
}
@end
