#import "AGValidationRule.h"
#import "AGUnits.h"
#import "AGVariable.h"
#import "AGDesc.h"

@interface AGForm : NSObject {
    AGVariable *formId;
    AGVariable *initialValue;
    id value;
    NSMutableArray *validationRules;
    NSMutableArray *dependencies;
}

@property(nonatomic, retain) AGVariable *formId;
@property(nonatomic, retain) AGVariable *initialValue;
@property(nonatomic, copy) id value;
@property(nonatomic, readonly) NSMutableArray *validationRules;
@property(nonatomic, readonly) NSMutableArray *dependencies;
@property(nonatomic, readonly) AGValidationRule *invalidRule;

- (void)executeVariables:(id)sender;
- (BOOL)isValid:(id)value;
- (BOOL)validate:(id)value;
- (void)invalidate;

@end
