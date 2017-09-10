#import "AGOverlayDesc.h"
#import "AGXMLProtocol.h"

static inline AGOverlayAnimation AGOverlayAnimationWithText(NSString *text){
    if ([text isEqualToString:AG_NONE]) {
        return overlayAnimationNone;
    } else if ([text isEqualToString:@"left"]) {
        return overlayAnimationLeft;
    } else if ([text isEqualToString:@"right"]) {
        return overlayAnimationRight;
    } else if ([text isEqualToString:@"top"]) {
        return overlayAnimationTop;
    } else if ([text isEqualToString:@"bottom"]) {
        return overlayAnimationBottom;
    }

    return overlayAnimationNone;
}

@interface AGOverlayDesc (XML) <AGXMLProtocol>

@end
