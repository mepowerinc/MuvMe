#import "AGToastItem.h"

@interface AGToast : NSObject {
    NSMutableArray *messages;
}

- (void)makeToast:(NSString *)message;
- (void)makeToast:(NSString *)message withColor:(UIColor *)color;
- (void)makeToast:(NSString *)message withDuration:(NSInteger)duration andPriority:(AGToastPriority)priority usingColor:(UIColor *)color;
- (void)makeValidationToast:(NSString *)message;

@end
