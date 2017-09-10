#import "AGApplication.h"

@interface AGApplication (Authentication)

- (void)loginWithAutosessionId;
- (void)loginOrUpdateWithSessionId:(NSString *)sessionId;
- (void)loginWithSessionId:(NSString *)sessionId;
- (void)loginWithBasicAuthSessionId:(NSString *)basicAuthSessionId;
- (void)logout;
- (void)logout:(NSString *)screenId;

@end
