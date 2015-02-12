//
//  DetailViewController.h
//  Insurentory
//
//  Created by Johnny on 2015-02-08.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AssetStaticTableViewController.h"

@class Insurentory;

@interface InsurentoryViewController : UIViewController <UITextFieldDelegate, AssetUpdateDelegate>

@property (strong, nonatomic) Insurentory *insurentory;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextView *notesTextView;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalValueLabel;
@property (weak, nonatomic) IBOutlet UITextView *locationTextView;

- (IBAction)saveInventoryButtonPressed:(id)sender;

- (IBAction)emailButtonPressed:(UIButton *)sender;

@end

