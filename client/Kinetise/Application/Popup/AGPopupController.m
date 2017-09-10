#import "AGPopupController.h"
#import "AGApplication.h"
#import "AGLayoutManager.h"
#import "AGControlDesc+Layout.h"
#import "AGPresenterDesc+Layout.h"

@interface AGPopupController (){
    UIWindow *window;
}
@end

@implementation AGPopupController

- (void)dealloc {
    [window release];
    [super dealloc];
}

- (void)present:(BOOL)animated completion:(void (^)(void))completion {
    if (![NSThread isMainThread]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self present:animated completion:completion];
        });
        return;
    }

    // window
    window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.backgroundColor = [UIColor clearColor];
    window.rootViewController = self;
    [window makeKeyAndVisible];

    // animation
    window.alpha = 0.0f;

    void (^animationBlock)(void) = ^{
        window.alpha = 1.0f;
    };

    if (animated) {
        [UIView animateWithDuration:0.2f delay:0.0f options:(UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionBeginFromCurrentState) animations:animationBlock completion:^(BOOL finished) {
            if (completion) {
                completion();
            }
        }];
    } else {
        animationBlock();
        if (completion) {
            completion();
        }
    }
}

- (void)dismiss:(BOOL)animated completion:(void (^)(void))completion {
    // animation
    window.alpha = 1.0f;

    void (^animationBlock)(void) = ^{
        window.alpha = 0.0f;
    };

    if (animated) {
        [UIView animateWithDuration:0.2f delay:0.0f options:(UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionBeginFromCurrentState) animations:animationBlock completion:^(BOOL finished) {
            if (completion) {
                completion();
            }
            window.hidden = YES;
            [window release];
        }];
    } else {
        animationBlock();
        if (completion) {
            completion();
        }
        window.hidden = YES;
        [window release];
    }
}

#pragma mark - Orientation

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    AGScreenDesc *screenDesc = AGAPPLICATION.currentScreenDesc;

    if (screenDesc.orientation == screenOrientationLandscape) {
        return UIInterfaceOrientationMaskLandscape;
    } else if (screenDesc.orientation == screenOrientationPortrait) {
        return UIInterfaceOrientationMaskPortrait;
    }

    return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end
