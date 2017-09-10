#import "LIALinkedInClient.h"
#import "LIALinkedInAuthorizationViewController.h"
#import <FXKeychain/FXKeychain.h>

#define LINKEDIN_TOKEN_KEY          @"linkedin_token"
#define LINKEDIN_EXPIRATION_KEY     @"linkedin_expiration"
#define LINKEDIN_CREATION_KEY       @"linkedin_token_created_at"

@interface LIALinkedInClient()
@property(nonatomic,retain) LIALinkedInApplication* application;
@property(nonatomic,assign) UIViewController* presentingViewController;
@end

@implementation LIALinkedInClient

#pragma mark - Initialization

-(void) dealloc{
    self.application = nil;
    [super dealloc];
}

+(LIALinkedInClient*) clientForApplication:(LIALinkedInApplication*)application_{
    return [[[self alloc] initWithApplication:application_] autorelease];
}

+(LIALinkedInClient*) clientForApplication:(LIALinkedInApplication*)application_ withPresentingViewController:presentingViewController_{
    return [[[self alloc] initWithApplication:application_ withPresentingViewController:presentingViewController_] autorelease];
}

-(instancetype) initWithApplication:(LIALinkedInApplication*)application_{
    return [self initWithApplication:application_ withPresentingViewController:nil];
}

-(instancetype) initWithApplication:(LIALinkedInApplication*)application_ withPresentingViewController:(UIViewController*)presentingViewController_{
    self = [super init];
    
    self.application = application_;
    self.presentingViewController = presentingViewController_;
    
    return self;
}

#pragma mark - Lifecycle

+(BOOL) hasValidToken{
    NSTimeInterval creationTS = [[[FXKeychain defaultKeychain] objectForKey:LINKEDIN_CREATION_KEY] doubleValue];
    NSTimeInterval expirationTS = [[[FXKeychain defaultKeychain] objectForKey:LINKEDIN_EXPIRATION_KEY] doubleValue];
    
    return !( [[NSDate date] timeIntervalSince1970] >= creationTS+expirationTS );
}

+(NSString*) accessToken{
    return [[FXKeychain defaultKeychain] objectForKey:LINKEDIN_TOKEN_KEY];
}

-(void) getAccessToken:(NSString *)authorizationCode success:(void (^)(NSDictionary*))success failure:(void (^)(NSError*))failure{
    NSString* escapedRedirectUri = [(NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self.application.redirectUri, NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8) autorelease];
    
    NSString* bodyData = [NSString stringWithFormat:@"code=%@&redirect_uri=%@&client_id=%@&client_secret=%@&grant_type=authorization_code",
                          authorizationCode,
                          escapedRedirectUri,
                          self.application.clientId,
                          self.application.clientSecret
                          ];

    NSURL* url = [NSURL URLWithString:@"https://www.linkedin.com/uas/oauth2/accessToken"];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: [bodyData dataUsingEncoding:NSUTF8StringEncoding] ];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error){
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        
        if( httpResponse.statusCode==200 ){
            NSDictionary* responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            NSString* accessToken = responseObject[@"access_token"];
            NSTimeInterval expiration = [responseObject[@"expires_in"] doubleValue];
            
            // store credentials
            [[FXKeychain defaultKeychain] setObject:accessToken forKey:LINKEDIN_TOKEN_KEY];
            [[FXKeychain defaultKeychain] setObject:@(expiration) forKey:LINKEDIN_EXPIRATION_KEY];
            [[FXKeychain defaultKeychain] setObject:@([[NSDate date] timeIntervalSince1970]) forKey:LINKEDIN_CREATION_KEY];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                success(responseObject);
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
        }
    }] resume];
    
    [request release];
}

-(void) getAuthorizationCode:(void (^)(NSString*))success cancel:(void (^)(void))cancel failure:(void (^)(NSError*))failure {
    LIALinkedInAuthorizationViewController* authorizationViewController = [[LIALinkedInAuthorizationViewController alloc] initWithApplication:self.application
                                                                           success:^(NSString *code) {
                                                                               [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                                                                               if (success) {
                                                                                   success(code);
                                                                               }
                                                                           }cancel:^{
                                                                               [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                                                                               if (cancel) {
                                                                                   cancel();
                                                                               }
                                                                           }failure:^(NSError *error) {
                                                                               [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                                                                               if (failure) {
                                                                                   failure(error);
                                                                               }
                                                                           }];
    
    // present authorization view controller
    if( self.presentingViewController==nil ){
        self.presentingViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    }
    
    UINavigationController* navigationViewController = [[UINavigationController alloc] initWithRootViewController:authorizationViewController];
    [authorizationViewController release];
    
    if( [[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad ){
        navigationViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self.presentingViewController presentViewController:navigationViewController animated:YES completion:nil];
    [navigationViewController release];
}

@end
