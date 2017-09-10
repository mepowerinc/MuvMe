#import "AGContainerDesc.h"

@implementation AGContainerDesc

@synthesize children;
@synthesize containerLayout;
@synthesize innerBorder;
@synthesize innerAlign;
@synthesize innerVAlign;
@synthesize hasHorizontalScroll;
@synthesize hasVerticalScroll;
@synthesize columns;
@synthesize contentWidth;
@synthesize contentHeight;
@synthesize verticalScrollOffset;
@synthesize horizontalScrollOffset;
@synthesize invertChildren;
@synthesize childrenSeparatorColor;

#pragma mark - Initialization

- (void)dealloc {
    [children release];
    [super dealloc];
}

- (id)init {
    self = [super init];

    children = [[NSMutableArray alloc] init];

    return self;
}

#pragma mark - Lifecycle

- (void)addChild:(AGControlDesc *)controlDesc {
    controlDesc.section = section;
    controlDesc.parent = self;
    [children addObject:controlDesc];
}

- (void)setSection:(AGSectionDesc *)section_ {
    if (section == section_) return;

    section = section_;

    if (section) {
        for (AGControlDesc *child in children) {
            child.section = section;
        }
    }
}

- (void)setItemIndex:(NSInteger)itemIndex_ {
    if (itemIndex == itemIndex_) return;

    itemIndex = itemIndex_;

    for (AGControlDesc *child in children) {
        child.itemIndex = itemIndex;
    }
}

- (NSArray *)actions {
    NSMutableArray *actions = (NSMutableArray *)[super actions];

    for (AGControlDesc *controlDesc in children) {
        [actions addObjectsFromArray:controlDesc.actions ];
    }

    return actions;
}

#pragma mark - Variables

- (void)executeVariables {
    [super executeVariables];

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
    [super resetState];

    horizontalScrollOffset = 0;
    verticalScrollOffset = 0;

    if (invertChildren) {
        verticalScrollOffset = contentHeight;
    }

    for (AGControlDesc *child in children) {
        [child resetState];
    }
}

#pragma mark - Copying

- (id)copyWithZone:(NSZone *)zone {
    AGContainerDesc *obj = [super copyWithZone:zone];

    for (AGControlDesc *child in children) {
        [obj addChild:[[child copy] autorelease] ];
    }
    obj.containerLayout = containerLayout;
    obj.innerBorder = innerBorder;
    obj.innerAlign = innerAlign;
    obj.innerVAlign = innerVAlign;
    obj.hasHorizontalScroll = hasHorizontalScroll;
    obj.hasVerticalScroll = hasVerticalScroll;
    obj.columns = columns;
    obj.invertChildren = invertChildren;
    obj.childrenSeparatorColor = childrenSeparatorColor;

    return obj;
}

@end
