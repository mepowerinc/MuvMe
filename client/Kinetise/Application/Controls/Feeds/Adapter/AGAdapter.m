#import "AGAdapter.h"
#import "AGDefaultLoadingIndicatorDesc.h"
#import "AGDefaultErrorIndicatorDesc.h"
#import "UIView+Debug.h"

@interface AGAdapter () <UICollectionViewDataSource, UICollectionViewDelegate>
@end

@implementation AGAdapter

@synthesize descriptor;

- (void)dealloc {
    self.descriptor = nil;
    [super dealloc];
}

- (id)initWithDesc:(AGControlDesc<AGFeedClientProtocol> *)descriptor_ {
    self = [super initWithFrame:CGRectZero collectionViewLayout:[[[[self layoutClass] alloc] initWithDesc:descriptor_] autorelease] ];

    self.descriptor = descriptor_;

    for (AGFeedItemTemplate *itemTemplate in descriptor.feed.itemTemplates) {
        [self registerClass:[self cellClass] forCellWithReuseIdentifier:itemTemplate.controlDesc.reuseIdentifier ];
    }
    [self registerClass:[self cellClass] forCellWithReuseIdentifier:AG_REUSE_IDENTIFIER_LOADING ];
    [self registerClass:[self cellClass] forCellWithReuseIdentifier:AG_REUSE_IDENTIFIER_NO_DATA ];
    [self registerClass:[self cellClass] forCellWithReuseIdentifier:AG_REUSE_IDENTIFIER_ERROR ];
    [self registerClass:[self cellClass] forCellWithReuseIdentifier:AG_REUSE_IDENTIFIER_LOAD_MORE ];

    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.delaysContentTouches = NO;
    self.directionalLockEnabled = YES;
    self.dataSource = self;
    self.delegate = self;

    return self;
}

- (Class)cellClass {
    return [AGAdapterCell class];
}

- (Class)layoutClass {
    return [AGAdapterLayout class];
}

#pragma mark - Assets

- (void)setupAssets {
    NSArray *cells = [self visibleCells];
    for (AGAdapterCell *cell in cells) {
        [cell.control setupAssets];
    }
}

- (void)loadAssets {
    NSArray *cells = [self visibleCells];
    for (AGAdapterCell *cell in cells) {
        [cell.control loadAssets];
    }
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];

    NSArray *cells = [self visibleCells];
    for (AGAdapterCell *cell in cells) {
        [cell setNeedsLayout];
        [cell.control setNeedsLayout];
    }
}

#pragma mark - UICollectionViewDataSource

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return descriptor.feedControls.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AGControlDesc *itemDesc = descriptor.feedControls[indexPath.item];
    AGAdapterCell *cell = (AGAdapterCell *)[self dequeueReusableCellWithReuseIdentifier:itemDesc.reuseIdentifier forIndexPath:indexPath];

    // control
    if (!cell.control) {
        cell.control = [AGControl controlWithDesc:itemDesc];
    }

    // enable load more
    if (itemDesc.identifier == descriptor.feed.itemTemplateLoadMore.identifier) {
        cell.control.enabled = YES;
    }

    // descriptor
    cell.control.descriptor = itemDesc;

    // parent
    AGControl *parent = (AGControl *)self.superview;
    cell.control.parent = parent;

    // setup assets
    [cell.control setupAssets];

    // load assets
    [cell.control loadAssets];

    // layout
    [cell.control setNeedsLayout];
    
    return cell;
}

@end
