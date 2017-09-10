#import "LIALinkedInApplication.h"

@implementation LIALinkedInApplication

@synthesize redirectUri;
@synthesize clientId;
@synthesize clientSecret;
@synthesize state;
@synthesize grantedAccess;

-(void) dealloc{
    self.redirectUri = nil;
    self.clientId = nil;
    self.clientSecret = nil;
    self.state = nil;
    self.grantedAccess = nil;
    [super dealloc];
}

+(instancetype) applicationWithRedirectUri:(NSString*)redirectUri_ clientId:(NSString*)clientId_ clientSecret:(NSString*)clientSecret_ state:(NSString*)state_ grantedAccess:(NSArray*)grantedAccess_{
    return [[[self alloc] initWithRedirectUri:redirectUri_ clientId:clientId_ clientSecret:clientSecret_ state:state_ grantedAccess:grantedAccess_] autorelease];
}

-(instancetype) initWithRedirectUri:(NSString*)redirectUri_ clientId:(NSString*)clientId_ clientSecret:(NSString*)clientSecret_ state:(NSString*)state_ grantedAccess:(NSArray*)grantedAccess_{
    self = [super init];
    
    self.redirectUri = redirectUri_;
    self.clientId = clientId_;
    self.clientSecret = clientSecret_;
    self.state = state_;
    self.grantedAccess = grantedAccess_;

    return self;
}

-(NSString*) grantedAccessString {
    return [self.grantedAccess componentsJoinedByString:@"%20"];
}

@end