#import <Foundation/Foundation.h>

@interface AGTextView : UITextView {
    BOOL shouldShowPlaceholder;
    NSMutableDictionary *eventsTargetActionsMap;
}

@property(nonatomic, copy) NSAttributedString *attributedPlaceholder;

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
- (void)removeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
- (NSSet *)allTargets;
- (UIControlEvents)allControlEvents;
- (NSArray *)actionsForTarget:(id)target forControlEvent:(UIControlEvents)controlEvent;
- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event;
- (void)sendActionsForControlEvents:(UIControlEvents)controlEvents;

@end
