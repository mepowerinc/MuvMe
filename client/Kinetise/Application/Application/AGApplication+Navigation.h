#import "AGApplication.h"

@interface AGApplication (Navigation)

- (void)goToScreen:(NSString *)screenId;
- (void)goToScreen:(NSString *)screenId withTransition:(AGTransition)transition;
- (void)goToScreen:(NSString *)screenId withContext:(id)context alterApiContext:(NSString *)alterApiContext guidContext:(NSString *)guidContext andTransition:(AGTransition)transition;
- (void)replaceScreen:(NSString *)screenId;
- (void)replaceScreen:(NSString *)screenId withTransition:(AGTransition)transition;
- (void)setStartScreen;
- (void)setLoginScreen;
- (void)setScreen:(NSString *)screenId;
- (void)goToProtectedScreen;
- (void)goToPreviousScreen;
- (void)goToPreviousScreenWithTransition:(AGTransition)transition;
- (void)backToScreen:(NSString *)screenId;
- (void)backToScreen:(NSString *)screenId withTransition:(AGTransition)transition;
- (void)backBySteps:(NSInteger)steps;
- (void)backBySteps:(NSInteger)steps withTransition:(AGTransition)transition;

@end
