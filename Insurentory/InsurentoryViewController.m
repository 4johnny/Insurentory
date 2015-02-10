//
//  DetailViewController.m
//  Insurentory
//
//  Created by Johnny on 2015-02-08.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "InsurentoryViewController.h"
#import "AppDelegate.h"
#import "Insurentory.h"
#import "Asset.h"

@interface InsurentoryViewController ()

@end

@implementation InsurentoryViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
	if (_detailItem != newDetailItem) {
	    _detailItem = newDetailItem;
	        
	    // Update the view.
	    [self configureView];
	}
}

- (void)configureView {
	// Update the user interface for the detail item.
	if (self.detailItem) {
        self.nameTextField.text = self.detailItem.name;
        
        [self.notesTextView.layer setBorderColor:[[UIColor blackColor] CGColor]];
        [self.notesTextView.layer setBorderWidth:1.0];
        
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        self.timestampLabel.text = [dateFormatter stringFromDate:self.detailItem.timeStamp];
        
        NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
        currencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
        self.totalValueLabel.text = [NSString stringWithFormat:@"%@",[currencyFormatter stringFromNumber:self.detailItem.totalValue]];
        
        if (self.detailItem.locationLatitude.floatValue != 0 || self.detailItem.locationLongitude.floatValue != 0) {
            self.locationTextField.hidden = YES;
        }
        
    }
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self configureView];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}




- (IBAction)saveInventoryButtonPressed:(id)sender {
    
    self.detailItem.name = self.nameTextField.text;
    self.detailItem.notes = self.notesTextView.text;
    
    // get values from gps location at first is possible
    self.detailItem.locationDescription = self.locationTextField.text;
    
    NSDecimalNumber *assetsValue = [NSDecimalNumber zero];
    for (Asset *asset in self.detailItem.assets) {
        assetsValue = [assetsValue decimalNumberByAdding:asset.value];
    }
    self.detailItem.totalValue = assetsValue;
    
    [InsurentoryViewController saveObjectContext];
}


+ (void)saveObjectContext {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate saveContext];
}

@end
