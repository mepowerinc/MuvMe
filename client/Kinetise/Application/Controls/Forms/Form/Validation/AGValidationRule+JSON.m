#import "AGValidationRule+JSON.h"

@implementation AGValidationRule (JSON)

- (id)initWithJSON:(NSDictionary *)json {
    self = [super init];
    
    // type
    self.type = AGValidationRuleTypeWithText(json[@"type"]);
    
    // message
    self.message = json[@"message"];
    
    // arguments
    if (self.type == validationRuleRequired) {
        if (json[@"value"]) {
            self.arguments = @[ json[@"value"] ];
        }
    } else if (self.type == validationRuleRegex) {
        self.arguments = @[ json[@"regex"] ];
    } else if (self.type == validationRuleSameAs) {
        self.arguments = @[ json[@"control"] ];
    } else if (self.type == validationRuleLuhn) {
        self.arguments = @[ json[@"digits"] ];
    } else if (self.type == validationRuleValueRange) {
        self.arguments = @[ json[@"min"], json[@"max"] ];
    } else if (self.type == validationRuleIf) {
        self.arguments = @[ json[@"if"] ];
    } else if (self.type == validationRuleJavaScript) {
        self.arguments = @[ json[@"code"] ];
    }
    
    // condition
    if (self.type != validationRuleIf) {
        self.condition = json[@"if"];
    }
    
    return self;
}

@end
