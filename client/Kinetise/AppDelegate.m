#import "AppDelegate.h"
#import "AGServicesManager.h"
#import "Settings.h"
#import "AGSplashController.h"
#import "UIDevice+Hardware.h"
#import "UIDevice+Jailbroken.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@implementation AppDelegate

@synthesize window;

#pragma mark - Initialization

- (void)dealloc {
    self.window = nil;
    [super dealloc];
}

#pragma mark - Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // jailbrake
    if ([[UIDevice currentDevice] isJailbroken]) {
        return NO;
    }
    
    // idle
    application.idleTimerDisabled = NO;
    
    // window
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    self.window = [[[UIWindow alloc] initWithFrame:screenBounds] autorelease];
    window.backgroundColor = [UIColor blackColor];
    
    // status bar
    application.statusBarStyle = UIStatusBarStyleLightContent;
    
    // splash
    AGSplashController *splash = [[AGSplashController alloc] initWithNibName:nil bundle:nil];
    window.rootViewController = splash;
    [splash release];
    
    // show window
    [window makeKeyAndVisible];
    
    // fb
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    // fb
    return [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // fb
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

#pragma mark - Orientation

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window_ {
    UIInterfaceOrientationMask orientations = UIInterfaceOrientationMaskAllButUpsideDown;
    
    if (window_.rootViewController) {
        orientations = [window_.rootViewController supportedInterfaceOrientations];
    }
    
    // !!!: Force interface orientation, presented controller
    if (window_.rootViewController.presentationController) {
        UIInterfaceOrientation orientation = [application statusBarOrientation];
        if (!(orientations&(1<<orientation)) ) {
            if (UIInterfaceOrientationIsPortrait(orientation) ) {
                [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeLeft) forKey:@"orientation"];
            } else {
                [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
            }
        }
    }
    
    return orientations;
}

#pragma mark - Push Notifications

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
#if !TARGET_IPHONE_SIMULATOR
    // registration info
    NSString *projectId = PUSHER_ID;
    NSString *deviceUuid = [[UIDevice currentDevice] deviceUuid];
    
    // registration token (remove spaces and < >)
    NSString *registrationToken = [[[[devToken description]
                                     stringByReplacingOccurrencesOfString:@"<"withString:@""]
                                    stringByReplacingOccurrencesOfString:@">" withString:@""]
                                   stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // request
    NSURL *url = [NSURL URLWithString:PUSHER_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.timeoutInterval = AG_TIME_OUT;
    
    // content-type
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    // http body
    NSDictionary *body = @{
                           @"projectid": projectId,
                           @"devicetoken": deviceUuid,
                           @"registrationtoken": registrationToken,
                           @"deviceos": @"iOS"
                           };
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
    
    // kinetise headers
    [[AGServicesManager sharedInstance].kinetiseHeaders enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop){
        [request addValue:obj forHTTPHeaderField:key];
    }];
    
    // session
    NSLog(@"Notification register URL: %@", url);
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSString *responseString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        NSLog(@"Notification response:%@, code: %zd", responseString, httpResponse.statusCode);
    }] resume];
#endif
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
#if !TARGET_IPHONE_SIMULATOR
    NSLog(@"Error in push notifications registration. Error: %@", error);
#endif
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
#if !TARGET_IPHONE_SIMULATOR
    NSLog(@"Remote notification: %@", [userInfo description]);
    NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
    
    NSString *alert = [apsInfo objectForKey:@"alert"];
    NSLog(@"Received push alert: %@", alert);
    
    NSString *sound = [apsInfo objectForKey:@"sound"];
    NSLog(@"Received push sound: %@", sound);
    
    NSString *badge = [apsInfo objectForKey:@"badge"];
    NSLog(@"Received push badge: %@", badge);
    application.applicationIconBadgeNumber = [[apsInfo objectForKey:@"badge"] integerValue];
#endif
}

@end
