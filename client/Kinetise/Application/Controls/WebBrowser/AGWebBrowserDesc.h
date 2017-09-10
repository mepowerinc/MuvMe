#import "AGControlDesc.h"

@interface AGWebBrowserDesc : AGControlDesc {
    AGVariable *src;
    BOOL useExternalBrowser;
}

@property(nonatomic, retain) AGVariable *src;
@property(nonatomic, assign) BOOL useExternalBrowser;

@end
