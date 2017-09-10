#import "AGParams.h"
#import "AGActionManager.h"

@implementation AGParams

@synthesize params;

#pragma mark - Initialization

- (void)dealloc {
    [params release];
    [super dealloc];
}

+ (instancetype)paramsWithJSONString:(NSString *)jsonString {
    AGParams *result = [[[self alloc] init] autorelease];

    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];

    if (jsonData) {
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        for (NSDictionary *paramDict in jsonArray) {
            result.params[ paramDict[@"paramName"] ] = paramDict[@"paramValue"];
        }
    }

    return result;
}

+ (instancetype)paramsWithJSON:(NSDictionary *)json {
    AGParams *result = [[[self alloc] init] autorelease];

    [result.params setDictionary:json];

    return result;
}

- (instancetype)init {
    self = [super init];

    params = [[NSMutableDictionary alloc] init];

    return self;
}

#pragma mark - Lifecycle

- (NSMutableDictionary *)execute {
    return [self execute:nil];
}

- (NSMutableDictionary *)execute:(id)sender {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];

    [params enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop){
        result[key] = [AGACTIONMANAGER executeString:obj withSender:sender];
    }];

    return result;
}

#pragma mark - Copying

- (id)copyWithZone:(NSZone *)zone {
    AGParams *obj = [[[self class] allocWithZone:zone] init];

    [obj.params setDictionary:[[params copy] autorelease] ];

    return obj;
}

@end
