//
//  MasterViewController.h
//  Insurentory
//
//  Created by Johnny on 2015-02-08.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@class InsurentoryStaticTableViewController;

@interface InsurentoriesTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) InsurentoryStaticTableViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;




@end

