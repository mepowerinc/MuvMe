#import "AGDefaultLoadingIndicator.h"
#import "AGActivityIndicatorView.h"
#import "AGDefaultLoadingIndicatorDesc.h"

@interface AGDefaultLoadingIndicator (){
    AGActivityIndicatorView *indicator;
}
@end

@implementation AGDefaultLoadingIndicator

- (id)initWithDesc:(AGDefaultLoadingIndicatorDesc *)descriptor_ {
    self = [super initWithDesc:descriptor_];

    // indicator
    indicator = (AGActivityIndicatorView *)contentView;
    indicator.image = AG_LOADING_IMAGE;

    return self;
}

- (Class)contentClass {
    return [AGActivityIndicatorView class];
}

@end
