//
//  AssetStaticTableViewController.m
//  Insurentory
//
//  Created by JoLi on 2015-02-10.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "AssetStaticTableViewController.h"
#import "AppDelegate.h"


#
# pragma mark - Interface
#


@interface AssetStaticTableViewController ()

@end


#
# pragma mark - Implementation
#


@implementation AssetStaticTableViewController


#
# pragma mark UIViewController
#


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	[self configureView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)saveAssetPressed:(UIBarButtonItem *)sender {
	
	[self.view endEditing:YES];

	self.asset.assetImage = UIImagePNGRepresentation(self.assetImageView.image);
	self.asset.receiptImage = UIImagePNGRepresentation(self.receiptImageView.image);
	self.asset.name = self.nameTextField.text;
	
	NSNumberFormatter *decimalFormatter = [[NSNumberFormatter alloc] init];
	decimalFormatter.numberStyle = NSNumberFormatterDecimalStyle;
	decimalFormatter.minimumFractionDigits = 2;
	decimalFormatter.maximumFractionDigits = 2;
	double oldValue = self.asset.value.doubleValue;
	self.asset.value = [NSDecimalNumber decimalNumberWithDecimal:[decimalFormatter numberFromString:self.valueTextField.text].decimalValue];
	
	[AssetStaticTableViewController saveObjectContext];
	
	double valueDelta = self.asset.value.doubleValue - oldValue;
	[self.delegate valueUpdated:valueDelta];
}


- (void)configureView {
	
	self.assetImageView.image = self.asset.assetImage
	? [UIImage imageWithData:self.asset.assetImage]
	: [UIImage imageNamed:@"foosball_table"];
	
	self.receiptImageView.image = self.asset.receiptImage
	? [UIImage imageWithData:self.asset.receiptImage]
	: [UIImage imageNamed:@"receipt1"];
	
	self.nameTextField.text = self.asset.name ? self.asset.name : @"<Name>";
	
	NSNumberFormatter *decimalFormatter = [[NSNumberFormatter alloc] init];
	decimalFormatter.numberStyle = NSNumberFormatterDecimalStyle;
	decimalFormatter.minimumFractionDigits = 2;
	decimalFormatter.maximumFractionDigits = 2;
	self.valueTextField.text = [decimalFormatter stringFromNumber:self.asset.value];
}


+ (void)saveObjectContext {
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate saveContext];
}


@end
