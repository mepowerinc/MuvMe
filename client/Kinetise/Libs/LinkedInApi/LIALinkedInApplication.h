#import <Foundation/Foundation.h>

@interface LIALinkedInApplication : NSObject

@property(nonatomic,copy) NSString* redirectUri;
@property(nonatomic,copy) NSString* clientId;
@property(nonatomic,copy) NSString* clientSecret;
@property(nonatomic,copy) NSString* state;
@property(nonatomic,retain) NSArray* grantedAccess;

+(instancetype) applicationWithRedirectUri:(NSString*)redirectUri clientId:(NSString*)clientId clientSecret:(NSString*)clientSecret state:(NSString*)state grantedAccess:(NSArray*)grantedAccess;
-(instancetype) initWithRedirectUri:(NSString*)redirectUri clientId:(NSString*)clientId clientSecret:(NSString*)clientSecret state:(NSString*)state grantedAccess:(NSArray*)grantedAccess;

-(NSString*) grantedAccessString;

@end