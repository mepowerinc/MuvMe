#import <Foundation/Foundation.h>
#import "AGSntpClientHub.h"

@protocol FAMSntpClientDelegate;

@interface AGSntpClient : NSObject
@property(nonatomic, assign) NSTimeInterval timeout;
@property(nonatomic, assign) id<FAMSntpClientDelegate> delegate;
@property(nonatomic, readonly) AGSntpClientHub *hub;

- (void)requestTime:(NSString *)host;
- (BOOL)synchronized;
- (NSDate *)synchronizedTime;
- (BOOL)isSynchronizing;

@end

@protocol FAMSntpClientDelegate <NSObject>
@optional
- (void)sntpClient:(AGSntpClient *)client receivedNtpTime:(NSDate *)date;
- (void)sntpClient:(AGSntpClient *)client failedWithError:(NSError *)error;

@end