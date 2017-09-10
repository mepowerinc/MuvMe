#import "AGDefaultErrorIndicator.h"
#import "AGDefaultErrorIndicatorDesc.h"

@implementation AGDefaultErrorIndicator

- (id)initWithDesc:(AGDefaultErrorIndicatorDesc *)descriptor_ {
    self = [super initWithDesc:descriptor_];

    // image view
    UIImageView *imageView = (UIImageView *)contentView;
    imageView.image = AG_ERROR_IMAGE;
    imageView.contentMode = UIViewContentModeScaleAspectFit;

    return self;
}

- (Class)contentClass {
    return [UIImageView class];
}

@end
