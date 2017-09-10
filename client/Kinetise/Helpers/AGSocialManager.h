#import "NSObject+Singleton.h"

#define AGSOCIALMANAGER [AGSocialManager sharedInstance]

typedef NS_OPTIONS (NSInteger, AGSocialService){
    AGSocialServiceNone = 0,
    AGSocialServiceFacebook = 1 << 1,
        AGSocialServiceTwitter = 1 << 2,
};

@interface AGSocialManager : NSObject

@property(nonatomic, assign) AGSocialService services;
@property(nonatomic, readonly) NSString *facebookAccessToken;
@property(nonatomic, readonly) NSString *twitterAccessToken;

SINGLETON_INTERFACE(AGSocialManager)

- (void)getAccessTokens:(void (^)())completionBlock;

@end
