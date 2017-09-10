#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, AGToastPriority) {
    toastPriorityLow = 0,
    toastPriorityNormal,
    toastPriorityHigh
};

@interface AGToastItem : NSObject

@property(nonatomic, copy) NSString *message;
@property(nonatomic, assign) NSInteger duration;
@property(nonatomic, assign) AGToastPriority priority;
@property(nonatomic, retain) UIColor *color;

@end
