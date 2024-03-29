//
//  BNRAssetTypeViewController.m
//  Homepwner
//
//  Created by Kyle Stevens on 3/28/14.
//  Copyright (c) 2014 kilovolt42. All rights reserved.
//

#import "BNRAssetTypeViewController.h"
#import "BNRItemStore.h"
#import "BNRItem.h"

@implementation BNRAssetTypeViewController

- (instancetype)init {
	return [super initWithStyle:UITableViewStylePlain];
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
	return [self init];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[[BNRItemStore sharedStore] allAssetTypes] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
	
	NSArray *allAssets = [[BNRItemStore sharedStore] allAssetTypes];
	NSManagedObject *assetType = allAssets[indexPath.row];
	
	// Use key-value coding to get the asset type's label
	NSString *assetLabel = [assetType valueForKey:@"label"];
	cell.textLabel.text = assetLabel;
	
	// Checkmark the one that is currently selected
	if (assetType == self.item.assetType) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
	cell.accessoryType = UITableViewCellAccessoryCheckmark;
	
	NSArray *allAssets = [[BNRItemStore sharedStore] allAssetTypes];
	NSManagedObject *assetType = allAssets[indexPath.row];
	self.item.assetType = assetType;
	
	if (self.popover) {
		[self.popover dismissPopoverAnimated:YES];
		[self.popover.delegate popoverControllerDidDismissPopover:self.popover];
	} else {
		[self.navigationController popViewControllerAnimated:YES];
	}
}

@end
