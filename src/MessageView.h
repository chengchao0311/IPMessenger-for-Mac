//
//  MessageView.h
//  IPMessenger
//
//  Created by ZhanHongjin on 14-4-23.
//
//
#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "RecvMessage.h"
#import "SendMessageView.h"
#import "SendMessage.h"
#import "UserInfo.h"
#import "Config.h"
#import "MessageCenter.h"
#import "LogManager.h"
#import "Message.h"
#import "AttachmentClient.h"
#import "AttachTableViewDelegate.h"

@interface MessageView : NSObject<AttachmentClientListener ,NSTextViewDelegate,NSTableViewDataSource,NSTableViewDelegate>{
    NSTextView *editTextView;
    NSTextView *historyTextView;
    
    NSView *attachList;
    NSDrawer *attachDrawer;
    NSMutableArray *infos;
    UserInfo * info;
    UserInfo * selfInfo;
    NSArray *attachs;
    
    IBOutlet NSWindow *window;
    IBOutlet NSTableView *attachTable;
    IBOutlet NSPanel *attachSheet;
    IBOutlet NSTextField *attachSheetTitleLabel;
    IBOutlet NSTextField *attachSheetFileNameLabel;
    IBOutlet NSProgressIndicator *attachSheetProgress;
    IBOutlet NSTextField *attachSheetPercentageLabel;
    IBOutlet NSTextField *attachSheetFileNumLabel;
    IBOutlet NSTextField *attachSheetSpeedLabel;
    IBOutlet NSTextField *attachSheetSizeLabel;
    IBOutlet NSTextField *attachSheetDirNumLabel;
    IBOutlet NSButton *attachSheetCancelButton;
    IBOutlet NSButton *attachSaveButton;
    IBOutlet NSTableView *contentTableView;
    
    AttachmentClient*				downloader;
    RecvMessage*					recvMsg;
    AttachTableViewDelegate*        attachTableViewDelegate;
    
    NSTimer*						attachSheetRefreshTimer;	// ダウンロードシート更新タイマ
	BOOL							attachSheetRefreshFileName;	// ダウンロードシード更新フラグ
	BOOL							attachSheetRefreshPercentage;
	BOOL							attachSheetRefreshTitle;
	BOOL							attachSheetRefreshFileNum;
	BOOL							attachSheetRefreshDirNum;
	BOOL							attachSheetRefreshSize;

    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSButtonCell *hisrotyButtonAction;
    NSInteger cellNumber;
    NSMutableArray * sendedArray;

    NSInteger pageNumber;
    NSInteger historyCount;
    NSTextField *pageLabel;
}
@property (assign) NSArray *attachs;
@property (assign) IBOutlet NSTextView *editTextView;
@property (assign) IBOutlet NSTextView *historyTextView;
@property (assign) IBOutlet NSView *attachList;
@property (assign) IBOutlet NSDrawer *attachDrawer;
@property (assign) IBOutlet NSButtonCell *hisrotyButtonAction;
@property (nonatomic,strong)UserInfo * info;
@property (nonatomic,strong)UserInfo * selfInfo;
@property (nonatomic,assign)NSInteger cellNumber;
@property (nonatomic,strong)NSMutableArray * sendedArray;
@property (assign) NSMutableArray *infos;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic,assign)NSInteger pageNumber;
@property (nonatomic,assign)NSInteger historyCount;

- (MessageView*)initWithUserInfo:(UserInfo*)user receiveMessage:(RecvMessage *)msg;
- (IBAction)sendButtonAction:(id)sender;
- (IBAction)histotyAction:(id)sender;
- (void)receiveMessage:(RecvMessage *)msg;
- (NSString *)loadRecordWithNumber:(int)historyNumber;
- (IBAction)downloadBtnPress:(id)sender;
- (IBAction)leftTopAction:(id)sender;
- (IBAction)leftAction:(id)sender;
- (IBAction)rightAction:(id)sender;
- (IBAction)rightTopAction:(id)sender;
- (void)showWindow;

@property (assign) IBOutlet NSTextField *pageLabel;
@end
