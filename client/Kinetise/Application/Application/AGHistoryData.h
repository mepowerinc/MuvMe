#import <Foundation/Foundation.h>

@interface AGHistoryData : NSObject {
    NSString *screenId;
    NSString *alterApiContext;
    NSString *guidContext;
    id context;
}

@property(nonatomic, copy) NSString *screenId;
@property(nonatomic, copy) NSString *alterApiContext;
@property(nonatomic, copy) NSString *guidContext;
@property(nonatomic, retain) id context;

@end
