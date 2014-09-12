// SLDubView.m
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

#import "SLDubView.h"

@interface SLDubView ()
@property (nonatomic, strong) UIBezierPath *portalPath;
@property (nonatomic, strong) CAShapeLayer *fillLayer;
@property (nonatomic, strong) NSMapTable *holes;
@property (nonatomic, strong) NSMapTable *tapBlocks;
@end

@implementation SLDubView

+ (void)resetAllIdentifiers {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *seen = [defaults objectForKey:@"com.swelllines.sldub.identifiers"];
    for(NSString *identifier in seen) {
        if([identifier isKindOfClass:[NSString class]]) {
            [defaults setBool:NO forKey:identifier];
        }
    }
    [defaults removeObjectForKey:@"com.swelllines.sldub.identifiers"];
    [defaults synchronize];
}

+ (void)resetIdentifier:(NSString *)identifier {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:identifier];
    [defaults synchronize];
}

+ (BOOL)hasShownIdentifier:(NSString *)identifier {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:identifier];
}

- (id)init {
    self = [super init];
    if(self) {
        [self commonInit];
    }

    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self commonInit];
    }

    return self;
}

- (id)initWithIdentifier:(NSString *)identifier {
    self = [super init];
    if(self) {
        self.identifier = identifier;
        [self commonInit];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame identifier:(NSString *)identifier {
    self = [super initWithFrame:frame];
    if(self) {
        self.identifier = identifier;
        [self commonInit];
    }

    return self;
}

- (void)commonInit {
    self.holes = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableStrongMemory];
    self.tapBlocks = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableCopyIn];
    self.dismissOnTap = YES;
    self.animationDuration = 0.15;
    
    self.fillLayer = [CAShapeLayer layer];
    self.fillLayer.fillRule = kCAFillRuleEvenOdd;
    self.fillLayer.fillColor = [UIColor colorWithWhite:0 alpha:0.75].CGColor;
    [self.layer addSublayer:self.fillLayer];

    if(self.identifier.length) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *seen = [defaults objectForKey:@"com.swelllines.sldub.identifiers"];
        if(seen == nil) {
            seen = @[];
        }

        if([seen containsObject:self.identifier] == NO) {
            seen = [seen arrayByAddingObject:self.identifier];
            [defaults setObject:seen forKey:@"com.swelllines.sldub.identifiers"];
            [defaults synchronize];
        }
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.fillLayer.frame = self.bounds;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    self.fillLayer.fillColor = backgroundColor.CGColor;
}

- (void)removeFromSuperview {
    if(self.identifier.length) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:self.identifier];
        [defaults synchronize];
    }
}

- (void)forItem:(SLDubItem *)item setTapBlock:(SLDubViewItemEventBlock)tapBlock {
    if(item == nil || tapBlock == nil) {
        return;
    }

    [self.tapBlocks setObject:tapBlock forKey:item];
}

- (void)punchHole:(UIBezierPath *)holePath forItem:(SLDubItem *)item {
    if(item == nil || holePath == nil) {
        return;
    }
    [self.holes setObject:holePath forKey:item];
    [self render:NO];
}

- (void)patchHoleForItem:(SLDubItem *)item {
    if(item == nil) {
        return;
    }

    if([self.holes objectForKey:item] != nil) {
        [self.holes removeObjectForKey:item];
    }
    if([self.tapBlocks objectForKey:item] != nil) {
        [self.tapBlocks removeObjectForKey:item];
    }

    [self render:NO];
}

- (void)updateHole:(UIBezierPath *)holePath forItem:(SLDubItem *)item animated:(BOOL)animated {
    if(item == nil || holePath == nil || [self.holes objectForKey:item] == nil) {
        return;
    }

    [self.holes setObject:holePath forKey:item];
    [self render:animated];
}

- (void)render:(BOOL)animated {
    UIBezierPath *portalPath = [UIBezierPath bezierPathWithRect:self.bounds];
    for(SLDubItem *item in self.holes) {
        [portalPath appendPath:[self.holes objectForKey:item]];
    }
    portalPath.usesEvenOddFillRule = YES;

    if(animated) {
        CABasicAnimation* fillLayerAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        fillLayerAnimation.duration = self.animationDuration;
        fillLayerAnimation.fromValue = (id)self.fillLayer.path;
        fillLayerAnimation.toValue = (id)portalPath.CGPath;

        self.fillLayer.path = portalPath.CGPath;
        [self.fillLayer addAnimation:fillLayerAnimation forKey:@"path"];
    }
    else {
        self.fillLayer.path = portalPath.CGPath;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if(touches.count != 1) {
        [super touchesEnded:touches withEvent:event];
        return;
    }

    UITouch *touch = touches.anyObject;
    if(touch.phase != UITouchPhaseEnded) {
        [super touchesEnded:touches withEvent:event];
        return;
    }

    CGPoint tapPoint = [touch locationInView:self];
    BOOL tappedInPortal = NO;
    for(SLDubItem *item in self.tapBlocks) {
        if([item.portalPath containsPoint:tapPoint]) {
            SLDubViewItemEventBlock tapBlock = [self.tapBlocks objectForKey:item];
            tapBlock();
            tappedInPortal = YES;
        }
    }

    if(tappedInPortal || self.dismissOnTap == NO) {
        return;
    }

    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;
    }
    completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
