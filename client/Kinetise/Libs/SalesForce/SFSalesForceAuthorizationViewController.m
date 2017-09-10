#import "SFSalesForceAuthorizationViewController.h"

@interface SFSalesForceAuthorizationViewController() <UIWebViewDelegate>{
    UIWebView* webView;
    BOOL shouldHandleURL;
}
@property(nonatomic,retain) NSURL* url;
@property(nonatomic,copy) NSString* redirectUri;
@property(nonatomic,copy) SFAuthorizationCodeSuccessCallback successCallback;
@property(nonatomic,copy) SFAuthorizationCodeCancelCallback cancelCallback;
@property(nonatomic,copy) SFAuthorizationCodeFailureCallback failureCallback;
@end

@implementation SFSalesForceAuthorizationViewController

#pragma mark - Initialization

-(void) dealloc{
    self.url = nil;
    self.redirectUri = nil;
    self.successCallback = nil;
    self.cancelCallback = nil;
    self.failureCallback = nil;
    [super dealloc];
}

-(instancetype) initWithURL:(NSURL*)url success:(SFAuthorizationCodeSuccessCallback)success cancel:(SFAuthorizationCodeCancelCallback)cancel failure:(SFAuthorizationCodeFailureCallback)failure{
    self = [super init];
    
    self.url = url;
    self.successCallback = success;
    self.cancelCallback = cancel;
    self.failureCallback = failure;
    
    // redirect uri
    NSURLComponents* urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    for(NSURLQueryItem* queryItem in urlComponents.queryItems){
        if( [queryItem.name isEqualToString:@"redirect_uri"] ){
            self.redirectUri = [(NSString*)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,(CFStringRef)queryItem.value,CFSTR(""),kCFStringEncodingUTF8) autorelease];
            break;
        }
    }
    
    return self;
}

-(void) viewDidLoad{
    [super viewDidLoad];
    
    // navigation button
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancelButton:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    [cancelButton release];
    
    // web view
    webView = [[UIWebView alloc] init];
    webView.delegate = self;
    webView.scalesPageToFit = YES;
    [self.view addSubview:webView];
    [webView release];
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    NSURLRequest* request = [NSURLRequest requestWithURL:self.url];
    [webView loadRequest:request];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

#pragma mark - Lifecycle

-(void) onCancelButton:(id)sender {
    self.cancelCallback();
}

#pragma mark - Layout

-(void) viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    webView.frame = self.view.bounds;
}

#pragma mark - UIWebViewDelegate

-(BOOL) webView:(UIWebView*)webView_ shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType{
    // uri
    NSString* uri = [request.URL absoluteString];
    
    // prevent loading URL if it is the redirect uri
    shouldHandleURL = [uri hasPrefix:self.redirectUri];
    
    // get access token
    if( shouldHandleURL ){
        NSString* accessToken = nil;
        NSRange range1 = [uri rangeOfString:@"#access_token="];
        NSRange range2 = [uri rangeOfString:@"&" options:NSCaseInsensitiveSearch range: NSMakeRange(range1.location+range1.length, uri.length-(range1.location+range1.length)) ];
        if( range1.location!=NSNotFound && range2.location!=NSNotFound ){
            accessToken = [uri substringWithRange: NSMakeRange(range1.location+range1.length, range2.location-range1.location-range1.length) ];
            accessToken = [(NSString*)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,(CFStringRef)accessToken,CFSTR(""),kCFStringEncodingUTF8) autorelease];
        }
        if( accessToken ){
            self.successCallback(accessToken);
        }else{
            NSDictionary* userInfo = @{ NSLocalizedDescriptionKey : @"Could not get access token" };
            NSError* error = [[[NSError alloc] initWithDomain:@"SFSalesforceErrorDomain" code:2 userInfo:userInfo] autorelease];
            self.failureCallback(error);
        }
    }
    
    return !shouldHandleURL;
}

-(void) webView:(UIWebView*)webView_ didFailLoadWithError:(NSError*)error{
    if( error.code != NSURLErrorCancelled ){
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if( !shouldHandleURL ) self.failureCallback(error);
    }else{
        self.cancelCallback();
    }
}

-(void) webViewDidFinishLoad:(UIWebView*) webView_{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

@end
