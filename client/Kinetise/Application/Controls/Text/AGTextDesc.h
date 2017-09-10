#import "AGControlDesc.h"
#import "AGTextStyle.h"
#import "AGString.h"

@interface AGTextDesc : AGControlDesc {
    AGTextStyle *textStyle;
    AGVariable *text;
    NSInteger maxCharacters;
    NSInteger maxLines;
    AGString *string;
}

@property(nonatomic, retain) AGTextStyle *textStyle;
@property(nonatomic, retain) AGVariable *text;
@property(nonatomic, assign) NSInteger maxCharacters;
@property(nonatomic, assign) NSInteger maxLines;
@property(nonatomic, retain) AGString *string;

@end
