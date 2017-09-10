#import <UIKit/UIKit.h>

@interface UIView (Recursion)

/**
   Return YES from the block to recurse into the subview.
   Set stop to YES to return the subview.
 */
- (UIView *)findViewRecursively:(BOOL (^)(UIView *subview, BOOL *stop))recurse;

@end

