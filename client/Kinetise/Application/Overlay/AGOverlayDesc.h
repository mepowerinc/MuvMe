#import "AGPopupDesc.h"
#import "AGControlDesc.h"
#import "AGAction.h"

typedef NS_ENUM (NSInteger, AGOverlayAnimation) {
    overlayAnimationNone = 0,
    overlayAnimationLeft,
    overlayAnimationRight,
    overlayAnimationTop,
    overlayAnimationBottom
};

@interface AGOverlayDesc : AGPopupDesc {
    NSString *overlayId;
    AGOverlayAnimation animation;
    AGSize offset;
    BOOL grayoutBackground;
    BOOL moveScreen;
    BOOL moveOverlay;
    AGPermissions permissions;
    AGAction *onEnterAction;
    AGAction *onExitAction;
}

@property(nonatomic, copy) NSString *overlayId;
@property(nonatomic, assign) AGOverlayAnimation animation;
@property(nonatomic, assign) AGSize offset;
@property(nonatomic, assign) BOOL grayoutBackground;
@property(nonatomic, assign) BOOL moveScreen;
@property(nonatomic, assign) BOOL moveOverlay;
@property(nonatomic, assign) AGPermissions permissions;

@property(nonatomic, retain) AGAction *onEnterAction;
@property(nonatomic, retain) AGAction *onExitAction;

@end
