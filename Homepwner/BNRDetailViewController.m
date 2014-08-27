//
//  BNRDetailViewController.m
//  Homepwner
//
//  Created by Kyle Stevens on 2/27/14.
//  Copyright (c) 2014 kilovolt42. All rights reserved.
//

#import "BNRDetailViewController.h"
#import "BNRItem.h"
#import "BNRImageStore.h"
#import "BNRItemStore.h"
#import "BNRAssetTypeViewController.h"

@interface BNRDetailViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) UIPopoverController *imagePickerPopover;
@property (strong, nonatomic) UIPopoverController *assetTypePickerPopover;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *serialNumberField;
@property (weak, nonatomic) IBOutlet UITextField *valueField;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraButton;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *serialNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *assetTypeButton;

@end

@implementation BNRDetailViewController

- (void)setItem:(BNRItem *)item {
	_item = item;
	self.navigationItem.title = _item.itemName;
}

- (instancetype)initWithNewItem:(BOOL)isNew {
	self = [super initWithNibName:nil bundle:nil];
	
	if (self) {
		if (isNew) {
			UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																					  target:self
																					  action:@selector(save:)];
			self.navigationItem.rightBarButtonItem = doneItem;
			
			UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																						target:self
																						action:@selector(cancel:)];
			self.navigationItem.leftBarButtonItem = cancelItem;
		}
		
		// Make sure this is NOT in the if (isNew) block of code
		NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
		[defaultCenter addObserver:self
						  selector:@selector(updateFonts)
							  name:UIContentSizeCategoryDidChangeNotification
							object:nil];
	}
	
	return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	@throw [NSException exceptionWithName:@"Wrong initializer"
								   reason:@"Use initForNewItem:"
								 userInfo:nil];
	return nil;
}

- (void)dealloc {
	NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
	[defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	UIImageView *iv = [[UIImageView alloc] initWithImage:nil];
	
	// The contentMode of the image view in the XIB was Apsect Fit:
	iv.contentMode = UIViewContentModeScaleAspectFit;
	
	// Do no produce a translated constraint for this view
	iv.translatesAutoresizingMaskIntoConstraints = NO;
	
	// The image view was a subview of the view
	[self.view addSubview:iv];
	
	// The image view was pointed to by the imageView property
	self.imageView = iv;
	
	// Set the vertical priorities to be less than
	// those of the other subviews
	[self.imageView setContentHuggingPriority:200 forAxis:UILayoutConstraintAxisVertical];
	[self.imageView setContentCompressionResistancePriority:700 forAxis:UILayoutConstraintAxisVertical];
	
	NSDictionary *nameMap = @{@"imageView" : self.imageView,
							  @"dateLabel" : self.dateLabel,
							  @"toolbar" : self.toolbar};
	
	// imageView is 0 pts from superview at left and right
	NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imageView]-0-|"
																			 options:0
																			 metrics:nil
																			   views:nameMap];
	
	// imageView is 8 pts from dateLabel at its top edge...
	// ... and 8 pts from toolbar at its bottom edge
	NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[dateLabel]-[imageView]-[toolbar]"
																		   options:0
																		   metrics:nil
																			 views:nameMap];
	
	[self.view addConstraints:horizontalConstraints];
	[self.view addConstraints:verticalConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	UIInterfaceOrientation io = [[UIApplication sharedApplication] statusBarOrientation];
	[self prepareViewsForOrientation:io];
	
	BNRItem *item = self.item;
	
	self.nameField.text = item.itemName;
	self.serialNumberField.text = item.serialNumber;
	self.valueField.text = [NSString stringWithFormat:@"%d", item.valueInDollars];
	
	// You need an NSDateFormatter that will turn a date into a simple date string
	static NSDateFormatter *dateFormatter = nil;
	if (!dateFormatter) {
		dateFormatter = [[NSDateFormatter alloc] init];
		dateFormatter.dateStyle = NSDateFormatterMediumStyle;
		dateFormatter.timeStyle = NSDateFormatterNoStyle;
	}
	
	// Use filtered NSDate object to set dateLabel contents
	self.dateLabel.text = [dateFormatter stringFromDate:item.dateCreated];
	
	NSString *imageKey = self.item.itemKey;
	
	// Get the image for its image key from the image store
	UIImage *imageToDisplay = [[BNRImageStore sharedStore] imageForKey:imageKey];
	
	// Use that image to put on the screen in the imageView
	self.imageView.image = imageToDisplay;
	
	NSString *typeLabel = [self.item.assetType valueForKey:@"label"];
	if (!typeLabel) {
		typeLabel = @"None";
	}
	
	self.assetTypeButton.title = [NSString stringWithFormat:@"Type: %@", typeLabel];
	
	[self updateFonts];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	// Clear first responder
	[self.view endEditing:YES];
	
	// "Save" changes to item
	BNRItem *item = self.item;
	item.itemName = self.nameField.text;
	item.serialNumber = self.serialNumberField.text;
	item.valueInDollars = [self.valueField.text intValue];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[self prepareViewsForOrientation:toInterfaceOrientation];
}

- (void)updateFonts {
	UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
	
	self.nameLabel.font = font;
	self.serialNumberLabel.font = font;
	self.valueLabel.font = font;
	self.dateLabel.font = font;
	
	self.nameField.font = font;
	self.serialNumberField.font = font;
	self.valueField.font = font;
}

- (IBAction)takePicture:(id)sender {
	if ([self.imagePickerPopover isPopoverVisible]) {
		// If the popover is already up, get rid of it
		[self.imagePickerPopover dismissPopoverAnimated:YES];
		self.imagePickerPopover = nil;
		return;
	}
	
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	
	// If the device has a camera, take a picture, otherwise,
	// just pick from the photo library
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
	} else {
		imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	}
	
	imagePicker.delegate = self;
	
	// Place image picker on screen
	// Check for iPad device before instantiating the popover controller
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
		// Create a new popover controller that will display the imagePicker
		self.imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
		
		self.imagePickerPopover.delegate = self;
		
		// Display the popover controller; sender
		// is the camera bar button item
		[self.imagePickerPopover presentPopoverFromBarButtonItem:sender
										permittedArrowDirections:UIPopoverArrowDirectionAny
														animated:YES];
	} else {
		[self presentViewController:imagePicker animated:YES completion:nil];
	}
}

- (IBAction)backgroundTapped:(id)sender {
	[self.view endEditing:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	// Get picked image from info dictionary
	UIImage *image = info[UIImagePickerControllerOriginalImage];
	
	[self.item setThumbnailFromImage:image];
	
	// Store the image in the BNRImageStore for this key
	[[BNRImageStore sharedStore] setImage:image forKey:self.item.itemKey];
	
	// Do I have a popover?
	if (self.imagePickerPopover) {
		// Dismiss it
		[self.imagePickerPopover dismissPopoverAnimated:YES];
		self.imagePickerPopover = nil;
		
		NSString *imageKey = self.item.itemKey;
		UIImage *imageToDisplay = [[BNRImageStore sharedStore] imageForKey:imageKey];
		self.imageView.image = imageToDisplay;
	} else {
		// Dismiss the modal image picker
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (void)prepareViewsForOrientation:(UIInterfaceOrientation)orientation {
	// Is it an iPad? No preparation necessary
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
		return;
	}
	
	// Is it landscape?
	if (UIInterfaceOrientationIsLandscape(orientation)) {
		self.imageView.hidden = YES;
		self.cameraButton.enabled = NO;
	} else {
		self.imageView.hidden = NO;
		self.cameraButton.enabled = YES;
	}
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	NSLog(@"User dismissed popover");
	if (popoverController == self.assetTypePickerPopover) {
		BNRAssetTypeViewController *avc = (BNRAssetTypeViewController *)self.assetTypePickerPopover.contentViewController;
		NSString *typeLabel = [avc.item.assetType valueForKey:@"label"];
		if (!typeLabel) {
			typeLabel = @"None";
		}
		self.assetTypeButton.title = [NSString stringWithFormat:@"Type: %@", typeLabel];
		self.assetTypePickerPopover = nil;
	} else if (popoverController == self.imagePickerPopover) {
		self.imagePickerPopover = nil;
	}
}

- (void)save:(id)sender {
	[self.presentingViewController dismissViewControllerAnimated:YES completion:self.dismissBlock];
}

- (void)cancel:(id)sender {
	// If the user cancelled, then remove the BNRItem from the store
	[[BNRItemStore sharedStore] removeItem:self.item];
	
	[self.presentingViewController dismissViewControllerAnimated:YES completion:self.dismissBlock];
}

- (IBAction)showAssetTypePicker:(id)sender {
	if (self.assetTypePickerPopover) {
		[self.assetTypePickerPopover dismissPopoverAnimated:YES];
		self.assetTypePickerPopover = nil;
		return;
	}
	
	[self.view endEditing:YES];
	
	BNRAssetTypeViewController *avc = [[BNRAssetTypeViewController alloc] init];
	avc.item = self.item;
	
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
		self.assetTypePickerPopover = [[UIPopoverController alloc] initWithContentViewController:avc];
		self.assetTypePickerPopover.delegate = self;
		avc.popover = self.assetTypePickerPopover;
		[self.assetTypePickerPopover presentPopoverFromBarButtonItem:sender
											permittedArrowDirections:UIPopoverArrowDirectionAny
															animated:YES];
	} else {
		[self.navigationController pushViewController:avc animated:YES];
	}
}

@end
