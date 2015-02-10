// SLDubItem.m
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


#import "SLDubItem.h"
#import "SLDubView.h"

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define SLDUBVIEWSTUBLENGTH 10

typedef enum {
    SLDubItemAxisX,
    SLDubItemAxisY
} SLDubItemAxis;

@interface SLDubItem ()
@property (nonatomic, strong) CATextLayer *messageLayer;
@property (nonatomic) BOOL connectionStartDirectionSetManually;
@property (nonatomic) BOOL connectionEndDirectionSetManually;
@property (nonatomic, weak) SLDubView *helpView;
@property (nonatomic) CGRect messageTextRect;
@end

@implementation SLDubItem

@synthesize messageRect = _messageRect;

- (id)init {
    self = [super init];
    if(self) {
        [self commonInit];
    }

    return self;
}

- (id)initWithLayer:(id)layer {
    self = [super initWithLayer:layer];
    if(self) {
        [self commonInit];
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self commonInit];
    }

    return self;
}

- (void)commonInit {
    self.fillColor = [UIColor clearColor].CGColor;
    self.lineWidth = 2;
    self.contentsScale = [[UIScreen mainScreen] scale];

    self.messageLayer = [[CATextLayer alloc] init];
    self.messageLayer.wrapped = YES;
    self.messageLayer.contentsScale = [[UIScreen mainScreen] scale];
    self.tintColor = [UIColor whiteColor];
    self.font = [UIFont boldSystemFontOfSize:14];
    self.textTruncation = SLDubItemTruncationEnd;

    self.contentsScale = [[UIScreen mainScreen] scale];
}


- (void)addToHelpView:(SLDubView *)helpView {
    self.helpView = helpView;

    self.frame = helpView.bounds;

    [self calculatePointsAndDirections];
    [helpView.layer addSublayer:self];

    [helpView punchHole:self.portalPath forItem:self];
    [self render:NO];
}

- (void)removeFromHelpView {
    [self removeFromSuperlayer];
    [self.helpView patchHoleForItem:self];
    self.helpView = nil;
}

- (void)setPortalPath:(UIBezierPath *)portalPath {
    _portalPath = portalPath;

    [self calculatePointsAndDirections];
}

- (void)setMessage:(id)message {
    if([message isKindOfClass:[NSMutableAttributedString class]]) {
        message = [[NSAttributedString alloc] initWithAttributedString:message];
    }

    assert([message isKindOfClass:[NSString class]] || [message isKindOfClass:[NSAttributedString class]]);

    self.messageLayer.string = message;

    [self calculateTextRect];
    [self calculatePointsAndDirections];
}

- (NSString *)message {
    return self.messageLayer.string;
}

- (void)setMessageRect:(CGRect)messageRect {
    _messageRect = messageRect;
    self.messageLayer.frame = messageRect;

    [self calculateTextRect];
    [self calculatePointsAndDirections];
}

- (CGRect)messageRect {
    return _messageRect;
}

- (void)setSizeMessageToText:(BOOL)sizeMessageToText {
    _sizeMessageToText = sizeMessageToText;

    [self calculateTextRect];
    [self calculatePointsAndDirections];
}

- (void)setTintColor:(UIColor *)tintColor {
    _tintColor = tintColor;

    self.strokeColor = tintColor.CGColor;
    self.messageLayer.foregroundColor = tintColor.CGColor;
}

- (void)setFont:(UIFont *)font {
    _font = font;

    self.messageLayer.font = CFBridgingRetain(font.fontName);
    self.messageLayer.fontSize = font.pointSize;

    [self calculatePointsAndDirections];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    _textAlignment = textAlignment;

    switch (textAlignment) {
        case NSTextAlignmentLeft:
            self.messageLayer.alignmentMode = kCAAlignmentLeft;
            break;
        case NSTextAlignmentCenter:
            self.messageLayer.alignmentMode = kCAAlignmentCenter;
            break;
        case NSTextAlignmentRight:
            self.messageLayer.alignmentMode = kCAAlignmentRight;
            break;
        case NSTextAlignmentJustified:
            self.messageLayer.alignmentMode = kCAAlignmentJustified;
            break;
        case NSTextAlignmentNatural:
            self.messageLayer.alignmentMode = kCAAlignmentNatural;
            break;
    }

    [self calculatePointsAndDirections];
}

- (void)setTextTruncation:(SLDubItemTruncation)textTruncation {
    _textTruncation = textTruncation;

    switch (textTruncation) {
        case SLDubItemTruncationNone:
            self.messageLayer.truncationMode = kCATruncationNone;
            break;
        case SLDubItemTruncationStart:
            self.messageLayer.truncationMode = kCATruncationStart;
            break;
        case SLDubItemTruncationEnd:
            self.messageLayer.truncationMode = kCATruncationEnd;
            break;
        case SLDubItemTruncationMiddle:
            self.messageLayer.truncationMode = kCATruncationMiddle;
            break;
    }
}

- (void)setConnectionStartDirection:(SLDubItemDirection)connectionStartDirection {
    _connectionStartDirection = connectionStartDirection;
    self.connectionStartDirectionSetManually = YES;
    [self calculatePointsAndDirections];
}

- (void)setConnectionEndDirection:(SLDubItemDirection)connectionEndDirection {
    _connectionEndDirection = connectionEndDirection;
    self.connectionEndDirectionSetManually = YES;
    [self calculatePointsAndDirections];
}

- (void)calculateTextRect {
    CGRect messageTextRect = self.messageRect;
    messageTextRect.size = [self messageSizeForWidth:self.messageRect.size.width];
    messageTextRect.origin.x += (self.messageRect.size.width - messageTextRect.size.width) / 2.0;

    if(self.sizeMessageToText) {
        self.messageLayer.frame = messageTextRect;
        self.messageTextRect = messageTextRect;
    }
    else if(messageTextRect.size.height > self.messageRect.size.height) {
        messageTextRect.size.height = self.messageRect.size.height;
        self.messageTextRect = messageTextRect;
    }
    else {
        self.messageTextRect = messageTextRect;
    }
}

- (void)calculatePointsAndDirections {
    if(self.portalPath == nil || ((NSString *)self.message).length == 0 || CGRectEqualToRect(self.messageTextRect, CGRectZero)) {
        return;
    }

    CGRect portalBounds = self.portalPath.bounds;
    CGRect descRect = self.messageTextRect;
    CGPoint endPoint;
    SLDubItemDirection lastMove;

    CGFloat messageTextPointY = descRect.origin.y + (self.font.pointSize * 0.5) + 1;
    CGFloat messageMidpointX = descRect.origin.x + (descRect.size.width * 0.5);
    CGFloat messageMidpointY = descRect.origin.y + (descRect.size.height * 0.5);

    if(self.connectionEndDirectionSetManually) {
        lastMove = self.connectionEndDirection;
        switch (self.connectionEndDirection) {
            case SLDubItemDirectionUp:
                endPoint = CGPointMake(messageMidpointX, descRect.origin.y + descRect.size.height + 2);
                break;
            case SLDubItemDirectionDown:
                endPoint = CGPointMake(messageMidpointX, descRect.origin.y - 2);
                break;
            case SLDubItemDirectionLeft:
                endPoint = CGPointMake(descRect.origin.x + descRect.size.width + 2, messageTextPointY);
                break;
            case SLDubItemDirectionRight:
                endPoint = CGPointMake(descRect.origin.x - 2, messageTextPointY);
                break;
        }
    }
    else {
        switch (self.textAlignment) {
            case NSTextAlignmentLeft:
            case NSTextAlignmentNatural:
                endPoint = CGPointMake(descRect.origin.x - 2, messageTextPointY);
                lastMove = SLDubItemDirectionRight;
                break;
            case NSTextAlignmentRight:
                endPoint = CGPointMake(descRect.origin.x + descRect.size.width + 2, messageTextPointY);
                lastMove = SLDubItemDirectionLeft;
                break;
            case NSTextAlignmentCenter:
            case NSTextAlignmentJustified:
                // The message is above the portal
                if(messageMidpointY <= portalBounds.origin.y) {
                    endPoint = CGPointMake(messageMidpointX, descRect.origin.y + descRect.size.height + 2);
                    lastMove = SLDubItemDirectionUp;
                }
                // The message is below the portal
                else {
                    endPoint = CGPointMake(messageMidpointX, descRect.origin.y - 2);
                    lastMove = SLDubItemDirectionDown;
                }
                break;
        }
    }


    CGPoint startPoint = CGPointZero;

    CGPoint portalTopmostPoint = CGPointMake(portalBounds.origin.x + (portalBounds.size.width * 0.5), portalBounds.origin.y);
    CGPoint portalBottommostPoint = CGPointMake(portalBounds.origin.x + (portalBounds.size.width * 0.5), portalBounds.origin.y + portalBounds.size.height);
    CGPoint portalLeftmostPoint = CGPointMake(portalBounds.origin.x, portalBounds.origin.y + (portalBounds.size.height * 0.5));
    CGPoint portalRightmostPoint = CGPointMake(portalBounds.origin.x + portalBounds.size.width, portalBounds.origin.y + (portalBounds.size.height * 0.5));

    if(self.connectionStartDirectionSetManually) {
        switch (self.connectionStartDirection) {
            case SLDubItemDirectionUp:
                startPoint = portalTopmostPoint;
                break;
            case SLDubItemDirectionDown:
                startPoint = portalBottommostPoint;
                break;
            case SLDubItemDirectionLeft:
                startPoint = portalLeftmostPoint;
                break;
            case SLDubItemDirectionRight:
                startPoint = portalRightmostPoint;
                break;
        }
    }
    else {
        SLDubItemDirection firstMove;
        BOOL labelIsAbove = endPoint.y < portalTopmostPoint.y;
        BOOL labelIsBelow = endPoint.y > portalBottommostPoint.y;
        BOOL labelIsRight = endPoint.x > portalRightmostPoint.x;
        BOOL labelIsLeft = endPoint.x < portalLeftmostPoint.x;

        if(labelIsAbove) {
            startPoint = portalTopmostPoint;
            firstMove = SLDubItemDirectionUp;
        }
        else if(labelIsBelow) {
            startPoint = portalBottommostPoint;
            firstMove = SLDubItemDirectionDown;
        }
        else if(labelIsRight) {
            startPoint = portalRightmostPoint;
            firstMove = SLDubItemDirectionRight;
        }
        else if(labelIsLeft) {
            startPoint = portalLeftmostPoint;
            firstMove = SLDubItemDirectionLeft;
        }
        else {
            NSLog(@"ERROR: Label intersects portal");
            return;
        }

        _connectionStartDirection = firstMove;
    }

    if(CGPointEqualToPoint(startPoint, CGPointZero)) {
        return;
    }

    _connectionStartPoint = startPoint;
    _connectionEndPoint = endPoint;
    _connectionEndDirection = self.connectionEndDirectionSetManually ? _connectionEndDirection : lastMove;
}

- (void)render:(BOOL)animated {
    self.frame = self.superlayer.bounds;

    if(self.message && self.messageLayer.superlayer == nil) {
        [self addSublayer:self.messageLayer];
    }

    UIBezierPath *linePath = [self makePath];

    [self.helpView updateHole:self.portalPath forItem:self animated:animated];
    
    if(animated) {
        CABasicAnimation* lineLayerAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        lineLayerAnimation.duration = 0.15;
        lineLayerAnimation.fromValue = (id)self.path;
        lineLayerAnimation.toValue = (id)linePath.CGPath;

        self.path = linePath.CGPath;
        [self addAnimation:lineLayerAnimation forKey:@"path"];
    }
    else {
        self.path = linePath.CGPath;
    }
}

- (UIBezierPath *)makePath {
    if(self.portalPath == nil || ((NSString *)self.message).length == 0) {
        return nil;
    }

    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath appendPath:self.portalPath];

    NSMutableArray *points = [NSMutableArray arrayWithCapacity:10];
    [self generatePointsFrom:self.connectionStartPoint moving:self.connectionStartDirection intoArray:points];

    [linePath moveToPoint:self.connectionStartPoint];
    CGPoint lastPoint = self.connectionStartPoint;

    for(NSInteger i = 0; i < points.count; i++) {
        CGPoint thisPoint = [points[i][@"point"] CGPointValue];
        CGPoint nextPoint;
        if(i == points.count - 1) {
            nextPoint = self.connectionEndPoint;
        }
        else {
            nextPoint = [points[i + 1][@"point"] CGPointValue];
        }

        CGFloat thisLineLength = [self lengthBetween:thisPoint otherPoint:lastPoint];
        CGFloat nextLineLength = [self lengthBetween:thisPoint otherPoint:nextPoint];
        CGFloat maxRadius = MIN(thisLineLength, nextLineLength) * 0.5;

        CGFloat radius = maxRadius;
        if(self.connectionCornerRadius >= 0) {
            radius = MIN(self.connectionCornerRadius, maxRadius);
        }

        SLDubItemDirection directionIn = (SLDubItemDirection)[points[i][@"directionIn"] integerValue];
        SLDubItemDirection directionOut = (SLDubItemDirection)[points[i][@"directionOut"] integerValue];

        CGPoint cornerPoint = thisPoint;
        CGPoint endPoint = thisPoint;
        CGPoint startPoint = thisPoint;


        BOOL clockwise = YES;
        if((directionIn == SLDubItemDirectionLeft && directionOut == SLDubItemDirectionDown) ||
           (directionIn == SLDubItemDirectionRight && directionOut == SLDubItemDirectionUp) ||
           (directionIn == SLDubItemDirectionUp && directionOut == SLDubItemDirectionLeft) ||
           (directionIn == SLDubItemDirectionDown && directionOut == SLDubItemDirectionRight)) {
            clockwise = NO;
        }

        CGFloat startAngle = [self directionToAngle:directionIn clockwise:clockwise];
        CGFloat endAngle = [self directionToAngle:directionOut clockwise:clockwise];

        switch (directionIn) {
            case SLDubItemDirectionUp:
                endPoint.y += radius;
                cornerPoint.y += radius;
                break;
            case SLDubItemDirectionDown:
                endPoint.y -= radius;
                cornerPoint.y -= radius;
                break;
            case SLDubItemDirectionLeft:
                endPoint.x += radius;
                cornerPoint.x += radius;
                break;
            case SLDubItemDirectionRight:
                endPoint.x -= radius;
                cornerPoint.x -= radius;
                break;
        }
        switch (directionOut) {
            case SLDubItemDirectionUp:
                startPoint.y -= radius;
                cornerPoint.y -= radius;
                break;
            case SLDubItemDirectionDown:
                startPoint.y += radius;
                cornerPoint.y += radius;
                break;
            case SLDubItemDirectionLeft:
                startPoint.x -= radius;
                cornerPoint.x -= radius;
                break;
            case SLDubItemDirectionRight:
                startPoint.x += radius;
                cornerPoint.x += radius;
                break;
        }

        [linePath addLineToPoint:endPoint];
        [linePath addArcWithCenter:cornerPoint radius:radius startAngle:startAngle endAngle:endAngle clockwise:clockwise];

        lastPoint = thisPoint;
    }

    [linePath addLineToPoint:self.connectionEndPoint];

    return linePath;
}

- (CGFloat)directionToAngle:(SLDubItemDirection)direction clockwise:(BOOL)clockwise {
    switch (direction) {
        case SLDubItemDirectionUp:
            return clockwise ? DEGREES_TO_RADIANS(180) : DEGREES_TO_RADIANS(0);
        case SLDubItemDirectionDown:
            return clockwise ? DEGREES_TO_RADIANS(0) : DEGREES_TO_RADIANS(180);
        case SLDubItemDirectionLeft:
            return clockwise ? DEGREES_TO_RADIANS(90) : DEGREES_TO_RADIANS(270);
        case SLDubItemDirectionRight:
            return clockwise ? DEGREES_TO_RADIANS(270) : DEGREES_TO_RADIANS(90);
    }
}

- (void)generatePointsFrom:(CGPoint)startPoint moving:(SLDubItemDirection)startDirection intoArray:(NSMutableArray *)points {
    CGPoint nextPoint;
    SLDubItemDirection nextDirection;

    BOOL startDirectionMovesOnY = startDirection == SLDubItemDirectionUp || startDirection == SLDubItemDirectionDown;
    BOOL goalDirectionMovesOnY = self.connectionEndDirection == SLDubItemDirectionUp || self.connectionEndDirection == SLDubItemDirectionDown;
    BOOL endPointIsLeftOfStartPoint = self.connectionEndPoint.x < startPoint.x;
    BOOL endPointIsAboveStartPoint = self.connectionEndPoint.y < startPoint.y;

    if(CGPointEqualToPoint(startPoint, self.connectionStartPoint) && (
       (startDirection == SLDubItemDirectionUp && startPoint.y <= self.connectionEndPoint.y) ||
       (startDirection == SLDubItemDirectionDown && startPoint.y >= self.connectionEndPoint.y) ||
       (startDirection == SLDubItemDirectionLeft && startPoint.x <= self.connectionEndPoint.x) ||
       (startDirection == SLDubItemDirectionRight && startPoint.x >= self.connectionEndPoint.x))) {

        nextPoint = [self addStubToPoint:startPoint direction:startDirection];

        if(startDirectionMovesOnY) {
            nextDirection = endPointIsLeftOfStartPoint ? SLDubItemDirectionLeft : SLDubItemDirectionRight;
        }
        else {
            nextDirection = endPointIsAboveStartPoint ? SLDubItemDirectionUp : SLDubItemDirectionDown;
        }
    }
    // Aligned
    else if(startDirection == self.connectionEndDirection) {
        if(startDirectionMovesOnY == NO) {
            if(startPoint.y == self.connectionEndPoint.y) {
                return;
            }

            nextPoint = [self midpointBetween:startPoint and:self.connectionEndPoint onAxis:SLDubItemAxisX];
            nextDirection = endPointIsAboveStartPoint ? SLDubItemDirectionUp : SLDubItemDirectionDown;
        }
        else {
            if(startPoint.x == self.connectionEndPoint.x) {
                return;
            }

            nextPoint = [self midpointBetween:startPoint and:self.connectionEndPoint onAxis:SLDubItemAxisY];
            nextDirection = endPointIsLeftOfStartPoint ? SLDubItemDirectionLeft : SLDubItemDirectionRight;
        }
    }
    // Off by 90º
    else if(startDirectionMovesOnY != goalDirectionMovesOnY) {
        // Handling the "S" cases
        if(self.connectionEndDirection == SLDubItemDirectionUp && endPointIsAboveStartPoint == NO) {
            nextPoint = [self midpointBetween:startPoint and:self.connectionEndPoint onAxis:SLDubItemAxisX];
            nextDirection = SLDubItemDirectionDown;
        }
        else if(self.connectionEndDirection == SLDubItemDirectionDown && endPointIsAboveStartPoint) {
            nextPoint = [self midpointBetween:startPoint and:self.connectionEndPoint onAxis:SLDubItemAxisX];
            nextDirection = SLDubItemDirectionUp;
        }
        else if(self.connectionEndDirection == SLDubItemDirectionLeft && endPointIsLeftOfStartPoint == NO) {
            nextPoint = [self midpointBetween:startPoint and:self.connectionEndPoint onAxis:SLDubItemAxisY];
            nextDirection = SLDubItemDirectionRight;
        }
        else if(self.connectionEndDirection == SLDubItemDirectionRight && endPointIsLeftOfStartPoint) {
            nextPoint = [self midpointBetween:startPoint and:self.connectionEndPoint onAxis:SLDubItemAxisY];
            nextDirection = SLDubItemDirectionLeft;
        }
        // Typical 90º cases
        else if(startDirectionMovesOnY) {
            nextPoint = CGPointMake(startPoint.x, self.connectionEndPoint.y);
            nextDirection = self.connectionEndPoint.x < startPoint.x ? SLDubItemDirectionLeft : SLDubItemDirectionRight;
        }
        else {
            nextPoint = CGPointMake(self.connectionEndPoint.x, startPoint.y);
            nextDirection = self.connectionEndPoint.y < startPoint.y ? SLDubItemDirectionUp : SLDubItemDirectionDown;
        }
    }
    // Off by 180º
    else {
        if(startDirectionMovesOnY) {
            nextPoint = CGPointMake(startPoint.x, self.connectionEndPoint.y);
            nextDirection = self.connectionEndPoint.x < startPoint.x ? SLDubItemDirectionLeft : SLDubItemDirectionRight;
        }
        else {
            nextPoint = CGPointMake(self.connectionEndPoint.x, startPoint.y);
            nextDirection = self.connectionEndPoint.y < startPoint.y ? SLDubItemDirectionUp : SLDubItemDirectionDown;
        }

        nextPoint = [self addStubToPoint:nextPoint direction:startDirection];
    }

    [points addObject:@{
        @"directionIn": @(startDirection),
        @"directionOut": @(nextDirection),
        @"point": [NSValue valueWithCGPoint:nextPoint]
    }];

    [self generatePointsFrom:nextPoint moving:nextDirection intoArray:points];
}

- (CGPoint)midpointBetween:(CGPoint)point1 and:(CGPoint)point2 onAxis:(SLDubItemAxis)axis {
    if(axis == SLDubItemAxisX) {
        CGFloat midX;
        if(point1.x > point2.x) {
            midX = point2.x + (point1.x - point2.x) * 0.5;
        }
        else {
            midX = point1.x + (point2.x - point1.x) * 0.5;
        }
        return CGPointMake(midX, point1.y);
    }
    else {
        CGFloat midY;
        if(point1.y > point2.y) {
            midY = point2.y + (point1.y - point2.y) * 0.5;
        }
        else {
            midY = point1.y + (point2.y - point1.y) * 0.5;
        }
        return CGPointMake(point1.x, midY);
    }
}

- (CGPoint)addStubToPoint:(CGPoint)point direction:(SLDubItemDirection)direction {
    CGPoint newPoint = point;
    switch (direction) {
        case SLDubItemDirectionUp:
            newPoint.y -= SLDUBVIEWSTUBLENGTH;
            break;
        case SLDubItemDirectionDown:
            newPoint.y += SLDUBVIEWSTUBLENGTH;
            break;
        case SLDubItemDirectionLeft:
            newPoint.x -= SLDUBVIEWSTUBLENGTH;
            break;
        case SLDubItemDirectionRight:
            newPoint.x += SLDUBVIEWSTUBLENGTH;
            break;
    }

    return newPoint;
}

- (CGFloat)lengthBetween:(CGPoint)point1 otherPoint:(CGPoint)point2 {
    CGFloat xDelta = point2.x - point1.x;
    CGFloat yDelta = point2.y - point1.y;
    return sqrtf(xDelta * xDelta + yDelta * yDelta);
}

- (CGSize)messageSizeForWidth:(CGFloat)width {
    CGSize size = CGSizeZero;
    if([self.message isKindOfClass:[NSString class]]) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = self.textAlignment;

        NSDictionary *attributes = @{
                 NSFontAttributeName: self.font,
                 NSParagraphStyleAttributeName: paragraphStyle
                 };

       size = [self.messageLayer.string boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    }
    else {
        size = [self.messageLayer.string boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    }

    return size;
}


@end
