#import "GPGoogleAuthorizationViewController.h"

@interface GPGoogleAuthorizationViewController () <UIWebViewDelegate>{
    UIWebView *webView;
    BOOL shouldHandleURL;
}
@property(nonatomic, retain) GPGoogleApplication *application;
@property(nonatomic, copy) void (^successCallback)(NSDictionary *);
@property(nonatomic, copy) void (^cancelCallback)(void);
@property(nonatomic, copy) void (^failureCallback)(NSError *);
@end

@implementation GPGoogleAuthorizationViewController

#pragma mark - Initialization

- (void)dealloc {
    self.application = nil;
    self.successCallback = nil;
    self.cancelCallback = nil;
    self.failureCallback = nil;
    [super dealloc];
}

- (instancetype)initWithApplication:(GPGoogleApplication *)application success:(void (^)(NSDictionary *))success cancel:(void (^)(void))cancel failure:(void (^)(NSError *))failure {
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
    
    NSString *uri = [NSString stringWithFormat:@"https://accounts.google.com/o/oauth2/v2/auth?response_type=token&client_id=%@&redirect_uri=%@&scope=%@&state=%@&suppress_webview_warning=true",
                     self.application.clientId,
                     escapedRedirectUri,
                     [self.application.permissions componentsJoinedByString:@"%20"],
                     self.application.state
                     ];
    
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookieStorage cookiesForURL:[NSURL URLWithString:@"https://accounts.google.com/o/oauth2/v2"]];
    for (NSHTTPCookie *cookie in cookies) {
        [cookieStorage deleteCookie:cookie];
    }
    
    NSURL *url = [NSURL URLWithString:uri];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
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
    NSString *uri = [[request URL] absoluteString];
    
    // prevent loading URL if it is the redirectUri
    shouldHandleURL = [uri hasPrefix:self.application.redirectUri];
    
    if (shouldHandleURL) {
        NSMutableDictionary *response = [NSMutableDictionary dictionary];
        NSString *accessToken = nil;
        NSArray *params = [[[request URL] fragment] componentsSeparatedByString:@"&"];
        
        for (NSString *param in params) {
            NSArray *keyValue = [param componentsSeparatedByString:@"="];
            if (keyValue.count > 1) {
                NSString *key = keyValue[0];
                NSString *value = keyValue[1];
                
                response[key] = value;
                if ([key isEqualToString:@"access_token"]) {
                    accessToken = value;
                }
            }
        }
        
        if (accessToken) {
            self.successCallback(response);
        } else {
            NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : @"Could not get authorization code" };
            NSError *error = [[[NSError alloc] initWithDomain:@"GPGoogleErrorDomain" code:2 userInfo:userInfo] autorelease];
            self.failureCallback(error);
        }
    }
    
    return !shouldHandleURL;
}

- (void)webView:(UIWebView *)webView_ didFailLoadWithError:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if (!shouldHandleURL) self.failureCallback(error);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView_ {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

@end
