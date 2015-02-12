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
#import "AssetsTableViewController.h"

@interface InsurentoryViewController ()

@end

@implementation InsurentoryViewController


- (void)viewDidLoad {
    [super viewDidLoad];
	
    [self configureView];
    
    UITapGestureRecognizer *backgroundTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlebackgroundTap:)];
    [self.view addGestureRecognizer:backgroundTap];
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

    }

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
    if (self.insurentory.locationDescription != nil) {
        
        self.locationTextView.text = self.insurentory.locationDescription;
        self.locationTextView.editable = NO;
    }
}


- (IBAction)saveInventoryButtonPressed:(id)sender {
	
	[self.view endEditing:YES];
	
    self.insurentory.name = self.nameTextField.text;
    self.insurentory.notes = self.notesTextView.text;

    self.insurentory.locationDescription =  self.locationTextView.text;
    
    // TODO: Instead use new AssetDelegate protocol
    NSDecimalNumber *assetsValue = [NSDecimalNumber zero];
    for (Asset *asset in self.insurentory.assets) {
        assetsValue = [assetsValue decimalNumberByAdding:asset.value];
    }
    self.insurentory.totalValue = assetsValue;
    
    [InsurentoryViewController saveObjectContext];
}


+ (void)saveObjectContext {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate saveContext];
}

@end
