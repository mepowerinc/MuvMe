#import "AGDefaultErrorIndicatorDesc.h"

@implementation AGDefaultErrorIndicatorDesc

- (id)init {
    self = [super init];

    // reuse identifier
    self.reuseIdentifier = AG_REUSE_IDENTIFIER_ERROR;

    // width
    self.width = AGSizeMake(AG_ERROR_INDICATOR_SIZE, unitKpx);

    // height
    self.height = AGSizeMake(AG_ERROR_INDICATOR_SIZE, unitKpx);

    // margin left
    self.marginLeft = AGSizeMake(0, unitKpx);

    // margin right
    self.marginRight = AGSizeMake(0, unitKpx);

    // margin top
    self.marginTop = AGSizeMake(0, unitKpx);

    // margin bottom
    self.marginBottom = AGSizeMake(0, unitKpx);

    // padding left
    self.paddingLeft = AGSizeMake(0, unitKpx);

    // padding right
    self.paddingRight = AGSizeMake(0, unitKpx);

    // padding top
    self.paddingTop = AGSizeMake(0, unitKpx);

    // padding bottom
    self.paddingBottom = AGSizeMake(0, unitKpx);

    // radius top left
    self.radiusTopLeft = AGSizeMake(0, unitKpx);

    // radius top right
    self.radiusTopRight = AGSizeMake(0, unitKpx);

    // radius bottom left
    self.radiusBottomLeft = AGSizeMake(0, unitKpx);

    // radius bottom right
    self.radiusBottomRight = AGSizeMake(0, unitKpx);

    // align
    self.align = alignCenter;

    // valign
    self.valign = valignCenter;

    // border left
    self.borderLeft = AGSizeMake(0, unitKpx);

    // border right
    self.borderRight = AGSizeMake(0, unitKpx);

    // border top
    self.borderTop = AGSizeMake(0, unitKpx);

    // border bottom
    self.borderBottom = AGSizeMake(0, unitKpx);
    self.borderLeft = AGSizeMake(0, unitKpx);

    // border color
    self.borderColor = AGColorClear();

    // background
    self.background = nil;

    // background color
    self.backgroundColor = AGColorClear();

    // on click action
    self.onClickAction = nil;

    return self;
}

@end
