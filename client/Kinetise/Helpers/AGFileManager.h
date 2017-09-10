#import "NSObject+Singleton.h"

#define AGFILEMANAGER [AGFileManager sharedInstance]

@interface AGFileManager : NSObject

    SINGLETON_INTERFACE(AGFileManager)

- (NSString *)pathForResource:(NSString *)fileName;
- (NSString *)pathForLocalizedResource:(NSString *)fileName;
- (NSString *)pathForUnlocalizedResource:(NSString *)fileName;

@end
