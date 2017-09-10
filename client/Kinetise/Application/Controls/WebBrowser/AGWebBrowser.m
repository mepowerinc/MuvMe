#import "AGWebBrowser.h"
#import "AGWebBrowserDesc.h"
#import "AGLayoutManager.h"
#import "NSString+UriEncoding.h"
#import "AGFileManager.h"

@implementation AGWebBrowser

- (id)initWithDesc:(AGWebBrowserDesc *)descriptor_ {
    self = [super initWithDesc:descriptor_];

    // web view
    webView = (WKWebView *)contentView;
    webView.navigationDelegate = self;

    // indicator
    indicator = [[AGActivityIndicatorView alloc] initWithImage:AG_LOADING_IMAGE];
    [contentView addSubview:indicator];
    [indicator release];
    indicator.hidden = YES;

    return self;
}

- (UIView *)newContent {
    NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    WKUserScript *wkUserScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKUserContentController *wkController = [[WKUserContentController alloc] init];
    [wkController addUserScript:wkUserScript];
    [wkUserScript release];

    WKWebViewConfiguration *wkWebConfig = [[[WKWebViewConfiguration alloc] init] autorelease];
    wkWebConfig.userContentController = wkController;
    wkWebConfig.preferences.javaScriptCanOpenWindowsAutomatically = YES;
    wkWebConfig.preferences.javaScriptEnabled = YES;
    [wkController release];

    return [[[self contentClass] alloc] initWithFrame:CGRectZero configuration:wkWebConfig];
}

- (Class)contentClass {
    return [WKWebView class];
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat indicatorPrefferedSize = AG_LOADING_SIZE;
    CGFloat indicatorSize = MIN(indicatorPrefferedSize, MIN(contentView.bounds.size.width, contentView.bounds.size.height));

    indicator.frame = CGRectMake(0, 0, indicatorSize, indicatorSize);
    indicator.center = CGPointMake(contentView.bounds.size.width*0.5, contentView.bounds.size.height*0.5);
}

#pragma mark - Assets

- (void)setupAssets {
    [super setupAssets];
}

- (void)loadAssets {
    AGWebBrowserDesc *desc = (AGWebBrowserDesc *)descriptor;

    // url
    NSURL *url = nil;
    NSString *uri = [desc.src.value uriString];
    if ([uri hasPrefix:@"assets://"]) {
        NSString *fileName = [uri substringFromIndex:[@"assets://" length] ];
        NSString *filePath = [AGFILEMANAGER pathForResource:fileName];
        url = [NSURL fileURLWithPath:filePath];
    } else if ([uri hasPrefix:@"http"]) {
        url = [NSURL URLWithString:uri];
    }

    // request
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [webView loadRequest:request];
    [request release];

    // indicator
    indicator.hidden = NO;

    [super loadAssets];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView_ didStartProvisionalNavigation:(WKNavigation *)navigation {
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    indicator.hidden = YES;
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    indicator.hidden = YES;
}

- (void)webView:(WKWebView *)webView_ decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    AGWebBrowserDesc *desc = (AGWebBrowserDesc *)descriptor;

    // external browser
    if (desc.useExternalBrowser && navigationAction.navigationType == WKNavigationTypeLinkActivated) {
        NSURLRequest *request = navigationAction.request;
        [[UIApplication sharedApplication] openURL:request.URL];

        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

@end
