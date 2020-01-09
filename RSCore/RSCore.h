//
//  RSCore.h
//  RSCore
//
//  Created by Brent Simmons on 3/25/15.
//  Copyright (c) 2015 Ranchero Software, LLC. All rights reserved.
//

@import Foundation;

#import <RSCore/RSPlatform.h>


/*Foundation*/

#import <RSCore/NSCalendar+RSCore.h>
#import <RSCore/NSData+RSCore.h>
#import <RSCore/NSFileManager+RSCore.h>
#import <RSCore/NSString+RSCore.h>


#if !TARGET_OS_IPHONE

/*AppKit*/

#import <RSCore/NSPasteboard+RSCore.h>
#import <RSCore/NSTableView+RSCore.h>

#import <RSCore/NSAppleEventDescriptor+RSCore.h>
#import <RSCore/SendToBlogEditorApp.h>

#else

#import <UIKit/UIKit.h>

#endif
