#import <Foundation/Foundation.h>

@interface AGDateFormatter : NSObject

@property(nonatomic, copy) NSString *dateFormat;

- (NSDateFormatter *)dateFormatter;
- (NSString *)widestDateStringWithFont:(NSString *)fontName andSize:(CGFloat)size andBold:(BOOL)bold andItalic:(BOOL)italic;

@end
