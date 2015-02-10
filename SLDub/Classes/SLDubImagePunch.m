//
//  SLDubImagePunch.m
//  SLDub-Example
//
//  Created by Ryan Grimm on 1/22/15.
//  Copyright (c) 2015 Swell Lines LLC. All rights reserved.
//

#import "SLDubImagePunch.h"

// We allocate the memory for the image mask here, but the CGImageRef is used
// outside of here. So provide a callback to free up the memory after the
// caller is done with the CGImageRef.
static void MaskDataProviderReleaseDataCallback(void *info, const void *data, size_t size) {
    free((void*)data);
}

@interface SLDubImagePunch ()

@end

@implementation SLDubImagePunch {
    NSUInteger _width;
    NSUInteger _height;
    NSMutableArray *_lineStack;
    NSUInteger _bytesPerPixel;

    CGImageRef _imageRef;
    unsigned char *_rawPixels;

    // The raw data for the resulting image mask
    unsigned char *_maskRows;
    NSUInteger mMaskRowBytes;

    // An intermediate table we use when examining the source image to determine
    // if we have visited a specific pixel location.
    BOOL *_visited;
}

- (id)initWithImage:(UIImage *)image threshold:(CGFloat)threshold {
    self = [super init];
    if (self) {
        self.image = image;
        self.threshold = threshold;

        _imageRef = self.image.CGImage;
        _width = CGImageGetWidth(_imageRef);
        _height = CGImageGetHeight(_imageRef);

        // calloc marks the mask as all black, or all masked in (i.e. the image
        // would be all there, by default). So use memset() to mark them all
        // transparent.
        mMaskRowBytes = (_width + 0x0000000F) & ~0x0000000F;
        _maskRows = calloc(_height, mMaskRowBytes);
        memset(_maskRows, 0xFF, _height * mMaskRowBytes);

        // Calloc marks them all as not visited
        _visited = calloc(_height * _width, sizeof(BOOL));

        // Create a stack to hold the line segments that still need to be processed.
        _lineStack = [NSMutableArray arrayWithCapacity:_height];
    }

    return self;
}

- (void) dealloc {
    free(_maskRows);
    free(_visited);
}

- (void)process {
    // First get the image into a data buffer.
    // After _rawPixels will contain the image data in a RGBA8888 pixel format.
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    _rawPixels = (unsigned char*) calloc(_height * _width * 4, sizeof(unsigned char));
    _bytesPerPixel = 4;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(_rawPixels, _width, _height, bitsPerComponent, _bytesPerPixel * _width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, _width, _height), _imageRef);
    CGContextRelease(context);

    // Prime the loop so we have something on the stack. searcLineAtPoint
    // will look both to the right and left for alpha pixels. It will then
    // throw that line segment onto the stack.
    [self searchLineAtPoint:CGPointMake(floor(_width / 2.0), floor(_height / 2.0))];

    // While the stack isn't empty, continue to process line segments that
    // are on the stack.
    while(_lineStack.count > 0) {
        // Pop the top segment off the stack
        NSDictionary* segment = [_lineStack lastObject];
        [_lineStack removeLastObject];

        // Process the segment, by looking both above and below it for alpha pixels
        [self processSegment:segment];
    }

    free(_rawPixels);
}


- (void)searchLineAtPoint:(CGPoint)point {
    // This function will look at the point passed in to see if it matches
    // the selected pixel. It will then look to the left and right of the
    // passed in point for pixels that match. In addition to adding a line
    // segment to the stack (to be processed later), it will mark the _visited
    // and _maskRows bitmaps to reflect if the pixels have been visited or
    // should be selected.

    // First, we want to do some sanity checking. This includes making sure
    // the point is in bounds, and that the specified point hasn't already
    // been visited.
    if((point.y < 0) || (point.y >= _height) || (point.x < 0) || (point.x >= _width)) {
        return;
    }

    BOOL *hasBeenVisited = (_visited + (long)point.y * _width + (long)point.x);
    if(*hasBeenVisited) {
        return;
    }

    // Make sure the point we're starting at at least matches. If it doesn't,
    // there's not a line segment here, and we can bail.
    if(![self markPointIfItMatches:point]) {
        return;
    }

    // Search left, marking pixels as visited, and in or out of the selection
    CGFloat x = point.x - 1.0;
    CGFloat left = point.x;
    while(x >= 0) {
        if([self markPointIfItMatches:CGPointMake(x, point.y)]) {
            left = x; // Expand our line segment to the left
        }
        else {
            break; // If it doesn't match, the we're done looking
        }
        x = x - 1.0;
    }

    // Search right, marking pixels as visited, and in or out of the selection
    CGFloat right = point.x;
    x = point.x + 1.0;
    while(x < _width) {
        if([self markPointIfItMatches: CGPointMake(x, point.y)]) {
            right = x; // Expand our line segment to the right
        }
        else {
            break; // If it doesn't match, the we're done looking
        }
        x = x + 1.0;
    }

    // Push the segment we just found onto the stack, so we can look above and below it later.
    NSDictionary *segment = @{
        @"left": @(left),
        @"right": @(right),
        @"y": @(point.y)
    };
    [_lineStack addObject:segment];
}

- (BOOL)markPointIfItMatches:(CGPoint) point {
    // This method examines a specific pixel to see if it should be in the selection
    //	or not, by determining if it is "close" to the user picked pixel. Regardless
    //	of it is in the selection, we mark the pixel as visited so we don't examine
    //	it again.

    // Do some sanity checking. If its already been visited, then it doesn't match
    BOOL *hasBeenVisited = (_visited + (long)point.y * _width + (long)point.x);
    if(*hasBeenVisited) {
        return NO;
    }

    // Ask a helper function to determine if the pixel passed in matches the user selected pixel
    BOOL returnValue = NO;
    if([self pixelMatches:point]) {
        returnValue = YES;

        // Now actually mark the mask
        unsigned char *maskRow = _maskRows + (mMaskRowBytes * (long)point.y);
        maskRow[(long)point.x] = 0x00; // all on
    }

    // We've made a decision about this pixel, so we've visted it. Mark it as such.
    *hasBeenVisited = YES;

    return returnValue;
}

- (BOOL)pixelMatches:(CGPoint)point {
    // Fetch out the alpha channel (3) value
    CGFloat alpha = (_rawPixels[[self alphaPixelIndexForPoint:point]] * 1.0) / 255.0;
    return alpha < self.threshold;
}

- (NSUInteger)alphaPixelIndexForPoint:(CGPoint) point {
    NSUInteger index = point.y * _width * _bytesPerPixel;
    index += point.x * _bytesPerPixel + 3;
    return index;
}

- (void)processSegment:(NSDictionary*)segment {
    // Figure out where this segment actually lies, by pulling the line segment
    // information out of the dictionary
    CGFloat left = [segment[@"left"] floatValue];
    CGFloat right = [segment[@"right"] floatValue];
    CGFloat y = [segment[@"y"] floatValue];

    // We're going to walk this segment, and test each integral point both
    // above and below it. Note that we're doing a four point connect.
    for(float x = left; x <= right; x = x + 1.0 ) {
        // check above
        [self searchLineAtPoint:CGPointMake(x, y - 1.0)];
        // check below
        [self searchLineAtPoint:CGPointMake(x, y + 1.0)];
    }
}

- (CGImageRef)createMask {
    // This function takes the raw mask bitmap that we filled in, and creates
    //	a CoreGraphics mask from it.
    
    // Gotta have a data provider to wrap our raw pixels. Provide a callback
    //	for the mask data to be freed. Note that we don't free _maskRows in our
    //	dealloc on purpose.
    CGDataProviderRef provider = CGDataProviderCreateWithData(nil, _maskRows, mMaskRowBytes * _height, &MaskDataProviderReleaseDataCallback);
    
    CGImageRef mask = CGImageMaskCreate(_width, _height, 8, 8, mMaskRowBytes, provider, nil, false);
    
    CGDataProviderRelease(provider);
    
    return mask;
}

@end
