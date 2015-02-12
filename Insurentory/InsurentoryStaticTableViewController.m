//
//  DetailViewController.m
//  Insurentory
//
//  Created by Johnny on 2015-02-08.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "InsurentoryStaticTableViewController.h"
#import "AppDelegate.h"
#import "Insurentory.h"
#import "Asset.h"
#import "AssetsTableViewController.h"
#import <CHCSVParser.h>
#import <MessageUI/MessageUI.h>


@interface InsurentoryStaticTableViewController () <MFMailComposeViewControllerDelegate>

@end

@implementation InsurentoryStaticTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
	
    
    
    UITapGestureRecognizer *backgroundTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlebackgroundTap:)];
    [self.view addGestureRecognizer:backgroundTap];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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

- (void)valueUpdated:(double)valueDelta{
    
    
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
    
	// Update the user interface for the detail item.
    if (!self.insurentory) return;
    
    // We have an insurentory, so load it into view
	
    self.nameTextField.text = self.insurentory.name;
	
	if (self.insurentory.notes) {
		self.notesTextView.text = self.insurentory.notes;
	}
    self.notesTextView.layer.borderColor = [UIColor blackColor].CGColor;
    self.notesTextView.layer.borderWidth = 1.0;
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    self.timestampLabel.text = [dateFormatter stringFromDate:self.insurentory.timeStamp];
    
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    currencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    self.totalValueLabel.text = [currencyFormatter stringFromNumber:self.insurentory.totalValue];

    self.locationTextView.layer.borderColor = [UIColor blackColor].CGColor;
    self.locationTextView.layer.borderWidth = 1.0;
    self.locationTextView.text = self.insurentory.locationDescription;
}


- (IBAction)saveInventoryButtonPressed:(id)sender {
	
	[self.view endEditing:YES];
	
    self.insurentory.name = self.nameTextField.text;
    self.insurentory.notes = self.notesTextView.text;
    self.insurentory.locationDescription =  self.locationTextView.text;
    
    [InsurentoryStaticTableViewController saveObjectContext];
}


- (IBAction)emailButtonPressed:(UIButton *)sender {
    
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


#pragma mark -  Helper methods

- (NSData *)generateCsvFromInsurentoryData
{
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


#pragma mark - MFMailCompose ViewController Delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
