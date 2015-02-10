//
//  SLDubImagePunch.h
//  SLDub-Example
//
//  Created by Ryan Grimm on 1/22/15.
//  Copyright (c) 2015 Swell Lines LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLDubImagePunch : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic) CGFloat threshold;

- (id)initWithImage:(UIImage *)image threshold:(CGFloat)threshold;
- (void)process;
- (CGImageRef) createMask;

@end
