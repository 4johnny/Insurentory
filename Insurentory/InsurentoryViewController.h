//
//  DetailViewController.h
//  Insurentory
//
//  Created by Johnny on 2015-02-08.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Insurentory;

@interface InsurentoryViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) Insurentory *detailItem;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextView *notesTextView;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (weak, nonatomic) IBOutlet UILabel *totalValueLabel;
@property (weak, nonatomic) IBOutlet UITextView *locationTextView;

- (IBAction)saveInventoryButtonPressed:(id)sender;


@end

