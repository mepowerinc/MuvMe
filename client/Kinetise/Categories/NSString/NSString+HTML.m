#import "NSString+HTML.h"

@implementation NSCharacterSet (HTML)

+ (NSCharacterSet *)htmlAttributeNameCharacterSet {
    return [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
}

@end

@implementation NSString (HTML)

- (NSString *)stringByExtractingPlainTextFromHTML {
    NSMutableString *processedText = [NSMutableString string];
    NSString *scannedText = nil;
    NSScanner *scanner = [NSScanner scannerWithString:self];
    scanner.charactersToBeSkipped = nil;

    while (![scanner isAtEnd]) {
        scannedText = nil;
        if ([scanner scanUpToString:@"<" intoString:&scannedText]) {
            [processedText appendString:scannedText];
        }

        if ([scanner scanString:@"<" intoString:nil]) {
            if ([scanner scanString:@"!--" intoString:nil]) {
                [scanner scanUpToString:@"-->" intoString:nil];
                [scanner scanString:@"-->" intoString:nil];
            } else {
                scannedText = nil;
                [scanner scanUpToString:@">" intoString:&scannedText];

                if ([scannedText isEqualToString:@"br /"]) {
                    [processedText appendString:@"\n"];
                } else if ([scannedText isEqualToString:@"br"]) {
                    [processedText appendString:@"\n"];
                } else if ([scannedText isEqualToString:@"br/"]) {
                    [processedText appendString:@"\n"];
                } else if ([scannedText isEqualToString:@"p"]) {
                    [processedText appendString:@"\n"];
                } else if ([scannedText isEqualToString:@"/p"]) {
                    [processedText appendString:@"\n"];
                }

                [scanner scanString:@">" intoString:nil];
            }
        }
    }

    return [processedText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)stringByExtractingIMGFromHTML {
    NSString *imageURL = nil;
    NSString *scannedText = nil;
    NSCharacterSet *tagNameCharacterSet = [NSCharacterSet htmlAttributeNameCharacterSet];
    NSScanner *scanner = [NSScanner scannerWithString:self];

    if ([scanner scanString:@"http://" intoString:nil] ||
        [scanner scanString:@"https://" intoString:nil] ||
        [scanner scanString:@"assets://" intoString:nil] ||
        [scanner scanString:@"local://" intoString:nil] ||
        [scanner scanString:@"/" intoString:nil]
        ) {
        return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }

    while (![scanner isAtEnd]) {
        [scanner scanUpToString:@"<" intoString:nil];
        if ([scanner scanString:@"<" intoString:nil]) {
            if ([scanner scanString:@"!--" intoString:nil]) {
                [scanner scanUpToString:@"-->" intoString:nil];
                [scanner scanString:@"-->" intoString:nil];
            } else if ([scanner scanString:@"img" intoString:nil]) {
                BOOL isValidImage = YES;
                imageURL = nil;

                while (![scanner scanString:@">" intoString:nil] && ![scanner scanString:@"/" intoString:nil]) {
                    NSString *parameter = nil;
                    scannedText = nil;

                    if (![scanner scanCharactersFromSet:tagNameCharacterSet intoString:&parameter]) {
                        return @"";
                    }

                    if (![scanner scanString:@"=" intoString:nil]) {
                        continue;
                    }

                    NSString *openingCharacter = nil;

                    if (![scanner scanString:@"\"" intoString:&openingCharacter]) {
                        if (![scanner scanString:@"'" intoString:&openingCharacter]) {
                            continue;
                        }
                    }

                    [scanner scanUpToString:openingCharacter intoString:&scannedText];

                    if (![scanner scanString:openingCharacter intoString:nil]) {
                        return @"";
                    }

                    if ([parameter isEqualToString:@"src"]) {
                        imageURL = scannedText;
                    } else if ([parameter isEqualToString:@"width"] || [parameter isEqualToString:@"height"]) {
                        if ([scannedText isEqualToString:@"1"]) {
                            isValidImage = NO;
                            break;
                        }
                    }
                }

                if (isValidImage && imageURL) {
                    return [imageURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                }
            } else {
                [scanner scanUpToString:@">" intoString:nil];
                [scanner scanString:@">" intoString:nil];
            }
        }
    }

    return @"";
}

- (NSString *)stringByExtractingURLFromHTML {
    NSString *scannedText = nil;
    NSCharacterSet *tagNameCharacterSet = [NSCharacterSet htmlAttributeNameCharacterSet];
    NSScanner *scanner = [NSScanner scannerWithString:self];

    if ([scanner scanString:@"http://" intoString:nil] ||
        [scanner scanString:@"https://" intoString:nil] ||
        [scanner scanString:@"assets://" intoString:nil] ||
        [scanner scanString:@"local://" intoString:nil] ||
        [scanner scanString:@"/" intoString:nil]
        ) {
        return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }

    while (![scanner isAtEnd]) {
        [scanner scanUpToString:@"<" intoString:nil];
        if ([scanner scanString:@"<" intoString:nil]) {
            if ([scanner scanString:@"!--" intoString:nil]) {
                [scanner scanUpToString:@"-->" intoString:nil];
                [scanner scanString:@"-->" intoString:nil];
            } else if ([scanner scanString:@"a" intoString:nil]) {
                NSString *href = nil;

                while (![scanner scanString:@">" intoString:nil] && ![scanner scanString:@"/" intoString:nil]) {
                    NSString *parameter = nil;
                    scannedText = nil;

                    if (![scanner scanCharactersFromSet:tagNameCharacterSet intoString:&parameter]) {
                        return @"";
                    }

                    if (![scanner scanString:@"=" intoString:nil]) {
                        continue;
                    }

                    NSString *openingCharacter = nil;

                    if (![scanner scanString:@"\"" intoString:&openingCharacter]) {
                        if (![scanner scanString:@"'" intoString:&openingCharacter]) {
                            continue;
                        }
                    }

                    [scanner scanUpToString:openingCharacter intoString:&scannedText];

                    if (![scanner scanString:openingCharacter intoString:nil]) {
                        return @"";
                    }

                    if ([parameter isEqualToString:@"href"]) {
                        href = scannedText;
                    }
                }

                if (href) {
                    return [href stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                }
            } else {
                [scanner scanUpToString:@">" intoString:nil];
                [scanner scanString:@">" intoString:nil];
            }
        }
    }

    return @"";
}

- (NSString *)stringByExtractingFacebookURLFromHTML {
    NSString *scannedText = nil;
    NSScanner *scanner = [NSScanner scannerWithString:self];

    [scanner scanUpToString:@"url=" intoString:nil];
    if ([scanner scanString:@"url=" intoString:nil]) {
        [scanner scanUpToString:@"&" intoString:&scannedText];
        if (scannedText) {
            return [scannedText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }

    return @"";
}

@end
