#import "NSObject+Singleton.h"

#define AGLOCALIZATION [AGLocalizationManager sharedInstance]

FOUNDATION_EXPORT NSString *const AGLocalizationChangedNotification;

@interface AGLocalizationManager : NSObject

@property(nonatomic, copy) NSString *localization;
@property(nonatomic, readonly) NSArray *shortMonthSymbols;
@property(nonatomic, readonly) NSArray *monthSymbols;
@property(nonatomic, readonly) NSArray *shortWeekdaySymbols;
@property(nonatomic, readonly) NSArray *weekdaySymbols;

SINGLETON_INTERFACE(AGLocalizationManager)

- (NSString *)localizedString:(NSString *)key;
- (NSString *)localizedHttpError:(NSInteger)statusCode;

@end
