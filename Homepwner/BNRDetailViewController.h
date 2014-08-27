//
//  BNRDetailViewController.h
//  Homepwner
//
//  Created by Kyle Stevens on 2/27/14.
//  Copyright (c) 2014 kilovolt42. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BNRItem;

@interface BNRDetailViewController : UIViewController

@property (nonatomic, strong) BNRItem *item;
@property (nonatomic, copy) void (^dismissBlock)(void);

- (instancetype)initWithNewItem:(BOOL)isNew;

@end
