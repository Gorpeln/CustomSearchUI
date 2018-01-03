


/**
 颜色相关
 */
#pragma mark -颜色相关

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define RANDOMCOLOR  [UIColor colorWithRed:arc4random()%256/255.0 green:arc4random()%256/255.0 blue:arc4random()%256/255.0 alpha:1];


/**
 设备屏幕大小
 */
#define BOUNDS              ([UIScreen mainScreen].bounds)
#define BOUNDS_WIDTH        [UIScreen mainScreen].bounds.size.width
#define BOUNDS_HEIGHT       [UIScreen mainScreen].bounds.size.height
#define BOUNDS_X            [UIScreen mainScreen].bounds.origin.x
#define BOUNDS_Y            [UIScreen mainScreen].bounds.origin.y

#define SCREENSCALE         BOUNDS_WIDTH / 375.0
#define BORDORWIDTH         7.5 * SCREENSCALE

//适配iPhone X
#define IS_IPHONEX              ((int)BOUNDS_HEIGHT % 812 == 0)
#define STATUSBARHEIGHT         (BOUNDS_HEIGHT == 812.0 ? 44 : 20)
#define NAVBARHEIGHT            44
#define TABBARHEIGHT            49
#define SAFEAREATOPHEIGHT       (BOUNDS_HEIGHT == 812.0 ? 88 : 64)
#define SAFEAREABOTOOMHEIGHT    (BOUNDS_HEIGHT == 812.0 ? 34 : 0)
#define SAFEAREAHEIGHT          BOUNDS_HEIGHT  - SAFEAREABOTOOMHEIGHT
#define SAFEAREAHEIGHT_TABLEVIEW          BOUNDS_HEIGHT - SAFEAREATOPHEIGHT - SAFEAREABOTOOMHEIGHT
#define SAFEAREAHEIGHT_TABLEVIEW_TABBAR   BOUNDS_HEIGHT - SAFEAREATOPHEIGHT - SAFEAREABOTOOMHEIGHT - TABBARHEIGHT


/**
 字体
 */
#define FONT(fontSize)          [UIFont systemFontOfSize:fontSize]
#define FONTOFHEITISC(fontSize) [UIFont fontWithName:@"Heiti SC" size:fontSize]

#define AdaptedWidth(x)         (x) * SCREENSCALE
#define CHINESE_SYSTEM(x)       [UIFont fontWithName:@"Heiti SC" size:x]
#define FONTADAPTED(fontSize)   CHINESE_SYSTEM(AdaptedWidth(fontSize))


/**
  调试输出
 */
#pragma mark -打印设置

#define DEBUGLOG 1

#ifdef DEBUGLOG
#       define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#       define DLog(...)
#endif

/**
 是否为空  字符串  数组  字典
 */
#define IsStrEmpty(_ref)    (((_ref) == nil) || ([(_ref) isEqual:[NSNull null]]) ||([(_ref)isEqualToString:@""]))

#define IsArrEmpty(_ref)    (((_ref) == nil) || ([(_ref) isEqual:[NSNull null]]) ||([(_ref) count] == 0))

#define IsDictEmpty(_ref) (_ref == nil || [_ref isKindOfClass:[NSNull class]] || _ref.allKeys == 0)


/**
 使图片圆角
 */
#pragma mark - 使图片圆角
#define ROUNDCORNER(imageView,roundCorner)  (imageView).layer.masksToBounds = YES; (imageView).layer.cornerRadius = roundCorner

/**
 正则表达
 */
#pragma mark - 正则表达
//判断邮箱是否规则
#define IsValidEmail(email)\
[[NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"\\b([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})\\b"] evaluateWithObject:email]
//判断电话号码是否规则
#define IsValidPhoneNum(phoneNum)\
[[NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^((13[0-9])|(15[^4,\\D])|(18[0-9]))\\d{8}$"] evaluateWithObject:[NSString stringWithFormat:@"%@",phoneNum]]
//判断用户名是否规则
#define IsValidUserName(userName)\
[[NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^[a-zA-Z][a-zA-Z0-9_]{1,17}$"] evaluateWithObject:userName]
//判断用户密码是否规则
#define IsValidUserPwd(pwd)\
[[NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^(\\w){6,20}$"] evaluateWithObject:pwd]

/**
 单例
 */
/******* 单例的声明和实现方法 *****/
#define DECLARE_SINGLETON(CLASS_NAME) \
+ (CLASS_NAME *)sharedInstance;


#define SYNTHESIZE_SINGLETONE_FOR_CLASS(CLASS_NAME) \
+ (CLASS_NAME *)sharedInstance\
{\
static CLASS_NAME *__##CLASS_NAME##_instance = nil;\
\
static dispatch_once_t onceToken;\
dispatch_once(&onceToken, ^{\
__##CLASS_NAME##_instance = [[CLASS_NAME alloc] init];\
});\
return __##CLASS_NAME##_instance;\
}








