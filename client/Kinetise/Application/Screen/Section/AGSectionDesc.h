#import "AGDesc.h"

@interface AGSectionDesc : AGDesc {
    NSMutableArray *children;
    CGFloat width;
    CGFloat height;
    CGFloat positionX;
    CGFloat positionY;
    CGFloat integralPositionX;
    CGFloat integralPositionY;
    CGFloat contentWidth;
    CGFloat contentHeight;
    BOOL hasVerticalScroll;
    CGFloat maxBlockWidth;
    CGFloat maxBlockWidthForMax;
    CGFloat maxBlockHeight;
    CGFloat maxBlockHeightForMax;
}

@property(nonatomic, readonly) NSMutableArray *children;

@property(nonatomic, assign) CGFloat width;
@property(nonatomic, assign) CGFloat height;
@property(nonatomic, assign) CGFloat positionX;
@property(nonatomic, assign) CGFloat positionY;
@property(nonatomic, assign) CGFloat integralPositionX;
@property(nonatomic, assign) CGFloat integralPositionY;
@property(nonatomic, assign) CGFloat contentWidth;
@property(nonatomic, assign) CGFloat contentHeight;
@property(nonatomic, assign) BOOL hasVerticalScroll;

@property(nonatomic, readonly) CGFloat maxBlockWidth;
@property(nonatomic, readonly) CGFloat maxBlockWidthForMax;
@property(nonatomic, readonly) CGFloat maxBlockHeight;
@property(nonatomic, readonly) CGFloat maxBlockHeightForMax;

@end
