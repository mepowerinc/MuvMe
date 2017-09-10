#import "AGApplication+Authentication.h"
#import "AGGPSTracker.h"
#import "NSString+GUID.h"
#import "AGServicesManager.h"
#import "AGApplication+Navigation.h"

@interface AGApplication ()
@property(nonatomic, retain) AGHistoryData *protectedScreenData;
@property(nonatomic, retain) id currentContext;
@property(nonatomic, assign) BOOL isLoggedIn;
@end

@implementation AGApplication (Authentication)

- (void)clearSession {
    self.sessionId = nil;
    self.basicAuthSessionId = nil;
    [[AGServicesManager sharedInstance] clearCache];
}

- (void)loginWithAutosessionId {
    if (self.isLoggedIn) return;

    [self clearSession];
    self.isLoggedIn = YES;
    self.sessionId = [NSString stringWithGUID];
}

- (void)loginOrUpdateWithSessionId:(NSString *)sessionId_ {
    if (!self.isLoggedIn) {
        [self loginWithSessionId:sessionId_];
    } else {
        self.sessionId = sessionId_;
    }
}

- (void)loginWithSessionId:(NSString *)sessionId_ {
    [self clearSession];
    self.isLoggedIn = YES;
    self.sessionId = sessionId_;
}

- (void)loginWithBasicAuthSessionId:(NSString *)basicAuthSessionId_ {
    [self clearSession];
    self.isLoggedIn = YES;
    self.basicAuthSessionId = basicAuthSessionId_;
}

- (void)logout {
    [self clearSession];
    self.isLoggedIn = NO;

    if ([AGGPSTracker isAllocated]) {
        [[AGGPSTracker sharedInstance] stopTracking];
    }

    [self setLoginScreen];
}

- (void)logout:(NSString *)screenId {
    [self clearSession];
    self.isLoggedIn = NO;

    if ([AGGPSTracker isAllocated]) {
        [[AGGPSTracker sharedInstance] stopTracking];
    }

    [self setScreen:screenId];
}

@end
