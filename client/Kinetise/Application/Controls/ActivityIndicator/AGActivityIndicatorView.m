#import "AGActivityIndicatorView.h"
#import <QuartzCore/QuartzCore.h>

@interface AGActivityIndicatorView ()
@property(nonatomic, retain) CALayer *animationLayer;
@end

@implementation AGActivityIndicatorView

@synthesize isAnimating;
@synthesize animationDuration;
@synthesize animationLayer;
@synthesize image;

#pragma mark - Initialization

- (void)dealloc {
    self.animationLayer = nil;
    self.image = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    // self properties
    self.animationDuration = 1;
    self.backgroundColor = [UIColor clearColor];

    // animation layer
    self.animationLayer = [CALayer layer];
    animationLayer.masksToBounds = YES;
    [self.layer addSublayer:animationLayer];

    // notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];

    // start animation
    [self startAnimating];

    return self;
}

- (id)initWithImage:(UIImage *)image_ {
    self = [self initWithFrame:CGRectMake(0, 0, image_.size.width, image_.size.height) ];

    self.image = image_;

    return self;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];

    animationLayer.frame = self.bounds;
}

#pragma mark - Lifecycle

- (void)setImage:(UIImage *)image_ {
    animationLayer.contents = (id)[image_ CGImage];
}

- (void)setHidden:(BOOL)hidden_ {
    [super setHidden:hidden_];

    if (hidden_) {
        [self stopAnimating];
    } else {
        [self startAnimating];
    }
}

#pragma  mark - Animation

- (void)startAnimating {
    if (isAnimating) return;

    isAnimating = YES;

    [self animate];
}

- (void)stopAnimating {
    if (!isAnimating) return;

    isAnimating = NO;

    [CATransaction begin];
    [animationLayer removeAllAnimations];
    [CATransaction commit];
}

- (void)animate {
    [CATransaction begin];
    CABasicAnimation *spinAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    spinAnimation.fromValue = [NSNumber numberWithFloat:M_PI_4];
    spinAnimation.toValue = [NSNumber numberWithFloat:M_PI_4];
    spinAnimation.duration = 0.125f;
    spinAnimation.cumulative = YES;
    spinAnimation.repeatCount = INFINITY;
    [animationLayer addAnimation:spinAnimation forKey:@"spinAnimation"];
    [CATransaction commit];

    [self setNeedsDisplay];

    /*
       [CATransaction begin];
       CABasicAnimation* spinAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
       spinAnimation.toValue = [NSNumber numberWithFloat:2*M_PI];
       spinAnimation.duration = animationDuration;
       spinAnimation.cumulative = YES;
       spinAnimation.removedOnCompletion = YES;
       spinAnimation.repeatCount = INFINITY;
       [animationLayer addAnimation:spinAnimation forKey:@"spinAnimation"];
       [CATransaction commit];
       [self setNeedsDisplay];
     */
}

#pragma mark - Notifications

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    if (shouldRestoreAnimation) {
        [self startAnimating];
        shouldRestoreAnimation = NO;
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    [self stopAnimating];
    shouldRestoreAnimation = YES;
}

@end
