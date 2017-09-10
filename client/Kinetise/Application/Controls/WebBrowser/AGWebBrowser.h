#import "AGControl.h"
#import "AGActivityIndicatorView.h"
#import <WebKit/WebKit.h>

@interface AGWebBrowser : AGControl <UIWebViewDelegate, WKNavigationDelegate>{
    WKWebView *webView;
    AGActivityIndicatorView *indicator;
}

@end
