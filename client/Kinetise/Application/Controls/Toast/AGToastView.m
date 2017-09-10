#import "AGToastView.h"
#import <QuartzCore/QuartzCore.h>

typedef void (^AGToastViewHideCallback)(void);

@implementation AGToastView

@synthesize message;
@synthesize bottomMargin;
@synthesize color;

#pragma mark - Initialization

- (void)dealloc {
    self.color = nil;
    self.message = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    // background color
    self.backgroundColor = [UIColor colorWithWhite:0.05f alpha:0.9f];

    // radius
    self.layer.cornerRadius = 2.0f;

    // shadow layer
    CALayer *shadowLayer = [CALayer layer];
    shadowLayer.shadowColor = [UIColor blackColor].CGColor;
    shadowLayer.shadowOpacity = 0.5f;
    shadowLayer.shadowRadius = 2.0f;
    shadowLayer.shadowOffset = CGSizeMake(0, 0);
    shadowLayer.shouldRasterize = YES;
    shadowLayer.rasterizationScale = [UIScreen mainScreen].scale;
    [self.layer addSublayer:shadowLayer];

    // shadow mask layer
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.fillRule = kCAFillRuleEvenOdd;
    maskLayer.shouldRasterize = YES;
    maskLayer.rasterizationScale = [UIScreen mainScreen].scale;
    shadowLayer.mask = maskLayer;

    // label
    label = [[UILabel alloc] initWithFrame:CGRectZero];
    [self addSubview:label];
    [label release];
    label.font = [UIFont systemFontOfSize:10];
    label.textAlignment = NSTextAlignmentLeft;
    label.backgroundColor = [UIColor clearColor];
    label.shadowColor = [UIColor colorWithWhite:0 alpha:0.5f];
    label.shadowOffset = CGSizeMake(1, 1);
    label.textColor = [UIColor whiteColor];
    label.numberOfLines = 0;

    // bottom margin
    bottomMargin = 10;

    // hidden
    self.hidden = YES;

    return self;
}

#pragma mark - Lifecycle

- (void)setBottomMargin:(NSInteger)bottomMargin_ {
    if (bottomMargin == bottomMargin_) return;

    bottomMargin = bottomMargin_;

    [self setNeedsLayout];
}

- (NSString *)message {
    return label.text;
}

- (void)setMessage:(NSString *)message_ {
    if ([label.text isEqualToString:message_]) return;

    label.text = message_;

    [self setNeedsLayout];
}

- (UIColor *)color {
    return self.backgroundColor;
}

- (void)setColor:(UIColor *)color_ {
    if (color_) {
        self.backgroundColor = [color_ colorWithAlphaComponent:0.9f];
    } else {
        self.backgroundColor = [UIColor colorWithWhite:0.05f alpha:0.9f];
    }
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];

    // bounds
    CGFloat width = ceilf(self.superview.bounds.size.width*0.75f);
    CGSize textSize = [label sizeThatFits:CGSizeMake(width, CGFLOAT_MAX) ];
    self.frame = CGRectMake( (self.superview.bounds.size.width-textSize.width-20)*0.5f,
                             self.superview.bounds.size.height-textSize.height-12-bottomMargin,
                             textSize.width+20,
                             textSize.height+12);

    // label
    label.frame = CGRectMake(10, 6, self.bounds.size.width-20, self.bounds.size.height-12);

    // shadow
    CALayer *shadowLayer = [self.layer.sublayers firstObject];
    shadowLayer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.layer.cornerRadius].CGPath;

    CGFloat radius = 2*shadowLayer.shadowRadius;
    CGRect frame = CGRectMake(-radius, -radius, self.layer.bounds.size.width+2*radius, self.layer.bounds.size.height+2*radius);
    CGAffineTransform trans = CGAffineTransformMakeTranslation(radius, radius);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, CGRectMake(0, 0, frame.size.width, frame.size.height));
    CGPathAddPath(path, &trans, shadowLayer.shadowPath);
    CGPathCloseSubpath(path);

    CAShapeLayer *maskLayer = (CAShapeLayer *)shadowLayer.mask;
    maskLayer.frame = frame;
    maskLayer.path = path;
    CFRelease(path);
}

#pragma mark - Show/Hide

- (void)show {
    [self showWithCompletionBlock:nil];
}

- (void)hide {
    [self hideWithCompletionBlock:nil];
}

- (void)showWithCompletionBlock:(void (^)(void))completionBlock {
    if (isAnimating || !self.hidden) return;

    isAnimating = YES;
    self.hidden = NO;
    self.alpha = 0.0f;
    [UIView animateWithDuration:0.2f animations:^{
        self.alpha = 1.0f;
    } completion:^(BOOL finished){
        isAnimating = NO;
        if (completionBlock != nil) {
            completionBlock();
        }
    }];
}

- (void)hideWithCompletionBlock:(void (^)(void))completionBlock {
    if (isAnimating || self.hidden) return;

    isAnimating = YES;
    [UIView animateWithDuration:0.2f animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished){
        isAnimating = NO;
        self.hidden = YES;
        if (completionBlock != nil) {
            completionBlock();
        }
    }];
}

@end
