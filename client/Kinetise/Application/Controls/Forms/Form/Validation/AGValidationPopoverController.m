#import "AGValidationPopoverController.h"
#import "AGValidationPopoverView.h"

@implementation AGValidationPopoverController

@synthesize arrowDirection;

- (void)dealloc {
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    self.arrowDirection = AGPopoverArrowDirectionUp;

    return self;
}

- (void)loadView {
    AGValidationPopoverView *view = [[AGValidationPopoverView alloc] initWithFrame:CGRectZero];
    self.view = view;
    [view release];

    view.touchOutsideBlock = ^{
        [self dismissPopoverAnimated:YES];
    };
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Presentation

- (void)presentPopoverFromView:(UIView *)fromView_ {
    UIView *view = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    CGRect convertedRect = [view convertRect:fromView_.bounds fromView:fromView_];
    [self presentPopoverFromRect:convertedRect inView:view permittedArrowDirections:AGPopoverArrowDirectionAny animated:YES];
}

- (void)presentPopoverFromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirections:(AGPopoverArrowDirection)arrowDirections animated:(BOOL)animated {
    if (self.view.superview) return;

    if (!view) {
        view = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    }
    [self.view removeFromSuperview];
    [view addSubview:self.view];

    presentingView = view;
    presentingRect = rect;

    self.view.frame = CGRectMake(rect.origin.x-self.view.frame.size.width, rect.origin.y+rect.size.height*0.5f-self.view.frame.size.height*0.5f, self.view.frame.size.width, self.view.frame.size.height);

    if (animated) {
        self.view.alpha = 0.0f;
        [UIView animateWithDuration:0.2f animations:^{
            self.view.alpha = 1.0f;
        }];
    }
}

#pragma mark - Dismission

- (void)dismissPopover {
    [self.view removeFromSuperview];

    /*if( [self.delegate respondsToSelector:@selector(popoverControllerDidDismissPopover:)] ){
        [self.delegate popoverControllerDidDismissPopover:self];
       }*/
}

- (void)dismissPopoverAnimated:(BOOL)animated {
    [self dismissPopoverAnimated:animated completion:nil];
}

- (void)dismissPopoverAnimated:(BOOL)animated completion:(AGPopoverCompletion)completionBlock {
    if (isAnimating) return;

    isAnimating = YES;

    if (animated) {
        [UIView animateWithDuration:0.2f animations:^{
            self.view.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [self dismissPopover];
            if (completionBlock) {
                completionBlock();
            }
            isAnimating = NO;
        }];
    } else {
        [self dismissPopover];
        if (completionBlock) {
            completionBlock();
        }
        isAnimating = NO;
    }
}

@end
