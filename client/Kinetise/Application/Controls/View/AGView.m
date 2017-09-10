#import "AGView.h"
#import "UIView+Debug.h"

@implementation AGView

@dynamic layer;
@synthesize descriptor;

#pragma mark - Initialization

- (void)dealloc {
    self.descriptor = nil;
    [super dealloc];
}

- (id)initWithDesc:(AGDesc *)descriptor_ {
    self = [super initWithFrame:CGRectZero];

    // descriptor
    self.descriptor = descriptor_;

    return self;
}

+ (Class)layerClass {
    return [AGLayer class];
}

#pragma mark - Descriptor

#pragma mark - Lifecycle

- (void)setupAssets {

}

- (void)loadAssets {

}

- (void)update {

}

@end
