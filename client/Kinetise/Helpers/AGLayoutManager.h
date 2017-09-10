#import "NSObject+Singleton.h"
#import "AGLayoutProtocol.h"

#define AGLAYOUTMANAGER [AGLayoutManager sharedInstance]
#define SCREEN_WIDTH AGLAYOUTMANAGER.screenSize.width
#define SCREEN_HEIGHT AGLAYOUTMANAGER.screenSize.height
#define SCREEN_SHORTER_SIDE AGLAYOUTMANAGER.screenShorterSide
#define SCREEN_LONGER_SIDE AGLAYOUTMANAGER.screenLongerSide

#define AGROUND(x) roundf(x)//roundf( (x)*[AGLayoutManager sharedInstance].screenScale ) * [AGLayoutManager sharedInstance].invScreenScale

@interface AGLayoutManager : NSObject {
    CGSize screenSize;
    CGFloat screenScale;
    CGFloat invScreenScale;
}

@property(nonatomic, readonly) CGSize screenSize;
@property(nonatomic, readonly) CGFloat screenShorterSide;
@property(nonatomic, readonly) CGFloat screenLongerSide;
@property(nonatomic, readonly) CGFloat screenScale;
@property(nonatomic, readonly) CGFloat invScreenScale;

SINGLETON_INTERFACE(AGLayoutManager)

- (void)layout:(id<AGLayoutProtocol>)desc;
- (void)layout:(id<AGLayoutProtocol>)desc withSize:(CGSize)size;
- (CGFloat)KPXToPixels:(NSInteger)kpx;
- (CGFloat)percentToPixels:(NSInteger)percent withValue:(CGFloat)value;
@end

