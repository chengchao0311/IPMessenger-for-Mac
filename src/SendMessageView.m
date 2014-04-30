/*============================================================================*
 * (C) 2001-2011 G.Ishiwata, All Rights Reserved.
 *
 *	Project		: IP Messenger for Mac OS X
 *	File		: SendMessageView.m
 *	Module		: 送信メッセージ表示View
 *============================================================================*/

#import "SendMessageView.h"
#import "AttachmentServer.h"
#import "SendControl.h"
#import "DebugLog.h"
#import "Attachment.h"
#import "AttachmentFile.h"
#import "SendMessage.h"
#import "MessageCenter.h"
#import "LogManager.h"
#import "MessageView.h"


@implementation SendMessageView

- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	if (self) {
		[self setRichText:NO];
		duringDragging = NO;
		// ファイルのドラッグを受け付ける
		if ([AttachmentServer isAvailable]) {
			[self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
		}
	}
	return self;
}

/*----------------------------------------------------------------------------*
 * ファイルドロップ処理（添付ファイル）
 *----------------------------------------------------------------------------*/

- (unsigned int)draggingEntered:(id <NSDraggingInfo>)sender
{
    NSLog(@"draggingEntered");
}

- (unsigned int)draggingUpdated:(id <NSDraggingInfo>)sender
{
    NSLog(@"draggingUpdated");
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    NSLog(@"draggingExited");
}

- (void)drawRect:(NSRect)aRect
{
	[super drawRect:aRect];
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
	return [AttachmentServer isAvailable];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	return [AttachmentServer isAvailable];
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
	NSPasteboard* 	pBoard	= [sender draggingPasteboard];
	NSArray*		files	= [pBoard propertyListForType:NSFilenamesPboardType];
	id				control	= [[self window] delegate];
	for (id file in files) {
		[control appendAttachmentByPath:file];
	}
	duringDragging = NO;
	[self setNeedsDisplay:YES];
}

@end
