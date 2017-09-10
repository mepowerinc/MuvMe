#import "NSObject+Singleton.h"

#define AGLOCALSTORAGE [AGLocalStorage sharedInstance]

@interface AGLocalStorage : NSObject

    SINGLETON_INTERFACE(AGLocalStorage)

- (NSString *)getValue:(NSString *)key;
- (void)setValue:(NSString *)value forKey:(NSString *)key;

- (void)query:(NSString *)table values:(NSDictionary *)values filter:(BOOL (^)(NSDictionary *item, NSDictionary *input))filter sort:(NSString *)sort ascending:(BOOL)ascending limit:(NSUInteger)limit completion:(void (^)(NSArray *items))completion;
- (void)insert:(NSString *)table values:(NSDictionary *)values completion:(void (^)(void))completion;
- (void)update:(NSString *)table values:(NSDictionary *)values by:(BOOL (^)(NSDictionary *item, NSDictionary *input))match completion:(void (^)(void))completion;
- (void)delete:(NSString *)table values:(NSDictionary *)values by:(BOOL (^)(NSDictionary *item, NSDictionary *input))match completion:(void (^)(void))completion;
- (NSString *)attachmentPath:(NSString *)fileName;

@end
