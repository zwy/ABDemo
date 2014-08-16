//
//  Address_Book.h
//  ABDemo
//
//  Created by Tony on 14-8-14.
//  Copyright (c) 2014年 zwy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Address_Book : NSManagedObject

@property (nonatomic, retain) NSString * table_Id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * telephone;
@property (nonatomic, retain) NSString * pinyin;
@property (nonatomic, retain) NSDate * created_Stamp;
@property (nonatomic, retain) NSDate * last_Updated_Stamp;

@end
