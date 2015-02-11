//
//  Insurentory.h
//  Insurentory
//
//  Created by Johnny on 2015-02-11.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Asset;

@interface Insurentory : NSManagedObject

@property (nonatomic, retain) NSString * locationDescription;
@property (nonatomic, retain) NSNumber * locationLatitude;
@property (nonatomic, retain) NSNumber * locationLongitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSDecimalNumber * totalValue;
@property (nonatomic, retain) NSSet *assets;
@end

@interface Insurentory (CoreDataGeneratedAccessors)

- (void)addAssetsObject:(Asset *)value;
- (void)removeAssetsObject:(Asset *)value;
- (void)addAssets:(NSSet *)values;
- (void)removeAssets:(NSSet *)values;

@end
