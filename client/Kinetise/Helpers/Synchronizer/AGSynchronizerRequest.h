#import <Foundation/Foundation.h>

@interface AGSynchronizerRequest : NSObject <NSCoding>

@property(nonatomic, copy) NSString *uri;
@property(nonatomic, copy) NSString *httpMethod;
@property(nonatomic, retain) NSDictionary *httpQueryParams;
@property(nonatomic, retain) NSDictionary *httpHeaderParams;
@property(nonatomic, retain) NSData *httpBody;
@property(nonatomic, copy) NSString *httpBodyFilePath;
@property(nonatomic, copy) NSString *responseTransform;

@property(nonatomic, copy) NSString *key;
@property(nonatomic, copy) id value;
@property(nonatomic, retain) NSDate *sendTimestamp;

- (void)clear;

@end
