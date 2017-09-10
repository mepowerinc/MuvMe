#import "AGSectionDesc.h"
#import "AGControlDesc.h"

@implementation AGSectionDesc

@synthesize children;
@synthesize width;
@synthesize height;
@synthesize positionX;
@synthesize positionY;
@synthesize integralPositionX;
@synthesize integralPositionY;
@synthesize contentWidth;
@synthesize contentHeight;
@synthesize hasVerticalScroll;
@synthesize maxBlockWidth;
@synthesize maxBlockWidthForMax;
@synthesize maxBlockHeight;
@synthesize maxBlockHeightForMax;

- (void)dealloc {
    [children release];
    [super dealloc];
}

- (id)init {
    self = [super init];

    children = [[NSMutableArray alloc] init];

    return self;
}

#pragma mark - Variables

- (void)executeVariables {
    for (AGControlDesc *child in children) {
        [child executeVariables];
    }
}

#pragma mark - Update

- (void)update {
    [super update];
    
    for (AGControlDesc *child in children) {
        [child update];
    }
}

#pragma mark - State

- (void)resetState {
    for (AGControlDesc *child in children) {
        [child resetState];
    }
}

#pragma mark - Lifecycle

- (NSArray *)actions {
    NSMutableArray *actions = (NSMutableArray *)[super actions];

    for (AGControlDesc *controlDesc in children) {
        [actions addObjectsFromArray:controlDesc.actions ];
    }

    return actions;
}

@end
