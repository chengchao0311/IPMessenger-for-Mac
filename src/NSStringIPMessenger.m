/*============================================================================*
 * (C) 2001-2011 G.Ishiwata, All Rights Reserved.
 *
 *	Project		: IP Messenger for Mac OS X
 *	File		: NSStringIPMessenger.m
 *	Module		: NSStringカテゴリ拡張
 *============================================================================*/

#import "NSStringIPMessenger.h"
#import "DebugLog.h"

@implementation NSString(IPMessenger)

// IPMessenger用送受信文字列変換（C文字列→NSString)
+ (id)stringWithSJISString:(const char*)cString
{
	return [[[NSString alloc] initWithSJISString:cString] autorelease];
}

// IPMessenger用送受信文字列変換（C文字列→NSString)
- (id)initWithSJISString:(const char*)cString
{
    NSStringEncoding encoder;
    NSString *string = [self initWithCString:cString encoding:encoder=-2147482063];
    NSLog(@"string = %@", string);
	return string;
    
}

// IPMessenger用送受信文字列変換（NSString→C文字列)
- (const char*)SJISString
{
<<<<<<< HEAD
    NSStringEncoding encoder;
    encoder=-2147482063;
=======
>>>>>>> e2273de20342b81f29221e3fd09a2dfabb8f0755
	// SJISの場合、'¥'は'\'に変換しておかないと文字化けする
	NSString* str = [self stringByReplacingOccurrencesOfString:@"¥"
													withString:@"\\"];
	if (![str canBeConvertedToEncoding:NSShiftJISStringEncoding]) {
		// 変換できない文字がある場合は安全な方法で変換する
<<<<<<< HEAD
		NSData*			data1 = [str dataUsingEncoding:encoder
=======
		NSData*			data1 = [str dataUsingEncoding:NSShiftJISStringEncoding
>>>>>>> e2273de20342b81f29221e3fd09a2dfabb8f0755
								  allowLossyConversion:YES];
		NSMutableData*	data2 = [[data1 mutableCopy] autorelease];
		[data2 appendBytes:"\0" length:1];
		return (const char*)[data2 bytes];
	}
	// 変換できるならそのまま
<<<<<<< HEAD
	return [str cStringUsingEncoding:encoder];
=======
	return [str cStringUsingEncoding:NSShiftJISStringEncoding];
>>>>>>> e2273de20342b81f29221e3fd09a2dfabb8f0755
}

@end
