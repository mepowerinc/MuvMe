#import "AGActionManager+Authorization.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <MBProgressHUD/MBProgressHUD+Hide.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <RMUniversalAlert/RMUniversalAlert.h>
#import "AGFormClientProtocol.h"
#import "AGLocalizationManager.h"
#import "LIALinkedInClient.h"
#import "GPGoogleClient.h"
#import "SFSalesForceClient.h"
#import "AGApplication+Popup.h"
#import "AGApplication+Authentication.h"
#import "AGApplication+Control.h"
#import "NSString+UriEncoding.h"
#import "NSString+MD5.h"
#import "NSString+SHA.h"
#import "NSData+HTTP.h"
#import "NSObject+Nil.h"
#import "NSString+Base64.h"
#import "NSString+URL.h"
#import "NSString+GUID.h"

@implementation AGActionManager (Authorization)

- (void)login:(id)sender :(id)object :(NSString *)controlAction :(NSString *)uri :(NSString *)httpQueryParamsString :(NSString *)headerParamsString :(NSString *)bodyParamsString :(NSString *)httpMethod :(NSString *)contentType :(NSString *)requestTransform :(NSString *)responseTransform :(NSString *)action {
    // uri
    uri = [[sender fullPath:uri] uriString];
    
    // params
    AGHTTPQueryParams *httpQueryParams = [AGHTTPQueryParams paramsWithJSONString:httpQueryParamsString ];
    AGHTTPHeaderParams *httpHeaderParams = [AGHTTPHeaderParams paramsWithJSONString:headerParamsString ];
    AGHTTPBodyParams *httpBodyParams = [AGHTTPBodyParams paramsWithJSONString:bodyParamsString ];
    
    // forms
    AGControlDesc *controlDesc = [self executeString:controlAction withSender:sender];
    NSMutableArray *forms = [[NSMutableArray alloc] init];
    [AGAPPLICATION getFormControlsDesc:controlDesc withArray:forms];
    
    // body
    NSData *bodyData = nil;
    if ([contentType isEqualToString:@"application/json"]) {
        bodyData = [self postDataFrom:sender withForms:forms andHttpBodyParams:[httpBodyParams execute:sender] usingTransform:requestTransform];
    } else if ([contentType isEqualToString:@"application/x-www-form-urlencoded"]) {
        NSMutableDictionary *postParameters = [self postParametersWithForms:forms];
        [postParameters addEntriesFromDictionary:[httpBodyParams execute:sender] ];
        bodyData = [NSData dataWithHTTPForm:postParameters];
    }
    
    // request
    AGActionManagerRequest *request = [[AGActionManagerRequest alloc] init];
    request.uri = uri;
    request.httpMethod = httpMethod;
    request.httpQueryParams = [httpQueryParams execute:sender];
    request.httpHeaderParams = [httpHeaderParams execute:sender];
    request.httpBody = bodyData;
    request.contentType = contentType;
    request.action = @"login";
    request.postAction = action;
    request.controlsToReset = forms;
    request.responseTransform = responseTransform;
    request.sender = sender;
    [self sendRequest:request];
    [request release];
    [forms release];
}

- (void)logout:(id)sender :(id)object :(NSString *)uri :(NSString *)httpQueryParamsString {
    // uri
    uri = [uri uriString];
    
    // params
    AGHTTPQueryParams *httpQueryParams = [AGHTTPQueryParams paramsWithJSONString:httpQueryParamsString ];
    
    // request
    AGActionManagerRequest *request = [[AGActionManagerRequest alloc] init];
    request.uri = uri;
    request.httpQueryParams = [httpQueryParams execute:sender];
    request.action = @"logout";
    request.sender = sender;
    [self sendRequest:request];
    [request release];
}

- (void)logout:(id)sender :(id)object :(NSString *)uri :(NSString *)httpQueryParamsString :(NSString *)action {
    // uri
    uri = [[sender fullPath:uri] uriString];
    
    // params
    AGHTTPQueryParams *httpQueryParams = [AGHTTPQueryParams paramsWithJSONString:httpQueryParamsString ];
    
    // request
    AGActionManagerRequest *request = [[AGActionManagerRequest alloc] init];
    request.uri = uri;
    request.httpQueryParams = [httpQueryParams execute:sender];
    request.action = @"logout";
    request.postAction = action;
    request.sender = sender;
    [self sendRequest:request];
    [request release];
}

- (NSString *)getSessionId:(id)sender :(id)object {
    if (!AGAPPLICATION.sessionId) {
        AGAPPLICATION.sessionId = [NSString stringWithGUID];
    }
    
    return AGAPPLICATION.sessionId;
}

- (NSNumber *)isLoggedIn:(id)sender :(id)object {
    return @(AGAPPLICATION.isLoggedIn);
}

- (void)facebookLogin:(id)sender :(id)object :(NSString *)appId :(NSString *)uri :(NSString *)action :(NSString *)httpQueryParamsString {
    uri = [[sender fullPath:uri] uriString];
    AGHTTPQueryParams *httpQueryParams = [AGHTTPQueryParams paramsWithJSONString:httpQueryParamsString ];
    
    // progress hud
    MBProgressHUD *progressHUD = [MBProgressHUD HUDForView:AGAPPLICATION.rootController.view];
    if (!progressHUD) {
        progressHUD = [MBProgressHUD showHUDAddedTo:AGAPPLICATION.rootController.view animated:YES];
        progressHUD.minShowTime = 0.25f;
    }
    
    // facebook access
    if ([FBSDKAccessToken currentAccessToken]) {
        NSString *accessToken = [FBSDKAccessToken currentAccessToken].tokenString;
        
        // request
        if (accessToken) {
            NSLog(@"Facebook access token: %@", accessToken);
            
            // request
            AGActionManagerRequest *request = [[AGActionManagerRequest alloc] init];
            request.uri = uri;
            request.httpQueryParams = [httpQueryParams execute:sender];
            request.httpBody = [NSData dataWithHTTPForm:@{@"access_token":accessToken} ];
            request.action = @"facebookLogin";
            request.postAction = action;
            request.sender = sender;
            [self sendRequest:request];
            [request release];
        } else {
            [progressHUD hide:YES completion:^{
                [AGAPPLICATION showErrorPopup:[AGLOCALIZATION localizedString:@"ERROR_LOGIN"] ];
            }];
        }
    } else {
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        login.loginBehavior = FBSDKLoginBehaviorNative;
        
        [login logInWithReadPermissions:@[@"email"] fromViewController:AGAPPLICATION.rootController handler:^(FBSDKLoginManagerLoginResult *result, NSError *error){
            if (error) {
                NSLog(@"FB error");
                
                [progressHUD hide:YES completion:^{
                    [AGAPPLICATION showErrorPopup:[AGLOCALIZATION localizedString:@"ERROR_LOGIN"] ];
                }];
            } else if (result.isCancelled) {
                NSLog(@"FB cancelled");
                
                [progressHUD hide:YES];
            } else {
                NSLog(@"FB logged in");
                
                NSString *accessToken = [FBSDKAccessToken currentAccessToken].tokenString;
                
                // request
                if (accessToken) {
                    NSLog(@"Facebook access token: %@", accessToken);
                    
                    // request
                    AGActionManagerRequest *request = [[AGActionManagerRequest alloc] init];
                    request.uri = uri;
                    request.httpQueryParams = [httpQueryParams execute:sender];
                    request.httpBody = [NSData dataWithHTTPForm:@{@"access_token":accessToken} ];
                    request.action = @"facebookLogin";
                    request.postAction = action;
                    request.sender = sender;
                    [self sendRequest:request];
                    [request release];
                } else {
                    [progressHUD hide:YES completion:^{
                        [AGAPPLICATION showErrorPopup:[AGLOCALIZATION localizedString:@"ERROR_LOGIN"] ];
                    }];
                }
            }
        }];
        
        [login release];
    }
}

- (void)linkedinLogin:(id)sender :(id)object :(NSString *)uri :(NSString *)action :(NSString *)httpQueryParamsString {
    NSString *appKey = AG_LINKEDIN_APP_KEY;
    NSString *appSecret = AG_LINKEDIN_APP_SECRET;
    
    uri = [[sender fullPath:uri] uriString];
    
    AGHTTPQueryParams *httpQueryParams = [AGHTTPQueryParams paramsWithJSONString:httpQueryParamsString ];
    
    LIALinkedInApplication *application = [LIALinkedInApplication applicationWithRedirectUri:@"http://localhost"
                                                                                    clientId:appKey
                                                                                clientSecret:appSecret
                                                                                       state:@"DCEEFWF45453sdffef424"
                                                                               grantedAccess:nil];
    
    LIALinkedInClient *client = [LIALinkedInClient clientForApplication:application];
    
    // progress hud
    MBProgressHUD *progressHUD = [MBProgressHUD HUDForView:AGAPPLICATION.rootController.view];
    if (!progressHUD) {
        progressHUD = [MBProgressHUD showHUDAddedTo:AGAPPLICATION.rootController.view animated:YES];
        progressHUD.minShowTime = 0.25f;
    }
    
    // client
    [client getAuthorizationCode:^(NSString *code) {
        [client getAccessToken:code success:^(NSDictionary *accessTokenData) {
            NSString *accessToken = accessTokenData[@"access_token"];
            if (isNil(accessToken) ) accessToken = @"";
            
            // request
            AGActionManagerRequest* request = [[AGActionManagerRequest alloc] init];
            request.uri = uri;
            request.httpQueryParams = [httpQueryParams execute:sender];
            request.httpBody = [NSData dataWithHTTPForm:@{@"access_token":accessToken} ];
            request.action = @"linkedinLogin";
            request.postAction = action;
            request.sender = sender;
            [self sendRequest:request];
            [request release];
        } failure:^(NSError *error) {
            NSLog(@"Quering Linkedin accessToken failed: %@", error);
            
            [progressHUD hide:YES completion:^{
                [AGAPPLICATION showErrorPopup:[AGLOCALIZATION localizedString:@"ERROR_LOGIN"] ];
            }];
        }];
    } cancel:^{
        NSLog(@"Linkedin authorization cancelled");
        
        [progressHUD hide:YES];
    } failure:^(NSError *error) {
        NSLog(@"Linkedin authorization failed: %@", error);
        
        [progressHUD hide:YES completion:^{
            [AGAPPLICATION showErrorPopup:[AGLOCALIZATION localizedString:@"ERROR_LOGIN"] ];
        }];
    }];
}

- (void)googleLogin:(id)sender :(id)object :(NSString *)uri :(NSString *)httpQueryParamsString :(NSString *)headerParamsString :(NSString *)bodyParamsString :(NSString *)httpMethod :(NSString *)contentType :(NSString *)requestTransform :(NSString *)responseTransform :(NSString *)action {
    // uri
    uri = [[sender fullPath:uri] uriString];
    
    // params
    AGHTTPQueryParams *httpQueryParams = [AGHTTPQueryParams paramsWithJSONString:httpQueryParamsString ];
    AGHTTPHeaderParams *httpHeaderParams = [AGHTTPHeaderParams paramsWithJSONString:headerParamsString ];
    AGHTTPBodyParams *httpBodyParams = [AGHTTPBodyParams paramsWithJSONString:bodyParamsString ];
    
    // client
    GPGoogleApplication *application = [GPGoogleApplication applicationWithRedirectUri:@"https://www.kinetise.com/oauth/index/google-redirect"
                                                                              clientId:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"GoogleClientID"]
                                                                                 state:@"profile"
                                                                           permissions:@[@"email", @"profile", @"https://www.googleapis.com/auth/spreadsheets", @"https://www.googleapis.com/auth/drive"]];
    
    GPGoogleClient *client = [GPGoogleClient clientWithApplication:application];
    
    // progress hud
    MBProgressHUD *progressHUD = [MBProgressHUD HUDForView:AGAPPLICATION.rootController.view];
    if (!progressHUD) {
        progressHUD = [MBProgressHUD showHUDAddedTo:AGAPPLICATION.rootController.view animated:YES];
        progressHUD.minShowTime = 0.25f;
    }
    
    // client request
    [client getAccessToken:^(NSString *accessToken) {
        if (isNotEmpty(uri) ) {
            // body
            NSData *bodyData = nil;
            
            if ([contentType isEqualToString:@"application/json"]) {
                NSMutableDictionary *json = [NSMutableDictionary dictionaryWithDictionary:@{@"access_token":accessToken} ];
                [json addEntriesFromDictionary:[httpBodyParams execute:sender] ];
                
                bodyData = [self postDataFrom:sender withJSON:json usingTransform:requestTransform];
            } else if ([contentType isEqualToString:@"application/x-www-form-urlencoded"]) {
                NSMutableDictionary *postParameters = [NSMutableDictionary dictionaryWithDictionary:@{@"access_token":accessToken} ];
                [postParameters addEntriesFromDictionary:[httpBodyParams execute:sender] ];
                
                bodyData = [NSData dataWithHTTPForm:postParameters];
            }
            
            // request
            AGActionManagerRequest *request = [[AGActionManagerRequest alloc] init];
            request.uri = uri;
            request.httpMethod = httpMethod;
            request.httpQueryParams = [httpQueryParams execute:sender];
            request.httpHeaderParams = [httpHeaderParams execute:sender];
            request.httpBody = bodyData;
            request.contentType = contentType;
            request.action = @"googleLogin";
            request.postAction = action;
            request.responseTransform = responseTransform;
            request.sender = sender;
            [self sendRequest:request];
            [request release];
        } else {
            // login
            [AGAPPLICATION loginWithAutosessionId];
            
            // post action
            [self executeString:action withSender:sender];
            
            // hud
            [progressHUD hide:YES];
        }
    } cancel:^{
        NSLog(@"GooglePlus authorization cancelled");
        
        [progressHUD hide:YES];
    } failure:^(NSError *error) {
        NSLog(@"GooglePlus authorization failed: %@", error);
        
        [progressHUD hide:YES completion:^{
            [AGAPPLICATION showErrorPopup:[AGLOCALIZATION localizedString:@"ERROR_LOGIN"] ];
        }];
    }];
}

- (NSString *)getGoogleUserAccessToken:(id)sender :(id)object {
    return [GPGoogleClient accessToken] ? [GPGoogleClient accessToken] : @"";
}

- (void)basicAuthLogin:(id)sender :(id)object :(NSString *)uri :(NSString *)loginControlId :(NSString *)passwordControlId :(NSString *)action :(NSString *)httpQueryParamsString {
    uri = [[sender fullPath:uri] uriString];
    
    AGHTTPQueryParams *httpQueryParams = [AGHTTPQueryParams paramsWithJSONString:httpQueryParamsString ];
    
    AGControlDesc<AGFormClientProtocol> *loginControlDesc = (AGControlDesc<AGFormClientProtocol> *)[AGAPPLICATION getControlDesc:loginControlId];
    AGControlDesc<AGFormClientProtocol> *passwordControlDesc = (AGControlDesc<AGFormClientProtocol> *)[AGAPPLICATION getControlDesc:passwordControlId];
    
    NSArray *forms = @[loginControlDesc, passwordControlDesc];
    
    NSMutableDictionary *controlValues = [self postParametersWithForms:forms];
    NSString *login = controlValues[loginControlDesc.form.formId.value];
    NSString *password = controlValues[passwordControlDesc.form.formId.value];
    
    // authorization
    NSString *authorization = [NSString stringWithFormat:@"Basic %@", [[NSString stringWithFormat:@"%@:%@", login, password] base64EncodedString] ];
    NSDictionary *httpHeaderParams = @{@"Authorization": authorization};
    
    // request
    AGActionManagerRequest *request = [[AGActionManagerRequest alloc] init];
    request.uri = uri;
    request.httpMethod = @"GET";
    request.httpQueryParams = [httpQueryParams execute:sender];
    request.httpHeaderParams = httpHeaderParams;
    request.action = @"basicAuthLogin";
    request.postAction = action;
    request.controlsToReset = forms;
    request.sender = sender;
    [self sendRequest:request];
    [request release];
}

- (NSString *)getBasicAuthBase64:(id)sender :(id)object {
    if (isNil(AGAPPLICATION.basicAuthSessionId) ) {
        return [NSString stringWithFormat:@"Basic %@", [@":" base64EncodedString] ];
    }
    return AGAPPLICATION.basicAuthSessionId;
}

- (void)basicAuthLogout:(id)sender :(id)object {
    [AGAPPLICATION logout];
}

- (void)salesforceLogin:(id)sender :(id)object :(NSString *)salesforceUri :(NSString *)salesforceHttpQueryParamsString :(NSString *)salesforceHeaderParamsString :(NSString *)action :(NSString *)alterapiUri :(NSString *)alterapiHttpQueryParamsString :(NSString *)alterapiHeaderParamsString {
    // salesforce uri
    salesforceUri = [[sender fullPath:salesforceUri] uriString];
    
    // salesforce http query params
    AGHTTPQueryParams *salesforceHttpQueryParams = [AGHTTPQueryParams paramsWithJSONString:salesforceHttpQueryParamsString ];
    NSString *URLQuery = [NSString URLQueryWithParameters:[salesforceHttpQueryParams execute:sender] ];
    salesforceUri = [salesforceUri stringByAppendingURLQuery:URLQuery];
    
    // unused header params
    //AGHTTPHeaderParams* salesforceHeaderParams = [AGHTTPHeaderParams paramsWithJSONString: salesforceHeaderParamsString ];
    
    // salesforce url
    NSURL *salesforceURL = [NSURL URLWithString:salesforceUri];
    
    // alterapi uri
    alterapiUri = [[sender fullPath:alterapiUri] uriString];
    
    // alterapi http query params
    AGHTTPQueryParams *alterapiHttpQueryParams = [AGHTTPQueryParams paramsWithJSONString:alterapiHttpQueryParamsString ];
    
    // alterapi header params
    AGHTTPHeaderParams *alterapiHeaderParams = [AGHTTPHeaderParams paramsWithJSONString:alterapiHeaderParamsString ];
    
    // progress hud
    __block MBProgressHUD *progressHUD = nil;
    
    // client
    SFSalesForceClient *client = [SFSalesForceClient clientWithURL:salesforceURL];
    [client getAccessToken:^(NSString *accessToken) {
        if (isNotEmpty(alterapiUri) ) {
            // progress hud
            progressHUD = [MBProgressHUD HUDForView:AGAPPLICATION.rootController.view];
            if (!progressHUD) {
                progressHUD = [MBProgressHUD showHUDAddedTo:AGAPPLICATION.rootController.view animated:YES];
                progressHUD.minShowTime = 0.25f;
            }
            
            // request
            AGActionManagerRequest *request = [[AGActionManagerRequest alloc] init];
            request.uri = alterapiUri;
            request.httpQueryParams = [alterapiHttpQueryParams execute:sender];
            request.httpHeaderParams = [alterapiHeaderParams execute:sender];
            request.httpBody = [NSData dataWithHTTPForm:@{@"access_token":accessToken} ];
            request.action = @"salesforceLogin";
            request.postAction = action;
            request.sender = sender;
            [self sendRequest:request];
            [request release];
        } else {
            // login
            [AGAPPLICATION loginWithAutosessionId];
            
            // post action
            [self executeString:action withSender:sender];
        }
    } cancel:^{
        NSLog(@"Salesforce authorization cancelled");
        
        [progressHUD hide:YES];
    } failure:^(NSError *error) {
        NSLog(@"Salesforce authorization failed: %@", error);
        
        if (progressHUD) {
            [progressHUD hide:YES completion:^{
                [AGAPPLICATION showErrorPopup:[AGLOCALIZATION localizedString:@"ERROR_LOGIN"] ];
            }];
        } else {
            [AGAPPLICATION showErrorPopup:[AGLOCALIZATION localizedString:@"ERROR_LOGIN"] ];
        }
    }];
}

- (NSString *)getSalesforceAccessToken:(id)sender :(id)object {
    return [SFSalesForceClient accessToken] ? [SFSalesForceClient accessToken] : @"";
}

@end
