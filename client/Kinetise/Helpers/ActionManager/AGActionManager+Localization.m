#import "AGActionManager+Localization.h"
#import "AGLocalizationManager.h"
#import "AGApplication.h"
#import "AGImageCache.h"

@implementation AGActionManager (Localization)

- (NSString *)translate:(id)sender :(id)object :(NSString *)string {
    return [AGLOCALIZATION localizedString:string ];
}

- (void)setLocalization:(id)sender :(id)object :(NSString *)localization {
    // localization
    AGLOCALIZATION.localization = localization;

    // clear image cache
    [AGIMAGECACHE removeAllImages];

    // reload screen
    [AGAPPLICATION reload];
}

- (NSString *)getLocalization:(id)sender :(id)object {
    return AGLOCALIZATION.localization;
}

- (NSString *)localizeText:(id)sender :(id)object :(NSString *)key {
    return [AGLOCALIZATION localizedString:key];
}

@end
