#import "AGControlDesc.h"

@interface AGVideoDesc : AGControlDesc {
    AGVariable *src;
    BOOL autoplay;
}

@property(nonatomic, retain) AGVariable *src;
@property(nonatomic, assign) BOOL autoplay;

@end
