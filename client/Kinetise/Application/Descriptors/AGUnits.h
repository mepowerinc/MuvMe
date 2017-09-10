#ifndef AppGen_AGUnits_h
#define AppGen_AGUnits_h

#import <Foundation/Foundation.h>

static NSString *AG_REUSE_IDENTIFIER_ITEM_TEMPLATE = @"AG_REUSE_IDENTIFIER_ITEM_TEMPLATE";
static NSString *AG_REUSE_IDENTIFIER_LOADING = @"AG_REUSE_IDENTIFIER_LOADING";
static NSString *AG_REUSE_IDENTIFIER_ERROR = @"AG_REUSE_IDENTIFIER_ERROR";
static NSString *AG_REUSE_IDENTIFIER_NO_DATA = @"AG_REUSE_IDENTIFIER_NO_DATA";
static NSString *AG_REUSE_IDENTIFIER_LOAD_MORE = @"AG_REUSE_IDENTIFIER_LOAD_MORE";

typedef NS_ENUM (NSInteger, AGUnitType) {
    unitMax = 0,
    unitMin,
    unitKpx,
    unitPercentage,
};

typedef NS_ENUM (NSInteger, AGLayoutType) {
    layoutVertical = 0,
    layoutHorizontal,
    layoutThumbnails,
    layoutGrid,
    layoutAbsolute
};

typedef struct AGAlignData {
    CGFloat elementsNoWidthAlignDistributed;
    CGFloat elementsNoHeightVAlignDistributed;
    CGFloat totalWidthForLeftAlign;
    CGFloat totalWidthForRightAlign;
    CGFloat totalWidthForCenterAlign;
    CGFloat totalWidthForDistributedAlign;
    CGFloat totalHeightForTopVAlign;
    CGFloat totalHeightForBottomVAlign;
    CGFloat totalHeightForCenterVAlign;
    CGFloat totalHeightForDistributedVAlign;
} AGAlignData;

static inline AGAlignData AGAlignDataZero(){
    AGAlignData v;
    v.elementsNoWidthAlignDistributed = 0;
    v.elementsNoHeightVAlignDistributed = 0;
    v.totalWidthForLeftAlign = 0;
    v.totalWidthForRightAlign = 0;
    v.totalWidthForCenterAlign = 0;
    v.totalWidthForDistributedAlign = 0;
    v.totalHeightForTopVAlign = 0;
    v.totalHeightForBottomVAlign = 0;
    v.totalHeightForCenterVAlign = 0;
    v.totalHeightForDistributedVAlign = 0;
    return v;
}

#pragma mark - Chart

typedef NS_ENUM (NSInteger, AGChartType){
    chartLine = 0,
    chartPie,
    chartBar,
    chartHorizontalBar
};

static inline AGChartType AGChartTypeWithText(NSString *value){
    AGChartType chartType = chartLine;
    
    if ([value isEqualToString:@"line"]) {
        chartType = chartLine;
    } else if ([value isEqualToString:@"pie"]) {
        chartType = chartPie;
    } else if ([value isEqualToString:@"bar"]) {
        chartType = chartBar;
    } else if ([value isEqualToString:@"horizontalbar"]) {
        chartType = chartHorizontalBar;
    }
    
    return chartType;
}

#pragma mark - Map

typedef NS_ENUM (NSInteger, AGMapRegion){
    mapRegionNone = 0,
    mapRegionPins,
    mapRegionUserLocation,
};

static inline AGMapRegion AGMapRegionWithText(NSString *value){
    AGMapRegion mapRegion = mapRegionNone;
    
    if ([value isEqualToString:@"pins"]) {
        mapRegion = mapRegionPins;
    } else if ([value isEqualToString:@"me"]) {
        mapRegion = mapRegionUserLocation;
    }
    
    return mapRegion;
}

#pragma mark - Cache Policy

typedef NS_ENUM (NSInteger, AGCachePolicy){
    cachePolicyDoNotCache = 0,
    cachePolicyForceReload,
    cachePolicyLiveStream,
    cachePolicyFreshData,
    cachePolicyOnlyCachedData,
    cachePolicyCachedData,
    cachePolicyCachedDataWithRefresh,
    cachePolicyMaxAge,
    cachePolicyRefreshEvery,
    cachePolicyCachedDataWithRefreshEvery,
    cachePolicyDefault = cachePolicyOnlyCachedData
};

static inline AGCachePolicy AGCachePolicyWithText(NSString *value){
    AGCachePolicy cachePolicy = cachePolicyDefault;
    
    if ([value isEqualToString:@"nostore"]) {
        cachePolicy = cachePolicyDoNotCache;
    } else if ([value isEqualToString:@"live"]) {
        cachePolicy = cachePolicyLiveStream;
    } else if ([value isEqualToString:@"freshdata"]) {
        cachePolicy = cachePolicyFreshData;
    } else if ([value isEqualToString:@"cachedata"]) {
        cachePolicy = cachePolicyCachedData;
    } else if ([value isEqualToString:@"cachedataandrefresh"]) {
        cachePolicy = cachePolicyCachedDataWithRefresh;
    } else if ([value isEqualToString:@"maxage"]) {
        cachePolicy = cachePolicyMaxAge;
    } else if ([value isEqualToString:@"refreshevery"]) {
        cachePolicy = cachePolicyRefreshEvery;
    } else if ([value isEqualToString:@"cachedataandrefreshevery"]) {
        cachePolicy = cachePolicyCachedDataWithRefreshEvery;
    } else if ([value isEqualToString:@"forcerefresh"]) {
        cachePolicy = cachePolicyForceReload;
    }
    
    return cachePolicy;
}

#pragma mark - Text Line Data

typedef struct AGLineData {
    NSInteger startIndex;
    NSInteger length;
    CGFloat width;
} AGLineData;

#pragma mark - Permissions

typedef NS_OPTIONS (NSInteger, AGPermissions){
    AGPermissionNone = 0,
    AGPermissionGPS = 1 << 0,
    AGPermissionGPSTracking = 1 << 1,
    AGPermissionPush = 1 << 2,
    AGPermissionAlterApi = 1 << 3,
    AGPermissionFacebook = 1 << 4,
    AGPermissionTwitter = 1 << 5,
};

static inline AGPermissions AGPermissionWithText(NSString *value){
    AGPermissions permission = AGPermissionNone;
    
    if ([value isEqualToString:@"GPS"]) {
        permission = AGPermissionGPS;
    } else if ([value isEqualToString:@"GPS_TRACKING"]) {
        permission = AGPermissionGPSTracking;
    } else if ([value isEqualToString:@"ALTERAPI"]) {
        permission = AGPermissionAlterApi;
    } else if ([value isEqualToString:@"PUSH"]) {
        permission = AGPermissionPush;
    } else if ([value isEqualToString:@"FACEBOOKTOKEN"]) {
        permission = AGPermissionFacebook;
    } else if ([value isEqualToString:@"TWITTERTOKEN"]) {
        permission = AGPermissionTwitter;
    }
    
    return permission;
}

#pragma mark - Code Scanner

typedef NS_OPTIONS (NSInteger, AGCodeType){
    AGCodeTypeNone = 0,
    AGCodeTypeUPCE = 1 << 0,
    AGCodeTypeCode39 = 1 << 1,
    AGCodeTypeCode93 = 1 << 2,
    AGCodeTypeCode128 = 1 << 3,
    AGCodeTypeEAN8 = 1 << 4,
    AGCodeTypeEAN13 = 1 << 5,
    AGCodeTypePDF417 = 1 << 6,
    AGCodeTypeQR = 1 << 7,
    AGCodeTypeAztec = 1 << 8,
    AGCodeTypeITF14 = 1 << 9,
    AGCodeTypeDataMatrix = 1 << 10,
};

static inline AGCodeType AGCodeTypeWithText(NSString *value){
    AGCodeType codeType = AGCodeTypeNone;
    
    if ([value isEqualToString:@"upce"]) {
        codeType = AGCodeTypeUPCE;
    } else if ([value isEqualToString:@"code39"]) {
        codeType = AGCodeTypeCode39;
    } else if ([value isEqualToString:@"code93"]) {
        codeType = AGCodeTypeCode93;
    } else if ([value isEqualToString:@"code128"]) {
        codeType = AGCodeTypeCode128;
    } else if ([value isEqualToString:@"ean8"]) {
        codeType = AGCodeTypeEAN8;
    } else if ([value isEqualToString:@"ean13"]) {
        codeType = AGCodeTypeEAN13;
    } else if ([value isEqualToString:@"pdf417"]) {
        codeType = AGCodeTypePDF417;
    } else if ([value isEqualToString:@"qr"]) {
        codeType = AGCodeTypeQR;
    } else if ([value isEqualToString:@"aztec"]) {
        codeType = AGCodeTypeAztec;
    } else if ([value isEqualToString:@"itf14"]) {
        codeType = AGCodeTypeITF14;
    } else if ([value isEqualToString:@"datamatrix"]) {
        codeType = AGCodeTypeDataMatrix;
    }
    
    return codeType;
}

#pragma mark - DatePicker

typedef NS_ENUM (NSInteger, AGDatePickerMode) {
    datePickerModeDate = 0,
    datePickerModeTime,
    datePickerModeDateTime,
};

static inline AGDatePickerMode AGDatePickerModeWithText(NSString *text){
    if ([text isEqualToString:@"date"]) {
        return datePickerModeDate;
    } else if ([text isEqualToString:@"time"]) {
        return datePickerModeTime;
    } else if ([text isEqualToString:@"datetime"]) {
        return datePickerModeDateTime;
    }
    
    return datePickerModeDate;
}

#pragma mark - Encryption

typedef NS_ENUM (NSInteger, AGEncryptionType) {
    encryptionNone = 0,
    encryptionMD5,
    encryptionSHA1
};

static inline AGEncryptionType AGEncryptionTypeWithText(NSString *text){
    if ([text isEqualToString:@"md5"]) {
        return encryptionMD5;
    } else if ([text isEqualToString:@"sha1"]) {
        return encryptionSHA1;
    }
    
    return encryptionNone;
}

#pragma mark - Keyboard

typedef NS_ENUM (NSInteger, AGKeyboardType) {
    keyboardTypeText = 0,
    keyboardTypeURL,
    keyboardTypeEmail,
    keyboardTypeNumber,
    keyboardTypePhone,
    keyboardTypeDecimal,
};

static inline AGKeyboardType AGKeyboardTypeWithText(NSString *text){
    if ([text isEqualToString:@"text"]) {
        return keyboardTypeText;
    } else if ([text isEqualToString:@"url"]) {
        return keyboardTypeURL;
    } else if ([text isEqualToString:@"email"]) {
        return keyboardTypeEmail;
    } else if ([text isEqualToString:@"number"]) {
        return keyboardTypeNumber;
    } else if ([text isEqualToString:@"phone"]) {
        return keyboardTypePhone;
    } else if ([text isEqualToString:@"decimal"]) {
        return keyboardTypeDecimal;
    }
    
    return keyboardTypeText;
}

#pragma mark - Feed

typedef NS_ENUM (NSInteger, AGFeedSortOrder) {
    feedSortOrderAscending = 0,
    feedSortOrderDescending,
};

static inline AGFeedSortOrder AGFeedSortOrderWithText(NSString *text){
    if ([text isEqualToString:@"ascending"]) {
        return feedSortOrderAscending;
    } else if ([text isEqualToString:@"descending"]) {
        return feedSortOrderDescending;
    }
    
    return feedSortOrderAscending;
}

typedef NS_ENUM (NSInteger, AGFeedPaginationType) {
    feedPaginantionNone = 0,
    feedPaginationURL,
    feedPaginationToken
};

typedef NS_ENUM (NSInteger, AGFeedFormat) {
    feedFormatXML = 0,
    feedFormatJSON,
    feedFormatCSV,
    feedFormatDB
};

typedef NS_ENUM (NSInteger, AGAssetType) {
    assetUnknown = 0,
    assetFile,
    assetHttp,
    assetContext,
    assetLocalStorage,
};

typedef NS_ENUM (NSInteger, AGAssetDataType) {
    assetFeedData = 0,
    assetImageData,
};

#pragma mark - ScreenOrientation

typedef NS_ENUM (NSInteger, AGScreenOrientation) {
    screenOrientationBoth = 0,
    screenOrientationPortrait,
    screenOrientationLandscape,
};

static inline AGScreenOrientation AGScreenOrientationWithText(NSString *text){
    if ([text isEqualToString:@"both"]) {
        return screenOrientationBoth;
    } else if ([text isEqualToString:@"portrait"]) {
        return screenOrientationPortrait;
    } else if ([text isEqualToString:@"landscape"]) {
        return screenOrientationLandscape;
    }
    
    return screenOrientationBoth;
}

#pragma mark - DateSource

typedef NS_ENUM (NSInteger, AGDateSource) {
    dateLocal = 0,
    dateInternet,
    dateNode,
};

static inline AGDateSource AGDateSourceWithText(NSString *text){
    if ([text isEqualToString:@"local"]) {
        return dateLocal;
    } else if ([text isEqualToString:@"internet"]) {
        return dateInternet;
    } else if ([text isEqualToString:@"node"]) {
        return dateNode;
    }
    
    return dateLocal;
}

#pragma mark - Timezone

typedef NS_ENUM (NSInteger, AGDateTimezone) {
    timezoneDefault = 0,
    timezoneInput,
};

static inline AGDateTimezone AGDateTimezoneWithText(NSString *text){
    if ([text isEqualToString:@"default"]) {
        return timezoneDefault;
    } else if ([text isEqualToString:@"input"]) {
        return timezoneInput;
    }
    
    return timezoneDefault;
}

#pragma mark - SizeMode

typedef NS_ENUM (NSInteger, AGSizeModeType) {
    sizeModeStretch = 0,
    sizeModeLongedge,
    sizeModeShortedge,
};

static inline AGSizeModeType AGSizeModeWithText(NSString *text){
    if ([text isEqualToString:@"stretch"]) {
        return sizeModeStretch;
    } else if ([text isEqualToString:@"longedge"]) {
        return sizeModeLongedge;
    } else if ([text isEqualToString:@"shortedge"]) {
        return sizeModeShortedge;
    }
    
    return sizeModeStretch;
}

#pragma mark - Align

typedef NS_ENUM (NSInteger, AGAlignType) {
    alignNone = 0,
    alignLeft,
    alignRight,
    alignCenter,
    alignDistributed,
};

static inline AGAlignType AGAlignWithText(NSString *text){
    if ([text isEqualToString:@"left"]) {
        return alignLeft;
    } else if ([text isEqualToString:@"right"]) {
        return alignRight;
    } else if ([text isEqualToString:@"center"]) {
        return alignCenter;
    } else if ([text isEqualToString:@"distributed"]) {
        return alignDistributed;
    }
    
    return alignNone;
}

#pragma mark - Valign

typedef NS_ENUM (NSInteger, AGValignType) {
    valignNone = 0,
    valignTop,
    valignBottom,
    valignCenter,
    valignDistributed,
    valignBelow,
    valignAbove
};

static inline AGValignType AGValignWithText(NSString *text){
    if ([text isEqualToString:@"top"]) {
        return valignTop;
    } else if ([text isEqualToString:@"center"]) {
        return valignCenter;
    } else if ([text isEqualToString:@"bottom"]) {
        return valignBottom;
    } else if ([text isEqualToString:@"distributed"]) {
        return valignDistributed;
    } else if ([text isEqualToString:@"below"]) {
        return valignBelow;
    } else if ([text isEqualToString:@"above"]) {
        return valignAbove;
    }
    
    return valignNone;
}

#pragma mark - AGColor

typedef struct AGColor {
    CGFloat r;
    CGFloat g;
    CGFloat b;
    CGFloat a;
} AGColor;

static inline AGColor AGColorClear(){
    AGColor v;
    v.r = 0.0f;
    v.g = 0.0f;
    v.b = 0.0f;
    v.a = 0.0f;
    return v;
}

static inline AGColor AGColorBlack(){
    AGColor v;
    v.r = 0.0f;
    v.g = 0.0f;
    v.b = 0.0f;
    v.a = 1.0f;
    return v;
}

static inline AGColor AGColorWithText(NSString *hex){
    if ([hex isEqualToString:AG_NONE]) {
        return AGColorClear();
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:hex ];
    unsigned color;
    [scanner scanHexInt:&color];
    
    if (hex.length == 8) {
        AGColor v;
        v.r = (((CGFloat)((color & 0xFF0000) >> 16)) / 255.0f);
        v.g = (((CGFloat)((color & 0xFF00) >>  8)) / 255.0f);
        v.b = (((CGFloat)(color & 0xFF)) / 255.0f);
        v.a = 1.0f;
        return v;
    } else if (hex.length == 10) {
        AGColor v;
        v.a = (((CGFloat)((color & 0xFF000000) >> 24)) / 255.0f);
        v.r = (((CGFloat)((color & 0xFF0000) >>  16)) / 255.0f);
        v.g = (((CGFloat)((color & 0xFF00) >> 8)) / 255.0f);
        v.b = (((CGFloat)(color & 0xFF)) / 255.0f);
        return v;
    }
    
    return AGColorClear();
}

static inline AGColor AGColorMake(CGFloat r, CGFloat g, CGFloat b, CGFloat a){
    AGColor v;
    v.r = r;
    v.g = g;
    v.b = b;
    v.a = a;
    return v;
}

static inline BOOL AGColorEqual(AGColor a, AGColor b){
    if (a.r != b.r) return NO;
    if (a.g != b.g) return NO;
    if (a.b != b.b) return NO;
    if (a.a != b.a) return NO;
    
    return YES;
}

#pragma mark - AGSize

typedef struct AGSize {
    NSInteger valueInUnits;
    AGUnitType units;
    CGFloat value;
    CGFloat integralValue;
} AGSize;

static inline AGSize AGSizeWithSize(AGSize size, CGFloat value){
    AGSize v;
    v.valueInUnits = size.valueInUnits;
    v.units = size.units;
    v.value = value;
    v.integralValue = 0;
    return v;
}

static inline AGSize AGSizeMake(NSInteger valueInUnits, AGUnitType units){
    AGSize v;
    v.valueInUnits = valueInUnits;
    v.units = units;
    v.value = 0;
    v.integralValue = 0;
    return v;
}

static inline AGSize AGSizeZero(){
    AGSize v;
    v.valueInUnits = 0;
    v.value = 0;
    v.units = unitKpx;
    v.integralValue = 0;
    return v;
}

static inline AGSize AGSizeWithText(NSString *text){
    AGSize v = AGSizeZero();
    
    if ([text hasSuffix:@"kpx"]) {
        v.valueInUnits = [[text substringToIndex:[text length]-3 ] intValue];
        v.units = unitKpx;
    } else if ([text hasSuffix:@"%"]) {
        v.valueInUnits = [[text substringToIndex:[text length]-1 ] intValue];
        v.units = unitPercentage;
    } else if ([text isEqualToString:@"min"]) {
        v.valueInUnits = 0;
        v.units = unitMin;
    } else if ([text isEqualToString:@"max"]) {
        v.valueInUnits = 0;
        v.units = unitMax;
    }
    
    return v;
}

#pragma mark - AGValidationType

typedef NS_ENUM (NSInteger, AGValidationRuleType) {
    validationRuleNone = 0,
    validationRuleRequired,
    validationRuleRegex,
    validationRuleSameAs,
    validationRuleLuhn,
    validationRuleValueRange,
    validationRuleIf,
    validationRuleJavaScript
};

static inline AGValidationRuleType AGValidationRuleTypeWithText(NSString *text){
    if ([text isEqualToString:@"REQUIRED"]) {
        return validationRuleRequired;
    } else if ([text isEqualToString:@"REGEX"]) {
        return validationRuleRegex;
    } else if ([text isEqualToString:@"SAME_AS"]) {
        return validationRuleSameAs;
    } else if ([text isEqualToString:@"LUHN_NUMBER"]) {
        return validationRuleLuhn;
    } else if ([text isEqualToString:@"VALUE_RANGE"]) {
        return validationRuleValueRange;
    } else if ([text isEqualToString:@"IF"]) {
        return validationRuleIf;
    } else if ([text isEqualToString:@"JAVASCRIPT"]) {
        return validationRuleJavaScript;
    }
    
    return validationRuleNone;
}

#endif
