#import "AGLocalStorage.h"
#import "AGDataProvider.h"
#import "AGApplication.h"
#import "AGFileManager.h"
#import "NSString+GUID.h"
#import "NSString+MD5.h"

@interface AGLocalStorage (){
    NSMutableDictionary *variables;
    NSMutableDictionary *storage;
}
@end

@implementation AGLocalStorage

SINGLETON_IMPLEMENTATION(AGLocalStorage)

#pragma mark - Initialization

- (void)dealloc {
    [variables release];
    [storage release];
    [super dealloc];
}

- (id)init {
    self = [super init];

    // variables
    variables = [[NSMutableDictionary alloc] init];

    // load variables
    FMResultSet *s = [DATABASE executeQuery:@"SELECT * FROM Variable"];
    while ([s next]) {
        NSString *key = [s stringForColumn:@"Key"];
        NSString *value = [s stringForColumn:@"Value"];
        variables[key] = value;
    }
    [s close];

    // storage
    storage = [[NSMutableDictionary alloc] init];

    // storage data
    NSString *destinationFilePath = FILE_PATH_LIBRARY(@"Storage");
    if (![[NSFileManager defaultManager] fileExistsAtPath:destinationFilePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:destinationFilePath withIntermediateDirectories:NO attributes:nil error:nil];
        
        NSDictionary *tables = AGAPPLICATION.descriptor.localStorage;
        [tables enumerateKeysAndObjectsUsingBlock:^(NSString *tableName, NSString *tableSource, BOOL *stop) {
            NSString *fileName = [tableSource substringFromIndex:[@"assets://" length] ];
            NSString *filePath = [AGFILEMANAGER pathForResource:fileName];
            NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
            NSArray *items = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            [data release];
            
            for(NSDictionary *item in items) {
                NSMutableDictionary *values = [[NSMutableDictionary alloc] init];
                
                [item enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *obj, BOOL *stop) {
                    if ([obj[@"metadata"][@"type"] isEqualToString:@"text"]) {
                        values[key] = obj[@"data"];
                    } else if ([obj[@"metadata"][@"type"] isEqualToString:@"boolean"]) {
                        values[key] = obj[@"data"];
                    } else if ([obj[@"metadata"][@"type"] isEqualToString:@"image"]) {
                        NSString *fileName = [obj[@"metadata"][@"localUri"] substringFromIndex:[@"local://" length] ];
                        NSString *filePath = [AGFILEMANAGER pathForResource: [NSString stringWithFormat:@"dbattachment/%@", fileName] ];
                        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                            filePath = [AGFILEMANAGER pathForResource:fileName];
                        }
                        values[key] = [NSURL fileURLWithPath:filePath];
                    }
                }];
                
                [self insert:tableName values:values completion:nil];
                [values release];
            }
        }];
    }

    return self;
}

#pragma mark - Lifecycle

- (NSString *)getValue:(NSString *)key {
    return variables[key];
}

- (void)setValue:(NSString *)value forKey:(NSString *)key {
    if (!key || !value) return;

    variables[key] = value;

    [DATABASE executeUpdate:@"INSERT OR REPLACE INTO Variable (Key, Value) VALUES (?, ?)", key, value];
}

- (NSMutableArray *)collection:(NSString *)collectionId {
    if (!storage[collectionId]) {
        NSString *fileName = [NSString stringWithFormat:@"Storage/%@.json", collectionId];
        NSString *filePath = FILE_PATH_LIBRARY(fileName);

        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSData *data = [NSData dataWithContentsOfFile:filePath];
            NSArray *collection = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            storage[collectionId] = collection;
        } else {
            NSData *data = [NSJSONSerialization dataWithJSONObject:@[] options:NSJSONWritingPrettyPrinted error:nil];
            [data writeToFile:filePath atomically:YES];
            storage[collectionId] = [NSMutableArray array];
        }
    }

    return storage[collectionId];
}

- (void)updateCollection:(NSString *)collectionId {
    if (!storage[collectionId]) return;

    NSString *fileName = [NSString stringWithFormat:@"Storage/%@.json", collectionId];
    NSString *filePath = FILE_PATH_LIBRARY(fileName);

    NSData *data = [NSJSONSerialization dataWithJSONObject:storage[collectionId] options:NSJSONWritingPrettyPrinted error:nil];
    [data writeToFile:filePath atomically:YES];
}

- (NSDictionary *)processValues:(NSDictionary *)values {
    NSMutableDictionary *mutableValues = [values isKindOfClass:[NSMutableDictionary class]] ? values : [values mutableCopy];

    // attachments
    [mutableValues enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop){
        if ([obj isKindOfClass:[NSURL class]]) {
            NSURL *url = obj;
            NSString *fileName = [NSString stringWithFormat:@"%@.%@", [url.path md5], [url.path pathExtension] ];
            NSString *filePath = [AGLOCALSTORAGE attachmentPath:fileName];
            NSString *storagePath = [NSString stringWithFormat:@"local://%@", [filePath lastPathComponent] ];

            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            [[NSFileManager defaultManager] copyItemAtPath:url.path toPath:filePath error:nil];
            mutableValues[key] = storagePath;
        }
    }];

    return mutableValues;
}

- (void)query:(NSString *)table values:(NSDictionary *)values filter:(BOOL (^)(NSDictionary *item, NSDictionary *input))filter sort:(NSString *)sort ascending:(BOOL)ascending limit:(NSUInteger)limit completion:(void (^)(NSArray *items))completion {
    NSArray *collection = [self collection:table];
    NSArray *result = [NSMutableArray arrayWithCapacity:collection.count];

    // filter
    for (NSDictionary *item in collection) {
        if (filter(item, values) ) {
            [(NSMutableArray *) result addObject:item];
        }
    }

    // sort
    if (sort.length > 0) {
        if (ascending) {
            NSSortDescriptor *sortDesccriptor = [NSSortDescriptor sortDescriptorWithKey:sort ascending:ascending];
            result = [result sortedArrayUsingDescriptors:@[sortDesccriptor]];
        } else {
            result = [[result reverseObjectEnumerator] allObjects];
        }
    }

    // limit
    if (limit > 0) {
        if (result.count > limit) {
            result = [result subarrayWithRange:NSMakeRange(0, limit) ];
        }
    }

    if (completion) completion(result);
}

- (void)insert:(NSString *)table values:(NSDictionary *)values completion:(void (^)(void))completion {
    values = [self processValues:values];
    NSMutableDictionary *item = [[values mutableCopy] autorelease];

    NSMutableArray *collection = [self collection:table];
    [collection addObject:item];

    [self updateCollection:table];
}

- (void)update:(NSString *)table values:(NSDictionary *)values by:(BOOL (^)(NSDictionary *item, NSDictionary *input))match completion:(void (^)(void))completion {
    NSMutableArray *collection = [self collection:table];
    values = [self processValues:values];

    for (NSMutableDictionary *item in collection) {
        if (match(item, values) ) {
            [item addEntriesFromDictionary:values];
        }
    }

    [self updateCollection:table];

    if (completion) completion();
}

- (void)delete:(NSString *)table values:(NSDictionary *)values by:(BOOL (^)(NSDictionary *item, NSDictionary *input))match completion:(void (^)(void))completion {
    NSMutableArray *collection = [self collection:table];
    values = [self processValues:values];

    for (int i = 0; i < collection.count; ++i) {
        NSDictionary *item = collection[i];

        if (match(item, values) ) {
            [collection removeObjectAtIndex:i];
            --i;
        }
    }

    [self updateCollection:table];

    if (completion) completion();
}

- (NSString *)attachmentPath:(NSString *)fileName {
    NSString *filePath = [NSString stringWithFormat:@"Storage/%@", fileName];

    return FILE_PATH_LIBRARY(filePath);
}

@end
