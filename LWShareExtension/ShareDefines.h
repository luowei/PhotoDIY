//
//  ShareDefines.h
//  LWMKShareExtention
//
//  Created by luowei on 2018/1/25.
//  Copyright © 2018年 wodedata. All rights reserved.
//

#ifndef ShareDefines_h
#define ShareDefines_h

#ifdef DEBUG
#define Log(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define Log(format, ...)
#endif

#define weakify(var) __weak typeof(var) weak_##var = var;

#define strongify(var) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
__strong typeof(var) var = weak_##var; \
_Pragma("clang diagnostic pop")


#define Share_Group @"group.com.wodedata.photodiy"
#define Share_Scheme @"PhotoDIY"
#define Key_SharedText @"Key_SharedText"


#endif /* ShareDefines_h */
