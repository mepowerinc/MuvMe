#import <Foundation/Foundation.h>

typedef void(^SFAccessTokenSuccessCallback)(NSString* accessToken);
typedef void(^SFAccessTokenFailureCallback)(NSError* error);

@interface SFSalesForceClient : NSObject

+(SFSalesForceClient*) clientWithURL:(NSURL*)url;
+(SFSalesForceClient*) clientWithURL:(NSURL*)url andPresentingViewController:(UIViewController*)presentingViewController;
-(instancetype) initWithURL:(NSURL*)url;
-(instancetype) initWithURL:(NSURL*)url andPresentingViewController:(UIViewController*)presentingViewController;

+(NSString*) accessToken;
-(void) getAccessToken:(SFAccessTokenSuccessCallback)success cancel:(void (^)(void))cancel failure:(SFAccessTokenFailureCallback)failure;

@end
