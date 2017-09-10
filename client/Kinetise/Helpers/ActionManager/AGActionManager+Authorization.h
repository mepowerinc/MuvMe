#import "AGActionManager.h"

@interface AGActionManager (Authorization)

- (void)login:(id)sender :(id)object :(NSString *)controlAction :(NSString *)uri :(NSString *)httpQueryParamsString :(NSString *)headerParamsString :(NSString *)bodyParamsString :(NSString *)httpMethod :(NSString *)contentType :(NSString *)requestTransform :(NSString *)responseTransform :(NSString *)action;
- (void)logout:(id)sender :(id)object :(NSString *)uri :(NSString *)httpQueryParamsString;
- (void)logout:(id)sender :(id)object :(NSString *)uri :(NSString *)httpQueryParamsString :(NSString *)action;
- (NSString *)getSessionId:(id)sender :(id)object;
- (NSNumber *)isLoggedIn:(id)sender :(id)object;

- (void)facebookLogin:(id)sender :(id)object :(NSString *)appId :(NSString *)uri :(NSString *)action :(NSString *)httpQueryParamsString;
- (void)linkedinLogin:(id)sender :(id)object :(NSString *)uri :(NSString *)action :(NSString *)httpQueryParamsString;
- (void)googleLogin:(id)sender :(id)object :(NSString *)uri :(NSString *)httpQueryParamsString :(NSString *)headerParamsString :(NSString *)bodyParamsString :(NSString *)httpMethod :(NSString *)contentType :(NSString *)requestTransform :(NSString *)responseTransform :(NSString *)action;
- (NSString *)getGoogleUserAccessToken:(id)sender :(id)object;

- (void)basicAuthLogin:(id)sender :(id)object :(NSString *)uri :(NSString *)loginControlId :(NSString *)passwordControlId :(NSString *)action :(NSString *)httpQueryParamsString;
- (NSString *)getBasicAuthBase64:(id)sender :(id)object;
- (void)basicAuthLogout:(id)sender :(id)object;

- (void)salesforceLogin:(id)sender :(id)object :(NSString *)salesforceUri :(NSString *)salesforceHttpQueryParamsString :(NSString *)salesforceHeaderParamsString :(NSString *)action :(NSString *)alteapiUri :(NSString *)alterapiHttpQueryParamsString :(NSString *)alterapiHeaderParamsString;
- (NSString *)getSalesforceAccessToken:(id)sender :(id)object;

@end
