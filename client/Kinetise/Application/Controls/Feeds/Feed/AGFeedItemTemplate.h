#import "AGControlDesc.h"
#import "AGFeedRequiredField.h"

@interface AGFeedItemTemplate : AGDesc {
    NSMutableArray *requiredFields;
    NSString *detailScreenId;
    AGControlDesc *controlDesc;
}

@property(nonatomic, readonly) NSMutableArray *requiredFields;
@property(nonatomic, copy) NSString *detailScreenId;
@property(nonatomic, retain) AGControlDesc *controlDesc;

@end
