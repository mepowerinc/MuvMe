#import "AGScreenDesc.h"
#import "AGActionManager.h"

@implementation AGScreenDesc

@synthesize screenId;
@synthesize atag;
@synthesize header;
@synthesize body;
@synthesize naviPanel;
@synthesize width;
@synthesize height;
@synthesize positionX;
@synthesize positionY;
@synthesize contentWidth;
@synthesize contentHeight;
@synthesize background;
@synthesize backgroundVideo;
@synthesize backgroundColor;
@synthesize backgroundSizeMode;
@synthesize orientation;
@synthesize hasPullToRefresh;
@synthesize isProtected;
@synthesize permissions;
@synthesize onEnterAction;
@synthesize onExitAction;
@synthesize statusBarColor;
@synthesize statusBarLightMode;

#pragma mark - Initialization

- (void)dealloc {
    self.screenId = nil;
    self.atag = nil;
    self.header = nil;
    self.body = nil;
    self.naviPanel = nil;
    self.background = nil;
    self.backgroundVideo = nil;
    self.onEnterAction = nil;
    self.onExitAction = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];
    
    permissions = AGPermissionNone;
    
    return self;
}

#pragma mark - Variables

- (void)executeVariables {
    [AGACTIONMANAGER executeVariable:background withSender:self];
    [AGACTIONMANAGER executeVariable:backgroundVideo withSender:self];
    
    [header executeVariables];
    [body executeVariables];
    [naviPanel executeVariables];
}

#pragma mark - Update

- (void)update {
    [super update];
    
    [header update];
    [body update];
    [naviPanel update];
}

#pragma mark - State

- (void)resetState {
    [header resetState];
    [body resetState];
    [naviPanel resetState];
}

#pragma mark - Lifecycle

- (NSArray *)actions {
    NSMutableArray *actions = (NSMutableArray *)[super actions];
    
    if (onEnterAction) [actions addObject:onEnterAction];
    if (onExitAction) [actions addObject:onExitAction];
    
    if (header) [actions addObjectsFromArray:header.actions ];
    if (body) [actions addObjectsFromArray:body.actions ];
    if (naviPanel) [actions addObjectsFromArray:naviPanel.actions ];
    
    return actions;
}

@end
