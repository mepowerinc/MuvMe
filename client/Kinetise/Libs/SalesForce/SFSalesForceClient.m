#import "SFSalesForceClient.h"
#import "SFSalesForceAuthorizationViewController.h"
#import <FXKeychain/FXKeychain.h>

#define SALESFORCE_TOKEN_KEY          @"salesforce_token"

@interface SFSalesForceClient()
@property(nonatomic,retain) NSURL* url;
@property(nonatomic,assign) UIViewController* presentingViewController;
@end

@implementation SFSalesForceClient

#pragma mark - Initialization

-(void) dealloc{
    self.url = nil;
    [super dealloc];
}

+(SFSalesForceClient*) clientWithURL:(NSURL*)url_{
    return [[[self alloc] initWithURL:url_] autorelease];
}

+(SFSalesForceClient*) clientWithURL:(NSURL*)url_ andPresentingViewController:(UIViewController*)presentingViewController_{
    return [[[self alloc] initWithURL:url_ andPresentingViewController:presentingViewController_] autorelease];
}

-(instancetype) initWithURL:(NSURL*)url_{
    return [self initWithURL:url_ andPresentingViewController:nil];
}

-(instancetype) initWithURL:(NSURL*)url_ andPresentingViewController:(UIViewController*)presentingViewController_{
    self = [super init];
    
    self.url = url_;
    self.presentingViewController = presentingViewController_;
    
    return self;
}

#pragma mark - Lifecycle

+(NSString*) accessToken{
    return [[FXKeychain defaultKeychain] objectForKey:SALESFORCE_TOKEN_KEY];
}

-(void) getAccessToken:(SFAccessTokenSuccessCallback)success cancel:(void (^)(void))cancel failure:(SFAccessTokenFailureCallback)failure{
    // authorization view controller
    SFSalesForceAuthorizationViewController* authorizationViewController = [[SFSalesForceAuthorizationViewController alloc] initWithURL:self.url
                                                                                                                                success:^(NSString* accessToken) {
                                                                                                                                    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                                                                                                                                    
                                                                                                                                    if (success) {
                                                                                                                                        // store credentials
                                                                                                                                        [[FXKeychain defaultKeychain] setObject:accessToken forKey:SALESFORCE_TOKEN_KEY];
                                                                                                                                        
                                                                                                                                        success(accessToken);
                                                                                                                                    }
                                                                                                                                }cancel:^{
                                                                                                                                    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                                                                                                                                    
                                                                                                                                    if (cancel) {
                                                                                                                                        cancel();
                                                                                                                                    }
                                                                                                                                }failure:^(NSError* error) {
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
