#import "LIALinkedInApplication.h"

@interface LIALinkedInClient : NSObject

+(LIALinkedInClient*) clientForApplication:(LIALinkedInApplication*)application;
+(LIALinkedInClient*) clientForApplication:(LIALinkedInApplication*)application withPresentingViewController:(UIViewController*)presentingViewController;

+(BOOL) hasValidToken;
+(NSString*) accessToken;
-(void) getAccessToken:(NSString*)authorizationCode success:(void (^)(NSDictionary*))success failure:(void (^)(NSError*))failure;
-(void) getAuthorizationCode:(void (^)(NSString*))success cancel:(void (^)(void))cancel failure:(void (^)(NSError*))failure;

@end
