#import "AGLocalizationManager.h"
#import "AGFileManager.h"
#import "GDataXMLNode+XPath.h"

NSString *const AGLocalizationChangedNotification = @"AGLocalizationChangedNotification";

#define KEY_LOCALIZATION @"localization"
#define KEY_LAST_SYSTEM_LOCALIZATION @"last_system_localization"

@interface AGLocalizationManager (){
    NSMutableDictionary *strings;
}
@property(nonatomic, retain) NSArray *shortMonthSymbols;
@property(nonatomic, retain) NSArray *monthSymbols;
@property(nonatomic, retain) NSArray *shortWeekdaySymbols;
@property(nonatomic, retain) NSArray *weekdaySymbols;
@end

@implementation AGLocalizationManager

SINGLETON_IMPLEMENTATION(AGLocalizationManager)

@synthesize localization;
@synthesize shortMonthSymbols;
@synthesize monthSymbols;
@synthesize shortWeekdaySymbols;
@synthesize weekdaySymbols;

- (void)dealloc {
    self.localization = nil;
    self.shortMonthSymbols = nil;
    self.monthSymbols = nil;
    self.shortWeekdaySymbols = nil;
    self.weekdaySymbols = nil;
    [strings release];
    [super dealloc];
}

- (id)init {
    self = [super init];

    // strings
    strings = [[NSMutableDictionary alloc] init];

    // system location
    NSString *systemLocation = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    NSString *lastSystemLocation = [[NSUserDefaults standardUserDefaults] stringForKey:KEY_LAST_SYSTEM_LOCALIZATION];
    NSString *lastLocation = [[NSUserDefaults standardUserDefaults] stringForKey:KEY_LOCALIZATION];

    // default location
    if (![lastSystemLocation isEqualToString:systemLocation]) {
        [[NSUserDefaults standardUserDefaults] setObject:systemLocation forKey:KEY_LAST_SYSTEM_LOCALIZATION];
        self.localization = systemLocation;
    } else if (lastLocation) {
        self.localization = lastLocation;
    } else {
        self.localization = systemLocation;
    }

    return self;
}

#pragma mark - Localization

- (void)setLocalization:(NSString *)localization_ {
    if ([localization isEqualToString:localization_]) return;

    // localization
    [localization release];
    localization = [localization_ copy];

    if (localization) {
        [[NSUserDefaults standardUserDefaults] setObject:localization forKey:KEY_LOCALIZATION];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_LOCALIZATION];
    }

    // load strings
    [strings removeAllObjects];

    if (localization) {
        NSString *filePath = [AGFILEMANAGER pathForUnlocalizedResource:@"strings.json"];
        NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
        NSDictionary *defaultStrings = nil;
        if (jsonData) {
            defaultStrings = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
            [strings setValuesForKeysWithDictionary:defaultStrings];
        }
        [jsonData release];

        filePath = [AGFILEMANAGER pathForLocalizedResource:@"strings.json"];
        jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
        NSDictionary *localizedStrings = nil;
        if (jsonData) {
            localizedStrings = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
            [strings addEntriesFromDictionary:localizedStrings];
        }
        [jsonData release];
    }

    // short weekday symbols
    self.shortWeekdaySymbols = @[
        [AGLOCALIZATION localizedString:@"ddd1"],
        [AGLOCALIZATION localizedString:@"ddd2"],
        [AGLOCALIZATION localizedString:@"ddd3"],
        [AGLOCALIZATION localizedString:@"ddd4"],
        [AGLOCALIZATION localizedString:@"ddd5"],
        [AGLOCALIZATION localizedString:@"ddd6"],
        [AGLOCALIZATION localizedString:@"ddd7"]
    ];

    // weekday symbols
    self.weekdaySymbols = @[
        [AGLOCALIZATION localizedString:@"dddd1"],
        [AGLOCALIZATION localizedString:@"dddd2"],
        [AGLOCALIZATION localizedString:@"dddd3"],
        [AGLOCALIZATION localizedString:@"dddd4"],
        [AGLOCALIZATION localizedString:@"dddd5"],
        [AGLOCALIZATION localizedString:@"dddd6"],
        [AGLOCALIZATION localizedString:@"dddd7"]
    ];

    // short month symbols
    self.shortMonthSymbols = @[
        [AGLOCALIZATION localizedString:@"mmm1"],
        [AGLOCALIZATION localizedString:@"mmm2"],
        [AGLOCALIZATION localizedString:@"mmm3"],
        [AGLOCALIZATION localizedString:@"mmm4"],
        [AGLOCALIZATION localizedString:@"mmm5"],
        [AGLOCALIZATION localizedString:@"mmm6"],
        [AGLOCALIZATION localizedString:@"mmm7"],
        [AGLOCALIZATION localizedString:@"mmm8"],
        [AGLOCALIZATION localizedString:@"mmm9"],
        [AGLOCALIZATION localizedString:@"mmm10"],
        [AGLOCALIZATION localizedString:@"mmm11"],
        [AGLOCALIZATION localizedString:@"mmm12"]
    ];

    // month symbols
    self.monthSymbols = @[
        [AGLOCALIZATION localizedString:@"mmmm1"],
        [AGLOCALIZATION localizedString:@"mmmm2"],
        [AGLOCALIZATION localizedString:@"mmmm3"],
        [AGLOCALIZATION localizedString:@"mmmm4"],
        [AGLOCALIZATION localizedString:@"mmmm5"],
        [AGLOCALIZATION localizedString:@"mmmm6"],
        [AGLOCALIZATION localizedString:@"mmmm7"],
        [AGLOCALIZATION localizedString:@"mmmm8"],
        [AGLOCALIZATION localizedString:@"mmmm9"],
        [AGLOCALIZATION localizedString:@"mmmm10"],
        [AGLOCALIZATION localizedString:@"mmmm11"],
        [AGLOCALIZATION localizedString:@"mmmm12"]
    ];

    // post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:AGLocalizationChangedNotification object:self];
}

- (NSString *)localizedString:(NSString *)key {
    NSString *result = strings[key];

    if (!result) {
        result = strings[@"ERROR_UNKNOWN"];
        if (!result) result = @"";
        NSLog(@"Missing text: %@", key);
    }

    return result;
}

- (NSString *)localizedHttpError:(NSInteger)statusCode {
    NSString *key = [NSString stringWithFormat:@"ERROR_HTTP_%zd", statusCode];
    NSString *result = [[self localizedString:@"ERROR_HTTP"] stringByAppendingFormat:@"%zd", statusCode];

    if (strings[key]) {
        result = [self localizedString:key];
    }

    return result;
}

@end
