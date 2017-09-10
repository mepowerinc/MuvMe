#import "AGJSOverlay.h"
#import "AGActionManager+Navigation.h"

@implementation AGJSOverlay

- (void)open:(NSString *)overlayId {
    [AGACTIONMANAGER showOverlay:nil :nil :overlayId];
}

- (void)close {
    [AGACTIONMANAGER hideOverlay:nil :nil];
}

@end
