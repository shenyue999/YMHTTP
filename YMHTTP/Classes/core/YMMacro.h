//
//  YMMacro.h
//  YMHTTP
//
//  Created by zymxxxs on 2020/1/3.
//

#import <Foundation/Foundation.h>
#import "curl.h"

#ifndef YMMacro_h
#define YMMacro_h

#ifndef YY_WEAKIFY
#if DEBUG
#if __has_feature(objc_arc)
#define YY_WEAKIFY(object) \
    autoreleasepool {}     \
    __weak __typeof__(object) weak##_##object = object;
#else
#define YY_WEAKIFY(object) \
    autoreleasepool {}     \
    __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define YY_WEAKIFY(object) \
    try {                  \
    } @finally {           \
    }                      \
    {}                     \
    __weak __typeof__(object) weak##_##object = object;
#else
#define YY_WEAKIFY(object) \
    try {                  \
    } @finally {           \
    }                      \
    {}                     \
    __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef YY_STRONGIFY
#if DEBUG
#if __has_feature(objc_arc)
#define YY_STRONGIFY(object) \
    autoreleasepool {}       \
    __typeof__(object) object = weak##_##object;
#else
#define YY_STRONGIFY(object) \
    autoreleasepool {}       \
    __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define YY_STRONGIFY(object) \
    try {                    \
    } @finally {             \
    }                        \
    __typeof__(object) object = weak##_##object;
#else
#define YY_STRONGIFY(object) \
    try {                    \
    } @finally {             \
    }                        \
    __typeof__(object) object = block##_##object;
#endif
#endif
#endif

#define YM_DEFER   \
    EXT_KEYWORDIFY \
    __strong ym_deferBlock_t ym_deferBlock_##__LINE__ __attribute__((cleanup(ym_deferFunc), unused)) = ^

#if defined(DEBUG)
#define EXT_KEYWORDIFY \
    autoreleasepool {}
#else
#define EXT_KEYWORDIFY \
    try {              \
    } @catch (...) {   \
    }
#endif
typedef void (^ym_deferBlock_t)(void);
NS_INLINE void ym_deferFunc(__strong ym_deferBlock_t *blockRef) { (*blockRef)(); }

#ifndef YM_ECODE
#define YM_ECODE(c) ym_handleEasyCode(c)
#endif

#ifndef YM_MCODE
#define YM_MCODE(c) ym_handleMultiCode(c)
#endif

NS_INLINE void ym_initializeLibcurl() {
    // TODO: throws
    curl_global_init(CURL_GLOBAL_SSL);
}

NS_INLINE void ym_handleEasyCode(int code) {
    if (code == CURLE_OK) return;
    NSString *reason = [NSString stringWithFormat:@"An error occurred, CURLcode is %@", @(code)];
    NSException *e = [NSException exceptionWithName:@"libcurl.easy" reason:reason userInfo:nil];
    @throw e;
}

NS_INLINE void ym_handleMultiCode(int code) {
    if (code == CURLM_OK) return;
    NSString *reason = [NSString stringWithFormat:@"An error occurred, CURLMcode is %@", @(code)];
    NSException *e = [NSException exceptionWithName:@"libcurl.multi" reason:reason userInfo:nil];
    @throw e;
}

#endif /* YMMacro_h */
