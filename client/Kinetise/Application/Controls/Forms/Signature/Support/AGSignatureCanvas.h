#import <UIKit/UIKit.h>

@interface AGSignatureCanvas : UIView

@property(nonatomic, assign) CGFloat strokeWidth;
@property(nonatomic, retain) UIColor *strokeColor;
@property(nonatomic, getter = isEnabled) BOOL enabled;
@property(nonatomic, retain) UIBezierPath *path;
@property(nonatomic, readonly) UIImage *image;
@property(nonatomic, readonly) BOOL hasSignature;

- (void)erase;

@end
