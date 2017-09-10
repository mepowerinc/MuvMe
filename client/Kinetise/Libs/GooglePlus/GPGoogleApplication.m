#import "GPGoogleApplication.h"

@implementation GPGoogleApplication

@synthesize redirectUri;
@synthesize clientId;
@synthesize state;
@synthesize permissions;

-(void) dealloc{
    self.redirectUri = nil;
    self.clientId = nil;
    self.state = nil;
    self.permissions = nil;
    [super dealloc];
}

+(instancetype) applicationWithRedirectUri:(NSString*)redirectUri_ clientId:(NSString*)clientId_ state:(NSString*)state_ permissions:(NSArray*)permissions_{
    return [[[self alloc] initWithRedirectUri:redirectUri_ clientId:clientId_ state:state_ permissions:permissions_] autorelease];
}

-(instancetype) initWithRedirectUri:(NSString*)redirectUri_ clientId:(NSString*)clientId_ state:(NSString*)state_ permissions:(NSArray*)permissions_{
    self = [super init];
    
    self.redirectUri = redirectUri_;
    self.clientId = clientId_;
    self.state = state_;
    self.permissions = permissions_;
    
    return self;
}

@end
