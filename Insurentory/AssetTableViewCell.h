//
//  AssetTableViewCell.h
//  Insurentory
//
//  Created by Johnny on 2015-02-11.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

#
# pragma mark - Interface
#

@interface AssetTableViewCell : UITableViewCell

#
# pragma mark Outlets
#

@property (weak, nonatomic) IBOutlet UIImageView *assetImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;

@end
