// analitics
#define ANALYTICS_APP_TRACKING_ID @"INSERT YOUR GOOGLE ANALYTICS TRACKING ID HERE"

// pusher
#define PUSHER_URL @"http://push.funandmobile.com/api/register"
#define PUSHER_ID @""

// variables
#define AG_MIN_IMAGE_SIZE 32
#define AG_MAX_IMAGE_SIZE 2048
#define AG_TEXT_PADDING 1.0
#define AG_MAX_SCREENS_HISTORY 10
#define AG_TIME_OUT 30
#define AG_FONT_NAME @"roboto"
#define AG_KPX_SCALE 0.001
#define AG_XML [AGXMLHelper sharedInstance].xmlDocument.rootElement
#define AG_MAX_PHOTO_SIZE CGSizeMake(1024, 1024)
#define AG_PIN_SIZE @"150kpx"
#define AG_NONE @"_NONE_"
#define AG_LOADING_SIZE [AGLAYOUTMANAGER KPXToPixels:AG_LOADING_INDICATOR_SIZE]
#define AG_PULL_TO_REFRESH_FONT_SIZE [AGLAYOUTMANAGER KPXToPixels:60]
#define AG_ERROR_INDICATOR_SIZE 500
#define AG_LOADING_INDICATOR_SIZE 150
#define AG_ERROR_IMAGE [AGIMAGECACHE imageForKey:FILE_PATH_BUNDLE(@"error.png")]
#define AG_LOADING_IMAGE [AGIMAGECACHE imageForKey:FILE_PATH_BUNDLE(@"loading.png")]
#define AG_GALLERY_DETAIL_PADDING 0
#define AG_IMAGE_SCALE [UIScreen mainScreen].scale
#define AG_FB_APP_ID @"INSERT YOUR FACEBOOK APP ID HERE"
#define AG_FB_APP_SECRET @"INSERT YOUR FACEBOOK APP SECRET HERE"
#define AG_TWITTER_APP_KEY @"INSERT YOUR TWITTER APP KEY HERE"
#define AG_TWITTER_APP_SECRET @"INSERT YOUR TWITTER APP SECRET HERE"
#define AG_LINKEDIN_APP_KEY @"INSERT YOUR LINKEDIN APP KEY HERE"
#define AG_LINKEDIN_APP_SECRET @"INSERT YOUR LINKEDIN APP SECRET HERE"

// file path
#define FILE_PATH_TEMP(filename) [NSTemporaryDirectory() stringByAppendingPathComponent:filename]
#define FILE_PATH_CACHE(filename) [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:filename]
#define FILE_PATH_DOCUMENT(filename) [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:filename]
#define FILE_PATH_LIBRARY(filename) [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:filename]
#define FILE_PATH_BUNDLE(filename) [[NSBundle bundleForClass:[self class]].bundlePath stringByAppendingPathComponent:filename]
