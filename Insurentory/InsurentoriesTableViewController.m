//
//  MasterViewController.m
//  Insurentory
//
//  Created by Johnny on 2015-02-08.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <LocalAuthentication/LocalAuthentication.h>
#import "InsurentoriesTableViewController.h"
#import "InsurentoryStaticTableViewController.h"
#import "Insurentory.h"
#import "AppDelegate.h"
#import "ChameleonFramework/Chameleon.h"


@interface InsurentoriesTableViewController ()

@property (nonatomic) CLLocation *insurentoryLocation;
@property (nonatomic) NSString *insurentoryAddress;

@end


@implementation InsurentoriesTableViewController



- (void)setupColors
{
    self.navigationController.navigationBar.barTintColor = FlatSkyBlue;
    self.navigationController.navigationBar.tintColor = FlatWhite;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: FlatWhite };
    self.navigationController.navigationBar.translucent = NO;
    
    self.tableView.separatorColor = FlatSkyBlue;
}







- (void)awakeFromNib {
	[super awakeFromNib];
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    self.clearsSelectionOnViewWillAppear = NO;
	    self.preferredContentSize = CGSizeMake(320.0, 600.0);
	}
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
	// Authenticate user via Touch ID
	[self authenticateUser];
	
    [self setupColors];
	
	// Do any additional setup after loading the view, typically from a nib.
	//self.navigationItem.leftBarButtonItem = self.editButtonItem;

	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
	self.navigationItem.rightBarButtonItem = addButton;
	self.detailViewController = (InsurentoryStaticTableViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.locationManager.delegate = self;
    
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


- (void)insertNewObject:(id)sender {
	NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
	NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    Insurentory *newInsurentory = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    newInsurentory.name = @"Home 2015";
    newInsurentory.timeStamp = [NSDate date];
    NSLog(@"Created new Inventory entity: %@", newInsurentory);
    
    newInsurentory.locationLatitude = [NSNumber numberWithDouble:self.insurentoryLocation.coordinate.latitude];
    newInsurentory.locationLongitude = [NSNumber numberWithDouble:self.insurentoryLocation.coordinate.longitude];
    NSLog(@"Insurentory lat: %@ | lng: %@", newInsurentory.locationLatitude, newInsurentory.locationLongitude);
    
    newInsurentory.locationDescription = self.insurentoryAddress;
    NSLog(@"Insurentory locationDescription : %@", newInsurentory.locationDescription);
    
	    
	// Save the context.
	NSError *error = nil;
	if (![context save:&error]) {
	    // Replace this implementation with code to handle the error appropriately.
	    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
}


#pragma mark - Location Manager Delegate 

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    self.insurentoryLocation = [locations lastObject];
    NSLog(@"Current location %@", self.insurentoryLocation);
    [manager stopUpdatingLocation];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:[locations lastObject] completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!(error))
         {
             CLPlacemark *placemark = [placemarks lastObject];
             self.insurentoryAddress = [placemark.addressDictionary[@"FormattedAddressLines"] componentsJoinedByString:@", "];
             //NSLog(@"Geocode addr: %@", self.insurentoryAddress);

         } else {
             NSLog(@"Geocoder failed with error %@", [error localizedDescription]);
         }
     }];

}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location manager error %@", [error localizedDescription]);
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	
	if ([[segue identifier] isEqualToString:@"showInsurentory"]) {
		
	    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	    Insurentory *currentInsurentory = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	    InsurentoryStaticTableViewController *controller = (InsurentoryStaticTableViewController *)segue.destinationViewController;
	    controller.insurentory = currentInsurentory;
		
	    controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
	    controller.navigationItem.leftItemsSupplementBackButton = YES;
	}
}


#pragma mark - Table View


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
	return [[self.fetchedResultsController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
	return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"insurentoryCell" forIndexPath:indexPath];
	[self configureCell:cell atIndexPath:indexPath];
	return cell;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    Insurentory *insurentory = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = insurentory.name;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:18];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    cell.detailTextLabel.text = [dateFormatter stringFromDate:insurentory.timeStamp];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
	// Return NO if you do not want the specified item to be editable.
	return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
	if (editingStyle == UITableViewCellEditingStyleDelete) {
        
	    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
	    [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
	        
	    NSError *error = nil;
	    if (![context save:&error]) {
            
	        // Replace this implementation with code to handle the error appropriately.
	        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	        abort();
	    }
	}
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Insurentory" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}    


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */


#
# pragma mark Helpers
#


- (void)authenticateUser {

	// Set up reusable alert controller
	UIAlertAction* okAlertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
	UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Error" message:nil preferredStyle:UIAlertControllerStyleAlert];
	
	// If cannot auth with Touch ID, we are done.
	LAContext *authContext = [[LAContext alloc] init];
	NSError *error = nil;
	if (![authContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
		
		alertController.message = @"Your device cannot authenticate using TouchID.";
		[alertController addAction:okAlertAction];
		[self presentViewController:alertController animated:YES completion:nil];
		
		[self enableAppView]; // NOTE: For simulator and pre-iPhone5s demo purposes, we just approve
		return;
	}
	
	[authContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"Please authenticate" reply:^(BOOL success, NSError *error) {
		
		// If authentication error, we are done.
		if (error) {
			
			alertController.message = @"There was a problem verifying your identity.";
			[alertController addAction:okAlertAction];
			[self presentViewController:alertController animated:YES completion:nil];
			return;
		}
		
		// If authentication failed, we are done.
		if (!success) {

			alertController.message = @"You are not the device owner.";
			[alertController addAction:okAlertAction];
			[self presentViewController:alertController animated:YES completion:nil];
			return;
		}
		dispatch_async(dispatch_get_main_queue(), ^{
			[self enableAppView];
		});
	}];
}


- (void)enableAppView {
	
	self.navigationController.view.userInteractionEnabled = YES;
}


@end
