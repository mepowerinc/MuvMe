#import "AGChartDesc.h"

@interface AGChartDesc ()
@property(nonatomic, retain) AGControlDesc *indicatorDesc;
@end

@implementation AGChartDesc

@synthesize indicatorDesc;
@synthesize feed;
@synthesize type;
@synthesize label;
@synthesize colors;
@synthesize dataset;

#pragma mark - Initialization

- (void)dealloc {
    self.indicatorDesc = nil;
    self.feed = nil;
    self.label = nil;
    [colors release];
    [dataset release];
    [super dealloc];
}

- (id)init {
    self = [super init];

    colors = [[NSMutableArray alloc] init];
    dataset = [[NSMutableArray alloc] init];

    return self;
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
