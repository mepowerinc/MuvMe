#import "AGDataFeedAdapterBorder.h"
#import "AGDataFeedAdapterBorderLayoutAttributes.h"

@implementation AGDataFeedAdapterBorder

- (void)applyLayoutAttributes:(AGDataFeedAdapterBorderLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];

    self.backgroundColor = layoutAttributes.color;
}

@end
