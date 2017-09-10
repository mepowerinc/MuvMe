#import "NSObject+Singleton.h"
#import <FMDB/FMDB.h>

#define DATABASE [AGDataProvider sharedInstance].db

@interface AGDataProvider : NSObject

    SINGLETON_INTERFACE(AGDataProvider)

@property(nonatomic, readonly) FMDatabase *db;

@end
