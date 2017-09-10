#import <Foundation/Foundation.h>

@interface NSURLRequest (HTTP)

+ (instancetype)GETRequestWithURL:(NSURL *)URL parameters:(NSDictionary *)parameters;
+ (instancetype)POSTRequestWithURL:(NSURL *)URL parameters:(NSDictionary *)parameters;
+ (instancetype)HTTPRequestWithURL:(NSURL *)URL method:(NSString *)method parameters:(NSDictionary *)parameters;
// POSTRequestWithURL:(NSURL*)URL parameters:(NSDictionary*)parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData)

@end

@interface NSMutableURLRequest (HTTP)

- (void)setURLQuery:(NSDictionary *)parameters;
- (void)addHTTPHeaders:(NSDictionary *)parameters;
- (void)addGETParameters:(NSDictionary *)parameters;
- (void)setGETParameters:(NSDictionary *)parameters;
- (void)setPOSTParameters:(NSDictionary *)parameters;
- (void)setHTTPBasicAuthUser:(NSString *)user password:(NSString *)password;

@end
