#import "AGActionManagerRequest.h"

@implementation AGActionManagerRequest

@synthesize uri;
@synthesize httpMethod;
@synthesize httpQueryParams;
@synthesize httpHeaderParams;
@synthesize httpBody;
@synthesize responseTransform;
@synthesize contentType;
@synthesize action;
@synthesize postAction;
@synthesize postScreen;
@synthesize controlsToReset;
@synthesize sender;

- (void)dealloc {
    self.uri = nil;
    self.httpMethod = nil;
    self.httpQueryParams = nil;
    self.httpHeaderParams = nil;
    self.httpBody = nil;
    self.responseTransform = nil;
    self.contentType = nil;
    self.action = nil;
    self.postAction = nil;
    self.postScreen = nil;
    self.controlsToReset = nil;
    self.sender = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];

    self.httpMethod = @"POST";

    return self;
}

@end
