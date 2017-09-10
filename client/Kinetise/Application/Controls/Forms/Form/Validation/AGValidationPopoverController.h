#import <UIKit/UIKit.h>

typedef void (^AGPopoverCompletion)();

typedef enum AGPopoverArrowDirection : NSUInteger {
    AGPopoverArrowDirectionUp = 1UL << 0,
        AGPopoverArrowDirectionDown = 1UL << 1,
        AGPopoverArrowDirectionLeft = 1UL << 2,
        AGPopoverArrowDirectionRight = 1UL << 3,
        AGPopoverNoArrow = 1UL << 4,
        AGPopoverArrowDirectionVertical = AGPopoverArrowDirectionUp | AGPopoverArrowDirectionDown | AGPopoverNoArrow,
        AGPopoverArrowDirectionHorizontal = AGPopoverArrowDirectionLeft | AGPopoverArrowDirectionRight,
        AGPopoverArrowDirectionAny = AGPopoverArrowDirectionUp | AGPopoverArrowDirectionDown | AGPopoverArrowDirectionLeft | AGPopoverArrowDirectionRight
} AGPopoverArrowDirection;

#ifndef AGPopoverArrowDirectionIsVertical
#define AGPopoverArrowDirectionIsVertical(direction)    ((direction) == AGPopoverArrowDirectionVertical || (direction) == AGPopoverArrowDirectionUp || (direction) == AGPopoverArrowDirectionDown || (direction) == AGPopoverNoArrow)
#endif

#ifndef AGPopoverArrowDirectionIsHorizontal
#define AGPopoverArrowDirectionIsHorizontal(direction)    ((direction) == AGPopoverArrowDirectionHorizontal || (direction) == AGPopoverArrowDirectionLeft || (direction) == AGPopoverArrowDirectionRight)
#endif

@interface AGValidationPopoverController : UIViewController {
    CGRect presentingRect;
    UIView *presentingView;
    AGPopoverArrowDirection arrowDirection;
    BOOL isAnimating;
}

@property(nonatomic, assign) AGPopoverArrowDirection arrowDirection;

- (void)presentPopoverFromView:(UIView *)fromView;
- (void)dismissPopoverAnimated:(BOOL)animated;
- (void)dismissPopoverAnimated:(BOOL)animated completion:(AGPopoverCompletion)completionBlock;

@end
