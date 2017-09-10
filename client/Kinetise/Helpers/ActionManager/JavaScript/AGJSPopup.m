#import "AGJSPopup.h"
#import "AGActionManager+Navigation.h"

@implementation AGJSPopup

- (void)close {
    [AGACTIONMANAGER closePopup:nil :nil];
}

@end
