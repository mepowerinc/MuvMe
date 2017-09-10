#import "AGSignatureCanvas.h"
#import <QuartzCore/QuartzCore.h>

static CGPoint CGPointMidPoint(CGPoint p0, CGPoint p1){
    return CGPointMake((p0.x + p1.x)*0.5f, (p0.y + p1.y)*0.5f);
}

@interface AGSignatureCanvas ()<UIGestureRecognizerDelegate>{
    CGPoint previousPoint;
    UIPanGestureRecognizer *panGestureRecognizer;
}
@end

@implementation AGSignatureCanvas

@synthesize strokeWidth;
@synthesize strokeColor;
@synthesize path;
@synthesize image;
@synthesize enabled;

#pragma mark - Initialization

- (void)dealloc {
    self.strokeColor = nil;
    self.path = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    // enabled
    self.enabled = YES;

    // path
    self.path = [UIBezierPath bezierPath];

    // pan gesture recognizer
    panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
    panGestureRecognizer.cancelsTouchesInView = NO;
    panGestureRecognizer.minimumNumberOfTouches = 1;
    panGestureRecognizer.maximumNumberOfTouches = 1;
    panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:panGestureRecognizer];
    [panGestureRecognizer release];

    // stroke size
    self.strokeWidth = 2.0f;

    // stroke color
    self.strokeColor = [UIColor blackColor];

    return self;
}

#pragma mark - Draw

- (void)drawRect:(CGRect)rect {
    // clipping
    if (self.layer.cornerRadius > 0) {
        [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.layer.cornerRadius] addClip];
    }

    // background color
    if (self.backgroundColor) {
        [self.backgroundColor setFill];
        UIRectFill(rect);
    }

    // lines
    [strokeColor setStroke];
    [path stroke];
}

#pragma mark - Lifecycle

- (BOOL)hasSignature {
    return !path.isEmpty;
}

- (void)setEnabled:(BOOL)enabled_ {
    if (enabled == enabled_) return;

    enabled = enabled_;

    panGestureRecognizer.enabled = enabled_;
}

- (void)setStrokeWidth:(CGFloat)strokeWidth_ {
    if (strokeWidth_ == strokeWidth) return;

    strokeWidth = strokeWidth_;
    path.lineWidth = strokeWidth;

    // display
    [self setNeedsDisplay];
}

- (void)setStrokeColor:(UIColor *)strokeColor_ {
    if ([strokeColor isEqual:strokeColor_]) return;

    [strokeColor release];
    strokeColor = [strokeColor_ retain];

    // display
    [self setNeedsDisplay];
}

- (void)erase {
    self.path = [UIBezierPath bezierPath];
    path.lineWidth = strokeWidth;

    // display
    [self setNeedsDisplay];
}

- (void)onPan:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint currentPoint = [gestureRecognizer locationInView:self];
    CGPoint midPoint = CGPointMidPoint(previousPoint, currentPoint);

    // gesture
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [path moveToPoint:currentPoint];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        [path addQuadCurveToPoint:midPoint controlPoint:previousPoint];
    }

    previousPoint = currentPoint;

    // display
    [self setNeedsDisplay];
}

- (UIImage *)image {
    UIGraphicsBeginImageContext(self.bounds.size);
    [strokeColor setStroke];
    [path stroke];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return result;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }

    return YES;
}

@end
