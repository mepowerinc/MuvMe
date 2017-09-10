#import "AGTextView.h"
#import <objc/runtime.h>

@interface TargetActionPair : NSObject {
    id target;
    SEL action;
}
@property(assign) id target;
@property(assign) SEL action;
+ (TargetActionPair *)pairWithTarget:(id)target andAction:(SEL)selector;
@end

@implementation TargetActionPair
@synthesize target;
@synthesize action;

+ (TargetActionPair *)pairWithTarget:(id)target_ andAction:(SEL)selector_ {
    TargetActionPair *pair = [[self alloc] init];
    
    pair.target = target_;
    pair.action = selector_;
    
    return [pair autorelease];
}

@end

@implementation AGTextView

@synthesize attributedPlaceholder;

- (void)dealloc {
    self.attributedPlaceholder = nil;
    [eventsTargetActionsMap release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    // events map
    eventsTargetActionsMap = [[NSMutableDictionary alloc] init];
    
    // notificationsqw
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(aps_textViewDidBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(aps_textViewDidChangeEditing:) name:UITextViewTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(aps_textViewDidEndEditing:) name:UITextViewTextDidEndEditingNotification object:nil];
    
    // settings
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = YES;
    self.editable = YES;
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textContainerInset = UIEdgeInsetsMake(2, 0, 2, 0);
    
    // placeholder
    shouldShowPlaceholder = YES;
    
    return self;
}

- (void)setText:(NSString *)text_ {
    [super setText:text_];
    
    [self onTextChange];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (shouldShowPlaceholder) {
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect {
    if (shouldShowPlaceholder) {
        UIEdgeInsets textInsets = textInsets = UIEdgeInsetsMake(2.5f, 5, 2.5f, 5);
        [attributedPlaceholder drawInRect:CGRectMake(textInsets.left, textInsets.top, rect.size.width-textInsets.left-textInsets.right, rect.size.height-textInsets.top-textInsets.bottom) ];
    }
}

#pragma mark - Actions

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    NSMutableSet *targetActions = eventsTargetActionsMap[@(controlEvents)];
    if (targetActions == nil) {
        targetActions = [NSMutableSet set];
        eventsTargetActionsMap[@(controlEvents)] = targetActions;
    }
    TargetActionPair *targetAction = [TargetActionPair pairWithTarget:target andAction:action];
    [targetActions addObject:targetAction];
}

- (void)removeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    NSMutableSet *targetActions = eventsTargetActionsMap[@(controlEvents)];
    TargetActionPair *targetAction = nil;
    
    for (TargetActionPair *ta in targetActions) {
        if (ta.target == target && ta.action == action) {
            targetAction = ta;
            break;
        }
    }
    if (targetAction) {
        [targetActions removeObject:targetAction];
    }
}

- (NSSet *)allTargets {
    NSMutableSet *targets = [NSMutableSet set];
    
    [eventsTargetActionsMap enumerateKeysAndObjectsUsingBlock:^(id key, NSSet *targetActions, BOOL *stop) {
        for (TargetActionPair *ta in targetActions) {
            [targets addObject:ta.target ];
        }
    }];
    
    return targets;
}

- (UIControlEvents)allControlEvents {
    NSArray *arrayOfEvents = eventsTargetActionsMap.allKeys;
    UIControlEvents allControlEvents = 0;
    
    for (NSNumber *e in arrayOfEvents) {
        allControlEvents = allControlEvents|e.unsignedIntegerValue;
    }
    ;
    
    return allControlEvents;
}

- (NSArray *)actionsForTarget:(id)target forControlEvent:(UIControlEvents)controlEvent {
    NSMutableSet *targetActions = [NSMutableSet set];
    for (NSNumber *ce in eventsTargetActionsMap.allKeys) {
        if (ce.unsignedIntegerValue & controlEvent) {
            [targetActions addObjectsFromArray:[eventsTargetActionsMap[ce] allObjects]];
        }
    }
    
    NSMutableArray *actions = [NSMutableArray array];
    for (TargetActionPair *ta in targetActions) {
        if (ta.target == target) {
            [actions addObject:NSStringFromSelector(ta.action) ];
        }
    }
    
    return actions.count ? actions : nil;
}

- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    [UIApplication.sharedApplication sendAction:action to:target from:self forEvent:event];
}

- (void)sendActionsForControlEvents:(UIControlEvents)controlEvents {
    for (id target in self.allTargets.allObjects) {
        NSArray *actions = [self actionsForTarget:target forControlEvent:controlEvents];
        for (NSString *action in actions) {
            [self sendAction:NSSelectorFromString(action) to:target forEvent:nil];
        }
    }
}

#pragma mark - Notifications

- (void)onTextChange {
    if (shouldShowPlaceholder != (self.attributedText.length == 0) ) {
        shouldShowPlaceholder = (self.attributedText.length == 0);
        [self setNeedsDisplay];
    }
}

- (void)aps_textViewDidBeginEditing:(NSNotification *)notification {
    [self aps_forwardControlEvent:UIControlEventEditingDidBegin fromSender:self];
}

- (void)aps_textViewDidChangeEditing:(NSNotification *)notification {
    [self onTextChange];
    
    [self aps_forwardControlEvent:UIControlEventEditingChanged fromSender:self];
}

- (void)aps_textViewDidEndEditing:(NSNotification *)notification {
    [self aps_forwardControlEvent:UIControlEventEditingDidEnd fromSender:self];
}

- (void)aps_forwardControlEvent:(UIControlEvents)controlEvent fromSender:(id)sender {
    NSArray *events = eventsTargetActionsMap.allKeys;
    for (NSNumber *ce in events) {
        if (ce.unsignedIntegerValue & controlEvent) {
            NSMutableSet *targetActions = eventsTargetActionsMap[ce];
            for (TargetActionPair *ta in targetActions) {
                [ta.target performSelector:ta.action];
            }
        }
    }
}

@end
