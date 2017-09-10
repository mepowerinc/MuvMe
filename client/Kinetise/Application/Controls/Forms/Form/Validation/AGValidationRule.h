#import "AGUnits.h"

@interface AGValidationRule : NSObject

@property(nonatomic, assign) AGValidationRuleType type;
@property(nonatomic, copy) NSString *message;
@property(nonatomic, retain) NSArray<NSString *> *arguments;
@property(nonatomic, copy) NSString *condition;

- (BOOL)check:(id)value;

@end
