#import "AGImageDesc.h"

@interface AGButtonDesc : AGImageDesc {
    AGColor activeBorderColor;
    AGVariable *activeSrc;
    AGHTTPQueryParams *activeHttpQueryParams;
    AGHTTPHeaderParams *activeHttpHeaderParams;
    AGVariable *invalidSrc;
    AGHTTPQueryParams *invalidHttpQueryParams;
    AGHTTPHeaderParams *invalidHttpHeaderParams;
}

@property(nonatomic, assign) AGColor activeBorderColor;
@property(nonatomic, retain) AGVariable *activeSrc;
@property(nonatomic, retain) AGHTTPQueryParams *activeHttpQueryParams;
@property(nonatomic, retain) AGHTTPHeaderParams *activeHttpHeaderParams;
@property(nonatomic, retain) AGVariable *invalidSrc;
@property(nonatomic, retain) AGHTTPQueryParams *invalidHttpQueryParams;
@property(nonatomic, retain) AGHTTPHeaderParams *invalidHttpHeaderParams;

@end
