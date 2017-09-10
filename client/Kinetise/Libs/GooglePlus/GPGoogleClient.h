#import "GPGoogleApplication.h"

@interface GPGoogleClient : NSObject

+(GPGoogleClient*) clientWithApplication:(GPGoogleApplication*)application;
+(GPGoogleClient*) clientWithApplication:(GPGoogleApplication*)application andPresentingViewController:(UIViewController*)presentingViewController;
-(instancetype) initWithApplication:(GPGoogleApplication*)application;
-(instancetype) initWithApplication:(GPGoogleApplication*)application andPresentingViewController:(UIViewController*)presentingViewController;

+(BOOL) hasValidToken;
+(NSString*) accessToken;
-(void) getAccessToken:(void (^)(NSString*))success cancel:(void (^)(void))cancel failure:(void (^)(NSError*))failure;

@end
