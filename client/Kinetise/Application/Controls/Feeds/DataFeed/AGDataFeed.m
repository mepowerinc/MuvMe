#import "AGDataFeed.h"
#import "AGDataFeedDesc.h"
#import "NSIndexPath+Array.h"
#import "UIView+Debug.h"

@implementation AGDataFeed

- (id)initWithDesc:(AGDataFeedDesc *)descriptor_ {
    self = [super initWithDesc:descriptor_];

    // adapter
    adapter = (AGDataFeedAdapter *)contentView;
    //adapter.paginationEnabled = YES;

    return self;
}

#pragma mark - Lifecycle

- (Class)contentClass {
    return [AGDataFeedAdapter class];
}

- (UIView *)newContent {
    return [[[self contentClass] alloc] initWithDesc:descriptor];
}

#pragma mark - Controls

- (void)addControl:(AGControl *)control {

}

- (NSArray *)controls {
    NSMutableArray *controls_ = [[[NSMutableArray alloc] init] autorelease];

    NSArray *cells = [adapter visibleCells];
    for (AGAdapterCell *cell in cells) {
        [controls_ addObject:cell.control];
    }

    return controls_;
}

#pragma mark - Assets

- (void)setupAssets {
    [super setupAssets];

    [adapter setupAssets];
}

- (void)loadAssets {
    [super loadAssets];

    [adapter loadAssets];
}

#pragma mark - Reload

- (void)reloadData {
    [adapter reloadData];

    // needs update scroll
    if ([contentView isKindOfClass:[UIScrollView class] ]) {
        shouldUpdateScrollView = YES;
    }
}

@end
