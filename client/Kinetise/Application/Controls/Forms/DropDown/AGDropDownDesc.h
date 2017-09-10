#import "AGPickerDesc.h"
#import "AGDSDropDownItem.h"

@interface AGDropDownDesc : AGPickerDesc {
    AGVariable *listSrc;
    AGVariable *watermark;
    NSString *itemPath;
    NSString *textPath;
    NSString *valuePath;
}

@property(nonatomic, retain) AGVariable *listSrc;
@property(nonatomic, retain) AGVariable *watermark;
@property(nonatomic, readonly) NSArray *items;
@property(nonatomic, copy) NSString *itemPath;
@property(nonatomic, copy) NSString *textPath;
@property(nonatomic, copy) NSString *valuePath;

@end
