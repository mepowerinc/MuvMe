#import "AGButtonDesc.h"
#import "AGFormClientProtocol.h"

@interface AGCompoundButtonDesc : AGButtonDesc <AGFormClientProtocol>{
    AGForm *form;
    AGSize checkWidth;
    AGSize checkHeight;
    AGSize innerSpace;
    AGValignType checkValign;
}

@property(nonatomic, assign) AGSize checkWidth;
@property(nonatomic, assign) AGSize checkHeight;
@property(nonatomic, assign) AGSize innerSpace;
@property(nonatomic, assign) AGValignType checkValign;

@end
