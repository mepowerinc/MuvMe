#import "AGGalleryDesc.h"

@implementation AGGalleryDesc

@synthesize feed;
@synthesize galleryElements;

- (void)dealloc {
    self.feed = nil;
    [galleryElements release];
    [super dealloc];
}

- (id)init {
    self = [super init];

    // gallery
    galleryElements = [[NSMutableArray alloc] init];

    return self;
}

- (void)setSection:(AGSectionDesc *)section_ {
    if (section == section_) return;

    section = section_;

    if (section) {
        for (AGControlDesc *child in galleryElements) {
            child.section = section;
        }
    }
}

#pragma mark - Feed

- (void)removeFeedControls {
    [galleryElements removeAllObjects];
}

- (void)removeLastFeedControl {
    [galleryElements removeLastObject];
}

- (void)addFeedControl:(AGControlDesc *)controlDesc {
    controlDesc.section = section;
    controlDesc.parent = self;
    [galleryElements addObject:controlDesc];
}

- (NSArray *)feedControls {
    return galleryElements;
}

#pragma mark - Variables

- (void)executeVariables {
    [super executeVariables];

    [feed executeVariables:self];

    for (AGControlDesc *child in galleryElements) {
        [child executeVariables];
    }
}

#pragma mark - Update

- (void)update {
    [super update];
    
    for (AGControlDesc *child in galleryElements) {
        [child update];
    }
}

@end
