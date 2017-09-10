#import "AGControl.h"
#import "UIView+Frame.h"
#import "AGActionManager.h"
#import "AGGalleryDesc.h"
#import "AGApplication.h"
#import "AGActionManager.h"
#import "AGLayoutManager.h"
#import "AGFormProtocol.h"
#import "AGFormClientProtocol.h"
#import "AGApplication+Control.h"
#import "NSObject+Nil.h"
#import "UIView+Hierarchy.h"
#import <MapKit/MapKit.h>

@implementation AGControl

@synthesize parent;
@synthesize contentView;
@synthesize state;

#pragma mark - Initialization

- (void)dealloc {
    self.parent = nil;
    [backgroundSource clearDelegatesAndCancel];
    [backgroundSource release];
    [states release];
    [super dealloc];
}

+ (instancetype)controlWithDesc:(AGDesc *)descriptor {
    NSString *classStr = NSStringFromClass([descriptor class]);
    classStr = [classStr stringByReplacingOccurrencesOfString:@"Desc" withString:@""];
    Class viewClass = NSClassFromString(classStr);
    
    return [[[viewClass alloc] initWithDesc:descriptor] autorelease];
}

- (id)initWithDesc:(AGControlDesc *)descriptor_ {
    self = [super initWithDesc:descriptor_];
    
    // states
    states = [[NSMutableDictionary alloc] init];
    
    // state
    state = UIControlStateNormal;
    self.enabled = YES;
    
    // hidden
    self.hidden = descriptor_.hidden;
    
    // normal border color
    UIColor *borderColor = [UIColor colorWithRed:descriptor_.borderColor.r green:descriptor_.borderColor.g blue:descriptor_.borderColor.b alpha:descriptor_.borderColor.a];
    [self setAppearance:@"border_color" withObject:borderColor forState:UIControlStateNormal];
    
    // invalid border color
    UIColor *invalidBorderColor = [UIColor colorWithRed:descriptor_.invalidBorderColor.r green:descriptor_.invalidBorderColor.g blue:descriptor_.invalidBorderColor.b alpha:descriptor_.invalidBorderColor.a];
    [self setAppearance:@"border_color" withObject:invalidBorderColor forState:UIControlStateInvalid];
    
    // background color
    self.backgroundColor = [UIColor colorWithRed:descriptor_.backgroundColor.r green:descriptor_.backgroundColor.g blue:descriptor_.backgroundColor.b alpha:descriptor_.backgroundColor.a];
    
    // background
    if (descriptor_.background) {
        backgroundView = [[AGImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:backgroundView];
        [backgroundView release];
    }
    
    // background source
    if (descriptor_.background) {
        backgroundSource = [[AGImageAsset alloc] initWithUri:[[descriptor_ fullPath:descriptor_.background.value] uriString] ];
        backgroundSource.delegate = self;
    }
    
    // background size mode
    if (descriptor_.backgroundSizeMode == sizeModeStretch) {
        backgroundView.contentMode = UIViewContentModeScaleToFill;
    } else if (descriptor_.backgroundSizeMode == sizeModeShortedge) {
        backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    } else if (descriptor_.backgroundSizeMode == sizeModeLongedge) {
        backgroundView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    // content
    Class contentViewClass = [self contentClass];
    CGFloat borderAndPadding = descriptor_.paddingLeft.value+descriptor_.paddingRight.value+descriptor_.paddingTop.value+descriptor_.paddingBottom.value+descriptor_.borderLeft.value+descriptor_.borderRight.value+descriptor_.borderTop.value+descriptor_.borderBottom.value;
    
    if (contentViewClass == [UIView class] && borderAndPadding == 0) {
        contentView = self;
    } else {
        contentView = [self newContent];
        [self addSubview:contentView];
        [contentView release];
        
        contentView.backgroundColor = [UIColor clearColor];
    }
    contentView.clipsToBounds = YES;
    
    // validation indicator
    if ([self conformsToProtocol:@protocol(AGFormProtocol)]) {
        validationIndicator = [[AGValidationIndicator alloc] initWithFrame:CGRectZero];
        [self addSubview:validationIndicator];
        [validationIndicator release];
    }
    
    // swipe left
    if (descriptor_.onSwipeLeftAction) {
        UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeLeft:)];
        swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [self addGestureRecognizer:swipeLeft];
    }
    
    // swipe right
    if (descriptor_.onSwipeRightAction) {
        UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeRight:)];
        swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:swipeRight];
    }
    
    // disable multitouch
    self.multipleTouchEnabled = NO;
    self.exclusiveTouch = YES;
    
    // previous element
    if ([descriptor_.onClickAction containsScript:@"previousElement()"]) {
        AGFeed *feed = AGAPPLICATION.currentContext;
        if (feed.dataSource && feed.itemIndex <= 0) {
            self.enabled = NO;
        }
    }
    
    // next element
    if ([descriptor_.onClickAction containsScript:@"nextElement()"]) {
        AGFeed *feed = AGAPPLICATION.currentContext;
        if (feed.dataSource && feed.itemIndex >= feed.dataSource.items.count-1) {
            self.enabled = NO;
        }
    }
    
    return self;
}

- (void)setDescriptor:(AGDesc *)descriptor_ {
    if (!descriptor) {
        [super setDescriptor:descriptor_];
        return;
    } else {
        [super setDescriptor:descriptor_];
        if (!descriptor_) return;
    }
    
    // restore invalid state
    if ([descriptor_ conformsToProtocol:@protocol(AGFormClientProtocol)]) {
        AGControlDesc<AGFormClientProtocol> *feedClient = (AGControlDesc<AGFormClientProtocol> *)descriptor_;
        if (feedClient.form.invalidRule) {
            self.invalid = YES;
        } else {
            self.invalid = NO;
        }
    }
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    AGControlDesc *desc = (AGControlDesc *)descriptor;
    
    // rounded corners
    self.layer.cornerRadiusTopLeft = desc.radiusTopLeft.value;
    self.layer.cornerRadiusTopRight = desc.radiusTopRight.value;
    self.layer.cornerRadiusBottomLeft = desc.radiusBottomLeft.value;
    self.layer.cornerRadiusBottomRight = desc.radiusBottomRight.value;
    
    // border
    self.layer.borderLeft = desc.borderLeft.value;
    self.layer.borderRight = desc.borderRight.value;
    self.layer.borderTop = desc.borderTop.value;
    self.layer.borderBottom = desc.borderBottom.value;
    
    // background
    if (backgroundView) {
        backgroundView.frame = CGRectMake(desc.borderLeft.value,
                                          desc.borderTop.value,
                                          MAX(desc.width.value, 0),
                                          MAX(desc.height.value, 0));
    }
    
    // content
    if (contentView != self && ![contentView isKindOfClass:[MKMapView class]]) {
        contentView.frame = CGRectMake(desc.paddingLeft.value+desc.borderLeft.value,
                                       desc.paddingTop.value+desc.borderTop.value,
                                       MAX(desc.viewportWidth, 0),
                                       MAX(desc.viewportHeight, 0));
        [contentView setNeedsLayout];
    }
    
    // validation indicator
    CGFloat validationIndicatorSize = [AGLAYOUTMANAGER KPXToPixels:60] + desc.borderTop.value + desc.borderRight.value + MAX(0, desc.radiusTopRight.value - MAX(desc.borderTop.value, desc.borderRight.value)) * 0.5f;
    validationIndicator.offset = UIOffsetMake(desc.borderRight.value, desc.borderTop.value);
    validationIndicator.frame = CGRectMake(self.bounds.size.width-validationIndicatorSize, 0, validationIndicatorSize, validationIndicatorSize);
}

#pragma mark - Lifecycle

- (Class)contentClass {
    return [UIView class];
}

- (UIView *)newContent {
    return [[[self contentClass] alloc] initWithFrame:CGRectZero];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    if (!newSuperview) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
}

#pragma mark - Touches

- (void)onSwipeLeft:(UIGestureRecognizer *)gestureRecognizer {
    NSLog(@"Left swipe");
}

- (void)onSwipeRight:(UIGestureRecognizer *)gestureRecognizer {
    NSLog(@"Right swipe");
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return CGRectContainsPoint(self.bounds, point);
}

- (void)onTouchBegan:(CGPoint)point {
    
}

- (void)onTouchMoved:(CGPoint)point {
    
}

- (void)onTouchEnded:(CGPoint)point {
    
}

- (void)onTouchCancelled:(CGPoint)point {
    
}

- (void)onTap:(CGPoint)point {
    AGControlDesc *desc = (AGControlDesc *)descriptor;
    
    // on click
    if (desc.onClickAction) {
        [AGACTIONMANAGER executeAction:desc.onClickAction withSender:desc];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    [self onTouchBegan:point];
    
    AGControlDesc *desc = (AGControlDesc *)descriptor;
    if (!desc.onClickAction && ![self canBecomeFirstResponder]) {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    [self onTouchMoved:point];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    [self onTouchEnded:point];
    
    if ([self pointInside:point withEvent:event]) {
        [self onTap:point];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    [self onTouchCancelled:point];
}

#pragma mark - Appearance

- (void)setAppearance:(NSString *)appearance withObject:(id)appearanceObject forState:(UIControlState)state_ {
    // create or returns control state
    NSMutableDictionary *stateDict = states[@(state_)];
    if (!stateDict) {
        stateDict = [NSMutableDictionary dictionary];
        states[@(state_)] = stateDict;
    }
    
    // update control state appearance
    if (appearanceObject) {
        stateDict[appearance] = appearanceObject;
    } else {
        [stateDict removeObjectForKey:appearance];
    }
    
    // update appearance
    if ( (self.state&state_) == state_) {
        [self updateAppearance];
    }
}

- (id)getAppearance:(NSString *)appearance forState:(UIControlState)state_ {
    NSDictionary *stateDict = states[@(state_)];
    
    return stateDict[appearance];
}

- (id)getCurrentAppearance:(NSString *)appearance {
    id object = [self getAppearance:appearance forState:self.state];
    
    // heuristic
    if (!object && self.state&UIControlStateDisabled) {
        object = [self getAppearance:appearance forState:UIControlStateDisabled];
    }
    if (!object && self.state&UIControlStateInvalid) {
        object = [self getAppearance:appearance forState:UIControlStateInvalid];
    }
    if (!object && self.state&UIControlStateHighlighted) {
        object = [self getAppearance:appearance forState:UIControlStateHighlighted];
    }
    if (!object && self.state&UIControlStateSelected) {
        object = [self getAppearance:appearance forState:UIControlStateSelected];
    }
    if (!object && self.state&UIControlStateFilled) {
        object = [self getAppearance:appearance forState:UIControlStateFilled];
    }
    if (!object) {
        object = [self getAppearance:appearance forState:UIControlStateNormal];
    }
    
    return object;
}

- (void)updateAppearance {
    // disabled
    if (self.isEnabled) {
        self.alpha = 1.0f;
        self.userInteractionEnabled = YES;
    } else {
        self.alpha = 0.5f;
        self.userInteractionEnabled = NO;
    }
    
    // border
    self.layer.borderColor = [[self getCurrentAppearance:@"border_color"] CGColor];
    
    // valid indicator
    if (self.isInvalid) {
        AGControlDesc<AGFormClientProtocol> *desc = (AGControlDesc<AGFormClientProtocol> *)descriptor;
        validationIndicator.hidden = NO;
        validationIndicator.message = [AGACTIONMANAGER executeString:desc.form.invalidRule.message withSender:desc];
        validationIndicator.color = [self getCurrentAppearance:@"border_color"];
        [validationIndicator bringToFront];
    } else {
        validationIndicator.hidden = YES;
    }
}

#pragma mark - State

- (void)setHidden:(BOOL)hidden_ {
    [super setHidden:hidden_];
    
    if (hidden_) {
        [self invalidate];
    }
}

- (void)setEnabled:(BOOL)enabled_ {
    if (self.isEnabled == enabled_) return;
    
    if (!enabled_) {
        state |= UIControlStateDisabled;
    } else {
        state &= ~UIControlStateDisabled;
    }
    
    self.userInteractionEnabled = enabled_;
    
    if (!enabled_) {
        [self invalidate];
    }
    
    // update appearance
    [self updateAppearance];
}

- (BOOL)isEnabled {
    return !( (state & UIControlStateDisabled) == UIControlStateDisabled);
}

- (void)setHighlighted:(BOOL)highlighted_ {
    if (self.highlighted == highlighted_) return;
    
    if (highlighted_) {
        state |= UIControlStateHighlighted;
    } else {
        state &= ~UIControlStateHighlighted;
    }
    
    // update appearance
    [self updateAppearance];
}

- (BOOL)isHighlighted {
    return (state & UIControlStateHighlighted) == UIControlStateHighlighted;
}

- (void)setSelected:(BOOL)selected_ {
    if (self.isSelected == selected_) return;
    
    if (selected_) {
        state |= UIControlStateSelected;
    } else {
        state &= ~UIControlStateSelected;
    }
    
    // update appearance
    [self updateAppearance];
}

- (BOOL)isSelected {
    return (state & UIControlStateSelected) == UIControlStateSelected;
}

- (void)setFilled:(BOOL)filled_ {
    if (self.isFilled == filled_) return;
    
    if (filled_) {
        state |= UIControlStateFilled;
    } else {
        state &= ~UIControlStateFilled;
    }
    
    // update appearance
    [self updateAppearance];
}

- (BOOL)isFilled {
    return (state & UIControlStateFilled) == UIControlStateFilled;
}

- (void)setInvalid:(BOOL)invalid_ {
    if (self.isInvalid == invalid_) return;
    
    // state
    if (invalid_) {
        state |= UIControlStateInvalid;
    } else {
        state &= ~UIControlStateInvalid;
    }
    
    // update appearance
    [self updateAppearance];
}

- (BOOL)isInvalid {
    return (state & UIControlStateInvalid) == UIControlStateInvalid;
}

#pragma mark - Validation

- (void)validate {
    AGControlDesc<AGFormClientProtocol> *desc = (AGControlDesc<AGFormClientProtocol> *)descriptor;
    
    if (![desc conformsToProtocol:@protocol(AGFormClientProtocol)]) return;
    
    if (!self.isEnabled || self.hidden) {
        return;
    }
    
    if (![desc.form validate:desc.form.value]) {
        self.invalid = YES;
        
        // message
        //if( desc.form.invalidRule.message ){ //![invalidRule isEqual:lastInvalidRule]
        //    [AGAPPLICATION.toast makeValidationToast:desc.form.invalidRule.message];
        //}
    }
}

- (void)invalidate {
    AGControlDesc<AGFormClientProtocol> *desc = (AGControlDesc<AGFormClientProtocol> *)descriptor;
    
    if (![desc conformsToProtocol:@protocol(AGFormClientProtocol)]) return;
    
    [desc.form invalidate];
    self.invalid = NO;
}

#pragma mark - Assets

- (void)setupAssets {
    [super setupAssets];
    
    AGControlDesc *desc = (AGControlDesc *)descriptor;
    CGSize backgroundSize = CGSizeMake(MAX(desc.width.value, 0), MAX(desc.height.value, 0) );
    
    backgroundSource.uri = [[desc fullPath:desc.background.value] uriString];
    backgroundSource.prefferedImageSize = MAX(backgroundSize.width, backgroundSize.height);
    
    if ([AGAPPLICATION isControl:desc liesOnControlOfType:[AGGalleryDesc class]] && ([backgroundSource.uri hasPrefix:@"assets://"] || [backgroundSource.uri hasPrefix:@"local://"]) ) {
        backgroundSource.cachePolicy = cachePolicyDoNotCache;
    } else {
        backgroundSource.cachePolicy = cachePolicyDefault;
    }
}

- (void)loadAssets {
    [super loadAssets];
    
    //AGControlDesc* desc = (AGControlDesc*)descriptor;
    
    [backgroundSource execute];
    
    // logout logic
    //if( isNotEmpty(desc.onClickAction.text) && [desc.onClickAction.text rangeOfString:@"logout"].location!=NSNotFound && !AGAPPLICATION.isLoggedIn ){
    //    self.enabled = NO;
    //}
}

#pragma mark - AGAssetDelegate

- (void)assetWillLoad:(AGAsset *)asset_ {
    if (asset_ == backgroundSource && asset_.assetType != assetFile) {
        backgroundView.image = nil;
    }
}

- (void)asset:(AGAsset *)asset_ didLoad:(UIImage *)object {
    if (asset_ == backgroundSource) {
        backgroundView.image = object;
    }
}

- (void)asset:(AGAsset *)asset_ didFail:(NSError *)error {
    if (asset_ == backgroundSource) {
        backgroundView.image = AG_ERROR_IMAGE;
    }
}

@end
