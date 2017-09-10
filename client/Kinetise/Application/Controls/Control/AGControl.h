#import "AGControlDesc.h"
#import "AGView.h"
#import "AGImageAsset.h"
#import "AGImageCache.h"
#import "AGImageView.h"
#import "AGValidationIndicator.h"

static const UIControlState UIControlStateInvalid = (1 << 16);
static const UIControlState UIControlStateFilled = (1 << 17);

@interface AGControl : AGView <AGAssetDelegate, UIGestureRecognizerDelegate>{
    UIView *contentView;
    AGImageView *backgroundView;
    AGImageAsset *backgroundSource;
    AGControl *parent;
    AGValidationIndicator *validationIndicator;
    NSMutableDictionary *states;
    UIControlState state;
}

@property(nonatomic, assign) AGControl *parent;
@property(nonatomic, readonly) UIView *contentView;
@property(nonatomic, readonly) UIControlState state;
@property(nonatomic, getter = isEnabled) BOOL enabled;
@property(nonatomic, getter = isHighlighted) BOOL highlighted;
@property(nonatomic, getter = isSelected) BOOL selected;
@property(nonatomic, getter = isFilled) BOOL filled;
@property(nonatomic, getter = isInvalid) BOOL invalid;

+ (instancetype)controlWithDesc:(AGDesc *)descriptor;
- (Class)contentClass;
- (UIView *)newContent;

- (void)onTouchBegan:(CGPoint)point;
- (void)onTouchMoved:(CGPoint)point;
- (void)onTouchEnded:(CGPoint)point;
- (void)onTouchCancelled:(CGPoint)point;
- (void)onTap:(CGPoint)point;

- (void)validate;
- (void)invalidate;

- (void)setAppearance:(NSString *)appearance withObject:(id)appearanceObject forState:(UIControlState)state;
- (id)getAppearance:(NSString *)appearance forState:(UIControlState)state;
- (id)getCurrentAppearance:(NSString *)appearance;
- (void)updateAppearance;

@end
