#import "AGActionManager+Logic.h"
#import "AGLocalStorage.h"
#import "AGLocalizationManager.h"
#import "AGApplication+Control.h"

@implementation AGActionManager (Logic)

- (NSString *)getLocalValue:(id)sender :(id)object :(NSString *)key {
    return [AGLOCALSTORAGE getValue:key] ? [AGLOCALSTORAGE getValue:key] : @"";
}

- (NSString *)setLocalValue:(id)sender :(id)object :(NSString *)key :(NSString *)value {
    [AGLOCALSTORAGE setValue:value forKey:key];
    
    return value;
}

- (void)saveFormToLocalValues:(id)sender :(id)object :(NSString *)controlAction :(NSString *)postAction {
    // form container
    AGControlDesc *controlDesc = [self executeString:controlAction withSender:sender];
    
    // validation
    if (![self validate:controlDesc]) {
        [AGAPPLICATION.toast makeValidationToast:[AGLOCALIZATION localizedString:@"FORM_INVALID"] ];
        return;
    }
    
    // form
    NSMutableArray *forms = [[NSMutableArray alloc] init];
    [AGAPPLICATION getFormControlsDesc:controlDesc withArray:forms];
    NSMutableDictionary *controlValues = [self postParametersWithForms:forms];
    
    [controlValues enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop){
        [AGLOCALSTORAGE setValue:value forKey:key];
    }];
    
    // reset controls
    [self resetControls:forms ];
    
    // post action
    if (postAction) {
        [self executeString:postAction withSender:sender];
    }
    
    [forms release];
}

- (id)condition:(id)sender :(id)object :(NSNumber *)condition :(NSString *)yesAction :(NSString *)noAction {
    if ([condition boolValue]) {
        return [self executeString:yesAction withSender:sender];
    } else {
        return [self executeString:noAction withSender:sender];
    }
}

- (id)if:(id)sender :(id)object :(NSNumber *)condition :(NSString *)yesAction :(NSString *)noAction {
    return [self condition:sender :object :condition :yesAction :noAction];
}

- (NSNumber *)equal:(id)sender :(id)object :(id)arg1 :(id)arg2 {
    return @([arg1 isEqual:arg2]);
}

- (NSNumber *)greater:(id)sender :(id)object :(id)arg1 :(id)arg2 {
    return @([arg1 compare:arg2] == NSOrderedDescending);
}

- (NSNumber *)lower:(id)sender :(id)object :(id)arg1 :(id)arg2 {
    return @([arg1 compare:arg2] == NSOrderedAscending);
}

- (NSNumber *)equalOrGreater:(id)sender :(id)object :(id)arg1 :(id)arg2 {
    return @([arg1 isEqual:arg2] || [arg1 compare:arg2] == NSOrderedDescending);
}

- (NSNumber *)equalOrLower:(id)sender :(id)object :(id)arg1 :(id)arg2 {
    return @([arg1 isEqual:arg2] || [arg1 compare:arg2] == NSOrderedAscending);
}

- (NSNumber *)not:(id)sender :(id)object :(id)arg1 {
    return @(![arg1 boolValue]);
}

- (NSNumber *)and:(id)sender :(id)object :(id)arg1 :(id)arg2 {
    return @([arg1 boolValue] && [arg2 boolValue]);
}

- (NSNumber *)or:(id)sender :(id)object :(id)arg1 :(id)arg2 {
    return @([arg1 boolValue] || [arg2 boolValue]);
}

@end
