#import <Foundation/Foundation.h>

@interface AGOfflineReader : NSObject

@property(nonatomic, copy) void (^completionBlock)(AGOfflineReader *offlineReader, NSError *error);
@property(nonatomic, copy) void (^progressBlock)(AGOfflineReader *offlineReader, float progress);

- (id)initWithJSON:(NSArray *)json;
- (void)start;
- (void)stop;

@end
