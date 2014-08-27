//
//  BNRItemsViewController.m
//  Homepwner
//
//  Created by Kyle Stevens on 2/27/14.
//  Copyright (c) 2014 kilovolt42. All rights reserved.
//

#import "BNRItemsViewController.h"
#import "BNRItemStore.h"
#import "BNRItem.h"
#import "BNRDetailViewController.h"
#import "BNRItemCell.h"
#import "BNRImageStore.h"
#import "BNRImageViewController.h"

@interface BNRItemsViewController () <UIPopoverControllerDelegate>
@property (nonatomic, strong) UIPopoverController *imagePopover;
@end

@implementation BNRItemsViewController

- (instancetype)init {
	// Call the superclass's designated initializer
	self = [super initWithStyle:UITableViewStylePlain];
	if (self) {
		UINavigationItem *navItem = self.navigationItem;
		navItem.title = @"Homepwner";
		
		// Create a new bar button item that will send
		// addNewItem: to BNRItemsViewController
		UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																			 target:self
																			 action:@selector(addNewItem:)];
		
		// Set this bar button item as the right item in the navigationItem
		navItem.rightBarButtonItem = bbi;
		
		navItem.leftBarButtonItem = self.editButtonItem;
		
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self
			   selector:@selector(updateTableViewForDynamicTypeSize)
				   name:UIContentSizeCategoryDidChangeNotification
				 object:nil];
	}
	return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
	return [self init];
}

- (void)dealloc {
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Load the NIB file
	UINib *nib = [UINib nibWithNibName:@"BNRItemCell" bundle:nil];
	
	// Register this NIB, which contains the cell
	[self.tableView registerNib:nib forCellReuseIdentifier:@"BNRItemCell"];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self updateTableViewForDynamicTypeSize];
}

- (void)updateTableViewForDynamicTypeSize {
	static NSDictionary *cellHeightDictionary;
	
	if (!cellHeightDictionary) {
		cellHeightDictionary = @{ UIContentSizeCategoryExtraSmall : @44,
								  UIContentSizeCategorySmall : @44,
								  UIContentSizeCategoryMedium : @44,
								  UIContentSizeCategoryLarge : @44,
								  UIContentSizeCategoryExtraLarge : @55,
								  UIContentSizeCategoryExtraExtraLarge : @65,
								  UIContentSizeCategoryExtraExtraExtraLarge : @75 };
	}
	
	NSString *userSize = [[UIApplication sharedApplication] preferredContentSizeCategory];
	
	NSNumber *cellHeight = cellHeightDictionary[userSize];
	[self.tableView setRowHeight:cellHeight.floatValue];
	[self.tableView reloadData];
}

- (IBAction)addNewItem:(id)sender {
	// Create a new BNRItem and add it to the store
	BNRItem *newItem = [[BNRItemStore sharedStore] createItem];
	
	BNRDetailViewController *detailViewController = [[BNRDetailViewController alloc] initWithNewItem:YES];
	
	detailViewController.item = newItem;
	detailViewController.dismissBlock = ^{
		[self.tableView reloadData];
	};
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
	navController.modalPresentationStyle = UIModalPresentationFormSheet;
	
	[self presentViewController:navController animated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[[BNRItemStore sharedStore] allItems] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	// Get a new or recycled cell
	BNRItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BNRItemCell" forIndexPath:indexPath];
	
	// Set the text on the cell with the description of the item
	// that is at the nth index of items, where n = row this cell
	// will appear in on the tableview
	NSArray *items = [[BNRItemStore sharedStore] allItems];
	BNRItem *item = items[indexPath.row];
	
	cell.nameLabel.text = item.itemName;
	cell.serialNumberLabel.text = item.serialNumber;
	cell.valueLabel.text = [NSString stringWithFormat:@"$%d", item.valueInDollars];
	
	cell.thumbnailView.image = item.thumbnail;
	
	__weak BNRItemCell *weakCell = cell;
	
	cell.actionBlock = ^{
		NSLog(@"Going to show image for %@", item);
		
		BNRItemCell *strongCell = weakCell;
		
		if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
			NSString *itemKey = item.itemKey;
			
			// If there is no image, we don't need to display anything
			UIImage *img = [[BNRImageStore sharedStore] imageForKey:itemKey];
			if (!img) {
				return;
			}
			
			// Make a rectangle for the frame of the thumbnail relative to
			// our table view
			// Note: there will be a warning on this line that we'll soon discuss
			CGRect rect = [self.view convertRect:strongCell.thumbnailView.bounds
										fromView:strongCell.thumbnailView];
			
			// Create a new BNRImageViewController and set its image
			BNRImageViewController *ivc = [[BNRImageViewController alloc] init];
			ivc.image = img;
			
			// Present a 600x600 popover from the rect
			self.imagePopover = [[UIPopoverController alloc] initWithContentViewController:ivc];
			self.imagePopover.delegate = self;
			self.imagePopover.popoverContentSize = CGSizeMake(600, 600);
			[self.imagePopover presentPopoverFromRect:rect
											   inView:self.view
							 permittedArrowDirections:UIPopoverArrowDirectionAny
											 animated:YES];
		}
	};
	
	return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	// If the table view is asking to commit a delete command...
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSArray *items = [[BNRItemStore sharedStore] allItems];
		BNRItem *item = items[indexPath.row];
		[[BNRItemStore sharedStore] removeItem:item];
		
		// Also remove that row from the table view with an animation
		[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
	[[BNRItemStore sharedStore] moveItemAtIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	BNRDetailViewController *detailViewController = [[BNRDetailViewController alloc] initWithNewItem:NO];
	
	NSArray *items = [[BNRItemStore sharedStore] allItems];
	BNRItem *selectedItem = items[indexPath.row];
	
	// Give detail view controller a pointer to the item object in row
	detailViewController.item = selectedItem;
	
	// Push it onto the top of the navigation controller's stack
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	self.imagePopover = nil;
}

@end
