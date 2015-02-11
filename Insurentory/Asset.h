//
//  Asset.h
//  Insurentory
//
//  Created by Johnny on 2015-02-11.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Insurentory;

@interface Asset : NSManagedObject

@property (nonatomic, retain) NSData * assetImage;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * receiptImage;
@property (nonatomic, retain) NSDecimalNumber * value;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) Insurentory *insurentory;

@end
