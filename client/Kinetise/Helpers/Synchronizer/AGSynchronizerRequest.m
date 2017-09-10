#import "AGSynchronizerRequest.h"

@implementation AGSynchronizerRequest

@synthesize uri;
@synthesize httpMethod;
@synthesize httpQueryParams;
@synthesize httpHeaderParams;
@synthesize httpBody;
@synthesize httpBodyFilePath;
@synthesize responseTransform;
@synthesize key;
@synthesize value;
@synthesize sendTimestamp;

- (void)dealloc {
    self.uri = nil;
    self.httpMethod = nil;
    self.httpQueryParams = nil;
    self.httpHeaderParams = nil;
    self.httpBody = nil;
    self.httpBodyFilePath = nil;
    self.responseTransform = nil;
    self.key = nil;
    self.value = nil;
    self.sendTimestamp = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];

    self.httpMethod = @"POST";
    self.sendTimestamp = [NSDate distantFuture];

    return self;
}

- (void)clear {
    self.uri = nil;
    self.httpMethod = nil;
    self.httpQueryParams = nil;
    self.httpHeaderParams = nil;
    self.httpBody = nil;
    self.httpBodyFilePath = nil;
    self.responseTransform = nil;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    AGSynchronizerRequest *obj = [[[self class] allocWithZone:zone] init];

    obj.uri = uri;
    obj.httpMethod = httpMethod;
    obj.httpQueryParams = httpQueryParams;
    obj.httpHeaderParams = httpHeaderParams;
    obj.httpBody = httpBody;
    obj.httpBodyFilePath = httpBodyFilePath;
    obj.responseTransform = responseTransform;
    obj.key = key;
    obj.value = value;
    obj.sendTimestamp = sendTimestamp;

    return obj;
}

#pragma mark - NSCompare

- (BOOL)isEqualToSynchronizerRequest:(AGSynchronizerRequest *)object {
    return [object.key isEqualToString:key];
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[AGSynchronizerRequest class]]) {
        return NO;
    }

    return [self isEqualToSynchronizerRequest:(AGSynchronizerRequest *)object];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];

    self.uri = [decoder decodeObjectForKey:@"uri"];
    self.httpMethod = [decoder decodeObjectForKey:@"httpMethod"];
    self.httpQueryParams = [decoder decodeObjectForKey:@"httpQueryParams"];
    self.httpHeaderParams = [decoder decodeObjectForKey:@"httpHeaderParams"];
    self.httpBody = [decoder decodeObjectForKey:@"httpBody"];
    self.httpBodyFilePath = [decoder decodeObjectForKey:@"httpBodyFilePath"];
    self.responseTransform = [decoder decodeObjectForKey:@"responseTransform"];
    self.key = [decoder decodeObjectForKey:@"key"];
    self.value = [decoder decodeObjectForKey:@"value"];
    self.sendTimestamp = [decoder decodeObjectForKey:@"timestamp"];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:uri forKey:@"uri"];
    [encoder encodeObject:httpMethod forKey:@"httpMethod"];
    [encoder encodeObject:httpQueryParams forKey:@"httpQueryParams"];
    [encoder encodeObject:httpHeaderParams forKey:@"httpHeaderParams"];
    [encoder encodeObject:httpBody forKey:@"httpBody"];
    [encoder encodeObject:httpBodyFilePath forKey:@"httpBodyFilePath"];
    [encoder encodeObject:responseTransform forKey:@"responseTransform"];
    [encoder encodeObject:key forKey:@"key"];
    [encoder encodeObject:value forKey:@"value"];
    [encoder encodeObject:sendTimestamp forKey:@"timestamp"];
}

@end
