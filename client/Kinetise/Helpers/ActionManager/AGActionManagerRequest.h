#import <Foundation/Foundation.h>

@interface AGActionManagerRequest : NSObject

@property(nonatomic, copy) NSString *uri;
@property(nonatomic, copy) NSString *httpMethod;
@property(nonatomic, retain) NSDictionary *httpQueryParams;
@property(nonatomic, retain) NSDictionary *httpHeaderParams;
@property(nonatomic, retain) NSData *httpBody;
@property(nonatomic, copy) NSString *responseTransform;
@property(nonatomic, copy) NSString *contentType;

@property(nonatomic, copy) NSString *action;
@property(nonatomic, copy) NSString *postAction;
@property(nonatomic, copy) NSString *postScreen;
@property(nonatomic, retain) NSArray *controlsToReset;
@property(nonatomic, retain) id sender;

@end
