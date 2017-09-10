#import <Foundation/Foundation.h>

@interface AGDSFeedItem : NSObject {
    NSMutableDictionary *values;
    NSString *alterApiContext;
    NSString *guid;
    NSInteger itemTemplateIndex;
}

@property(nonatomic, readonly) NSMutableDictionary *values;
@property(nonatomic, copy) NSString *alterApiContext;
@property(nonatomic, copy) NSString *guid;
@property(nonatomic, assign) NSInteger itemTemplateIndex;

@end
