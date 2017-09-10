#import "AGPaymentViewController.h"
#import "NSString+URL.h"

NSString *const successUri = @"https://www.kinetise.com/app/payment/success";
NSString *const failureUri = @"https://www.kinetise.com/app/payment/failure";

@interface AGPaymentViewController ()<UIWebViewDelegate>{
    NSURL *url;
    UIWebView *webView;
    BOOL shouldHandleURL;
}
@property(nonatomic, retain) NSURL *url;
@property(nonatomic, copy) AGPaymentSuccessCallback successCallback;
@property(nonatomic, copy) AGPaymentCancelCallback cancelCallback;
@property(nonatomic, copy) AGPaymentFailureCallback failureCallback;
@end

@implementation AGPaymentViewController

@synthesize url;
@synthesize successCallback;
@synthesize cancelCallback;
@synthesize failureCallback;

- (void)dealloc {
    self.url = nil;
    self.successCallback = nil;
    self.cancelCallback = nil;
    self.failureCallback = nil;
    [super dealloc];
}

- (instancetype)initWithURL:(NSURL *)url_ success:(AGPaymentSuccessCallback)success cancel:(AGPaymentCancelCallback)cancel failure:(AGPaymentFailureCallback)failure {
    self = [super init];

    self.successCallback = success;
    self.cancelCallback = cancel;
    self.failureCallback = failure;

    NSString *uri = [url_ absoluteString];
    uri = [uri stringByAppendingURLQuery:[NSString stringWithFormat:@"redirect_success=%@", [successUri URLEncodedString] ] ];
    uri = [uri stringByAppendingURLQuery:[NSString stringWithFormat:@"redirect_failed=%@", [failureUri URLEncodedString] ] ];
    self.url = [NSURL URLWithString:uri];

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancelButton:)];
    self.navigationItem.leftBarButtonItem = cancelButton;

    webView = [[UIWebView alloc] init];
    webView.delegate = self;
    webView.scalesPageToFit = YES;
    [self.view addSubview:webView];
    [webView release];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    webView.frame = self.view.bounds;
}

- (void)onCancelButton:(id)sender {
    self.cancelCallback();
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView_ shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *uri = [[request URL] absoluteString];

    shouldHandleURL = NO;

    if ([uri isEqualToString:successUri]) {
        shouldHandleURL = YES;
        self.successCallback();
    } else if ([uri isEqualToString:failureUri]) {
        shouldHandleURL = YES;
        self.failureCallback();
    }

    return !shouldHandleURL;
}

- (void)webView:(UIWebView *)webView_ didFailLoadWithError:(NSError *)error {
    if (error.code == NSURLErrorCancelled) {
        return;
    }
    if (!shouldHandleURL) self.failureCallback();
}

@end
