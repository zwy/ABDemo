//
//  ViewController.h
//  ABDemo
//
//  Created by Tony on 14-8-14.
//  Copyright (c) 2014年 zwy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate>
@property (nonatomic, retain)IBOutlet UITableView *tableView;

//@property (nonatomic,strong)UISearchDisplayController *searchController;
@property (nonatomic,strong)UISearchBar *searchBar;

@end
