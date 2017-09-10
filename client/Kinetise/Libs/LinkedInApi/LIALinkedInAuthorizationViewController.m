#import "LIALinkedInAuthorizationViewController.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

NSString *kLinkedInErrorDomain = @"LIALinkedInERROR";
NSString *kLinkedInDeniedByUser = @"the+user+denied+your+request";

@interface LIALinkedInAuthorizationViewController () <UIWebViewDelegate>{
    UIWebView *webView;
    BOOL shouldHandleURL;
}
@property(nonatomic, retain) LIALinkedInApplication *application;
@property(nonatomic, copy) LIAAuthorizationCodeFailureCallback failureCallback;
@property(nonatomic, copy) LIAAuthorizationCodeSuccessCallback successCallback;
@property(nonatomic, copy) LIAAuthorizationCodeCancelCallback cancelCallback;
@end

@implementation LIALinkedInAuthorizationViewController

#pragma mark - Initialization

- (void)dealloc {
    self.application = nil;
    self.successCallback = nil;
    self.cancelCallback = nil;
    self.failureCallback = nil;
    [super dealloc];
}

- (id)initWithApplication:(LIALinkedInApplication *)application success:(LIAAuthorizationCodeSuccessCallback)success cancel:(LIAAuthorizationCodeCancelCallback)cancel failure:(LIAAuthorizationCodeFailureCallback)failure {
    self = [super init];
    
    self.application = application;
    self.successCallback = success;
    self.cancelCallback = cancel;
    self.failureCallback = failure;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // navigation button
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancelButton:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    [cancelButton release];
    
    // web view
    webView = [[UIWebView alloc] init];
    webView.delegate = self;
    webView.scalesPageToFit = YES;
    [self.view addSubview:webView];
    [webView release];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSString *escapedRedirectUri = [(NSString *) CFURLCreateStringByAddingPercentEscapes (NULL, (CFStringRef)self.application.redirectUri, NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8)autorelease];
    
    NSString *uri = [NSString stringWithFormat:@"https://www.linkedin.com/oauth/v2/authorization?response_type=code&client_id=%@&state=%@&redirect_uri=%@",
                     self.application.clientId,
                     self.application.state,
                     escapedRedirectUri];
    
    if (self.application.grantedAccessString) {
        uri = [uri stringByAppendingFormat:@"&scope=%@", self.application.grantedAccessString];
    }
    
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookieStorage cookiesForURL:[NSURL URLWithString:@"https://www.linkedin.com/oauth/v2"]];
    for (NSHTTPCookie *cookie in cookies) {
        [cookieStorage deleteCookie:cookie];
    }
    
    NSURL *url = [NSURL URLWithString:uri];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

#pragma mark - Lifecycle

- (void)onCancelButton:(id)sender {
    self.cancelCallback();
}

#pragma mark - Layout

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    webView.frame = self.view.bounds;
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView_ shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *url = [[request URL] absoluteString];
    
    // prevent loading URL if it is the redirectUri
    shouldHandleURL = [url hasPrefix:self.application.redirectUri];
    
    if (shouldHandleURL) {
        if ([url rangeOfString:@"error"].location != NSNotFound) {
            BOOL accessDenied = [url rangeOfString:kLinkedInDeniedByUser].location != NSNotFound;
            if (accessDenied) {
                self.cancelCallback();
            } else {
                NSError *error = [[[NSError alloc] initWithDomain:kLinkedInErrorDomain code:1 userInfo:nil] autorelease];
                self.failureCallback(error);
            }
        } else {
            NSString *receivedState = [self extractGetParameter:@"state" fromURLString:url];
            //assert that the state is as we expected it to be
            if ([self.application.state isEqualToString:receivedState]) {
                //extract the code from the url
                NSString *authorizationCode = [self extractGetParameter:@"code" fromURLString:url];
                self.successCallback(authorizationCode);
            } else {
                NSError *error = [[[NSError alloc] initWithDomain:kLinkedInErrorDomain code:2 userInfo:nil] autorelease];
                self.failureCallback(error);
            }
        }
    }
    return !shouldHandleURL;
}

- (NSString *)extractGetParameter:(NSString *)parameterName fromURLString:(NSString *)urlString {
    NSMutableDictionary *mdQueryStrings = [NSMutableDictionary dictionary];
    urlString = [[urlString componentsSeparatedByString:@"?"] objectAtIndex:1];
    
    for (NSString *qs in [urlString componentsSeparatedByString:@"&"]) {
        [mdQueryStrings setValue:[[[[qs componentsSeparatedByString:@"="] objectAtIndex:1] stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:[[qs componentsSeparatedByString:@"="] objectAtIndex:0]];
    }
    
    return [mdQueryStrings objectForKey:parameterName];
}

- (void)webView:(UIWebView *)webView_ didFailLoadWithError:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if (!shouldHandleURL) self.failureCallback(error);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView_ {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSString *js =
        @"var meta = document.createElement('meta'); "
        @"meta.setAttribute( 'name', 'viewport' ); "
        @"meta.setAttribute( 'content', 'width = 540px, initial-scale = 1.0, user-scalable = yes' ); "
        @"document.getElementsByTagName('head')[0].appendChild(meta)";
        
        [webView_ stringByEvaluatingJavaScriptFromString:js];
    }
}

@end
