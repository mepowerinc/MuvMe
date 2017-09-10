#import "AGToast.h"
#import "AGToastView.h"
#import "AGApplication.h"

@implementation AGToast

- (void)dealloc {
    [messages release];
    [super dealloc];
}

- (id)init {
    self = [super init];

    // messages
    messages = [[NSMutableArray alloc] init];

    return self;
}

- (void)makeToast:(NSString *)message {
    [self makeToast:message withDuration:2.0f andPriority:toastPriorityNormal usingColor:nil];
}

- (void)makeValidationToast:(NSString *)message {
    AGApplicationDesc *desc = AGAPPLICATION.descriptor;
    UIColor *color = [UIColor colorWithRed:desc.validationColor.r green:desc.validationColor.g blue:desc.validationColor.b alpha:desc.validationColor.a];

    [self makeToast:message withDuration:2.0f andPriority:toastPriorityNormal usingColor:color];
}

- (void)makeToast:(NSString *)message withColor:(UIColor *)color {
    [self makeToast:message withDuration:2.0f andPriority:toastPriorityNormal usingColor:color];
}

- (void)makeToast:(NSString *)message withDuration:(NSInteger)duration andPriority:(AGToastPriority)priority usingColor:(UIColor *)color {
    // item
    AGToastItem *newItem = [[AGToastItem alloc] init];
    newItem.message = message;
    newItem.duration = duration;
    newItem.priority = priority;
    newItem.color = color;

    // add item
    NSInteger index = 0;
    for (int i = 0; i < messages.count; ++i) {
        AGToastItem *item = messages[i];
        if (item.priority >= newItem.priority) {
            index = i;
        }
    }

    if (index < messages.count) {
        AGToastItem *prevItem = messages[index];
        if ([prevItem isEqual:newItem]) {
            [newItem release];
            return;
        }
    }

    if (index+1 < messages.count) {
        [messages insertObject:newItem atIndex:index+1];
    } else {
        [messages addObject:newItem];
    }
    [newItem release];

    // show toast
    if (messages.count == 1) {
        [self nextMessage];
    }
}

- (void)nextMessage {
    if (messages.count == 0) return;

    NSInteger bottomMargin = 10;
    UIView *superView = AGAPPLICATION.navigationController.view;
    if (AGAPPLICATION.currentScreen) {
        if (AGAPPLICATION.currentScreen.naviPanel) {
            bottomMargin += AGAPPLICATION.currentScreen.naviPanel.bounds.size.height;
        }
    }

    // toast
    AGToastView *toastView = [[AGToastView alloc] initWithFrame:CGRectZero];
    [superView addSubview:toastView];
    [toastView release];
    toastView.bottomMargin = bottomMargin;

    // tap gesture
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [toastView addGestureRecognizer:tapGestureRecognizer];
    [tapGestureRecognizer release];

    // show
    AGToastItem *item = [messages firstObject];
    toastView.message = item.message;
    toastView.color = item.color;

    [toastView showWithCompletionBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, item.duration*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [toastView hideWithCompletionBlock:^{
                if (messages.count) {
                    [messages removeObjectAtIndex:0];
                }
                [self nextMessage];
                [toastView removeFromSuperview];
            }];
        });
    }];
}

- (void)onTap:(UITapGestureRecognizer *)gestureRecognizer {
    AGToastView *toastView = (AGToastView *)gestureRecognizer.view;

    [toastView hideWithCompletionBlock:^{
        if (messages.count) {
            [messages removeObjectAtIndex:0];
        }
        [self nextMessage];
        [toastView removeFromSuperview];
    }];
}

@end
