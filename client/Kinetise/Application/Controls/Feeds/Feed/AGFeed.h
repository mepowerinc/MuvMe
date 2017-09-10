#import "AGUnits.h"
#import "AGDSFeed.h"
#import "AGFeedItemTemplate.h"
#import "AGControlDesc.h"
#import "AGHTTPQueryParams.h"
#import "AGHTTPHeaderParams.h"
#import "AGHTTPBodyParams.h"

@interface AGFeed : NSObject {
    NSMutableDictionary *namespaces;
    NSMutableDictionary *usingFields;
    NSMutableArray *itemTemplates;
    AGHTTPQueryParams *httpQueryParams;
    AGHTTPHeaderParams *httpHeaderParams;
    AGHTTPBodyParams *httpBodyParams;
    NSString *requestBodyTransform;
    NSString *httpMethod;
    AGCachePolicy cachePolicy;
    CGFloat cacheInterval;
    NSString *itemPath;
    AGVariable *src;
    NSInteger showItems;
    AGFeedFormat format;
    AGDSFeed *dataSource;
    AGControlDesc *itemTemplateNoData;
    AGControlDesc *itemTemplateLoading;
    AGControlDesc *itemTemplateError;
    AGControlDesc *itemTemplateLoadMore;
    NSInteger pageIndex;
    NSString *sortField;
    AGFeedSortOrder sortOrder;
    NSDate *dateTS;
    NSInteger itemIndex;
    NSString *csvSeparator;
    BOOL csvHeader;
    NSString *guidUsingField;
    AGVariable *formId;

    AGFeedPaginationType paginationType;
    NSString *paginationHtthParam;
    NSString *paginationPath;
    BOOL hasSilentResponse;
}

@property(nonatomic, readonly) NSMutableDictionary *namespaces;
@property(nonatomic, readonly) NSMutableDictionary *usingFields;
@property(nonatomic, readonly) NSMutableArray *itemTemplates;
@property(nonatomic, retain) AGHTTPQueryParams *httpQueryParams;
@property(nonatomic, retain) AGHTTPHeaderParams *httpHeaderParams;
@property(nonatomic, retain) AGHTTPBodyParams *httpBodyParams;
@property(nonatomic, copy) NSString *requestBodyTransform;
@property(nonatomic, copy) NSString *httpMethod;
@property(nonatomic, assign) AGCachePolicy cachePolicy;
@property(nonatomic, assign) CGFloat cacheInterval;
@property(nonatomic, copy) NSString *itemPath;
@property(nonatomic, retain) AGVariable *src;
@property(nonatomic, assign) NSInteger showItems;
@property(nonatomic, assign) AGFeedFormat format;
@property(nonatomic, retain) AGDSFeed *dataSource;
@property(nonatomic, retain) AGControlDesc *itemTemplateNoData;
@property(nonatomic, retain) AGControlDesc *itemTemplateLoading;
@property(nonatomic, retain) AGControlDesc *itemTemplateError;
@property(nonatomic, retain) AGControlDesc *itemTemplateLoadMore;
@property(nonatomic, assign) NSInteger pageIndex;
@property(nonatomic, copy) NSString *sortField;
@property(nonatomic, assign) AGFeedSortOrder sortOrder;
@property(nonatomic, retain) NSDate *dateTS;
@property(nonatomic, assign) NSInteger itemIndex;
@property(nonatomic, copy) NSString *csvSeparator;
@property(nonatomic, assign) BOOL csvHeader;
@property(nonatomic, copy) NSString *guidUsingField;
@property(nonatomic, retain) AGVariable *formId;
@property(nonatomic, copy) NSString *fullPath;
@property(nonatomic, assign) AGFeedPaginationType paginationType;
@property(nonatomic, copy) NSString *paginationHtthParam;
@property(nonatomic, copy) NSString *paginationPath;
@property(nonatomic, assign) BOOL hasSilentResponse;

- (void)executeVariables:(id)sender;
- (NSString *)fullPath:(NSString *)relativePath;

@end
