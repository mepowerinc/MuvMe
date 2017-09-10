#import "AGCustomButton.h"
#import "AGCustomButtonDesc.h"

@interface AGCustomButton()
@property(nonatomic, retain) UIButton *button;
@end

@implementation AGCustomButton

@synthesize button;

#pragma mark - Initialization

- (void)dealloc {
    [button release];
    [super dealloc];
}

- (id)initWithDesc:(AGCustomButtonDesc *)descriptor_ {
    self = [super initWithDesc:descriptor_];
    
    // Initialize view based on descriptor
    // Add subviews to self.contentView or customize content view by overriding contentClass method
    self.button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:descriptor_.text forState:UIControlStateNormal];
    [self.contentView addSubview:button];
    
    return self;
}

- (Class)contentClass {
    return [UIView class];
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Layout subviews
    self.button.frame = self.contentView.bounds;
}

@end
