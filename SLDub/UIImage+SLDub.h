//
//  UIImage+SLDub.h
//  SLDub-Example
//
//  Created by Ryan Grimm on 1/20/15.
//  Copyright (c) 2015 Swell Lines LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (SLDub)

- (UIBezierPath *)pathFromInnerAlpha:(CGFloat)threshold;

@end
