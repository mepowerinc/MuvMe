#import "AGDesc.h"
#import "AGScreenDesc.h"
#import "AGControlDesc.h"
#import "AGOverlayDesc.h"

@interface AGApplicationDesc : AGDesc {
    NSString *name;
    NSString *xmlVersion;
    NSString *xmlCreatedVersion;
    NSString *apiVersion;
    AGVariable *startScreen;
    AGVariable *loginScreen;
    AGVariable *protectedLoginScreen;
    AGVariable *mainScreen;
    NSString *defaultUserAgent;
    NSMutableDictionary *screens;
    NSMutableDictionary *overlays;
    NSMutableDictionary *regularExpressions;
    NSMutableDictionary *localStorage;
    AGPermissions permissions;
    CGFloat minTextMultiplier;
    CGFloat maxTextMultiplier;
    AGColor validationColor;
}

@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *xmlVersion;
@property(nonatomic, copy) NSString *xmlCreatedVersion;
@property(nonatomic, copy) NSString *apiVersion;
@property(nonatomic, retain) AGVariable *startScreen;
@property(nonatomic, retain) AGVariable *loginScreen;
@property(nonatomic, retain) AGVariable *protectedLoginScreen;
@property(nonatomic, retain) AGVariable *mainScreen;
@property(nonatomic, copy) NSString *defaultUserAgent;
@property(nonatomic, readonly) NSMutableDictionary *screens;
@property(nonatomic, readonly) NSMutableDictionary *popups;
@property(nonatomic, readonly) NSMutableDictionary *overlays;
@property(nonatomic, readonly) NSMutableDictionary *regularExpressions;
@property(nonatomic, readonly) NSMutableDictionary *localStorage;
@property(nonatomic, assign) AGPermissions permissions;
@property(nonatomic, assign) CGFloat minTextMultiplier;
@property(nonatomic, assign) CGFloat maxTextMultiplier;
@property(nonatomic, assign) AGColor validationColor;

@end
