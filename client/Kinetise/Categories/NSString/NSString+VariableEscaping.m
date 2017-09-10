#import "NSString+VariableEscaping.h"

@implementation NSString (VariableEscaping)

- (NSString *)variableEscape {
    NSMutableString *s = [NSMutableString stringWithString:self];
    [s replaceOccurrencesOfString:@"[" withString:@"\\[" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"]" withString:@"\\]" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"'" withString:@"\\'" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\\" withString:@"\\\\" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@";" withString:@"\\;" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    return s;
}

- (NSString *)variableUnescape {
    NSMutableString *s = [NSMutableString stringWithString:self];
    [s replaceOccurrencesOfString:@"\\[" withString:@"[" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\\]" withString:@"]" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\\'" withString:@"'" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\\\\" withString:@"\\" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\\;" withString:@";" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    return s;
}

@end
