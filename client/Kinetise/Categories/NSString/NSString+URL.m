//
//  Uri.m
//
//  Version 1.0.1
//
//  Created by Nick Lockwood on 11/01/2012.
//  Copyright (C) 2012 Charcoal Design
//
//  Distributed under the permissive zlib License
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/Uri
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import "NSString+URL.h"

NSString *const URLSchemeComponent = @"scheme";
NSString *const URLHostComponent = @"host";
NSString *const URLPortComponent = @"port";
NSString *const URLUserComponent = @"user";
NSString *const URLPasswordComponent = @"password";
NSString *const URLPathComponent = @"path";
NSString *const URLParameterStringComponent = @"parameterString";
NSString *const URLQueryComponent = @"query";
NSString *const URLFragmentComponent = @"fragment";

@implementation NSString (Uri)

#pragma mark URLEncoding

- (NSString *)URLEncodedString {
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)self,
                                                                           NULL,
                                                                           CFSTR("!*'();:@&=+$,/?%#[]\" "),
                                                                           kCFStringEncodingUTF8);
    [result autorelease];

    return result;
}

- (NSString *)URLDecodedString {
    NSString *result = (NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                           (CFStringRef)self,
                                                                                           CFSTR(""),
                                                                                           kCFStringEncodingUTF8);
    [result autorelease];

    return result;
}

- (NSString *)URLDecodedString:(BOOL)decodePlusAsSpace {
    NSString *string = [[self copy] autorelease];
    if (decodePlusAsSpace) {
        string = [string stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    }
    return [string URLDecodedString];
}

#pragma mark URL path extension

- (NSString *)stringByAppendingURLPathExtension:(NSString *)extension {
    NSString *lastPathComponent = [[self lastURLPathComponent] stringByAppendingPathExtension:extension];
    return [[self stringByDeletingLastURLPathComponent] stringByAppendingURLPathComponent:lastPathComponent];
}

- (NSString *)stringByDeletingURLPathExtension {
    NSString *lastPathComponent = [[self lastURLPathComponent] stringByDeletingPathExtension];
    return [[self stringByDeletingLastURLPathComponent] stringByAppendingURLPathComponent:lastPathComponent];
}

- (NSString *)URLPathExtension {
    return [[self lastURLPathComponent] pathExtension];
}

#pragma mark URL paths

- (NSString *)stringByAppendingURLPathComponent:(NSString *)str {
    NSString *url = self;

    //remove fragment
    NSString *fragment = [url URLFragment];
    url = [url stringByDeletingURLFragment];

    //remove query
    NSString *query = [url URLQuery];
    url = [url stringByDeletingURLQuery];

    //strip leading slash on path
    if ([str hasPrefix:@"/"]) {
        str = [str substringFromIndex:1];
    }

    //add trailing slash
    if ([url length] && ![url hasSuffix:@"/"]) {
        url = [url stringByAppendingString:@"/"];
    }

    //reassemble url
    url = [url stringByAppendingString:str];
    url = [url stringByAppendingURLQuery:query];
    url = [url stringByAppendingURLFragment:fragment];

    return url;
}

- (NSString *)stringByDeletingLastURLPathComponent {
    NSString *url = self;

    //remove fragment
    NSString *fragment = [url URLFragment];
    url = [url stringByDeletingURLFragment];

    //remove query
    NSString *query = [url URLQuery];
    url = [url stringByDeletingURLQuery];

    //trim path
    NSRange range = [url rangeOfString:@"/" options:NSBackwardsSearch];
    if (range.location != NSNotFound) url = [url substringToIndex:range.location + 1];

    //reassemble url
    url = [url stringByAppendingURLQuery:query];
    url = [url stringByAppendingURLFragment:fragment];

    return url;
}

- (NSString *)lastURLPathComponent {
    NSString *url = self;

    //remove fragment
    url = [url stringByDeletingURLFragment];

    //remove query
    url = [url stringByDeletingURLQuery];

    //get last path component
    NSRange range = [url rangeOfString:@"/" options:NSBackwardsSearch];
    if (range.location != NSNotFound) url = [url substringFromIndex:range.location + 1];

    return url;
}

#pragma mark Query strings

+ (NSString *)URLQueryWithParameters:(NSDictionary *)parameters {
    return [self URLQueryWithParameters:parameters options:URLQueryOptionDefault];
}

+ (NSString *)URLQueryWithParameters:(NSDictionary *)parameters options:(URLQueryOptions)options {
    BOOL useArraySyntax = options & 8;
    URLQueryOptions arrayHandling = (options & 7) ? : URLQueryOptionUseArrays;

    NSMutableString *result = [NSMutableString string];
    for (NSString *key in parameters) {
        NSString *encodedKey = [key URLEncodedString];
        id value = parameters[key];
        if ([value isKindOfClass:[NSArray class]]) {
            if (arrayHandling == URLQueryOptionKeepFirstValue && [value count]) {
                if ([result length]) {
                    [result appendString:@"&"];
                }
                [result appendFormat:@"%@=%@", encodedKey, [value[0] URLEncodedString]];
            } else if (arrayHandling == URLQueryOptionKeepLastValue && [value count]) {
                if ([result length]) {
                    [result appendString:@"&"];
                }
                [result appendFormat:@"%@=%@", encodedKey, [[value lastObject] URLEncodedString]];
            } else {
                for (NSString *element in value) {
                    if ([result length]) {
                        [result appendString:@"&"];
                    }
                    if (useArraySyntax) {
                        [result appendFormat:@"%@[]=%@", encodedKey, [element URLEncodedString]];
                    } else {
                        [result appendFormat:@"%@=%@", encodedKey, [element URLEncodedString]];
                    }
                }
            }
        } else {
            if ([result length]) {
                [result appendString:@"&"];
            }
            if (useArraySyntax && arrayHandling == URLQueryOptionAlwaysUseArrays) {
                [result appendFormat:@"%@[]=%@", encodedKey, [value URLEncodedString]];
            } else {
                [result appendFormat:@"%@=%@", encodedKey, [value URLEncodedString]];
            }
        }
    }
    return result;
}

- (NSRange)rangeOfURLQuery {
    NSRange queryRange = NSMakeRange(0, [self length]);
    NSRange fragmentStart = [self rangeOfString:@"#"];
    if (fragmentStart.length) {
        queryRange.length -= (queryRange.length - fragmentStart.location);
    }
    NSRange queryStart = [self rangeOfString:@"?"];
    if (queryStart.length) {
        queryRange.location = queryStart.location;
        queryRange.length -= queryRange.location;
    }
    NSString *queryString = [self substringWithRange:queryRange];
    if (queryStart.length || [queryString rangeOfString:@"="].length) {
        return queryRange;
    }
    return NSMakeRange(NSNotFound, 0);
}

- (NSString *)URLQuery {
    NSRange queryRange = [self rangeOfURLQuery];
    if (queryRange.location == NSNotFound) {
        return nil;
    }
    NSString *queryString = [self substringWithRange:queryRange];
    if ([queryString hasPrefix:@"?"]) {
        queryString = [queryString substringFromIndex:1];
    }
    return queryString;
}

- (NSString *)stringByDeletingURLQuery {
    NSRange queryRange = [self rangeOfURLQuery];
    if (queryRange.location != NSNotFound) {
        NSString *prefix = [self substringToIndex:queryRange.location];
        NSString *suffix = [self substringFromIndex:queryRange.location + queryRange.length];
        return [prefix stringByAppendingString:suffix];
    }
    return self;
}

- (NSString *)stringByReplacingURLQueryWithQuery:(NSString *)query {
    return [[self stringByDeletingURLQuery] stringByAppendingURLQuery:query];
}

- (NSString *)stringByAppendingURLQuery:(NSString *)query {
    //check for nil input
    if ([query length] == 0) {
        return self;
    }

    NSString *result = self;
    NSString *fragment = [result URLFragment];
    result = [self stringByDeletingURLFragment];
    NSString *queryString = [result URLQuery];
    if (queryString) {
        if ([queryString length]) {
            result = [result stringByAppendingFormat:@"&%@", query];
        } else {
            result = [result stringByAppendingString:query];
        }
    } else {
        result = [result stringByAppendingFormat:@"?%@", query];
    }
    if ([fragment length]) {
        result = [result stringByAppendingFormat:@"#%@", fragment];
    }
    return result;
}

- (NSString *)stringByMergingURLQuery:(NSString *)query {
    return [self stringByMergingURLQuery:query options:URLQueryOptionDefault];
}

- (NSString *)stringByMergingURLQuery:(NSString *)query options:(URLQueryOptions)options {
    URLQueryOptions arrayHandling = (options & 7) ? : URLQueryOptionKeepLastValue;

    //check for nil input
    query = [query URLQuery];
    if ([query length] == 0) {
        return self;
    }

    //check for nil query string
    NSString *queryString = [self URLQuery];
    if ([queryString length] == 0) {
        return [self stringByAppendingURLQuery:query];
    }

    NSMutableDictionary *parameters = [[queryString URLQueryParametersWithOptions:options] mutableCopy];

#if !__has_feature(objc_arc)
    [parameters autorelease];
#endif

    NSDictionary *newParameters = [query URLQueryParametersWithOptions:options];
    for (NSString *key in newParameters) {
        id value = newParameters[key];
        id oldValue = parameters[key];
        if ([oldValue isKindOfClass:[NSArray class]]) {
            if ([value isKindOfClass:[NSArray class]]) {
                value = [oldValue arrayByAddingObjectsFromArray:value];
            } else {
                value = [oldValue arrayByAddingObject:value];
            }
        } else if (oldValue) {
            if ([value isKindOfClass:[NSArray class]]) {
                value = [@[oldValue] arrayByAddingObjectsFromArray: value];
            } else if (arrayHandling == URLQueryOptionKeepFirstValue) {
                value = oldValue;
            } else if (arrayHandling == URLQueryOptionUseArrays ||
                       arrayHandling == URLQueryOptionAlwaysUseArrays) {
                value = @[oldValue, value];
            }
        } else if (arrayHandling == URLQueryOptionAlwaysUseArrays) {
            value = @[value];
        }
        parameters[key] = value;
    }

    return [self stringByReplacingURLQueryWithQuery:[NSString URLQueryWithParameters:parameters options:options]];
}

- (NSDictionary *)URLQueryParameters {
    return [self URLQueryParametersWithOptions:URLQueryOptionDefault];
}

- (NSDictionary *)URLQueryParametersWithOptions:(URLQueryOptions)options {
    URLQueryOptions arrayHandling = (options & 7) ? : URLQueryOptionKeepLastValue;

    NSString *queryString = [self URLQuery];

    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSArray *parameters = [queryString componentsSeparatedByString:@"&"];
    for (NSString *parameter in parameters) {
        NSArray *parts = [parameter componentsSeparatedByString:@"="];
        NSString *key = [parts[0] URLDecodedString:YES];
        if ([parts count] > 1) {
            id value = [parts[1] URLDecodedString:YES];
            BOOL arrayValue = [key hasSuffix:@"[]"];
            if (arrayValue) {
                key = [key substringToIndex:[key length] - 2];
            }
            id existingValue = result[key];
            if ([existingValue isKindOfClass:[NSArray class]]) {
                value = [existingValue arrayByAddingObject:value];
            } else if (existingValue) {
                if (arrayHandling == URLQueryOptionKeepFirstValue) {
                    value = existingValue;
                } else if (arrayHandling != URLQueryOptionKeepLastValue) {
                    value = @[existingValue, value];
                }
            } else if ((arrayValue && arrayHandling == URLQueryOptionUseArrays) ||
                       arrayHandling == URLQueryOptionAlwaysUseArrays) {
                value = @[value];
            }
            result[key] = value;
        }
    }
    return result;
}

#pragma mark URL Host

- (NSRange)rangeOfScheme {
    NSUInteger pos = [self rangeOfString:@"://" options:NSCaseInsensitiveSearch].location;

    return (pos != NSNotFound) ? NSMakeRange(0, pos) : NSMakeRange(NSNotFound, 0);
}

- (NSRange)rangeOfHost {
    NSRange schemeRange = [self rangeOfScheme];
    NSUInteger hostPos = (schemeRange.location != NSNotFound) ? schemeRange.location + schemeRange.length + 3 : 0;
    NSUInteger pos = [self rangeOfString:@"/" options:0 range:NSMakeRange(hostPos, self.length - hostPos)].location;
    NSUInteger hostLen = ((pos != NSNotFound) ? pos : self.length);

    return NSMakeRange(hostPos, hostLen-hostPos);
}

- (NSRange)rangeOfHostWithScheme {
    NSRange schemeRange = [self rangeOfScheme];
    NSUInteger hostPos = (schemeRange.location != NSNotFound) ? schemeRange.location + schemeRange.length + 3 : 0;
    NSUInteger pos = [self rangeOfString:@"/" options:0 range:NSMakeRange(hostPos, self.length - hostPos)].location;
    NSUInteger hostLen = ((pos != NSNotFound) ? pos : self.length);

    return NSMakeRange(0, hostLen);
}

- (NSString *)URLHost {
    NSRange hostRange = [self rangeOfHost];

    if (hostRange.location != NSNotFound) {
        return [self substringWithRange:hostRange];
    }

    return nil;
}

- (NSString *)URLHostWithScheme {
    NSRange hostRange = [self rangeOfHostWithScheme];

    if (hostRange.location != NSNotFound) {
        return [self substringWithRange:hostRange];
    }

    return nil;
}

#pragma mark URL fragment ID

- (NSString *)URLFragment {
    NSRange fragmentStart = [self rangeOfString:@"#"];
    if (fragmentStart.location != NSNotFound) {
        return [self substringFromIndex:fragmentStart.location + 1];
    }
    return nil;
}

- (NSString *)stringByDeletingURLFragment {
    NSRange fragmentStart = [self rangeOfString:@"#"];
    if (fragmentStart.location != NSNotFound) {
        return [self substringToIndex:fragmentStart.location];
    }
    return self;
}

- (NSString *)stringByAppendingURLFragment:(NSString *)fragment {
    if (fragment) {
        NSRange fragmentStart = [self rangeOfString:@"#"];
        if (fragmentStart.location != NSNotFound) {
            return [self stringByAppendingString:fragment];
        }
        return [self stringByAppendingFormat:@"#%@", fragment];
    }
    return self;
}

#pragma mark URL conversion

- (NSURL *)URLValue {
    if ([self isAbsolutePath]) {
        return [NSURL fileURLWithPath:self];
    }
    return [NSURL URLWithString:self];
}

- (NSURL *)URLValueRelativeToURL:(NSURL *)baseURL {
    return [NSURL URLWithString:self relativeToURL:baseURL];
}

@end
