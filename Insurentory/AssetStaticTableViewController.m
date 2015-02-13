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


#
# pragma mark <UITableViewDelegate>
#


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	switch (indexPath.item) {
			
		case 0:
		case 1:
			[self showImagePickerSourceSelector];
			break;
			
		default:
			break;
	}
}


#
# pragma mark <UIActionSheetDelegate>
#


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	switch (buttonIndex) {
			
		case 0:
			[self showCameraImagePicker];
			break;
			
		case 1:
			[self showPhotoLibraryImagePicker];
			break;
			
		default:
			break;
	}
}


#
# pragma mark <UIImagePickerControllerDelegate>
#


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	
	UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
	// CGRect cropRect = [[info objectForKey:UIImagePickerControllerCropRect]CGRectValue];

	UIImage *selectedImage = [info objectForKey:UIImagePickerControllerEditedImage];
	if(!selectedImage) {
		selectedImage = originalImage;
	}
	
	// Save original image to photo album
	if ([picker sourceType] == UIImagePickerControllerSourceTypeCamera) {
		UIImageWriteToSavedPhotosAlbum(originalImage, nil, nil, nil);
	}

	// Put selected image into view
	switch ([self.tableView indexPathForSelectedRow].item) {
			
		case 0:
			self.assetImageView.image = selectedImage;
			break;
			
		case 1:
			self.receiptImageView.image = selectedImage;
			break;
			
		default:
			break;
	}
	
	[picker dismissViewControllerAnimated:YES completion:NULL];
}


#
# pragma mark Action Handlers
#


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
	[self.navigationController popViewControllerAnimated:YES];
}


#
# pragma mark Helpers
#


- (void)showImagePickerSourceSelector {
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		
		[self showImageSourceActionSheet];
		
	} else {
		
		// NOTE: Most iOS devices have cameras.  But still helps for simulator.
		[self showPhotoLibraryImagePicker];
	}
}


- (void)showImageSourceActionSheet {

	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Image Source" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Library", nil];
	actionSheet.tag = 0;
	[actionSheet showInView:self.view];
}


- (void)showCameraImagePicker {
	
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	imagePicker.allowsEditing = YES;
	[imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
	[self presentViewController:imagePicker animated:true completion:nil];
}


- (void)showPhotoLibraryImagePicker {
	
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	imagePicker.allowsEditing = YES;
	[imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
	[self presentViewController:imagePicker animated:YES completion:nil];
}


- (void)configureView {
	
	self.assetImageView.image = self.asset.assetImage
	? [UIImage imageWithData:self.asset.assetImage]
	: [UIImage imageNamed:@"asset_placeholder"];
	
	self.receiptImageView.image = self.asset.receiptImage
	? [UIImage imageWithData:self.asset.receiptImage]
	: [UIImage imageNamed:@"receipt_placeholder"];
	
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
