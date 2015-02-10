//
//  UIImage+SLDub.m
//  SLDub-Example
//
//  Created by Ryan Grimm on 1/20/15.
//  Copyright (c) 2015 Swell Lines LLC. All rights reserved.
//

#import "UIImage+SLDub.h"

typedef enum {
    UIImageSLDubQuadBottomLeft,
    UIImageSLDubQuadBottomRight,
    UIImageSLDubQuadTopLeft,
    UIImageSLDubQuadTopRight
} UIImageSLDubQuad;

@implementation UIImage (SLDub)

- (UIBezierPath *)pathFromInnerAlpha:(CGFloat)threshold {
    // XXX - check to make sure it has an alpha channel

    // First get the image into a data buffer
    CGImageRef imageRef = self.CGImage;
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerPixel * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);

    BOOL *alphaPixels = calloc(height * width, sizeof(BOOL));

    // Now the rawData contains the image data in the RGBA8888 pixel format.
    NSUInteger byteIndex = 0;
    for (int i = 0; i < width * height; ++i) {
        CGFloat alpha = (rawData[byteIndex + 3] * 1.0) / 255.0;
        alphaPixels[i] = alpha > threshold;
        byteIndex += bytesPerPixel;
    }

    free(rawData);

    CGPoint center = CGPointMake(floor(width / 2.0), floor(height / 2.0));
    CGPoint startingPoint;
    NSUInteger centerRowOffset = (width * center.y);

    UIBezierPath *path = [UIBezierPath bezierPath];

    for(int i = center.x; i <= width; i++) {
        if(alphaPixels[centerRowOffset + i]) {
            startingPoint = CGPointMake(i - 1, center.y);
            break;
        }
    }

    [path moveToPoint:startingPoint];

    NSMutableArray *points = [NSMutableArray arrayWithCapacity:250];

    CGPoint lastPointTR = CGPointMake(0, width);
    BOOL atMax = NO;
    for(int y = center.y; y >= 0 && atMax == NO; y--) {
        for(int x = center.x; x <= width; x++) {
            if(alphaPixels[(int)((width * y) + x)]) {
                atMax = x == center.x;
                lastPointTR = CGPointMake(x - 1, y);
                [path addLineToPoint:lastPointTR];
                break;
            }
        }
    }

    CGPoint lastPointTL = CGPointMake(0, 0);
    for(int y = center.y; y >= 0 && atMax == NO; y--) {
        for(int x = center.x; x <= width; x++) {
            if(alphaPixels[(int)((width * y) + x)]) {
                atMax = x == center.x;
                lastPointTL = CGPointMake(x - 1, y);
                [path addLineToPoint:lastPointTL];
                break;
            }
        }
    }

    /*
    CGPoint lastPointTL = CGPointMake(0, 0);
    atMax = NO;
    for(int x = lastPointTR.x - 1; x >= 0 && atMax == NO; x--) {
        for(int y = lastPointTR.y; y <= center.y; y++) {
            if(alphaPixels[(int)((width * y) + x)]) {
                atMax = y == center.y;
                lastPointTL = CGPointMake(x + 1, y);
                [path addLineToPoint:lastPointTL];
                break;
            }
        }
    }
*/
    CGPoint lastPointBL = CGPointMake(0, 0);
    atMax = NO;
    for(int y = lastPointTL.y; y <= height && atMax == NO; y++) {
        for(int x = center.x; x >= 0; x--) {
            if(alphaPixels[(int)((width * y) + x)]) {
                atMax = x == center.x;
                lastPointBL = CGPointMake(x - 1, y);
                [path addLineToPoint:lastPointBL];
                break;
            }
        }
    }





/*
    for(int y = lastPointTR.y; y <= center.y; y++) {
        for(int x = center.x; x >= 0; x--) {
            if(alphaPixels[(int)((width * y) + x)]) {
                lastPointTR = CGPointMake(x + 1, y);
                [path addLineToPoint:lastPointTR];
                break;
            }
        }
    }


    atMax = NO;
    for(int y = center.y; y <= height && atMax == NO; y++) {
        for(int x = center.x; x >= 0; x--) {
            if(alphaPixels[(int)((width * y) + x)]) {
                atMax = x == center.x;
                lastPointTR = CGPointMake(x + 1, y);
                [path addLineToPoint:lastPointTR];
                break;
            }
        }
    }

    atMax = NO;
    for(int y = center.y; y <= height && atMax == NO; y++) {
        for(int x = center.x; x <= width; x++) {
            if(alphaPixels[(int)((width * y) + x)]) {
                atMax = x == center.x;
                lastPointTR = CGPointMake(x - 1, y);
                [path addLineToPoint:lastPointTR];
                break;
            }
        }
    }
*/
    [path closePath];

//    free(alphaPixels);

    return path;
}


@end
