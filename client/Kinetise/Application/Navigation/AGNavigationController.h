#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, AGTransition) {
    transitionNone = 0,
    transitionFade,
    transitionSlideLeft,
    transitionSlideRight,
    transitionCoverLeft,
    transitionUncoverLeft,
    transitionCoverRight,
    transitionUncoverRight,
    transitionCoverTop,
    transitionUncoverTop,
    transitionCoverBottom,
    transitionUncoverBottom,
};

static inline AGTransition AGTransitionWithText(NSString *text){
    if (!text) return transitionNone;
    
    if ([text isEqualToString:@"fade"]) {
        return transitionFade;
    } else if ([text isEqualToString:@"slideleft"]) {
        return transitionSlideLeft;
    } else if ([text isEqualToString:@"slideright"]) {
        return transitionSlideRight;
    } else if ([text isEqualToString:@"coverfromleft"]) {
        return transitionCoverLeft;
    } else if ([text isEqualToString:@"uncovertoleft"]) {
        return transitionUncoverLeft;
    } else if ([text isEqualToString:@"coverfromright"]) {
        return transitionCoverRight;
    } else if ([text isEqualToString:@"uncovertoright"]) {
        return transitionUncoverRight;
    } else if ([text isEqualToString:@"coverfromtop"]) {
        return transitionCoverTop;
    } else if ([text isEqualToString:@"uncovertotop"]) {
        return transitionUncoverTop;
    } else if ([text isEqualToString:@"coverfrombottom"]) {
        return transitionCoverBottom;
    } else if ([text isEqualToString:@"uncovertobottom"]) {
        return transitionUncoverBottom;
    }
    
    return transitionNone;
}

@interface AGNavigationController : UINavigationController

@property(nonatomic, assign) AGTransition transition;

@end
