#import "AGValidationRule.h"
#import "AGFormClientProtocol.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "AGRegexCache.h"
#import "AGActionManager.h"
#import "AGApplication.h"
#import "AGApplication+Control.h"
#import "AGFeedDateParser.h"

@implementation AGValidationRule

@synthesize type;
@synthesize message;
@synthesize arguments;
@synthesize condition;

- (void)dealloc {
    self.message = nil;
    self.arguments = nil;
    self.condition = nil;
    [super dealloc];
}

bool luhn(const char *cc);

bool luhn(const char *cc){
    const int m[] = {0, 2, 4, 6, 8, 1, 3, 5, 7, 9};
    size_t i;
    int odd = 1, sum = 0;
    
    for (i = strlen(cc); i--; odd = !odd) {
        int digit = cc[i] - '0';
        sum += odd ? digit : m[digit];
    }
    
    return sum % 10 == 0;
}

- (BOOL)check:(id)value {
    // condition
    if (self.condition.length > 0) {
        if (![[AGACTIONMANAGER executeString:self.condition withSender:nil] boolValue]) {
            return YES;
        }
    }
    
    // required
    if (type == validationRuleRequired) {
        if (arguments.firstObject) {
            if (![value isEqual:arguments[0] ]) return NO;
        } else {
            if ([value isKindOfClass:[NSString class]]) {
                if ( ((NSString *)value).length == 0) {
                    return NO;
                }
            } else if ([value isKindOfClass:[NSNumber class]]) {
                if (![value boolValue]) return NO;
            } else if ([value isKindOfClass:[UIBezierPath class]]) {
                if ([value isEmpty]) return NO;
            } else {
                if (!value) return NO;
            }
        }
    }
    // regex
    else if (type == validationRuleRegex) {
        NSRegularExpression *regex = [[AGRegexCache sharedInstance] regexForPattern:arguments[0] options:0];
        NSInteger numOfMatches = [regex numberOfMatchesInString:value options:0 range:NSMakeRange(0, [value length])];
        return (numOfMatches > 0);
    }
    // same as
    else if (type == validationRuleSameAs) {
        id<AGFormClientProtocol> form = [AGACTIONMANAGER executeString:arguments[0] withSender:nil];
        return [value isEqual:form.form.value ];
    }
    // luhn
    else if (type == validationRuleLuhn) {
        const char *number = nil;
        NSInteger digits = [arguments[0] integerValue];
        
        if ([value isKindOfClass:[NSNumber class]]) {
            number = [[value stringValue] cStringUsingEncoding:NSUTF8StringEncoding];
        } else if ([value isKindOfClass:[NSString class]]) {
            number = [value cStringUsingEncoding:NSUTF8StringEncoding];
        } else {
            return NO;
        }
        
        if (strlen(number) != digits) {
            return NO;
        }
        
        if (!luhn(number) ) {
            return NO;
        }
    }
    // range
    else if (type == validationRuleValueRange) {
        if ([value isKindOfClass:[NSNumber class]]) {
            if ([value compare:arguments[0]] == NSOrderedAscending) {
                return NO;
            }
            if ([value compare:arguments[1]] == NSOrderedDescending) {
                return NO;
            }
        } else if ([value isKindOfClass:[NSString class]]) {
            AGFeedDateParser *dateParser = [[AGFeedDateParser alloc] init];
            
            NSDate *date = [dateParser dateFromString:value];
            NSDate *minDate = [dateParser dateFromString:arguments[0] ];
            NSDate *maxDate = [dateParser dateFromString:arguments[1] ];
            
            if ([date compare:minDate] == NSOrderedAscending) {
                [dateParser release];
                return NO;
            }
            if ([date compare:maxDate] == NSOrderedDescending) {
                [dateParser release];
                return NO;
            }
            
            [dateParser release];
        } else {
            return NO;
        }
    }
    // if
    else if (type == validationRuleIf) {
        return [[AGACTIONMANAGER executeString:arguments[0] withSender:nil] boolValue];
    }
    // javascript
    else if (type == validationRuleJavaScript) {
        // context
        JSContext *context = [[[JSContext alloc] init] autorelease];
        context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
            NSLog(@"%@\n", exception);
        };
        
        // script
        NSString *script = [NSString stringWithFormat:@"function check(value){%@}", arguments[0]];
        [context evaluateScript:script];
        
        // check function
        JSValue *checkFunction = [context objectForKeyedSubscript:@"check"];
        
        return [checkFunction callWithArguments:@[value] ].toBool;
    }
    
    return YES;
}

@end
