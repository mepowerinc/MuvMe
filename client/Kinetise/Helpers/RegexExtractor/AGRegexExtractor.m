#import "AGRegexExtractor.h"
#import "AGRegexRule.h"
#import "AGApplication.h"
#import "AGRegexCache.h"
#import "NSString+HTML.h"
#import "NSObject+Nil.h"

@implementation AGRegexExtractor

+ (NSString *)processTagsWithString:(NSString *)text andRules:(NSArray *)rules {
    if (!rules || !rules.count) {
        return text;
    }
    if (!text) {
        return nil;
    }

    NSMutableString *mutableText = [NSMutableString stringWithString:text];

    for (AGRegexRule *rule in rules) {
        if (!rule.returnMatch) {
            NSRegularExpression *regex = [[AGRegexCache sharedInstance] regexForPattern:rule.tag options:NSRegularExpressionCaseInsensitive];
            [regex replaceMatchesInString:mutableText options:0 range:NSMakeRange(0, mutableText.length) withTemplate:rule.replaceWith];
        } else {
            NSRegularExpression *regex = [[AGRegexCache sharedInstance] regexForPattern:rule.tag options:NSRegularExpressionCaseInsensitive];

            NSRange firstMatchRange = [regex rangeOfFirstMatchInString:mutableText options:0 range:NSMakeRange(0, mutableText.length)];
            if (firstMatchRange.location != NSNotFound) {
                [regex replaceMatchesInString:mutableText options:0 range:firstMatchRange withTemplate:rule.replaceWith];
            } else {
                [mutableText setString:@""];
            }
        }
    }

    return [mutableText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSString *)processTagsWithString:(NSString *)text andRegexName:(NSString *)regexName {
    if ([text isKindOfClass:[NSString class]]) {
        if ([regexName isEqualToString:@"controlimage"]) {
            return [text stringByExtractingIMGFromHTML];
        } else if ([regexName isEqualToString:@"controltext"]) {
            return [text stringByExtractingPlainTextFromHTML];
        } else if ([regexName isEqualToString:@"url"]) {
            return [text stringByExtractingURLFromHTML];
        } else if ([regexName isEqualToString:@"facebookurl"]) {
            return [text stringByExtractingFacebookURLFromHTML];
        }

        NSArray *rules = AGAPPLICATION.descriptor.regularExpressions[regexName];

        return [AGRegexExtractor processTagsWithString:text andRules:rules];
    }

    return text;
}

@end
