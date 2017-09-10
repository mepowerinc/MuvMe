#import "UIView+Frame.h"

@implementation UIView (Frame)
- (void)setFramePosition:(CGPoint)position frameAnchor:(UIFrameAnchor)anchor {
    switch (anchor) {
    case UIFrameAnchorTopLeft:
        self.frame = CGRectMake(position.x, position.y, self.frame.size.width, self.frame.size.height);
        break;
    case UIFrameAnchorTopRight:
        self.frame = CGRectMake(position.x-self.bounds.size.width, position.y, self.frame.size.width, self.frame.size.height);
        break;
    case UIFrameAnchorTopCenter:
        self.frame = CGRectMake(position.x-self.bounds.size.width*0.5, position.y, self.frame.size.width, self.frame.size.height);
        break;
    case UIFrameAnchorCenter:
        self.frame = CGRectMake(position.x-self.bounds.size.width*0.5, position.y-self.bounds.size.height*0.5, self.frame.size.width, self.frame.size.height);
        break;
    case UIFrameAnchorLeftCenter:
        self.frame = CGRectMake(position.x, position.y-self.bounds.size.height*0.5, self.frame.size.width, self.frame.size.height);
        break;
    case UIFrameAnchorRightCenter:
        self.frame = CGRectMake(position.x-self.bounds.size.width, position.y-self.bounds.size.height*0.5, self.frame.size.width, self.frame.size.height);
        break;
    case UIFrameAnchorBottomLeft:
        self.frame = CGRectMake(position.x, position.y-self.bounds.size.height, self.frame.size.width, self.frame.size.height);
        break;
    case UIFrameAnchorBottomRight:
        self.frame = CGRectMake(position.x-self.bounds.size.width, position.y-self.bounds.size.height, self.frame.size.width, self.frame.size.height);
        break;
    case UIFrameAnchorBottomCenter:
        self.frame = CGRectMake(position.x-self.bounds.size.width*0.5, position.y-self.bounds.size.height, self.frame.size.width, self.frame.size.height);
        break;
    default:
        break;
    }
}

- (void)setFramePosition:(CGPoint)position {
    self.frame = CGRectMake(position.x, position.y, self.frame.size.width, self.frame.size.height);
}

- (void)setFrameSize:(CGSize)size {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width, size.height);

}

- (void)setFrameWidth:(CGFloat)width {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, self.bounds.size.height);
}

- (void)setFrameHeight:(CGFloat)height {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, height);
}

- (void)setFrameX:(CGFloat)x {
    self.frame = CGRectMake(x, self.frame.origin.y, self.bounds.size.width, self.bounds.size.height);
}

- (void)setFrameY:(CGFloat)y {
    self.frame = CGRectMake(self.frame.origin.x, y, self.bounds.size.width, self.bounds.size.height);
}

- (CGPoint)frameCenter {
    return CGPointMake(self.bounds.size.width*0.5, self.bounds.size.height*0.5);
}

- (CGFloat)frameX {
    return self.frame.origin.x;
}

- (CGFloat)frameY {
    return self.frame.origin.y;
}

- (CGFloat)frameBottom {
    return self.frame.origin.y+self.frame.size.height;
}

- (CGFloat)frameRight {
    return self.frame.origin.x+self.frame.size.width;
}

- (CGFloat)frameWidth {
    return self.bounds.size.width;
}

- (CGFloat)frameHeight {
    return self.bounds.size.height;
}

- (CGFloat)frameHalfWidth {
    return self.bounds.size.width*0.5f;
}

- (CGFloat)frameHalfHeight {
    return self.bounds.size.height*0.5f;
}

- (CGRect)frameWithPosition:(CGPoint)position {
    return CGRectMake(position.x, position.y, self.frame.size.width, self.frame.size.height);
}

- (CGRect)frameWithSize:(CGSize)size {
    return CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width, size.height);
}

- (CGRect)frameWithWidth:(CGFloat)width {
    return CGRectMake(self.frame.origin.x, self.frame.origin.y, width, self.bounds.size.height);
}

- (CGRect)frameWithHeight:(CGFloat)height {
    return CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, height);
}

- (CGRect)frameWithX:(CGFloat)x {
    return CGRectMake(x, self.frame.origin.y, self.bounds.size.width, self.bounds.size.height);
}

- (CGRect)frameWithY:(CGFloat)y {
    return CGRectMake(self.frame.origin.x, y, self.bounds.size.width, self.bounds.size.height);
}

@end