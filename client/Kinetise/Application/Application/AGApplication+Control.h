#import "AGApplication.h"

@interface AGApplication (Control)

- (BOOL)isControl:(AGControlDesc *)controlDesc liesOnScreen:(AGScreenDesc *)screenDesc;
- (BOOL)isControl:(AGControlDesc *)controlDesc liesOnControlOfType:(Class)parentClass;
- (AGView *)getViewWithDesc:(AGDesc *)desc;
- (AGControlDesc *)getControlDesc:(NSString *)controlId;
- (AGControlDesc *)getControlDesc:(NSString *)controlId withParent:(AGDesc *)parentDesc;
- (AGControl *)getControl:(NSString *)controlId;
- (AGControl *)getControl:(NSString *)controlId withParent:(AGView *)parent;
- (AGControl *)getControlWithDesc:(AGControlDesc *)controlDesc;
- (void)getFormControlsDesc:(AGDesc *)desc withArray:(NSMutableArray *)array;
- (void)getFormControls:(AGView *)control withArray:(NSMutableArray *)array;
- (void)getFeedControlsDesc:(AGDesc *)desc withArray:(NSMutableArray *)array;
- (id<AGFeedClientProtocol>)getControlFeedParent:(AGControlDesc *)controlDesc;
- (void)getControlsOfType:(Class)className withParent:(AGView *)control withArray:(NSMutableArray *)array;
- (void)getInputControls:(AGView *)control withArray:(NSMutableArray *)array;
- (AGPresenterDesc *)getControlPresenterDesc:(AGControlDesc *)controlDesc;
- (AGPresenter *)getControlPresenter:(AGControl *)control;

@end
