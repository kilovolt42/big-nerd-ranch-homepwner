//
//  BNRItemCell.m
//  Homepwner
//
//  Created by Kyle Stevens on 3/4/14.
//  Copyright (c) 2014 kilovolt42. All rights reserved.
//

#import "BNRItemCell.h"

@interface BNRItemCell ()

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imageViewHeightConstraint;

@end

@implementation BNRItemCell

- (IBAction)showImage:(id)sender {
	if (self.actionBlock) {
		self.actionBlock();
	}
}

- (void)updateInterfaceForDynamicTypeSize {
	UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
	self.nameLabel.font = font;
	self.serialNumberLabel.font = font;
	self.valueLabel.font = font;
	
	static NSDictionary *imageSizetDictionary;
	
	if (!imageSizetDictionary) {
		imageSizetDictionary = @{ UIContentSizeCategoryExtraSmall : @40,
								  UIContentSizeCategorySmall : @40,
								  UIContentSizeCategoryMedium : @40,
								  UIContentSizeCategoryLarge : @40,
								  UIContentSizeCategoryExtraLarge : @45,
								  UIContentSizeCategoryExtraExtraLarge : @55,
								  UIContentSizeCategoryExtraExtraExtraLarge : @65 };
	}
	
	NSString *userSize = [[UIApplication sharedApplication] preferredContentSizeCategory];
	
	NSNumber *imageSize = imageSizetDictionary[userSize];
	self.imageViewHeightConstraint.constant = imageSize.floatValue;
}

- (void)awakeFromNib {
	[self updateInterfaceForDynamicTypeSize];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
		   selector:@selector(updateInterfaceForDynamicTypeSize)
			   name:UIContentSizeCategoryDidChangeNotification
			 object:nil];
	
	NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.thumbnailView
																  attribute:NSLayoutAttributeHeight
																  relatedBy:NSLayoutRelationEqual
																	 toItem:self.thumbnailView
																  attribute:NSLayoutAttributeWidth
																 multiplier:1
																   constant:0];
	[self.thumbnailView addConstraint:constraint];
}

- (void)dealloc {
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
}

@end
