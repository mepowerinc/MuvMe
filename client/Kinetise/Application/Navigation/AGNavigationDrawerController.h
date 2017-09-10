#import <UIKit/UIKit.h>

@protocol AGNavigationDrawerControllerDelegate;

typedef NS_ENUM (NSInteger, AGDrawerPanelPosition) {
    drawerPanelPositionNone = 0,
    drawerPanelPositionLeft,
    drawerPanelPositionRight,
    drawerPanelPositionTop,
    drawerPanelPositionBottom
};

@interface AGNavigationDrawerController : UIViewController

@property(nonatomic, assign) id<AGNavigationDrawerControllerDelegate> delegate;
@property(nonatomic, retain) UIViewController *mainController;
@property(nonatomic, retain) UIViewController *panelController;
@property(nonatomic, assign) AGDrawerPanelPosition panelPosition;
@property(nonatomic, readonly) UIView *statusBar;
@property(nonatomic, assign) BOOL shouldMoveScreen;
@property(nonatomic, assign) BOOL shouldMoveOverlay;
@property(nonatomic, assign) BOOL shouldGrayoutBackgroud;

- (void)togglePanel;
- (void)showPanel;
- (void)hidePanel;

@end

@protocol AGNavigationDrawerControllerDelegate<NSObject>
@optional
- (void)navigationDrawerWillShowPanel:(AGNavigationDrawerController *)drawer;
- (void)navigationDrawerDidShowPanel:(AGNavigationDrawerController *)drawer;
- (void)navigationDrawerWillHidePanel:(AGNavigationDrawerController *)drawer;
- (void)navigationDrawerDidHidePanel:(AGNavigationDrawerController *)drawer;
@end
