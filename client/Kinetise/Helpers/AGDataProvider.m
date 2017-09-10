#import "AGDataProvider.h"

@interface AGDataProvider (){
    FMDatabase *db;
}
@end

@implementation AGDataProvider

@synthesize db;

SINGLETON_IMPLEMENTATION(AGDataProvider)

#pragma mark - Initialization

- (void)dealloc {
    [db close];
    [db release];
    [super dealloc];
}

- (id)init {
    self = [super init];

    // copy db
    NSString *sourceFilePath = FILE_PATH_BUNDLE(@"Kinetise.sqlite");
    NSString *destinationFilePath = FILE_PATH_LIBRARY(@"Kinetise.sqlite");
    if (![[NSFileManager defaultManager] fileExistsAtPath:destinationFilePath]) {
        [[NSFileManager defaultManager] copyItemAtPath:sourceFilePath toPath:destinationFilePath error:nil];
    }

    // db
    db = [[FMDatabase alloc] initWithPath:destinationFilePath];
    db.shouldCacheStatements = YES;
#ifdef DEBUG
    db.logsErrors = YES;
#endif

    // open db
    if (![db open]) {
        [db close];
        [db release];
        db = nil;
    }

    return self;
}

@end
