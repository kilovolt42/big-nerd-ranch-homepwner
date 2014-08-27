//
//  BNRItem.h
//  Homepwner
//
//  Created by Kyle Stevens on 3/27/14.
//  Copyright (c) 2014 kilovolt42. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface BNRItem : NSManagedObject

@property (nonatomic, strong) NSDate *dateCreated;
@property (nonatomic, strong) NSString *itemKey;
@property (nonatomic, strong) NSString *itemName;
@property (nonatomic) double orderingValue;
@property (nonatomic, strong) NSString *serialNumber;
@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic) int valueInDollars;
@property (nonatomic, strong) NSManagedObject *assetType;

- (void)setThumbnailFromImage:(UIImage *)image;

@end
