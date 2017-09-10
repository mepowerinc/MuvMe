#import "AGLayer.h"

@interface AGLayer (){
    CAShapeLayer *borderLayer;
    CAShapeLayer *maskLayer;
    BOOL isDirtyLayers;
}
@end

@implementation AGLayer

@synthesize cornerRadiusTopLeft;
@synthesize cornerRadiusTopRight;
@synthesize cornerRadiusBottomLeft;
@synthesize cornerRadiusBottomRight;
@synthesize borderLeft;
@synthesize borderRight;
@synthesize borderTop;
@synthesize borderBottom;

#pragma mark - Layout

- (void)layoutSublayers {
    [super layoutSublayers];

    if (isDirtyLayers) {
        [self updateRoundedCornersLayer];
        [self updateBorderLayer];
        isDirtyLayers = NO;
    }
}

- (void)setFrame:(CGRect)frame {
    if (!CGSizeEqualToSize(self.frame.size, frame.size) ) {
        isDirtyLayers = YES;
    }

    [super setFrame:frame];
}

- (void)setBounds:(CGRect)bounds {
    if (!CGSizeEqualToSize(self.bounds.size, bounds.size) ) {
        isDirtyLayers = YES;
    }

    [super setBounds:bounds];
}

#pragma mark - Lifecycle

- (void)setCornerRadiusTopLeft:(CGFloat)cornerRadiusTopLeft_ {
    if (cornerRadiusTopLeft == cornerRadiusTopLeft_) return;

    cornerRadiusTopLeft = cornerRadiusTopLeft_;
    isDirtyLayers = YES;
}

- (void)setCornerRadiusTopRight:(CGFloat)cornerRadiusTopRight_ {
    if (cornerRadiusTopRight == cornerRadiusTopRight_) return;

    cornerRadiusTopRight = cornerRadiusTopRight_;
    isDirtyLayers = YES;
}

- (void)setCornerRadiusBottomLeft:(CGFloat)cornerRadiusBottomLeft_ {
    if (cornerRadiusBottomLeft == cornerRadiusBottomLeft_) return;

    cornerRadiusBottomLeft = cornerRadiusBottomLeft_;
    isDirtyLayers = YES;
}

- (void)setCornerRadiusBottomRight:(CGFloat)cornerRadiusBottomRight_ {
    if (cornerRadiusBottomRight == cornerRadiusBottomRight_) return;

    cornerRadiusBottomRight = cornerRadiusBottomRight_;
    isDirtyLayers = YES;
}

- (void)setBorderLeft:(CGFloat)borderLeft_ {
    if (borderLeft_ == borderLeft) return;

    borderLeft = borderLeft_;
    isDirtyLayers = YES;
}

- (void)setBorderRight:(CGFloat)borderRight_ {
    if (borderRight_ == borderRight) return;

    borderRight = borderRight_;
    isDirtyLayers = YES;
}

- (void)setBorderTop:(CGFloat)borderTop_ {
    if (borderTop_ == borderTop) return;

    borderTop = borderTop_;
    isDirtyLayers = YES;
}

- (void)setBorderBottom:(CGFloat)borderBottom_ {
    if (borderBottom_ == borderBottom) return;

    borderBottom = borderBottom_;
    isDirtyLayers = YES;
}

- (void)setBorderColor:(CGColorRef)borderColor_ {
    [super setBorderColor:borderColor_];

    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    borderLayer.fillColor = borderColor_;
    [CATransaction commit];
}

#pragma mark - Rounded Corners

- (void)updateRoundedCornersLayer {
    CGFloat halfSize = self.bounds.size.width*0.5f;
    BOOL hasCornersRadius = cornerRadiusTopLeft+cornerRadiusTopRight+cornerRadiusBottomLeft+cornerRadiusBottomRight > 0.f;
    BOOL isCircle = cornerRadiusTopLeft >= halfSize && cornerRadiusTopRight >= halfSize && cornerRadiusBottomLeft >= halfSize && cornerRadiusBottomRight >= halfSize && self.bounds.size.width == self.bounds.size.height;

    // layer
    if (hasCornersRadius && !maskLayer) {
        maskLayer = [CAShapeLayer layer];
        self.mask = maskLayer;
    }

    // radius
    if (hasCornersRadius) {
        if (isCircle) {
            CGPathRef path = CGPathCreateWithEllipseInRect(self.bounds, nil);
            maskLayer.path = path;
            CFRelease(path);
        } else {
            CGRect rect = self.bounds;
            CGFloat minx = CGRectGetMinX(rect);
            CGFloat midx = CGRectGetMidX(rect);
            CGFloat maxx = CGRectGetMaxX(rect);
            CGFloat miny = CGRectGetMinY(rect);
            CGFloat midy = CGRectGetMidY(rect);
            CGFloat maxy = CGRectGetMaxY(rect);

            CGMutablePathRef path = CGPathCreateMutable();
            CGPathMoveToPoint(path, nil, minx, midy);
            CGPathAddArcToPoint(path, nil, minx, miny, midx, miny, cornerRadiusTopLeft);
            CGPathAddArcToPoint(path, nil, maxx, miny, maxx, midy, cornerRadiusTopRight);
            CGPathAddArcToPoint(path, nil, maxx, maxy, midx, maxy, cornerRadiusBottomRight);
            CGPathAddArcToPoint(path, nil, minx, maxy, minx, midy, cornerRadiusBottomLeft);
            CGPathCloseSubpath(path);

            maskLayer.path = path;
            CFRelease(path);
        }
    } else {
        if (maskLayer == self.mask) {
            self.mask = nil;
        }
        maskLayer = nil;
    }
}

#pragma mark - Border

- (void)updateBorderLayer {
    CGFloat halfSize = self.bounds.size.width*0.5f;
    BOOL hasBorder = borderLeft+borderRight+borderTop+borderBottom > 0.f;
    BOOL hasCornersRadius = cornerRadiusTopLeft+cornerRadiusTopRight+cornerRadiusBottomLeft+cornerRadiusBottomRight > 0.f;
    BOOL isCircle = cornerRadiusTopLeft >= halfSize && cornerRadiusTopRight >= halfSize && cornerRadiusBottomLeft >= halfSize && cornerRadiusBottomRight >= halfSize && self.bounds.size.width == self.bounds.size.height;

    // layer
    if (hasBorder && !borderLayer) {
        borderLayer = [CAShapeLayer layer];
        borderLayer.fillColor = self.borderColor;
        [self addSublayer:borderLayer];
    }

    // border
    if (hasBorder) {
        CGMutablePathRef path = CGPathCreateMutable();

        if (isCircle) {
            borderLayer.fillRule = kCAFillRuleEvenOdd;
        } else {
            borderLayer.fillRule = kCAFillRuleNonZero;
        }

        if (hasCornersRadius) {
            if (isCircle) {
                CGPathAddEllipseInRect(path, nil, CGRectMake(borderLeft, borderTop, self.bounds.size.width-borderLeft-borderRight, self.bounds.size.height-borderTop-borderBottom));
                CGPathAddEllipseInRect(path, nil, self.bounds);
            } else {
                // circle approximated by 4 points
                // α = 4/3 * tan(θ/4)
                // 0.552284777

                // circle approximated by 4 points with error distribution
                // α = 4/3 * tan(θ/4) − 0.03552442 * cos2(θ/4) tan5(θ/4)
                // 0.551915024

                CGFloat factor = 0.552284777f;
                CGRect rect = self.bounds;
                CGFloat minx = CGRectGetMinX(rect);
                CGFloat maxx = CGRectGetMaxX(rect);
                CGFloat miny = CGRectGetMinY(rect);
                CGFloat maxy = CGRectGetMaxY(rect);
                //CGFloat inset = 0;

                // top left corner
                if (cornerRadiusTopLeft) {
                    CGFloat radiusX = MAX(cornerRadiusTopLeft, borderLeft);
                    CGFloat radiusY = MAX(cornerRadiusTopLeft, borderTop);
                    CGPathMoveToPoint(path, nil, minx, miny+radiusY);
                    CGPathAddArcToPoint(path, nil, minx, miny, minx+radiusX, miny, radiusY);
                    CGPathAddLineToPoint(path, nil, minx+radiusX, miny+borderTop);

                    CGPathAddCurveToPoint(path, nil,
                                          minx+radiusX-(radiusX-borderLeft)*factor, miny+borderTop,
                                          minx+borderLeft, miny+radiusY-(radiusY-borderTop)*factor,
                                          minx+borderLeft, miny+radiusY);

                    CGPathAddLineToPoint(path, nil, minx, miny+radiusY);
                    CGPathCloseSubpath(path);
                }

                // top border
                if (borderTop) {
                    CGPathAddRect(path, nil, CGRectMake(cornerRadiusTopLeft, 0, self.bounds.size.width-cornerRadiusTopLeft-cornerRadiusTopRight, borderTop));
                }

                // top right corner
                if (cornerRadiusTopRight) {
                    CGFloat radiusX = MAX(cornerRadiusTopRight, borderRight);
                    CGFloat radiusY = MAX(cornerRadiusTopRight, borderTop);
                    CGPathMoveToPoint(path, nil, maxx-radiusX, miny);
                    CGPathAddArcToPoint(path, nil, maxx, miny, maxx, miny+radiusY, cornerRadiusTopRight);
                    CGPathAddLineToPoint(path, nil, maxx-borderRight, miny+radiusY);

                    CGPathAddCurveToPoint(path, nil,
                                          maxx-borderRight, miny+radiusY-(radiusY-borderTop)*factor,
                                          maxx-radiusX+(radiusX-borderRight)*factor, miny+borderTop,
                                          maxx-radiusX, miny+borderTop);

                    CGPathAddLineToPoint(path, nil, maxx-radiusX, miny);
                    CGPathCloseSubpath(path);
                }

                // right border
                if (borderRight) {
                    CGPathAddRect(path, nil, CGRectMake(self.bounds.size.width-borderRight, cornerRadiusTopRight, borderRight, self.bounds.size.height-cornerRadiusTopRight-cornerRadiusBottomRight));
                }

                // bottom right corner
                if (cornerRadiusBottomRight) {
                    CGFloat radiusX = MAX(cornerRadiusBottomRight, borderRight);
                    CGFloat radiusY = MAX(cornerRadiusBottomRight, borderBottom);
                    CGPathMoveToPoint(path, nil, maxx, maxy-radiusY);
                    CGPathAddArcToPoint(path, nil, maxx, maxy, maxx-radiusX, maxy, cornerRadiusBottomRight);
                    CGPathAddLineToPoint(path, nil, maxx-radiusX, maxy-borderBottom);

                    CGPathAddCurveToPoint(path, nil,
                                          maxx-radiusX+(radiusX-borderRight)*factor, maxy-borderBottom,
                                          maxx-borderRight, maxy-radiusY+(radiusY-borderBottom)*factor,
                                          maxx-borderRight, maxy-radiusY);

                    CGPathAddLineToPoint(path, nil, maxx, maxy-radiusY);
                    CGPathCloseSubpath(path);
                }

                // bottom border
                if (borderBottom) {
                    CGPathAddRect(path, nil, CGRectMake(cornerRadiusBottomLeft, self.bounds.size.height-borderBottom, self.bounds.size.width-cornerRadiusBottomLeft-cornerRadiusBottomRight, borderBottom));
                }

                // bottom left corner
                if (cornerRadiusBottomLeft) {
                    CGFloat radiusX = MAX(cornerRadiusBottomLeft, borderLeft);
                    CGFloat radiusY = MAX(cornerRadiusBottomLeft, borderBottom);
                    CGPathMoveToPoint(path, nil, minx+radiusX, maxy);
                    CGPathAddArcToPoint(path, nil, minx, maxy, minx, maxy-radiusY, cornerRadiusBottomLeft);
                    CGPathAddLineToPoint(path, nil, minx+borderLeft, maxy-radiusY);

                    CGPathAddCurveToPoint(path, nil,
                                          minx+borderLeft, maxy-radiusY+(radiusY-borderBottom)*factor,
                                          minx+radiusX-(radiusX-borderLeft)*factor, maxy-borderBottom,
                                          minx+radiusX, maxy-borderBottom);

                    CGPathAddLineToPoint(path, nil, minx+radiusX, maxy);
                    CGPathCloseSubpath(path);
                }

                // left border
                if (borderLeft) {
                    CGPathAddRect(path, nil, CGRectMake(0, cornerRadiusTopLeft, borderLeft, self.bounds.size.height-cornerRadiusTopLeft-cornerRadiusBottomLeft));
                }
            }
        } else {
            if (borderTop) {
                CGPathAddRect(path, nil, CGRectMake(borderLeft, 0, self.bounds.size.width-borderLeft-borderRight, borderTop));
            }
            if (borderBottom) {
                CGPathAddRect(path, nil, CGRectMake(borderLeft, self.bounds.size.height-borderBottom, self.bounds.size.width-borderLeft-borderRight, borderBottom));
            }
            if (borderLeft) {
                CGPathAddRect(path, nil, CGRectMake(0, 0, borderLeft, self.bounds.size.height));
            }
            if (borderRight) {
                CGPathAddRect(path, nil, CGRectMake(self.bounds.size.width-borderRight, 0, borderRight, self.bounds.size.height));
            }
        }

        borderLayer.path = path;
        CFRelease(path);
    } else {
        [borderLayer removeFromSuperlayer];
        borderLayer = nil;
    }
}

@end
