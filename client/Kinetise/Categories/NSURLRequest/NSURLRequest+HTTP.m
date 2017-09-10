#import "NSURLRequest+HTTP.h"
#import "NSData+HTTP.h"
#import "NSString+Base64.h"
#import "NSString+URL.h"

@implementation NSURLRequest (HTTP)

+ (instancetype)GETRequestWithURL:(NSURL *)URL parameters:(NSDictionary *)parameters {
    return [self HTTPRequestWithURL:URL method:@"GET" parameters:parameters];
}

+ (instancetype)POSTRequestWithURL:(NSURL *)URL parameters:(NSDictionary *)parameters {
    return [self HTTPRequestWithURL:URL method:@"POST" parameters:parameters];
}

+ (instancetype)HTTPRequestWithURL:(NSURL *)URL method:(NSString *)method parameters:(NSDictionary *)parameters {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = [method uppercaseString];

    if ([method isEqualToString:@"GET"]) {
        [request setGETParameters:parameters];
    } else if ([method isEqualToString:@"POST"]) {
        [request setPOSTParameters:parameters];
    }

    return request;
}

@end

@implementation NSMutableURLRequest (HTTP)

- (void)setURLQuery:(NSDictionary *)parameters {
    NSString *uri = (self.URL.absoluteString ? : @"");
    NSString *query = [NSString URLQueryWithParameters:parameters];
    self.URL = [NSURL URLWithString:[uri stringByAppendingURLQuery:query] ];
}

- (void)addHTTPHeaders:(NSDictionary *)parameters {
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        [self addValue:value forHTTPHeaderField:key];
    }];
}

- (void)addGETParameters:(NSDictionary *)parameters {
    if (!parameters) return;

    NSString *uri = (self.URL.absoluteString ? : @"");
    NSString *query = [NSString URLQueryWithParameters:parameters];
    NSString *existingQuery = [uri URLQuery];

    if (existingQuery) {
        query = [existingQuery stringByMergingURLQuery:query];
    }

    self.URL = [NSURL URLWithString:[uri stringByAppendingURLQuery:query] ];
}

- (void)setGETParameters:(NSDictionary *)parameters {
    if (!parameters) return;

    NSString *uri = (self.URL.absoluteString ? : @"");
    NSString *query = [NSString URLQueryWithParameters:parameters];

    self.URL = [NSURL URLWithString:[uri stringByAppendingURLQuery:query] ];
}

- (void)setPOSTParameters:(NSDictionary *)parameters {
    self.HTTPMethod = @"POST";
    self.HTTPBody = [NSData dataWithHTTPForm:parameters];
    [self addValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [self addValue:[NSString stringWithFormat:@"%zd", self.HTTPBody.length] forHTTPHeaderField:@"Content-Length"];
}

- (void)setHTTPBasicAuthUser:(NSString *)user password:(NSString *)password {
    NSString *authHeader = [NSString stringWithFormat:@"%@:%@", (user ? : @""), (password ? : @"")];
    authHeader = [NSString stringWithFormat:@"Basic %@", [authHeader base64EncodedString]];
    [self addValue:authHeader forHTTPHeaderField:@"Authorization"];
}

@end
