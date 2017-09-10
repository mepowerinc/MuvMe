#import "AGControlDesc.h"
#import "AGSectionDesc.h"
#import "AGContainerDesc.h"
#import "AGFeedClientProtocol.h"
#import "NSString+GUID.h"
#import "AGActionManager.h"
#import "AGApplication.h"
#import "AGApplication+Control.h"

@implementation AGControlDesc

@synthesize identifier;
@synthesize reuseIdentifier;
@synthesize itemIndex;
@synthesize width;
@synthesize height;
@synthesize marginLeft;
@synthesize marginRight;
@synthesize marginBottom;
@synthesize marginTop;
@synthesize paddingLeft;
@synthesize paddingRight;
@synthesize paddingTop;
@synthesize paddingBottom;
@synthesize radiusTopLeft;
@synthesize radiusTopRight;
@synthesize radiusBottomLeft;
@synthesize radiusBottomRight;
@synthesize align;
@synthesize valign;
@synthesize borderLeft;
@synthesize borderRight;
@synthesize borderTop;
@synthesize borderBottom;
@synthesize borderColor;
@synthesize invalidBorderColor;
@synthesize background;
@synthesize backgroundColor;
@synthesize backgroundSizeMode;
@synthesize parent;
@synthesize section;
@synthesize positionX;
@synthesize positionY;
@synthesize integralPositionX;
@synthesize integralPositionY;
@synthesize globalPositionX;
@synthesize globalPositionY;
@synthesize globalIntegralPositionX;
@synthesize globalIntegralPositionY;
@synthesize blockWidth;
@synthesize blockHeight;
@synthesize viewportWidth;
@synthesize viewportHeight;
@synthesize excludeFromCalculateVar;
@synthesize hiddenVar;
@synthesize excludeFromCalculate;
@synthesize hidden;
@synthesize onClickAction;
@synthesize onSwipeLeftAction;
@synthesize onSwipeRightAction;
@synthesize onChangeAction;
@synthesize onUpdateAction;
@synthesize onEndEditing;
@synthesize maxBlockWidth;
@synthesize maxBlockWidthForMax;
@synthesize maxBlockHeight;
@synthesize maxBlockHeightForMax;

#pragma mark - Initialization

- (void)dealloc {
    self.identifier = nil;
    self.reuseIdentifier = nil;
    self.background = nil;
    self.parent = nil;
    self.section = nil;
    self.excludeFromCalculateVar = nil;
    self.hiddenVar = nil;
    self.onClickAction = nil;
    self.onSwipeLeftAction = nil;
    self.onSwipeRightAction = nil;
    self.onChangeAction = nil;
    self.onUpdateAction = nil;
    self.onEndEditing = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];

    // default identifier
    self.identifier = [NSString stringWithGUID];

    // item intex
    itemIndex = NSNotFound;

    return self;
}

- (CGFloat)blockWidth {
    return width.value+marginLeft.value+marginRight.value+borderLeft.value+borderRight.value;
}

- (CGFloat)blockHeight {
    return height.value+marginTop.value+marginBottom.value+borderTop.value+borderBottom.value;
}

- (CGFloat)viewportWidth {
    return width.value-paddingLeft.value-paddingRight.value;
}

- (CGFloat)viewportHeight {
    return height.value-paddingTop.value-paddingBottom.value;
}

- (AGAlignType)align {
    if (parent && [parent isKindOfClass:[AGContainerDesc class]]) {
        AGAlignType parentInnerAlign = ((AGContainerDesc *)parent).innerAlign;
        if (parentInnerAlign != alignNone) return parentInnerAlign;
    }
    return align;
}

- (AGValignType)valign {
    if (parent && [parent isKindOfClass:[AGContainerDesc class]]) {
        AGValignType parentInnerVAlign = ((AGContainerDesc *)parent).innerVAlign;
        if (parentInnerVAlign != valignNone) return parentInnerVAlign;
    }
    return valign;
}

#pragma mark - Variables

- (void)executeVariables {
    [AGACTIONMANAGER executeVariable:background withSender:self];

    if (excludeFromCalculateVar) {
        [AGACTIONMANAGER executeVariable:excludeFromCalculateVar withSender:self];
        excludeFromCalculate = [excludeFromCalculateVar.value boolValue];
    }

    if (hiddenVar) {
        [AGACTIONMANAGER executeVariable:hiddenVar withSender:self];
        hidden = [hiddenVar.value boolValue];
    }
}

#pragma mark - Update

- (void)update {
    [super update];
    
    if (onUpdateAction) {
        [AGACTIONMANAGER executeString:onUpdateAction.text withSender:self];
    }
}

- (NSString *)fullPath:(NSString *)relativePath {
    if ([relativePath hasPrefix:@"/"]) {
        AGFeed *feed = nil;
        id<AGFeedClientProtocol> feedClient = [AGAPPLICATION getControlFeedParent:self];

        if (feedClient) {
            feed = feedClient.feed;
        } else {
            feed = AGAPPLICATION.currentContext;
        }

        if (feed) {
            return [feed fullPath:relativePath];
        }
    }

    return relativePath;
}

#pragma mark - Lifecycle

- (NSArray *)actions {
    NSMutableArray *actions = (NSMutableArray *)[super actions];

    if (onClickAction) [actions addObject:onClickAction ];
    if (onSwipeLeftAction) [actions addObject:onSwipeLeftAction ];
    if (onSwipeRightAction) [actions addObject:onSwipeRightAction ];
    if (onChangeAction) [actions addObject:onChangeAction ];
    if (onEndEditing) [actions addObject:onEndEditing ];

    if ([self conformsToProtocol:@protocol(AGFeedClientProtocol)]) {
        AGFeed *feed = [(id < AGFeedClientProtocol >) self feed];

        for (AGFeedItemTemplate *itemTemplate in feed.itemTemplates) {
            [actions addObjectsFromArray:itemTemplate.controlDesc.actions ];
        }

        [actions addObjectsFromArray:feed.itemTemplateNoData.actions ];
        [actions addObjectsFromArray:feed.itemTemplateError.actions ];
        [actions addObjectsFromArray:feed.itemTemplateLoading.actions ];
        [actions addObjectsFromArray:feed.itemTemplateLoadMore.actions ];
    }

    return actions;
}

#pragma mark - Copying

- (id)copyWithZone:(NSZone *)zone {
    AGControlDesc *obj = [[[self class] allocWithZone:zone] init];

    obj.identifier = identifier;
    obj.reuseIdentifier = reuseIdentifier;
    obj.width = width;
    obj.height = height;
    obj.marginLeft = marginLeft;
    obj.marginRight = marginRight;
    obj.marginTop = marginTop;
    obj.marginBottom = marginBottom;
    obj.paddingLeft = paddingLeft;
    obj.paddingRight = paddingRight;
    obj.paddingTop = paddingTop;
    obj.paddingBottom = paddingBottom;
    obj.radiusBottomLeft = radiusBottomLeft;
    obj.radiusBottomRight = radiusBottomRight;
    obj.radiusTopLeft = radiusTopLeft;
    obj.radiusTopRight = radiusTopRight;
    obj.align = align;
    obj.valign = valign;
    obj.borderLeft = borderLeft;
    obj.borderRight = borderRight;
    obj.borderTop = borderTop;
    obj.borderBottom = borderBottom;
    obj.borderColor = borderColor;
    obj.invalidBorderColor = invalidBorderColor;
    obj.background = [[background copy] autorelease];
    obj.backgroundColor = backgroundColor;
    obj.backgroundSizeMode = backgroundSizeMode;
    obj.parent = nil;
    obj.section = nil;
    obj.excludeFromCalculateVar = [[excludeFromCalculateVar copy] autorelease];
    obj.hiddenVar = [[hiddenVar copy] autorelease];
    obj.excludeFromCalculate = excludeFromCalculate;
    obj.hidden = hidden;
    obj.onClickAction = [[onClickAction copy] autorelease];
    obj.onSwipeLeftAction = [[onSwipeLeftAction copy] autorelease];
    obj.onSwipeRightAction = [[onSwipeRightAction copy] autorelease];
    obj.onChangeAction = [[onChangeAction copy] autorelease];
    obj.onUpdateAction = [[onUpdateAction copy] autorelease];
    obj.onEndEditing = [[onEndEditing copy] autorelease];

    return obj;
}

@end
