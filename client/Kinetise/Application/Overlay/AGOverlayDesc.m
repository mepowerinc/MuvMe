#import "AGOverlayDesc.h"

@implementation AGOverlayDesc

@synthesize overlayId;
@synthesize animation;
@synthesize offset;
@synthesize moveScreen;
@synthesize moveOverlay;
@synthesize grayoutBackground;
@synthesize permissions;
@synthesize onEnterAction;
@synthesize onExitAction;

#pragma mark - Initialization

- (void)dealloc {
    self.overlayId = nil;
    self.onEnterAction = nil;
    self.onExitAction = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];

    permissions = AGPermissionNone;

    return self;
}

#pragma mark - Lifecycle

- (NSArray *)actions {
    NSMutableArray *actions = (NSMutableArray *)[super actions];

    if (onEnterAction) [actions addObject:onEnterAction];
    if (onExitAction) [actions addObject:onExitAction];

    if (controlDesc) [actions addObjectsFromArray:controlDesc.actions ];

    return actions;
}

@end
