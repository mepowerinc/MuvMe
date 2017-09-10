#import <Foundation/Foundation.h>

@interface AGAction : NSObject {
    NSString *text;
}

@property(nonatomic, copy) NSString *text;

+ (instancetype)actionWithText:(NSString *)text;
+ (BOOL)actionsRequireGPS:(NSArray *)actions;
- (BOOL)containsScript:(NSString *)script;

@end
