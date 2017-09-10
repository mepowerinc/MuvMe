#import <JavaScriptCore/JavaScriptCore.h>

// Base64

@protocol AGJSBase64Export <JSExport>
- (NSString *)encode:(NSString *)string;
- (NSString *)decode:(NSString *)string;
@end

@interface AGJSBase64 : NSObject <AGJSBase64Export>
@end

// Url

@protocol AGJSUrlExport <JSExport>
- (NSString *)encode:(NSString *)string;
- (NSString *)decode:(NSString *)string;
@end

@interface AGJSUrl : NSObject <AGJSUrlExport>
@end

// Html

@protocol AGJSHtmlExport <JSExport>
- (NSString *)text:(NSString *)string;
- (NSString *)image:(NSString *)string;
- (NSString *)url:(NSString *)string;
- (NSString *)fbUrl:(NSString *)string;
@end

@interface AGJSHtml : NSObject <AGJSHtmlExport>
@end

// Utils

@protocol AGJSUtilExport <JSExport>
- (NSString *)guid;
- (NSString *)md5:(NSString *)string;
- (NSString *)sha1:(NSString *)string;
@property(nonatomic, readonly) AGJSBase64 *base64;
@property(nonatomic, readonly) AGJSHtml *html;
@property(nonatomic, readonly) AGJSUrl *url;
@end

@interface AGJSUtil : NSObject <AGJSUtilExport>
@end
