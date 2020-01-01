//
//  RSCore.h
//  RSCore
//
//  Created by Brent Simmons on 3/25/15.
//  Copyright (c) 2015 Ranchero Software, LLC. All rights reserved.
//

@import Foundation;

#import <RSCore/RSBlocks.h>
#import <RSCore/RSPlatform.h>


/*Foundation*/

#import <RSCore/NSCalendar+RSCore.h>
#import <RSCore/NSData+RSCore.h>
#import <RSCore/NSFileManager+RSCore.h>
#import <RSCore/NSString+RSCore.h>


#if !TARGET_OS_IPHONE

/*AppKit*/

#import <RSCore/NSColor+RSCore.h>
#import <RSCore/NSEvent+RSCore.h>
#import <RSCore/NSPasteboard+RSCore.h>
#import <RSCore/NSStoryboard+RSCore.h>
#import <RSCore/NSTableView+RSCore.h>
#import <RSCore/NSView+RSCore.h>

#import <RSCore/NSImage+RSCore.h>

#import <RSCore/RSGeometry.h>

#import <RSCore/NSAppleEventDescriptor+RSCore.h>
#import <RSCore/SendToBlogEditorApp.h>

#import <RSCore/NSAttributedString+RSCore.h>
#endif


/*Images*/

#import <RSCore/RSImageRenderer.h>
#import <RSCore/RSScaling.h>


/*Text*/

#import <RSCore/RSMacroProcessor.h>

