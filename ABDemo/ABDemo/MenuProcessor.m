//
//  MenuProcessor.m
//  iMenu
//
//  Created by jisheng du on 12-1-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MenuProcessor.h"

@implementation MenuProcessor
@synthesize menuManagedObjectModel = _menuManagedObjectModel;
@synthesize menuManagedObjectContext = _menuManagedObjectContext;
@synthesize menuPersistentStoreCoordinator = _menuPersistentStoreCoordinator;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize entityName = _entityName;
@synthesize sortName = _sortName;

- (id)init {
	if (self = [super init]) {
        [self menuManagedObjectContext];
	}
	return self;
}

- (NSManagedObjectModel *) menuManagedObjectModel {
    if (_menuManagedObjectModel != nil) {
        return _menuManagedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _menuManagedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];      
    return _menuManagedObjectModel;
}

- (NSPersistentStoreCoordinator *)menuPersistentStoreCoordinator {
	
    if (_menuPersistentStoreCoordinator != nil) {
        return _menuPersistentStoreCoordinator;
    }
	
    NSURL *cacheDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    NSURL *storeURL = [cacheDirectory URLByAppendingPathComponent:@"Model.sqlite"];
    NSDictionary *optionsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    NSError *error = nil;
    _menuPersistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self menuManagedObjectModel]];
    if (![_menuPersistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:optionsDictionary error:&error])
    {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
        
    }    
    
    return _menuPersistentStoreCoordinator;
    
}

- (NSManagedObjectContext *) menuManagedObjectContext {
	
    if (_menuManagedObjectContext != nil) {
        return _menuManagedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self menuPersistentStoreCoordinator];
    if (coordinator != nil) {
        _menuManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_menuManagedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return _menuManagedObjectContext;
}


//- (NSFetchedResultsController *)fetchedResultsController {
//    
//    if (!_entityName||!_sortName) {
//        return nil;
//    }
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    // Edit the entity name as appropriate.
//    NSEntityDescription *entity = [NSEntityDescription entityForName:_entityName inManagedObjectContext:_menuManagedObjectContext];
//    [fetchRequest setEntity:entity];
//    
//    // Set the batch size to a suitable number.
////    [fetchRequest setFetchBatchSize:20];
//    
//    // Edit the sort key as appropriate.
//    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:_sortName ascending:YES];
//    
//    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:aSortDescriptor, nil];
//    //    
//    [fetchRequest setSortDescriptors:sortDescriptors];
//    [fetchRequest setFetchLimit:21];
////    [fetchRequest setFetchOffset:_currentPage * 21];
//    
//    // Edit the section name key path and cache name if appropriate.
//    // nil for section name key path means "no sections".
//    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
//                                                                   managedObjectContext:_menuManagedObjectContext 
//                                                                     sectionNameKeyPath:nil 
//                                                                              cacheName:_entityName];
//    return _fetchedResultsController;
//}

- (NSFetchedResultsController *)fetchedResultsController:(NSPredicate *)filterPredicate limit:(NSInteger)limit{
    
    if (!_entityName||!_sortName) {
        return nil;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:_entityName inManagedObjectContext:_menuManagedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    //    [fetchRequest setFetchBatchSize:20];
    if (filterPredicate) {
        [fetchRequest setPredicate:filterPredicate];
    }
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:_sortName ascending:NO];
    
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:aSortDescriptor, nil];
    //
    [fetchRequest setSortDescriptors:sortDescriptors];
    [fetchRequest setFetchLimit:limit];
    [fetchRequest setFetchOffset:_currentPage * limit];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:_menuManagedObjectContext
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:_entityName];
    return _fetchedResultsController;
}

- (NSFetchedResultsController *)ascendingfetchedResultsController:(NSPredicate *)filterPredicate limit:(NSInteger)limit{
    
    if (!_entityName||!_sortName) {
        return nil;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:_entityName inManagedObjectContext:_menuManagedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    //    [fetchRequest setFetchBatchSize:20];
    if (filterPredicate) {
        [fetchRequest setPredicate:filterPredicate];
    }
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:_sortName ascending:YES];
    
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:aSortDescriptor, nil];
    //
    [fetchRequest setSortDescriptors:sortDescriptors];
    [fetchRequest setFetchLimit:limit];
    [fetchRequest setFetchOffset:_currentPage * limit];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:_menuManagedObjectContext
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:_entityName];
    return _fetchedResultsController;
}

- (id)getSpecificValueWithColumName:(NSString *)columName  andFunctionName:(NSString *)function attributeType:(NSAttributeType)attributeType filter:(NSPredicate *)filterPredicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:_entityName inManagedObjectContext:_menuManagedObjectContext];
    [request setEntity:entity];
    if (filterPredicate) {
        [request setPredicate:filterPredicate];
    }
    // Specify that the request should return dictionaries.
    [request setResultType:NSDictionaryResultType];
    
    // Create an expression for the key path.
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:columName];
    
    // Create an expression to represent the minimum value at the key path 'creationDate'
    NSString *functionName = @"";
    NSString *descripName = @"";
    if ([function caseInsensitiveCompare:@"min"] == NSOrderedSame) {
        functionName = @"min:";
        descripName = @"minDate";
    }
    else if([function caseInsensitiveCompare:@"max"] == NSOrderedSame) {
        functionName = @"max:";
        descripName = @"maxDate";
    }
    NSExpression *minExpression = [NSExpression expressionForFunction:functionName arguments:[NSArray arrayWithObject:keyPathExpression]];
    
    // Create an expression description using the minExpression and returning a date.
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    
    // The name is the key that will be used in the dictionary for the return value.
    [expressionDescription setName:descripName];
    [expressionDescription setExpression:minExpression];
    
    [expressionDescription setExpressionResultType:attributeType];
    
    // Set the request's properties to fetch just the property represented by the expressions.
    [request setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
    
    // Execute the fetch.
    NSError *error = nil;
    NSArray *objects = [_menuManagedObjectContext executeFetchRequest:request error:&error];
    if (objects == nil) {
        // Handle the error.
        return nil;
    }
    else {
        if ([objects count] > 0) {
//            NSLog(@"Minimum date: %@", [[objects objectAtIndex:0] valueForKey:descripName]);
            return [[objects objectAtIndex:0] valueForKey:descripName];
        }
    }
    return nil;
}

@end
