#import "UIDevice+Hardware.h"
#import <sys/utsname.h>

@implementation UIDevice (Hardware)

/*-(NSString*) getModel{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *model = malloc(size);
    sysctlbyname("hw.machine", model, &size, NULL, 0);
    NSString *deviceModel = [NSString stringWithCString:model encoding:NSUTF8StringEncoding];
    free(model);
    return deviceModel;
   }*/

- (NSString *)deviceUuid {
    NSString *deviceUuid = [self valueForKeychainKey:@"deviceUuid" service:@"deviceUuid"];

    // backwards compatibility for e.g. push notifications
    if (!deviceUuid) {
        deviceUuid = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceUuid"];
    }

    if (!deviceUuid) {
        CFUUIDRef uuidObj = CFUUIDCreate(NULL);
        CFStringRef cfUuid = CFUUIDCreateString(NULL, uuidObj);
        deviceUuid = [NSString stringWithString:(NSString *)cfUuid];

        [self setValue:deviceUuid forKeychainKey:@"deviceUuid" inService:@"deviceUuid"];

        CFRelease(cfUuid);
        CFRelease(uuidObj);
    }

    return deviceUuid;
}

- (NSMutableDictionary *)keychainItemForKey:(NSString *)key service:(NSString *)service {
    NSMutableDictionary *keychainItem = [NSMutableDictionary dictionary];

    keychainItem[(id)kSecClass] = (id)kSecClassGenericPassword;
    keychainItem[(id)kSecAttrAccessible] = (id)kSecAttrAccessibleAlways;
    keychainItem[(id)kSecAttrAccount] = key;
    keychainItem[(id)kSecAttrService] = service;

    return keychainItem;
}

- (OSStatus)setValue:(NSString *)value forKeychainKey:(NSString *)key inService:(NSString *)service {
    NSMutableDictionary *keychainItem = [self keychainItemForKey:key service:service];
    keychainItem[(id)kSecValueData] = [value dataUsingEncoding:NSUTF8StringEncoding];

    return SecItemAdd((CFDictionaryRef)keychainItem, NULL);
}

- (NSString *)valueForKeychainKey:(NSString *)key service:(NSString *)service {
    OSStatus status;
    NSMutableDictionary *keychainItem = [self keychainItemForKey:key service:service];
    keychainItem[(id)kSecReturnData] = (id)kCFBooleanTrue;
    keychainItem[(id)kSecReturnAttributes] = (id)kCFBooleanTrue;

    CFDictionaryRef result = nil;
    status = SecItemCopyMatching((CFDictionaryRef)keychainItem, (CFTypeRef *)&result);
    if (status != noErr) {
        return nil;
    }

    NSDictionary *resultDict = (NSDictionary *)result;
    NSData *data = resultDict[(id)kSecValueData];

    if (!data) {
        return nil;
    }

    return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
}

- (NSString *)hardwareString {
    struct utsname systemInfo;
    uname(&systemInfo);

    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

- (NSString *)hardwareDescription {
    NSDictionary *devices = @{
        @"iPhone1,1": @"iPhone 2G",
        @"iPhone1,2": @"iPhone 3G",
        @"iPhone2,1": @"iPhone 3GS",
        @"iPhone3,1": @"iPhone 4",
        @"iPhone3,2": @"iPhone 4",
        @"iPhone3,3": @"iPhone 4",
        @"iPhone4,1": @"iPhone 4S",
        @"iPhone5,1": @"iPhone 5",
        @"iPhone5,2": @"iPhone 5",
        @"iPhone5,3": @"iPhone 5c",
        @"iPhone5,4": @"iPhone 5c",
        @"iPhone6,1": @"iPhone 5s",
        @"iPhone6,2": @"iPhone 5s",
        @"iPhone7,1": @"iPhone 6 Plus",
        @"iPhone7,2": @"iPhone 6",
        @"iPhone8,1": @"iPhone 6s",
        @"iPhone8,2": @"iPhone 6s Plus",

        @"iPod1,1": @"iPod Touch (1 Gen)",
        @"iPod2,1": @"iPod Touch (2 Gen)",
        @"iPod3,1": @"iPod Touch (3 Gen)",
        @"iPod4,1": @"iPod Touch (4 Gen)",
        @"iPod5,1": @"iPod Touch (5 Gen)",
        @"iPod7,1": @"iPod Touch (6 Gen)",

        @"iPad1,1": @"iPad (WiFi)",
        @"iPad1,2": @"iPad 3G",
        @"iPad2,1": @"iPad 2 (WiFi)",
        @"iPad2,2": @"iPad 2 (GSM)",
        @"iPad2,3": @"iPad 2 (CDMA)",
        @"iPad2,4": @"iPad 2 (WiFi)",
        @"iPad2,5": @"iPad Mini (WiFi)",
        @"iPad2,6": @"iPad Mini (GSM)",
        @"iPad2,7": @"iPad Mini (CDMA)",
        @"iPad3,1": @"iPad 3 (WiFi)",
        @"iPad3,2": @"iPad 3 (CDMA)",
        @"iPad3,3": @"iPad 3 (Global)",
        @"iPad3,4": @"iPad 4 (WiFi)",
        @"iPad3,5": @"iPad 4 (CDMA)",
        @"iPad3,6": @"iPad 4 (Global)",
        @"iPad4,1": @"iPad Air (WiFi)",
        @"iPad4,2": @"iPad Air (WiFi+GSM)",
        @"iPad4,3": @"iPad Air (WiFi+CDMA)",
        @"iPad4,4": @"iPad Mini Retina (WiFi)",
        @"iPad4,5": @"iPad Mini Retina (WiFi+CDMA)",
        @"iPad4,6": @"iPad Mini Retina (Wi-Fi + Cellular CN)",
        @"iPad4,7": @"iPad Mini 3 (Wi-Fi)",
        @"iPad4,8": @"iPad Mini 3 (Wi-Fi + Cellular)",
        @"iPad4,9": @"iPad mini 3 (Wi-Fi/Cellular, China)",
        @"iPad5,1": @"iPad mini 4 (Wi-Fi Only)",
        @"iPad5,2": @"iPad mini 4 (Wi-Fi/Cellular)",
        @"iPad5,3": @"iPad Air 2 (Wi-Fi)",
        @"iPad5,4": @"iPad Air 2 (Wi-Fi + Cellular)",
        @"iPad6,7": @"iPad Pro (Wi-Fi Only)",
        @"iPad6,8": @"iPad Pro (Wi-Fi/Cellular)",

        @"i386": @"Simulator",
        @"x86_64": @"Simulator"
    };

    return devices[ [self hardwareString] ];
}

@end
