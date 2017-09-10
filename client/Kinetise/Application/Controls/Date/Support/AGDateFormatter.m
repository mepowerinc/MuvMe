#import "AGDateFormatter.h"
#import "AGLocalizationManager.h"
#import "AGFontManager.h"

@interface AGDateFormatter (){
    BOOL needsUpdateDateFormatter;
    BOOL needsUpdateWidestDateString;
}
@property(nonatomic, retain) NSDictionary *replacement;
@property(nonatomic, retain) NSDateFormatter *dateFormatter;
@property(nonatomic, copy) NSString *widestDateString;
@property(nonatomic, copy) NSString *fontName;
@property(nonatomic, assign) CGFloat fontSize;
@property(nonatomic, assign) BOOL fontBold;
@property(nonatomic, assign) BOOL fontItalic;
@end

@implementation AGDateFormatter

@synthesize replacement;
@synthesize dateFormat;
@synthesize dateFormatter;
@synthesize widestDateString;
@synthesize fontName;
@synthesize fontSize;
@synthesize fontItalic;
@synthesize fontBold;

#pragma mark - Initialization

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.replacement = nil;
    self.dateFormat = nil;
    self.dateFormatter = nil;
    self.widestDateString = nil;
    self.fontName = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];

    // needs update
    needsUpdateDateFormatter = YES;
    needsUpdateWidestDateString = YES;

    // replacement
    self.replacement = @{
        @"m"     : @"M",
        @"mm"    : @"MM",
        @"mmm"   : @"MMM",
        @"mmmm"  : @"MMMM",
        @"ddd"   : @"EEE",
        @"dddd"  : @"EEEE",
        @"h"     : @"H",
        @"hh"    : @"HH",
        @"k"     : @"h",
        @"kk"    : @"hh",
        @"n"     : @"m",
        @"nn"    : @"mm",
        @"z"     : @"S",
        @"zzz"   : @"SSS"
    };

    // notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeLocalization:) name:AGLocalizationChangedNotification object:nil];

    return self;
}

#pragma mark - Lifecycle

- (void)setDateFormat:(NSString *)dateFormat_ {
    if ([dateFormat isEqualToString:dateFormat_]) return;

    if (dateFormat) {
        [dateFormat release];
        dateFormat = nil;
    }

    if (dateFormat_) {
        dateFormat = [dateFormat_ copy];
        needsUpdateDateFormatter = YES;
        needsUpdateWidestDateString = YES;
    }
}

- (NSDateFormatter *)dateFormatter {
    if (needsUpdateDateFormatter) {
        [self updateDateFormatter];
    }

    return dateFormatter;
}

- (NSString *)widestDateStringWithFont:(NSString *)fontName_ andSize:(CGFloat)size_ andBold:(BOOL)bold_ andItalic:(BOOL)italic_ {
    if ([fontName isEqualToString:fontName_] && fontSize == size_ && fontBold == bold_ && fontItalic == italic_ && widestDateString && !needsUpdateWidestDateString) return widestDateString;

    self.fontName = fontName_;
    self.fontSize = size_;
    self.fontBold = bold_;
    self.fontItalic = italic_;

    [self updateWidestDateString];

    return widestDateString;
}

- (void)updateDateFormatter {
    needsUpdateDateFormatter = NO;

    // 12-hour clock
    NSString *newDateFormat = [dateFormat stringByReplacingOccurrencesOfString:@"hh12" withString:@"kk"];
    newDateFormat = [newDateFormat stringByReplacingOccurrencesOfString:@"h12" withString:@"k"];

    BOOL upperCasePeriod = ([newDateFormat rangeOfString:@"AMPM"].location != NSNotFound);
    newDateFormat = [newDateFormat stringByReplacingOccurrencesOfString:@"ampm" withString:@"a"];
    newDateFormat = [newDateFormat stringByReplacingOccurrencesOfString:@"AMPM" withString:@"a"];

    NSArray *sequences = [self findSequences:newDateFormat];
    NSMutableString *format = [[NSMutableString alloc] init];

    for (NSString *sequence in sequences) {
        NSString *newFormat = replacement[sequence];

        if (newFormat) {
            [format appendString:newFormat];
        } else {
            [format appendString:sequence];
        }
    }

    // date formatter
    self.dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.locale = locale;
    [locale release];
    dateFormatter.dateFormat = format;
    [format release];

    // symbols
    [dateFormatter setShortMonthSymbols:AGLOCALIZATION.shortMonthSymbols ];
    [dateFormatter setMonthSymbols:AGLOCALIZATION.monthSymbols ];
    [dateFormatter setShortWeekdaySymbols:AGLOCALIZATION.shortWeekdaySymbols ];
    [dateFormatter setWeekdaySymbols:AGLOCALIZATION.weekdaySymbols ];

    // ampm
    if (upperCasePeriod) {
        [dateFormatter setAMSymbol:@"AM"];
        [dateFormatter setPMSymbol:@"PM"];
    } else {
        [dateFormatter setAMSymbol:@"am"];
        [dateFormatter setPMSymbol:@"pm"];
    }
}

- (void)updateWidestDateString {
    needsUpdateWidestDateString = NO;

    // setup font manager
    [AGFONTMANAGER setFont:AG_FONT_NAME withSize:fontSize andBold:fontBold andItalic:fontItalic];

    // segments
    NSArray *segments = [self segmentsFromDateFormat:dateFormat];

    BOOL hasShortMonthName = [segments containsObject:@"mmm"];
    BOOL hasFullMonthName = [segments containsObject:@"mmmm"];
    BOOL hasShortWeekdayName = [segments containsObject:@"ddd"];
    BOOL hasFullWeekdayName = [segments containsObject:@"dddd"];
    BOOL hasampm = [segments containsObject:@"ampm"];
    BOOL hasAMPM = [segments containsObject:@"AMPM"];

    // find maximum digit
    CGFloat maxDigitWidth = 0.0f;
    NSString *digitStr = nil;

    for (int i = 0; i < 10; ++i) {
        NSString *tempDigitStr = [NSString stringWithFormat:@"%zd", i];
        CGFloat strWidth = [AGFONTMANAGER getWidthForString:tempDigitStr];

        if (strWidth > maxDigitWidth) {
            maxDigitWidth = strWidth;
            digitStr = tempDigitStr;
        }
    }

    int widestWeekdayIndex = 0;
    CGFloat maxWeekdayWidth = 0.0f;

    // find the widest weekday name
    if (hasShortWeekdayName || hasFullWeekdayName) {
        for (int i = 0; i < 7; ++i) {
            NSMutableString *weekday = [[NSMutableString alloc] init];
            if (hasShortWeekdayName)
                [weekday appendString:AGLOCALIZATION.shortWeekdaySymbols[i] ];

            if (hasShortWeekdayName && hasFullWeekdayName)
                [weekday appendString:@" "];

            if (hasFullWeekdayName)
                [weekday appendString:AGLOCALIZATION.weekdaySymbols[i] ];

            CGFloat strWidth = [AGFONTMANAGER getWidthForString:weekday];
            if (strWidth > maxWeekdayWidth) {
                maxWeekdayWidth = strWidth;
                widestWeekdayIndex = i;
            }

            [weekday release];
        }
    }

    int widestMonthIndex = 0;
    CGFloat maxMonthWidth = 0.0f;

    // find the widest month name
    if (hasShortMonthName || hasFullMonthName) {
        for (int i = 0; i < 12; ++i) {
            NSMutableString *month = [[NSMutableString alloc] init];
            if (hasShortMonthName)
                [month appendString:AGLOCALIZATION.shortMonthSymbols[i] ];

            if (hasShortMonthName && hasFullMonthName)
                [month appendString:@" "];

            if (hasFullMonthName)
                [month appendString:AGLOCALIZATION.monthSymbols[i] ];

            CGFloat strWidth = [AGFONTMANAGER getWidthForString:month];
            if (strWidth > maxMonthWidth) {
                maxMonthWidth = strWidth;
                widestMonthIndex = i;
            }

            [month release];
        }
    }

    // find am, pm, AM, PM
    NSString *widestampm = nil;
    if (hasampm) {
        CGFloat amStrWidth = [AGFONTMANAGER getWidthForString:@"am"];
        CGFloat pmStrWidth = [AGFONTMANAGER getWidthForString:@"pm"];

        if (amStrWidth > pmStrWidth)
            widestampm = @"am";
        else
            widestampm = @"pm";
    }

    NSString *widestAMPM = nil;
    if (hasAMPM) {
        CGFloat amStrWidth = [AGFONTMANAGER getWidthForString:@"AM"];
        CGFloat pmStrWidth = [AGFONTMANAGER getWidthForString:@"PM"];

        if (amStrWidth > pmStrWidth)
            widestAMPM = @"AM";
        else
            widestAMPM = @"PM";
    }

    // mock date
    NSMutableString *newWidestDate = [[[NSMutableString alloc] init] autorelease];

    for (NSString *segment in segments) {
        if ([segment isEqualToString:@"yy"]) {
            [newWidestDate appendFormat:@"%@%@", digitStr, digitStr];

        } else if ([segment isEqualToString:@"yyyy"]) {
            [newWidestDate appendFormat:@"%@%@%@%@", digitStr, digitStr, digitStr, digitStr];

        } else if ([segment isEqualToString:@"m"] || [segment isEqualToString:@"mm"]) {
            [newWidestDate appendFormat:@"%@%@", digitStr, digitStr];

        } else if ([segment isEqualToString:@"mmm"]) {
            [newWidestDate appendString:AGLOCALIZATION.shortMonthSymbols[widestMonthIndex] ];

        } else if ([segment isEqualToString:@"mmmm"]) {
            [newWidestDate appendString:AGLOCALIZATION.monthSymbols[widestMonthIndex] ];

        } else if ([segment isEqualToString:@"d"] || [segment isEqualToString:@"dd"]) {
            [newWidestDate appendFormat:@"%@%@", digitStr, digitStr];

        } else if ([segment isEqualToString:@"ddd"]) {
            [newWidestDate appendString:AGLOCALIZATION.shortWeekdaySymbols[widestWeekdayIndex] ];

        } else if ([segment isEqualToString:@"dddd"]) {
            [newWidestDate appendString:AGLOCALIZATION.weekdaySymbols[widestWeekdayIndex] ];

        } else if ([segment isEqualToString:@"h"] || [segment isEqualToString:@"hh"] || [segment isEqualToString:@"h12"] || [segment isEqualToString:@"hh12"]) {
            [newWidestDate appendFormat:@"%@%@", digitStr, digitStr];

        } else if ([segment isEqualToString:@"ampm"]) {
            [newWidestDate appendString:widestampm];

        } else if ([segment isEqualToString:@"AMPM"]) {
            [newWidestDate appendString:widestAMPM];

        } else if ([segment isEqualToString:@"n"] || [segment isEqualToString:@"nn"]) {
            [newWidestDate appendFormat:@"%@%@", digitStr, digitStr];

        } else if ([segment isEqualToString:@"s"] || [segment isEqualToString:@"ss"]) {
            [newWidestDate appendFormat:@"%@%@", digitStr, digitStr];

        } else if ([segment isEqualToString:@"z"] || [segment isEqualToString:@"zzz"]) {
            [newWidestDate appendFormat:@"%@%@%@", digitStr, digitStr, digitStr];

        } else {
            [newWidestDate appendString:segment];
        }
    }

    self.widestDateString = newWidestDate;
}

- (NSArray *)segmentsFromDateFormat:(NSString *)string {
    NSMutableArray *sequences = [[[self findSequences:string] mutableCopy] autorelease];

    // find hh12, ampm, AMPM
    for (int i = 0; i < [sequences count]; ++i) {
        if (i + 2 < [sequences count]) {
            if ([sequences[i] isEqualToString:@"h"] &&
                [sequences[i+1] isEqualToString:@"1"] &&
                [sequences[i+2] isEqualToString:@"2"]) {
                [sequences removeObjectAtIndex:i+1];
                [sequences removeObjectAtIndex:i+1];
                sequences[i] = @"h12";
                continue;
            }

            if ([sequences[i] isEqualToString:@"hh"] &&
                [sequences[i+1] isEqualToString:@"1"] &&
                [sequences[i+2] isEqualToString:@"2"]) {
                [sequences removeObjectAtIndex:i+1];
                [sequences removeObjectAtIndex:i+1];
                sequences[i] = @"hh12";
                continue;
            }

        }

        if (i + 3 < [sequences count]) {
            if ([sequences[i] isEqualToString:@"a"] &&
                [sequences[i+1] isEqualToString:@"m"] &&
                [sequences[i+2] isEqualToString:@"p"] &&
                [sequences[i+3] isEqualToString:@"m"]) {
                [sequences removeObjectAtIndex:i+1];
                [sequences removeObjectAtIndex:i+1];
                [sequences removeObjectAtIndex:i+1];
                sequences[i] = @"ampm";
                continue;
            }

            if ([sequences[i] isEqualToString:@"A"] &&
                [sequences[i+1] isEqualToString:@"M"] &&
                [sequences[i+2] isEqualToString:@"P"] &&
                [sequences[i+3] isEqualToString:@"M"]) {
                [sequences removeObjectAtIndex:i+1];
                [sequences removeObjectAtIndex:i+1];
                [sequences removeObjectAtIndex:i+1];
                sequences[i] = @"AMPM";
                continue;
            }
        }
    }

    return sequences;
}

- (NSArray *)findSequences:(NSString *)string {
    if (!string) return nil;

    NSMutableArray *result = [NSMutableArray array];
    if (string.length == 0) return result;

    int sequenceLength = 1;
    unichar lastChar = [string characterAtIndex:0];

    for (int i = 1; i < string.length; ++i) {
        unichar currentChar = [string characterAtIndex:i];
        if (currentChar == lastChar) {
            ++sequenceLength;
        } else {
            NSString *currentSequence = [self stringWithChar:lastChar occurrences:sequenceLength];
            [result addObject:currentSequence];
            sequenceLength = 1;
        }

        lastChar = currentChar;
    }

    NSString *currentSequence = [self stringWithChar:lastChar occurrences:sequenceLength];
    [result addObject:currentSequence];

    return result;
}

- (NSString *)stringWithChar:(unichar)c occurrences:(NSInteger)occurrences {
    NSMutableString *result = [NSMutableString string];

    for (int i = 0; i < occurrences; ++i) {
        [result appendFormat:@"%c", c];
    }

    return result;
}

#pragma mark - Notifications

- (void)changeLocalization:(NSNotification *)notification {
    needsUpdateDateFormatter = YES;
    needsUpdateWidestDateString = YES;
}

@end
