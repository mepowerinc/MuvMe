#import "AGJSUtil.h"
#import "AGActionManager+Text.h"
#import "AGActionManager+Actions.h"

// Base64

@implementation AGJSBase64

- (NSString *)encode:(NSString *)string {
    return [AGACTIONMANAGER encode:nil :nil :@"base64" :string];
}

- (NSString *)decode:(NSString *)string {
    return [AGACTIONMANAGER decode:nil :nil :@"base64" :string];
}

@end

// Url

@implementation AGJSUrl

- (NSString *)encode:(NSString *)string {
    return [AGACTIONMANAGER encode:nil :nil :@"url" :string];
}

- (NSString *)decode:(NSString *)string {
    return [AGACTIONMANAGER decode:nil :nil :@"url" :string];
}

@end

// Html

@implementation AGJSHtml

- (NSString *)text:(NSString *)string {
    return [AGACTIONMANAGER regex:nil :nil :string :@"controltext"];
}

- (NSString *)image:(NSString *)string {
    return [AGACTIONMANAGER regex:nil :nil :string :@"controlimage"];
}

- (NSString *)url:(NSString *)string {
    return [AGACTIONMANAGER regex:nil :nil :string :@"url"];
}

- (NSString *)fbUrl:(NSString *)string {
    return [AGACTIONMANAGER regex:nil :nil :string :@"facebookurl"];
}

@end

// Utils

@interface AGJSUtil ()
@property(nonatomic, retain) AGJSBase64 *base64;
@property(nonatomic, retain) AGJSHtml *html;
@property(nonatomic, retain) AGJSUrl *url;
@end

@implementation AGJSUtil

- (void)dealloc {
    self.base64 = nil;
    self.html = nil;
    self.url = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];

    self.base64 = [[[AGJSBase64 alloc] init] autorelease];
    self.html = [[[AGJSHtml alloc] init] autorelease];
    self.url = [[[AGJSUrl alloc] init] autorelease];

    return self;
}

- (NSString *)guid {
    return [AGACTIONMANAGER generateGuid:nil :nil];
}

- (NSString *)md5:(NSString *)string {
    return [AGACTIONMANAGER encode:nil :nil :@"md5" :string];
}

- (NSString *)sha1:(NSString *)string {
    return [AGACTIONMANAGER encode:nil :nil :@"sha1" :string];
}

@end
