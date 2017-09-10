#import "AGControlDesc.h"

@interface AGContainerDesc : AGControlDesc {
    NSMutableArray *children;
    AGLayoutType containerLayout;
    AGSize innerBorder;
    AGAlignType innerAlign;
    AGValignType innerVAlign;
    BOOL hasHorizontalScroll;
    BOOL hasVerticalScroll;
    NSInteger columns;
    CGFloat contentWidth;
    CGFloat contentHeight;
    CGFloat verticalScrollOffset;
    CGFloat horizontalScrollOffset;
    BOOL invertChildren;
    AGColor childrenSeparatorColor;
}

@property(nonatomic, readonly) NSMutableArray *children;

@property(nonatomic, assign) AGLayoutType containerLayout;
@property(nonatomic, assign) AGSize innerBorder;
@property(nonatomic, assign) AGAlignType innerAlign;
@property(nonatomic, assign) AGValignType innerVAlign;
@property(nonatomic, assign) BOOL hasHorizontalScroll;
@property(nonatomic, assign) BOOL hasVerticalScroll;
@property(nonatomic, assign) NSInteger columns;

@property(nonatomic, assign) CGFloat contentWidth;
@property(nonatomic, assign) CGFloat contentHeight;

@property(nonatomic, assign) CGFloat verticalScrollOffset;
@property(nonatomic, assign) CGFloat horizontalScrollOffset;

@property(nonatomic, assign) BOOL invertChildren;
@property(nonatomic, assign) AGColor childrenSeparatorColor;

- (void)addChild:(AGControlDesc *)controlDesc;

@end
