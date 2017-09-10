#import "AGWebBrowserDesc.h"
#import "AGActionManager.h"

@implementation AGWebBrowserDesc

@synthesize src;
@synthesize useExternalBrowser;

#pragma mark - Initialization

- (void)dealloc {
    self.src = nil;
    [super dealloc];
}

#pragma mark - Variables

- (void)executeVariables {
    [super executeVariables];
    [AGACTIONMANAGER executeVariable:src withSender:self];
}

#pragma mark - Copying

- (id)copyWithZone:(NSZone *)zone {
    AGWebBrowserDesc *obj = [super copyWithZone:zone];

    obj.src = [[src copy] autorelease];
    obj.useExternalBrowser = useExternalBrowser;

    return obj;
}

@end
