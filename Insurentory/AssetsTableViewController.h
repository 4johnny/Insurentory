//
//  AssetsViewController.h
//  Insurentory
//
//  Created by JoLi on 2015-02-10.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Insurentory.h"

#
# pragma mark - Interface
#

@interface AssetsTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

#
# pragma mark Properties
#

@property (nonatomic) Insurentory* insurentory;

@property (strong, nonatomic) NSFetchedResultsController* fetchedResultsController;

@end
