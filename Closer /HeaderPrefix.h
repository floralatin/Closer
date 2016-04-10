//
//  HeaderPrefix.h
//  Closer
//
//  Created by zhangkai on 16/3/14.
//  Copyright © 2016年 Closer_All. All rights reserved.
//

#ifndef HeaderPrefix_h
#define HeaderPrefix_h

//#ifdef DEBUG
//#define DGLog(...) NSLog(@"%s %d \n %@\n\n",__func__,__LINE__,__VA_ARGS__);
//#else
//#define DGLog(...)
//#endif
//
//#ifndef __OPTIMIZE__
//#define NSLog(...) NSLog(__VA_ARGS__)
//#else
//#define NSLog(...) {}
//#endif


#define WIDTH  [UIScreen mainScreen].bounds.size.width
#define  HEIGHT [UIScreen mainScreen].bounds.size.height


//写在 .h 文件中
#define singleton_interface(className) \
+ (className *)shared##className;


/// 写在.m文件中
#define singleton_implementation(className) \
static className *_instance = nil; \
+ (className *)shared##className \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [[[self class] alloc] init]; \
}); \
return _instance; \
} \
+ (id)allocWithZone:(NSZone *)zone \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [super allocWithZone:zone]; \
}); \
return _instance; \
} \

#endif /* HeaderPrefix_h */
