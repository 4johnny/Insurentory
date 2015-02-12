//
//  AssetStaticTableViewController.h
//  Insurentory
//
//  Created by JoLi on 2015-02-10.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Asset.h"

#
# pragma mark - Protocol
#

@protocol AssetUpdateDelegate <NSObject>

- (void)valueUpdated:(double)valueDelta;

@end

#
# pragma mark - Interface
#

@interface AssetStaticTableViewController : UITableViewController <UINavigationControllerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate>

#
# pragma mark Properties
#

@property (nonatomic) id <AssetUpdateDelegate> delegate;
@property (nonatomic) Asset* asset;

#
# pragma mark Outlets
#

@property (weak, nonatomic) IBOutlet UIImageView *assetImageView;
@property (weak, nonatomic) IBOutlet UIImageView *receiptImageView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *valueTextField;

@end
