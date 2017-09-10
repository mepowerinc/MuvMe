#import <UIKit/UIKit.h>

typedef enum {
    UIFrameAnchorTopLeft,
    UIFrameAnchorTopRight,
    UIFrameAnchorTopCenter,
    UIFrameAnchorCenter,
    UIFrameAnchorLeftCenter,
    UIFrameAnchorRightCenter,
    UIFrameAnchorBottomLeft,
    UIFrameAnchorBottomRight,
    UIFrameAnchorBottomCenter,
} UIFrameAnchor;

@interface UIView (Frame)
- (void)setFramePosition:(CGPoint)position frameAnchor:(UIFrameAnchor)anchor;
- (void)setFramePosition:(CGPoint)position;
- (void)setFrameSize:(CGSize)size;
- (void)setFrameWidth:(CGFloat)width;
- (void)setFrameHeight:(CGFloat)height;
- (void)setFrameX:(CGFloat)x;
- (void)setFrameY:(CGFloat)y;
- (CGPoint)frameCenter;
- (CGFloat)frameX;
- (CGFloat)frameY;
- (CGFloat)frameBottom;
- (CGFloat)frameRight;
- (CGFloat)frameWidth;
- (CGFloat)frameHeight;
- (CGFloat)frameHalfWidth;
- (CGFloat)frameHalfHeight;
- (CGRect)frameWithPosition:(CGPoint)position;
- (CGRect)frameWithSize:(CGSize)size;
- (CGRect)frameWithWidth:(CGFloat)width;
- (CGRect)frameWithHeight:(CGFloat)height;
- (CGRect)frameWithX:(CGFloat)x;
- (CGRect)frameWithY:(CGFloat)y;
@end