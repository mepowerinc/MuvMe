#import <QuartzCore/QuartzCore.h>

@interface AGLayer : CALayer

@property(nonatomic, assign) CGFloat cornerRadiusTopLeft;
@property(nonatomic, assign) CGFloat cornerRadiusTopRight;
@property(nonatomic, assign) CGFloat cornerRadiusBottomLeft;
@property(nonatomic, assign) CGFloat cornerRadiusBottomRight;
@property(nonatomic, assign) CGFloat borderLeft;
@property(nonatomic, assign) CGFloat borderRight;
@property(nonatomic, assign) CGFloat borderTop;
@property(nonatomic, assign) CGFloat borderBottom;

@end
