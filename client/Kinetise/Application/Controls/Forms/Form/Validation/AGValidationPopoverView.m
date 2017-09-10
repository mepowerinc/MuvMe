#import "AGValidationPopoverView.h"

@implementation AGValidationPopoverView

@synthesize touchOutsideBlock;

- (void)dealloc {
    self.touchOutsideBlock = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    self.backgroundColor = [UIColor clearColor];
    self.frame = CGRectMake(0, 0, 200, 80);

    return self;
}

#pragma mark - Draw

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGFloat arrowSize = 10;
    CGRect arrowRect = CGRectMake(rect.size.width-arrowSize, CGRectGetMidY(rect)-arrowSize*0.5f, arrowSize, arrowSize);
    CGRect bubbleRect = CGRectMake(0, 0, rect.size.width-arrowSize, rect.size.height);
    CGColorRef color = [UIColor redColor].CGColor;

    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:bubbleRect cornerRadius:8];
    CGContextSetFillColorWithColor(context, color);
    [bezierPath fill];

    CGContextBeginPath(context);
    CGContextMoveToPoint(context, CGRectGetMinX(arrowRect), CGRectGetMinY(arrowRect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(arrowRect), CGRectGetMidY(arrowRect));
    CGContextAddLineToPoint(context, CGRectGetMinX(arrowRect), CGRectGetMaxY(arrowRect));
    CGContextClosePath(context);
    CGContextFillPath(context);
}

#pragma mark - Touches

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *subview = [super hitTest:point withEvent:event];

    if (UIEventTypeTouches == event.type) {
        if (!subview && touchOutsideBlock) {
            touchOutsideBlock();
        }
    }

    return subview;
}

@end
