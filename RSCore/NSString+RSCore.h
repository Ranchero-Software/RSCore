//
//  NSString+RSCore.h
//  RSCore
//
//  Created by Brent Simmons on 3/25/15.
//  Copyright (c) 2015 Ranchero Software, LLC. All rights reserved.
//

@import Foundation;
@import CoreGraphics;

/// used but replaceable
BOOL RSStringIsEmpty(NSString * _Nullable s); /*Yes if null, NSNull, or length < 1*/

/// unused
BOOL RSEqualStrings(NSString * _Nullable s1, NSString * _Nullable s2); /*Equal if both are nil*/

NS_ASSUME_NONNULL_BEGIN

/// unused
NSString *RSStringReplaceAll(NSString *stringToSearch, NSString *searchFor, NSString *replaceWith); /*Literal search*/

@interface NSString (RSCore)


/*The hashed data is a UTF-8 encoded version of the string.*/

/// both used
- (NSData *)rs_md5HashData;
- (NSString *)rs_md5HashString;


/*Trims whitespace from leading and trailing ends. Collapses internal whitespace to single @" " character.
 Whitespace is space, tag, cr, and lf characters.*/

/// used
- (NSString *)rs_stringWithCollapsedWhitespace;

/// used
- (NSString *)rs_stringByTrimmingWhitespace;

/// used
- (BOOL)rs_stringMayBeURL;

/// unused
- (NSString *)rs_normalizedURLString; //Change feed: to http:, etc.

/*0.0f to 1.0f for each.*/
/// unused
typedef struct {
	CGFloat red;
	CGFloat green;
	CGFloat blue;
	CGFloat alpha;
} RSRGBAComponents;

/*red, green, blue components default to 1.0 if not specified.
 alpha defaults to 1.0 if not specified.*/
/// unused
- (RSRGBAComponents)rs_rgbaComponents;


/*If string doesn't have the prefix or suffix, it returns self. If prefix or suffix is nil or empty, returns self. If self and prefix or suffix are equal, returns @"".*/

/// used internally
- (NSString *)rs_stringByStrippingPrefix:(NSString *)prefix caseSensitive:(BOOL)caseSensitive;
/// unused
- (NSString *)rs_stringByStrippingSuffix:(NSString *)suffix caseSensitive:(BOOL)caseSensitive;

/// unused
- (NSString *)rs_stringByStrippingHTML:(NSUInteger)maxCharacters;
/// used
- (NSString *)rs_stringByConvertingToPlainText;

/*Filename from path, file URL string, or external URL string.*/

/// unused
- (NSString *)rs_filename;

/// used
- (BOOL)rs_caseInsensitiveContains:(NSString *)s;

/// used
- (NSString *)rs_stringByEscapingSpecialXMLCharacters;

/// unused except by rs_stringByPrependingNumberOfTabs
+ (NSString *)rs_stringWithNumberOfTabs:(NSInteger)numberOfTabs;
/// unused
- (NSString *)rs_stringByPrependingNumberOfTabs:(NSInteger)numberOfTabs;

// Remove leading http:// or https://

/// used
- (NSString *)rs_stringByStrippingHTTPOrHTTPSScheme;

/// unused but useful
+ (NSString *)rs_debugStringWithData:(NSData *)d; // Assume it’s UTF8, at least for now. Good enough for most debugging purposes.

@end

NS_ASSUME_NONNULL_END
