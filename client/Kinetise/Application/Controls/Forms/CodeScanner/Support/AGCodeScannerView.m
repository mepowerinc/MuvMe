#import "AGCodeScannerView.h"

@implementation AGCodeScannerView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    self.backgroundColor = [UIColor clearColor];

    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextClearRect(context, rect);

    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 2.0f);
    CGFloat size = 20.f;

    CGContextMoveToPoint(context, 0.0f, 0.0f);
    CGContextAddLineToPoint(context, size, 0.0f);
    CGContextMoveToPoint(context, 0.0f, 0.0f);
    CGContextAddLineToPoint(context, 0.0f, size);

    CGContextMoveToPoint(context, self.bounds.size.width, 0.0f);
    CGContextAddLineToPoint(context, self.bounds.size.width-size, 0.0f);
    CGContextMoveToPoint(context, self.bounds.size.width, 0.0f);
    CGContextAddLineToPoint(context, self.bounds.size.width, size);

    CGContextMoveToPoint(context, 0.0f, self.bounds.size.height);
    CGContextAddLineToPoint(context, size, self.bounds.size.height);
    CGContextMoveToPoint(context, 0.0f, self.bounds.size.height);
    CGContextAddLineToPoint(context, 0.0f, self.bounds.size.height-size);

    CGContextMoveToPoint(context, self.bounds.size.width, self.bounds.size.height);
    CGContextAddLineToPoint(context, self.bounds.size.width-size, self.bounds.size.height);
    CGContextMoveToPoint(context, self.bounds.size.width, self.bounds.size.height);
    CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height-size);

    CGContextStrokePath(context);
}

@end
