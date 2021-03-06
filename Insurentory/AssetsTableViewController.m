//
//  AssetsTableViewController.m
//  Insurentory
//
//  Created by JoLi on 2015-02-10.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "AssetsTableViewController.h"
#import "AssetStaticTableViewController.h"
#import "AssetTableViewCell.h"
#import "ChameleonFramework/Chameleon.h"


#
# pragma mark - Interface
#


@interface AssetsTableViewController ()

@property (nonatomic) BOOL needsShowAssetSegue;

@end


#
# pragma mark - Implementation
#


@implementation AssetsTableViewController


#
# pragma mark Property Accessors
#


- (NSFetchedResultsController *)fetchedResultsController {
	
	if (_fetchedResultsController != nil) return _fetchedResultsController;
	
	// Build fetch request for assets in this inventory, sorted by timestamp
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Asset"];
	fetchRequest.fetchBatchSize = 20;
	fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO]];
	fetchRequest.predicate = [NSPredicate predicateWithFormat:@"insurentory.timeStamp == %@", self.insurentory.timeStamp];
	
	// Edit the section name key path and cache name if appropriate.
	// nil for section name key path means "no sections".
	_fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.insurentory.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
	_fetchedResultsController.delegate = self;
	
	NSError *error = nil;
	if (![_fetchedResultsController performFetch:&error]) {
		
		// Replace this implementation with code to handle the error appropriately.
		// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
		NSLog(@"Unresolved error %@, %@", error, error.userInfo);
		abort();
	}
	
	return _fetchedResultsController;
}


#
# pragma mark NSObject(UINibLoadingAdditions)
#


- (void)awakeFromNib {
	[super awakeFromNib];
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		self.clearsSelectionOnViewWillAppear = NO;
		self.preferredContentSize = CGSizeMake(320.0, 600.0);
	}
}



#
# pragma mark UIViewController
#


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorColor = FlatSkyBlue;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

	// Do any additional setup after loading the view, typically from a nib.
	//self.navigationItem.leftBarButtonItem = self.editButtonItem;
	
	//	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
	//	self.navigationItem.rightBarButtonItem = addButton;
	
	self.needsShowAssetSegue = NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	
    // Dispose of any resources that can be recreated.
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	
	// Get the new view controller using [segue destinationViewController].
	// Pass the selected object to the new view controller.

	if ([segue.identifier isEqualToString:@"showAsset"]) {
		
		// Inject asset model into asset view controller
		NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
		AssetStaticTableViewController* assetViewController = segue.destinationViewController;
		assetViewController.asset = [self.fetchedResultsController objectAtIndexPath:indexPath];
		assetViewController.delegate = self;
	}
}


#
# pragma mark <UITableViewDataSource>
#


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	return 1; //self.fetchedResultsController.sections.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
//	id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
	
	return self.fetchedResultsController.fetchedObjects.count; // sectionInfo.numberOfObjects;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"assetCell" forIndexPath:indexPath];
	[self configureCell:cell atIndexPath:indexPath];
	
	return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Return NO if you do not want the specified item to be editable.
	return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		NSManagedObjectContext *context = self.fetchedResultsController.managedObjectContext;
		Asset* asset = [self.fetchedResultsController objectAtIndexPath:indexPath];
		double valueDelta = asset.value.doubleValue;
		[context deleteObject:asset];
		
		NSError *error = nil;
		if (![context save:&error]) {
			
			// Replace this implementation with code to handle the error appropriately.
			// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			NSLog(@"Unresolved error %@, %@", error, error.userInfo);
			abort();
		}
		
		[self.delegate valueUpdated:(-valueDelta)];
	}
}


#
# pragma mark <NSFetchedResultsControllerDelegate>
#


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	
	// NOTE: Do *not* call reloadData between begin and end, since it will cancel animations
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

	if (self.needsShowAssetSegue) {
		self.needsShowAssetSegue = NO;

		// Select first item, since our sort order is inserting at top of list
		[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
		[self performSegueWithIdentifier:@"showAsset" sender:self];
	}
	
	self.fetchedResultsController = nil;
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
# pragma mark <AssetUpdateDelegate>
#


- (void)valueUpdated:(double)valueDelta {

	[self.delegate valueUpdated:valueDelta];
}


#
# pragma mark Action Handlers
#


- (IBAction)addPressed:(UIBarButtonItem *)sender {
	
	self.needsShowAssetSegue = YES;
	[self insertNewObject:sender];
}


#
# pragma mark Helpers
#


- (void)insertNewObject:(id)sender {
	
	NSManagedObjectContext *context = self.fetchedResultsController.managedObjectContext;
	NSEntityDescription *entity = self.fetchedResultsController.fetchRequest.entity;
	
	Asset* newAsset = [NSEntityDescription insertNewObjectForEntityForName:entity.name inManagedObjectContext:context];
	newAsset.timeStamp = [NSDate date];
	newAsset.insurentory = self.insurentory;
    [self.insurentory addAssetsObject:newAsset];
	NSLog(@"Created new Asset entity: %@", newAsset);

	// Save the context
	NSError *error = nil;
	if (![context save:&error]) {
		
		// Replace this implementation with code to handle the error appropriately.
		// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
		NSLog(@"Unresolved error %@, %@", error, error.userInfo);
		abort();
	}
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
	Asset* asset = [self.fetchedResultsController objectAtIndexPath:indexPath];
	AssetTableViewCell* assetTableViewCell = (AssetTableViewCell*)cell;
	
	assetTableViewCell.assetImageView.image = asset.assetImage
	? [UIImage imageWithData:asset.assetImage]
	: [UIImage imageNamed:@"asset_placeholder"];
	
	assetTableViewCell.nameLabel.text = asset.name ? asset.name : @"<Name>";
    
    assetTableViewCell.nameLabel.font = [UIFont boldSystemFontOfSize:18];
	
	NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
	currencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
	assetTableViewCell.valueLabel.text = [currencyFormatter stringFromNumber:asset.value];
}


@end
