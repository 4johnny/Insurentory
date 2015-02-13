//
//  DetailViewController.m
//  Insurentory
//
//  Created by Johnny on 2015-02-08.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <CHCSVParser.h>
#import <MessageUI/MessageUI.h>
#import <EventKit/EventKit.h>
#import "InsurentoryStaticTableViewController.h"
#import "AppDelegate.h"
#import "Insurentory.h"
#import "Asset.h"
#import "AssetsTableViewController.h"
#import "ChameleonFramework/Chameleon.h"


#define REMINDER_BUTTON_INDEX 2


@interface InsurentoryStaticTableViewController () <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) EKEventStore* eventStore;
//@property (nonatomic, strong) EKCalendar* defaultCalendar;

@end


@implementation InsurentoryStaticTableViewController


- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Background tap dismisses keyboards
	UITapGestureRecognizer *backgroundTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlebackgroundTap:)];
	[self.view addGestureRecognizer:backgroundTap];
	
	// Create event store for Reminders
	self.eventStore = [[EKEventStore alloc] init];
	// TODO: Disable Reminder button
}


- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self checkEventStoreAccessForReminders];
	
	[self configureView];
}


- (void)handlebackgroundTap:(UITapGestureRecognizer *)sender {
	
	[self.view endEditing:YES];
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	
	if ([[segue identifier] isEqualToString:@"Assets"]) {
		
		AssetsTableViewController *controller = (AssetsTableViewController *)[segue destinationViewController];
		controller.insurentory = self.insurentory;
		controller.delegate = self;
	}
}


- (void)valueUpdated:(double)valueDelta {
	
	self.insurentory.totalValue = [self.insurentory.totalValue decimalNumberByAdding:[NSDecimalNumber decimalNumberWithDecimal:[NSNumber numberWithDouble:valueDelta].decimalValue]];
	self.insurentory.timeStamp = [NSDate date];
	[InsurentoryStaticTableViewController saveObjectContext];
}


#pragma mark - Managing the detail item


- (void)setInsurentory:(id)newInsurentory {
	
	if (_insurentory != newInsurentory) {
		_insurentory = newInsurentory;
		
		// Update the view.
		[self configureView];
	}
}


- (void)configureView {
	
	// Update the user interface for the insurentory item.
	
	self.tableView.separatorColor = FlatSkyBlue;
	
	self.nameTextField.text = self.insurentory.name;
	
	if (self.insurentory.notes) {
		self.notesTextView.text = self.insurentory.notes;
	}
	self.notesTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
	self.notesTextView.layer.borderWidth = 0.3;
	self.notesTextView.layer.cornerRadius = 5;
	self.notesTextView.clipsToBounds = YES;
	
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
	self.timestampLabel.text = [dateFormatter stringFromDate:self.insurentory.timeStamp];
	
	NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
	currencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
	self.totalValueLabel.text = [currencyFormatter stringFromNumber:self.insurentory.totalValue];
	
	self.locationTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
	self.locationTextView.layer.borderWidth = 0.3;
	self.locationTextView.layer.cornerRadius = 5;
	self.locationTextView.clipsToBounds = YES;
	self.locationTextView.text = self.insurentory.locationDescription;
}


#pragma mark - Action Handlers


- (IBAction)saveButtonPressed:(id)sender {
	
	[self.view endEditing:YES];
	
	self.insurentory.name = self.nameTextField.text;
	self.insurentory.notes = self.notesTextView.text;
	self.insurentory.locationDescription =  self.locationTextView.text;
	
	[InsurentoryStaticTableViewController saveObjectContext];
	[self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)emailButtonPressed:(UIBarButtonItem *)sender {
	
	if ( [MFMailComposeViewController canSendMail] )
	{
		MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
		mailComposer.mailComposeDelegate = self;
		
		[mailComposer setMessageBody:@"Hi,\nHere is my house contents. Could you please give me a quote for insurance?\n Thank you!" isHTML:NO];
		
		[mailComposer setSubject:[NSString stringWithFormat:@"Insurentory: %@", self.insurentory.name]];
		
		[mailComposer addAttachmentData:[self generateCsvFromInsurentoryData]  mimeType:@"cvs" fileName:[NSString stringWithFormat:@"Insurentory %@.csv", self.insurentory.name]];
		
		[self presentViewController:mailComposer animated:YES completion:nil];
	}
	
}


- (IBAction)reminderButtonPressed:(UIBarButtonItem *)sender {
	
	EKAuthorizationStatus authStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
	if (authStatus != EKAuthorizationStatusAuthorized) return;
	
	// Set up reusable alert controller
	UIAlertAction* okAlertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
	UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Error" message:nil preferredStyle:UIAlertControllerStyleAlert];
	[alertController addAction:okAlertAction];
	
	// Create reminder
	EKReminder* reminder = [EKReminder reminderWithEventStore:self.eventStore];
	reminder.title = [NSString stringWithFormat:@"Renew contents insurance, since \"%@\" is expiring.", self.insurentory.name];
	reminder.calendar = self.eventStore.defaultCalendarForNewReminders;
	reminder.dueDateComponents = [self dateComponentsForReminderDueDate];
	
	// Add alarm
	NSDate* now = [NSDate date];
	NSDate* soon = [now dateByAddingTimeInterval:30];
	EKAlarm* alarm = [EKAlarm alarmWithAbsoluteDate:soon]; //reminder.dueDateComponents.date];
	[reminder addAlarm:alarm];
	 
	NSError *error = nil;
	if (![self.eventStore saveReminder:reminder commit:YES error:&error]) {
		
		alertController.message = @"Error saving new reminder";
		[self presentViewController:alertController animated:YES completion:nil];
		NSLog(@"Error saving new reminder: %@ %@", error.localizedDescription, error.userInfo);
		return;
	}
	
	alertController.title = @"Success!";
	alertController.message = [NSString stringWithFormat:@"New reminder added: %@", reminder.title];
	[self presentViewController:alertController animated:YES completion:nil];
	
	//	[event addAlarm:[EKAlarm alarmWithAbsoluteDate:event.startDate]];
}


- (IBAction)airdropButtonPressed:(UIBarButtonItem *)sender {
	
	
}


#pragma mark - Reminders

// Check the authorization status of our application for Reminders
- (void)checkEventStoreAccessForReminders {
	
	// Set up reusable alert controller
	UIAlertAction* okAlertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
	UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Error" message:nil preferredStyle:UIAlertControllerStyleAlert];
	[alertController addAction:okAlertAction];
	
	EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
	switch (status) {
			
			// Update our UI if the user has granted access to their Reminders
		case EKAuthorizationStatusAuthorized: [self accessGrantedForReminders];
			break;
			
			// Prompt the user for access if there is no definitive answer
		case EKAuthorizationStatusNotDetermined: [self requestRemindersAccess];
			break;
			
			// Display a message if the user has denied or restricted access
		case EKAuthorizationStatusDenied:
		case EKAuthorizationStatusRestricted: {
			
			alertController.message = @"Permission was not granted for Reminders";
			[self presentViewController:alertController animated:YES completion:nil];
			break;
		}
			
		default:
			break;
	}
}


// Prompt the user for access to their Reminders
- (void)requestRemindersAccess {
	
	[self.eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
		
		if (!granted) return;
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			[self accessGrantedForReminders];
		});
	}];
}


// This method is called when the user has granted permission to Reminders
- (void)accessGrantedForReminders {
	
	// TODO: Enable Reminder button
	
	//	self.defaultCalendar = [self.eventStore defaultCalendarForNewReminders];
}


#pragma mark - MFMailCompose ViewController Delegate


- (void)mailComposeController:(MFMailComposeViewController *)controller
		  didFinishWithResult:(MFMailComposeResult)result
						error:(NSError *)error {
	
	[self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -  Helper methods


- (NSData *)generateCsvFromInsurentoryData {
	
	NSOutputStream *outputStream = [[NSOutputStream alloc] initToMemory];
	CHCSVWriter *csvWriter = [[CHCSVWriter alloc] initWithOutputStream:outputStream encoding:NSUTF8StringEncoding delimiter:','];
	
	[csvWriter writeLineOfFields:@[self.insurentory.name, self.insurentory.timeStamp, self.insurentory.totalValue]];
	[csvWriter writeLineOfFields:@[ @"Asset Name", @"Asset Value"]];
	//[csvWriter finishLine];
	
	for (Asset *asset in self.insurentory.assets) {
		//[csvWriter writeLineOfFields: @[asset.name, asset.value]];
		[csvWriter writeField:asset.name];
		[csvWriter writeField:asset.value];
		[csvWriter finishLine];
	}
	
	[csvWriter closeStream];
	
	NSData *bufferOutput = [outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
	return bufferOutput;
}


+ (void)saveObjectContext {
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate saveContext];
}


- (NSDateComponents*)dateComponentsForReminderDueDate {
	
//	NSDateComponents* dateComponents = [[NSDateComponents alloc] init];
//	dateComponents.second = 10;
	
	NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	NSUInteger componentUnitFlags = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
	NSDateComponents* dueDateComponents = [gregorianCalendar components:componentUnitFlags fromDate:[NSDate date]];
	
	return dueDateComponents;
	
	//	NSDateComponents *oneDayComponents = [[NSDateComponents alloc] init];
	//	oneDayComponents.day = 1;
	//
	//	NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	//	NSDate *tomorrow = [gregorianCalendar dateByAddingComponents:oneDayComponents toDate:[NSDate date] options:0];
	//
	//	NSUInteger unitFlags = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
	//	NSDateComponents *tomorrowAt4PM = [gregorianCalendar components:unitFlags fromDate:tomorrow];
	//	tomorrowAt4PM.hour = 16;
	//	tomorrowAt4PM.minute = 0;
	//	tomorrowAt4PM.second = 0;
	//
	//	return tomorrowAt4PM;
}


@end
