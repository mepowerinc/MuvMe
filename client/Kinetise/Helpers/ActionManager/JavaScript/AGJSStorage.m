#import "AGJSStorage.h"
#import "AGActionManager+Logic.h"

@implementation AGJSStorage

- (NSString *)get:(NSString *)key {
    return [AGACTIONMANAGER getLocalValue:nil :nil :key];
}

- (void)set:(NSString *)key :(id)value {
    if ([value isKindOfClass:[NSString class]]) {
        [AGACTIONMANAGER setLocalValue:nil :nil :key :value];
    } else if ([value isKindOfClass:[NSNumber class]]) {
        [AGACTIONMANAGER setLocalValue:nil :nil :key :[value stringValue]];
    } else {
        [AGACTIONMANAGER setLocalValue:nil :nil :key :@""];
    }
}

- (void)insert:(NSString *)controlId {
    [AGACTIONMANAGER saveFormToLocalValues:nil :nil :controlId :nil];
}

@end
