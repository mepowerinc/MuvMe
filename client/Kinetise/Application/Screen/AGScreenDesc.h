#import "AGPresenterDesc.h"
#import "AGHeaderDesc.h"
#import "AGBodyDesc.h"
#import "AGNaviPanelDesc.h"
#import "AGVariable.h"
#import "AGAction.h"

@interface AGScreenDesc : AGPresenterDesc {
    NSString *screenId;
    NSString *atag;
    AGHeaderDesc *header;
    AGBodyDesc *body;
    AGNaviPanelDesc *naviPanel;
    CGFloat width;
    CGFloat height;
    CGFloat positionX;
    CGFloat positionY;
    CGFloat contentWidth;
    CGFloat contentHeight;
    AGVariable *background;
    AGVariable *backgroundVideo;
    AGColor backgroundColor;
    AGSizeModeType backgroundSizeMode;
    AGScreenOrientation orientation;
    BOOL hasPullToRefresh;
    BOOL isProtected;
    AGPermissions permissions;
    AGAction *onEnterAction;
    AGAction *onExitAction;
    AGColor statusBarColor;
    BOOL statusBarLightMode;
}

@property(nonatomic, copy) NSString *screenId;
@property(nonatomic, copy) NSString *atag;
@property(nonatomic, retain) AGHeaderDesc *header;
@property(nonatomic, retain) AGBodyDesc *body;
@property(nonatomic, retain) AGNaviPanelDesc *naviPanel;

@property(nonatomic, assign) CGFloat width;
@property(nonatomic, assign) CGFloat height;
@property(nonatomic, assign) CGFloat positionX;
@property(nonatomic, assign) CGFloat positionY;
@property(nonatomic, assign) CGFloat contentWidth;
@property(nonatomic, assign) CGFloat contentHeight;
@property(nonatomic, assign) AGScreenOrientation orientation;
@property(nonatomic, assign) BOOL hasPullToRefresh;
@property(nonatomic, assign) BOOL isProtected;
@property(nonatomic, assign) AGPermissions permissions;

@property(nonatomic, retain) AGVariable *background;
@property(nonatomic, retain) AGVariable *backgroundVideo;
@property(nonatomic, assign) AGColor backgroundColor;
@property(nonatomic, assign) AGSizeModeType backgroundSizeMode;

@property(nonatomic, retain) AGAction *onEnterAction;
@property(nonatomic, retain) AGAction *onExitAction;

@property(nonatomic, assign) AGColor statusBarColor;
@property(nonatomic, assign) BOOL statusBarLightMode;

@end
