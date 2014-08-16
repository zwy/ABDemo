//
//  MenuProcessor.h
//  iMenu
//
//  Created by jisheng du on 12-1-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface MenuProcessor : NSObject
@property (nonatomic, retain) NSManagedObjectModel *menuManagedObjectModel;
@property (nonatomic, retain) NSManagedObjectContext *menuManagedObjectContext;
@property (nonatomic, retain) NSPersistentStoreCoordinator *menuPersistentStoreCoordinator;
@property (nonatomic, retain)  NSFetchedResultsController      *fetchedResultsController;
@property (nonatomic, retain) NSString *entityName;
@property (nonatomic, retain) NSString *sortName;
@property (nonatomic, assign) NSInteger currentPage;

- (NSManagedObjectContext *) menuManagedObjectContext;
- (NSFetchedResultsController *)fetchedResultsController:(NSPredicate *)filterPredicate limit:(NSInteger)limit;
- (NSFetchedResultsController *)ascendingfetchedResultsController:(NSPredicate *)filterPredicate limit:(NSInteger)limit;
- (id)getSpecificValueWithColumName:(NSString *)columName  andFunctionName:(NSString *)function attributeType:(NSAttributeType)attributeType filter:(NSPredicate *)filterPredicate;
@end
