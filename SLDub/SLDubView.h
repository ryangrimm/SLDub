// SLDubView.h
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

#import <UIKit/UIKit.h>
#import "SLDubItem.h"

typedef void (^SLDubViewItemEventBlock)();

@interface SLDubView : UIView

- (id)initWithIdentifier:(NSString *)identifier;
- (id)initWithFrame:(CGRect)frame identifier:(NSString *)identifier;

- (void)forItem:(SLDubItem *)item setTapBlock:(SLDubViewItemEventBlock)tapBlock;

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic) BOOL dismissOnTap;

@end

@interface SLDubView (Private)

- (void)punchHole:(UIBezierPath *)holePath forItem:(SLDubItem *)item;
- (void)patchHoleForItem:(SLDubItem *)item;
- (void)updateHole:(UIBezierPath *)holePath forItem:(SLDubItem *)item animated:(BOOL)animated;

@end
