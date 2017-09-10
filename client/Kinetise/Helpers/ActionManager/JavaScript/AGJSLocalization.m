#import "AGJSLocalization.h"
#import "AGActionManager+Localization.h"

@implementation AGJSLocalization

- (void)setLanguage:(NSString *)language {
    [AGACTIONMANAGER setLocalization:nil :nil :language];
}

- (NSString *)language {
    return [AGACTIONMANAGER getLocalization:nil :nil];
}

- (NSString *)localize:(NSString *)text {
    return [AGACTIONMANAGER localizeText:nil :nil :text];
}

@end
