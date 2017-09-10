#import "AGAction.h"

@interface AGVariable : AGAction {
    NSString *value;
}

@property(nonatomic, copy) NSString *value;

+ (id)variableWithText:(NSString *)text;

@end