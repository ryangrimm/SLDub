// SLDubItem.h
//
// Copyright (c) 2014 Swell Lines LLC ( http://swelllines.com/ )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>
@class SLDubView;

typedef enum {
    SLDubItemTruncationNone,
    SLDubItemTruncationStart,
    SLDubItemTruncationEnd,
    SLDubItemTruncationMiddle
} SLDubItemTruncation;

typedef enum {
    SLDubItemDirectionUp,
    SLDubItemDirectionRight,
    SLDubItemDirectionDown,
    SLDubItemDirectionLeft
} SLDubItemDirection;

#define SLDubItemConnectionCornerRadiusAuto -1;

@interface SLDubItem : CAShapeLayer

- (void)addToHelpView:(SLDubView *)helpView;
- (void)removeFromHelpView;
- (void)render:(BOOL)animated;

@property (nonatomic, strong) UIBezierPath *portalPath;
@property (nonatomic, strong) NSString *description;
@property (nonatomic) CGRect descriptionRect;
@property (nonatomic) BOOL sizeDescriptionToText;
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic) NSTextAlignment textAlignment;
@property (nonatomic) SLDubItemTruncation textTruncation;
@property (nonatomic) CGFloat connectionCornerRadius;

@property (nonatomic, readonly) CGPoint connectionStartPoint;
@property (nonatomic) SLDubItemDirection connectionStartDirection;
@property (nonatomic, readonly) CGPoint connectionEndPoint;
@property (nonatomic) SLDubItemDirection connectionEndDirection;

@end
