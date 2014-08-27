//
//  BNRImageTransformer.m
//  Homepwner
//
//  Created by Kyle Stevens on 3/15/14.
//  Copyright (c) 2014 kilovolt42. All rights reserved.
//

#import "BNRImageTransformer.h"

@implementation BNRImageTransformer

+ (Class)transformedValueClass {
	return [NSData class];
}

- (id)transformedValue:(id)value {
	if (!value) {
		return nil;
	}
	
	if ([value isKindOfClass:[NSData class]]) {
		return value;
	}
	
	return UIImagePNGRepresentation(value);
}

- (id)reverseTransformedValue:(id)value {
	return [UIImage imageWithData:value];
}

@end
