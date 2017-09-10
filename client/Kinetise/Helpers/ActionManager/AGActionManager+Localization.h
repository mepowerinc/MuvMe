#import "AGActionManager.h"

@interface AGActionManager (Localization)

- (NSString *)translate:(id)sender :(id)object :(NSString *)string;
- (void)setLocalization:(id)sender :(id)object :(NSString *)localization;
- (NSString *)getLocalization:(id)sender :(id)object;
- (NSString *)localizeText:(id)sender :(id)object :(NSString *)key;

@end
