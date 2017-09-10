#import <Foundation/Foundation.h>

@interface GPGoogleApplication : NSObject

@property(nonatomic,copy) NSString* redirectUri;
@property(nonatomic,copy) NSString* clientId;
@property(nonatomic,copy) NSString* state;
@property(nonatomic,retain) NSArray* permissions;

+(instancetype) applicationWithRedirectUri:(NSString*)redirectUri clientId:(NSString*)clientId state:(NSString*)state permissions:(NSArray*)permissions;
-(instancetype) initWithRedirectUri:(NSString*)redirectUri clientId:(NSString*)clientId state:(NSString*)state permissions:(NSArray*)permissions;

@end
