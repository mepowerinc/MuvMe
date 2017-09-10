#import "AGTextDesc.h"
#import "AGHTTPQueryParams.h"
#import "AGHTTPHeaderParams.h"

@interface AGImageDesc : AGTextDesc {
    AGVariable *src;
    AGHTTPQueryParams *httpQueryParams;
    AGHTTPHeaderParams *httpHeaderParams;
    AGSizeModeType sizeMode;
    BOOL showLoading;
}

@property(nonatomic, retain) AGVariable *src;
@property(nonatomic, retain) AGHTTPQueryParams *httpQueryParams;
@property(nonatomic, retain) AGHTTPHeaderParams *httpHeaderParams;
@property(nonatomic, assign) AGSizeModeType sizeMode;
@property(nonatomic, assign) BOOL showLoading;

@end
