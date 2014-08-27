//
//  BNRImageViewController.m
//  Homepwner
//
//  Created by Kyle Stevens on 3/4/14.
//  Copyright (c) 2014 kilovolt42. All rights reserved.
//

#import "BNRImageViewController.h"

@interface BNRImageViewController ()

@end

@implementation BNRImageViewController

- (void)loadView {
	UIImageView *imageView = [[UIImageView alloc] init];
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	self.view = imageView;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	// We must cast the view to UIImageView so the compiler knows it
	// is okey to send it setImage:
	UIImageView *imageView = (UIImageView *)self.view;
	imageView.image = self.image;
}

@end
