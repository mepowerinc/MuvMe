#import "GPGoogleClient.h"
#import "GPGoogleAuthorizationViewController.h"
#import <FXKeychain/FXKeychain.h>

#define GOOGLEPLUS_TOKEN_KEY          @"googleplus_token"
#define GOOGLEPLUS_EXPIRATION_KEY     @"googleplus_expiration"
#define GOOGLEPLUS_CREATION_KEY       @"googleplus_token_created_at"

@interface GPGoogleClient()
@property(nonatomic,retain) GPGoogleApplication* application;
@property(nonatomic,assign) UIViewController* presentingViewController;
@end

@implementation GPGoogleClient

#pragma mark - Initialization

-(void) dealloc{
    self.application = nil;
    [super dealloc];
}

+(GPGoogleClient*) clientWithApplication:(GPGoogleApplication*)application_{
    return [[[self alloc] initWithApplication:application_] autorelease];
}

+(GPGoogleClient*) clientWithApplication:(GPGoogleApplication*)application_ andPresentingViewController:(UIViewController*)presentingViewController_{
    return [[[self alloc] initWithApplication:application_ andPresentingViewController:presentingViewController_] autorelease];
}

-(instancetype) initWithApplication:(GPGoogleApplication*)application_{
    return [self initWithApplication:application_ andPresentingViewController:nil];
}

-(instancetype) initWithApplication:(GPGoogleApplication*)application_ andPresentingViewController:(UIViewController*)presentingViewController_{
    self = [super init];
    
    self.application = application_;
    self.presentingViewController = presentingViewController_;
    
    return self;
}

#pragma mark - Lifecycle

+(BOOL) hasValidToken{
    NSTimeInterval creationTS = [[[FXKeychain defaultKeychain] objectForKey:GOOGLEPLUS_CREATION_KEY] doubleValue];
    NSTimeInterval expirationTS = [[[FXKeychain defaultKeychain] objectForKey:GOOGLEPLUS_EXPIRATION_KEY] doubleValue];
    
    return !( [[NSDate date] timeIntervalSince1970] >= creationTS+expirationTS );
}

+(NSString*) accessToken{
    return [[FXKeychain defaultKeychain] objectForKey:GOOGLEPLUS_TOKEN_KEY];
}

-(void) getAccessToken:(void (^)(NSString*))success cancel:(void (^)(void))cancel failure:(void (^)(NSError*))failure{
    // authorization view controller
    GPGoogleAuthorizationViewController* authorizationViewController = [[GPGoogleAuthorizationViewController alloc] initWithApplication:self.application
                                                                                                                                success:^(NSDictionary *response) {
                                                                                                                                    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                                                                                                                                    
                                                                                                                                    if (success) {
                                                                                                                                        NSString* accessToken = response[@"access_token"];
                                                                                                                                        NSTimeInterval expiration = [response[@"expires_in"] doubleValue];
                                                                                                                                        
                                                                                                                                        // store credentials
                                                                                                                                        [[FXKeychain defaultKeychain] setObject:accessToken forKey:GOOGLEPLUS_TOKEN_KEY];
                                                                                                                                        [[FXKeychain defaultKeychain] setObject:@(expiration) forKey:GOOGLEPLUS_EXPIRATION_KEY];
                                                                                                                                        [[FXKeychain defaultKeychain] setObject:@([[NSDate date] timeIntervalSince1970]) forKey:GOOGLEPLUS_CREATION_KEY];
                                                                                                                                        
                                                                                                                                        success(accessToken);
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
