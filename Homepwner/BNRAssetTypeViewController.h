//
//  BNRAssetTypeViewController.h
//  Homepwner
//
//  Created by Kyle Stevens on 3/28/14.
//  Copyright (c) 2014 kilovolt42. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BNRItem;

@interface BNRAssetTypeViewController : UITableViewController

@property (nonatomic, strong) BNRItem *item;
@property (nonatomic, weak) UIPopoverController *popover;

@end
