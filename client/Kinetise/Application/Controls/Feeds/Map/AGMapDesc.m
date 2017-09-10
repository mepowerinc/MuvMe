#import "AGMapDesc.h"
#import "AGActionManager.h"

@interface AGMapDesc ()
@property(nonatomic, retain) AGControlDesc *indicatorDesc;
@end

@implementation AGMapDesc

@synthesize indicatorDesc;
@synthesize feed;
@synthesize pinSize;
@synthesize geoDataSrc;
@synthesize xSrc;
@synthesize ySrc;
@synthesize pinSrc;
@synthesize region;
@synthesize regionRadius;
@synthesize showUserLocation;
@synthesize showMapPopup;

#pragma mark - Initialization

- (void)dealloc {
    self.indicatorDesc = nil;
    self.feed = nil;
    self.geoDataSrc = nil;
    self.xSrc = nil;
    self.ySrc = nil;
    self.pinSrc = nil;
    [super dealloc];
}

#pragma mark - Lifecycle

- (void)setSection:(AGSectionDesc *)section_ {
    if (section == section_) return;

    section = section_;

    if (section) {
        indicatorDesc.section = section;
    }
}

- (void)setItemIndex:(NSInteger)itemIndex_ {
    if (itemIndex == itemIndex_) return;

    itemIndex = itemIndex_;

    indicatorDesc.itemIndex = itemIndex;
}

- (NSArray *)actions {
    NSMutableArray *actions = (NSMutableArray *)[super actions];

    [actions addObjectsFromArray:indicatorDesc.actions ];

    return actions;
}

#pragma mark - Variables

- (void)executeVariables {
    [super executeVariables];

    [feed executeVariables:self];
    [indicatorDesc executeVariables];

    [AGACTIONMANAGER executeVariable:geoDataSrc withSender:self];
}

#pragma mark - State

- (void)resetState {
    [super resetState];

    [indicatorDesc resetState];
}

#pragma mark - Feed

- (void)removeFeedControls {
    self.indicatorDesc = nil;
}

- (void)removeLastFeedControl {
    self.indicatorDesc = nil;
}

- (void)addFeedControl:(AGControlDesc *)controlDesc {
    if (![controlDesc.reuseIdentifier hasPrefix:AG_REUSE_IDENTIFIER_ITEM_TEMPLATE]) {
        self.indicatorDesc = controlDesc;
    }
}

- (NSArray *)feedControls {
    return @[];
}

@end
