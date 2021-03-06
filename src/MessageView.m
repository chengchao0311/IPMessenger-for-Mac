//
//  MessageView.m
//  IPMessenger
//
//  Created by ZhanHongjin on 14-4-23.
//
//

#import "MessageView.h"
#import "AttachmentFile.h"
#import "Attachment.h"
#import "RecvMessage.h"
#import "DebugLog.h"
#import "AppControl.h"
#include <unistd.h>

@implementation MessageView
@synthesize pageLabel;
@synthesize editTextView;
@synthesize historyTextView;
@synthesize attachList;
@synthesize attachDrawer;
@synthesize hisrotyButtonAction;
@synthesize info;
@synthesize selfInfo;
@synthesize managedObjectContext;
@synthesize persistentStoreCoordinator;
@synthesize managedObjectModel;
@synthesize infos;
@synthesize attachs;
@synthesize cellNumber;
@synthesize sendedArray;
@synthesize pageNumber;
@synthesize historyCount;

#pragma mark - InitWindow

-(MessageView*)initWithUserInfo:(UserInfo*)user receiveMessage:(RecvMessage *)msg{
	// Nibファイルロード
	if (![NSBundle loadNibNamed:@"MessageWindow" owner:self]) {
        return nil;
	}
    
    //数据初始化
    cellNumber   = 0;
    pageNumber   = 0;
    historyCount = 0;
    
    selfInfo = [(AppControl*)[NSApp delegate] getSelfInfo];
    info = [user retain];
    if (msg) {
        recvMsg = [msg retain];
        //显示收到的消息
        NSDate * date = [[NSDate date] dateByAddingTimeInterval:3600*8];
        NSString * string = [NSString stringWithFormat:@"%@:(%@)\n %@",[msg fromUser].userName,[date.description substringToIndex:19],msg.appendix];
        [sendedArray addObject:string];
        [contentTableView reloadData];
        [contentTableView scrollRowToVisible:[sendedArray count]-1];
            if ([recvMsg.attachments count] > 0) {
                attachs = recvMsg.attachments;
                [attachDrawer openOnEdge:[attachDrawer preferredEdge]];
                if ([NSThread isMainThread]) {
                    attachTableViewDelegate = [[AttachTableViewDelegate alloc] init];
                    attachTableViewDelegate.attachArr = attachs;
                    [attachTable setDataSource:attachTableViewDelegate];
                    [attachTable setDelegate:attachTableViewDelegate];
                    [attachTable selectAll:self];
                }
            }
         [attachSaveButton setEnabled:YES];
    }
    


    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recvMessage:) name:@"RecvMessage" object:nil];
    [window setTitle:user.userName];
    [window makeKeyAndOrderFront:self];
    
    [self loadRecordWithNumber:4];
    return self;
}

-(void)showWindow{
     [window makeKeyAndOrderFront:self];
}

#pragma mark - ReceiveMessage(接收消息)
- (void)receiveMessage:(RecvMessage *)msg{
    UserInfo * info                   = [msg fromUser];
    NSDate * date                     = [[NSDate date] dateByAddingTimeInterval:3600*8];
    NSString * string                 = [NSString stringWithFormat:@"%@:(%@)\n %@",[msg fromUser].userName,[date.description substringToIndex:19],msg.appendix];
    [sendedArray addObject:string];
    [contentTableView reloadData];
    [contentTableView scrollRowToVisible:[sendedArray count]-1];
    recvMsg                           = [msg retain];
    if ([msg.attachments count] > 0) {
        //[attachDrawer open:self];
        [attachSaveButton setEnabled:YES];
    attachs                           = msg.attachments;

    attachTableViewDelegate           = [[AttachTableViewDelegate alloc] init];
    attachTableViewDelegate.attachArr = attachs;
        [attachDrawer openOnEdge:[attachDrawer preferredEdge]];
        [attachTable setDataSource:attachTableViewDelegate];
        [attachTable setDelegate:attachTableViewDelegate];
        [attachTable reloadData];
        [attachTable selectAll:self];
    }
    [self showWindow];
}

#pragma mark - SendMessage(发送消息)
- (IBAction)sendButtonAction:(id)sender {
    
    if ([[[editTextView textStorage] string] isEqualToString:@""]) {
        return;
    }
    
   SendMessage *	snedMessage;
	NSMutableArray*	to;
	NSString*		msg;
	BOOL			sealed;
	BOOL			locked;

	Config*			config = [Config sharedConfig];
    //	NSUInteger		index;
    
    // 送信情報整理
	msg		= [[editTextView textStorage] string];
	sealed	= NO;
	locked	= NO;
	to		= [[NSMutableArray alloc] init] ;
    [to addObject:info];
 
	// 送信情報構築
	snedMessage = [SendMessage messageWithMessage:msg
							   attachments:nil
									  seal:sealed
									  lock:locked];
	// メッセージ送信
	[[MessageCenter sharedCenter] sendMessage:snedMessage to:to];
	// ログ出力
	[[LogManager standardLog] writeSendLog:snedMessage to:to];
	// 受信ウィンドウ消去（初期設定かつ返信の場合）
    //	if (config.hideReceiveWindowOnReply) {
    //		ReceiveControl* receiveWin = [[WindowManager sharedManager] receiveWindowForKey:receiveMessage];
    //		if (receiveWin) {
    //			[[receiveWin window] performClose:self];
    //		}
    //	}
    NSDate * date = [[NSDate date] dateByAddingTimeInterval:3600*8];
    NSString * string = [NSString stringWithFormat:@"**%@:(%@)\n %@",[selfInfo userName],[date.description substringToIndex:19],[[editTextView textStorage]string]];
    [editTextView setString:@""];
    [sendedArray addObject:string];
    [contentTableView reloadData];
    [contentTableView scrollRowToVisible:[sendedArray count]-1];
    
}

#pragma mark - LoadHistoryRecord(历史记录)

- (IBAction)histotyAction:(id)sender {
    NSRect rect = window.frame;
    if (rect.size.width == 300) {
        pageNumber = 0;
        NSString * historyString = [self loadRecordWithNumber:50];
        [historyTextView setString:historyString];
        NSRange range;
        range = NSMakeRange ([[historyTextView string] length], 0);
        [historyTextView scrollRangeToVisible: range];
        rect.size.width = 600;
    }else{
        rect.size.width = 300;
    }
    
    [window setFrame:rect display:YES];
    
}



- (NSString *)loadRecordWithNumber:(int)historyNumber{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
    
    NSDate *now = [NSDate dateWithTimeIntervalSince1970:0];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:now];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *startOftoday = [calendar dateFromComponents:components];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(to = %@ OR from = %@) AND sendTime > %@", info.ipAddress, info.ipAddress, startOftoday];
    
    NSSortDescriptor *sortDesc = [[NSSortDescriptor alloc] initWithKey:@"sendTime" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDesc]];
    
    [fetchRequest setPredicate:pred];
    [fetchRequest setEntity:entity];
    if (historyNumber == 4) {
        [fetchRequest setFetchLimit:historyNumber];
    }
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    //获取历史记录长度
    historyCount = [fetchedObjects count];
    if (historyCount%50 > 0) {
        [pageLabel setStringValue:[NSString stringWithFormat:@"共%i页，当前第%i页",historyCount/50+1,historyCount/50+1-pageNumber]];
    }else{
        [pageLabel setStringValue:[NSString stringWithFormat:@"共%i页，当前第%i页",historyCount/50+1,historyCount/50-pageNumber]];
    }
    
    
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [historyTextView setString:@""];
    NSString * historyString = @"";
    BOOL isInit = NO;
    if (sendedArray == nil) {
        sendedArray = [[NSMutableArray alloc] init];
        isInit = YES;
    }
    int i;
    if ((pageNumber+1)*50>[fetchedObjects count]) {
        i = pageNumber*50 + [fetchedObjects count]%50 - 1;
    }else if((pageNumber+1)*50<[fetchedObjects count]) {
        i = (pageNumber+1)*50 - 1;
    }else if (historyNumber == 4){
        i = 4;
    }
    
    
    for (int j =1;i>=pageNumber*50&&j<=50;i--,j++) {
        Message *msg = [fetchedObjects objectAtIndex:i];
        NSString * oneHistory;
        if (![msg.to isEqualToString:@"self"]) {
            oneHistory = [NSString stringWithFormat:@"%@ : (%@)\n %@\n",selfInfo.userName, [dateFormater stringFromDate:msg.sendTime],msg.content];
        }else{
            oneHistory = [NSString stringWithFormat:@"%@ : (%@)\n %@\n",info.userName, [dateFormater stringFromDate:msg.sendTime],msg.content];
        }
        historyString = [historyString stringByAppendingString:oneHistory];
        
        if (isInit ) {
            NSString * str;
            if (![msg.to isEqualToString:@"self"]) {
                str = [NSString stringWithFormat:@"**%@ : (%@)\n %@",selfInfo.userName, [dateFormater stringFromDate:msg.sendTime],msg.content];
            }else{
                str = [NSString stringWithFormat:@"%@ : (%@)\n %@",info.userName, [dateFormater stringFromDate:msg.sendTime],msg.content];
            }
            
            [sendedArray addObject:str];
        }
    }
    
    [contentTableView reloadData];
    
    return historyString;
}

#pragma mark - Core Date
- (NSManagedObjectContext *) managedObjectContext {
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
    
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self  applicationDocumentsDirectory]
                                               stringByAppendingPathComponent: @"ipmessager3.sqlite"]];
    
    NSError *error = nil;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
    						 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
    						 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
        // Handle error
    }
    
    return persistentStoreCoordinator;
}
- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}



#pragma mark - accelerator key(快捷键)

- (BOOL)textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector{
    if (commandSelector == @selector(insertNewline:)) {
        [self sendButtonAction:nil];
        return YES;
    }else{
        return NO;
    }
}

#pragma mark - TableView
- (NSView *)tableView:(NSTableView *)atableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSTextField * text = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 270, 40)];
    text.font = [NSFont fontWithName:@"HelveticaNeue-Light" size:13.0];
    [text setTextColor:[NSColor blackColor]];
    [text setBezeled:NO];
    [text setEditable:NO];
    [text setSelectable:YES];
    NSString * string = [sendedArray objectAtIndex:row];
    if ([[string substringToIndex:2] isEqualToString:@"**"]) {
        [text setStringValue:[string substringFromIndex:2]];
        [text setTextColor:[NSColor blueColor]];
    }else{
        [text setStringValue:string];
    }
    
    return text;
}

- (CGFloat)tableView:(NSTableView *)atableView heightOfRow:(NSInteger)row{
    
        NSString * string = [sendedArray objectAtIndex:row];
        string = [string substringFromIndex:[string rangeOfString:@"\n"].location+[string rangeOfString:@"\n"].length];
        NSSize size = [string sizeWithAttributes:@{ NSFontAttributeName : [NSFont fontWithName:@"HelveticaNeue-Light" size:13.0] }];
        int line = size.width/270 + size.height/20;
        int x = size.width;
        if (x%270>0) {
            line++;
        }
        return line*20;
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)atableView{
        return [sendedArray count];
}

#pragma mark - 历史记录翻页
- (IBAction)leftTopAction:(id)sender {
    if ((pageNumber+1)*50<historyCount) {
        pageNumber = historyCount/50;
        if (historyCount%50 == 0) {
            pageNumber--;
        }
        [historyTextView setString:[self loadRecordWithNumber:50]];
    }
    
}

- (IBAction)leftAction:(id)sender {
    if ((pageNumber+1)*50<historyCount) {
        pageNumber++;
        [historyTextView setString:[self loadRecordWithNumber:50]];
    }
}

- (IBAction)rightAction:(id)sender {
    if (pageNumber > 0) {
        pageNumber--;
        [historyTextView setString:[self loadRecordWithNumber:50]];
    }
    
}

- (IBAction)rightTopAction:(id)sender {
    if (pageNumber > 0) {
        pageNumber = 0;
        [historyTextView setString:[self loadRecordWithNumber:50]];
    }
}
/*----------------------------------------------------------------------------*
 *文件下载
 *----------------------------------------------------------------------------*/
#pragma mark - 文件下载
- (IBAction)downloadBtnPress:(id)sender {
    NSOpenPanel* op = [NSOpenPanel openPanel];
    [attachSaveButton setEnabled:NO];
    [op setCanChooseFiles:NO];
    [op setCanChooseDirectories:YES];
    [op setPrompt:NSLocalizedString(@"RecvDlg.Attach.SelectBtn", nil)];
    [op beginSheetForDirectory:nil
                          file:nil
                modalForWindow:window
                 modalDelegate:self
                didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
                   contextInfo:sender];
}

- (void)downloadSheetRefresh:(NSTimer*)timer {
	if (attachSheetRefreshTitle) {
		unsigned num	= [downloader numberOfTargets];
		unsigned index	= [downloader indexOfTarget] + 1;
		NSString* title = [NSString stringWithFormat:NSLocalizedString(@"RecvDlg.AttachSheet.Title", nil), index, num];
		[attachSheetTitleLabel setStringValue:title];
		attachSheetRefreshTitle = NO;
	}
	if (attachSheetRefreshFileName) {
		[attachSheetFileNameLabel setStringValue:[downloader currentFile]];
		attachSheetRefreshFileName = NO;
	}
	if (attachSheetRefreshFileNum) {
		[attachSheetFileNumLabel setObjectValue:[NSNumber numberWithUnsignedInt:[downloader numberOfFile]]];
		attachSheetRefreshFileNum = NO;
	}
	if (attachSheetRefreshDirNum) {
		[attachSheetDirNumLabel setObjectValue:[NSNumber numberWithUnsignedInt:[downloader numberOfDirectory]]];
		attachSheetRefreshDirNum = NO;
	}
	if (attachSheetRefreshPercentage) {
		[attachSheetPercentageLabel setStringValue:[NSString stringWithFormat:@"%d %%", [downloader percentage]]];
		attachSheetRefreshPercentage = NO;
	}
	if (attachSheetRefreshSize) {
		double		downSize	= [downloader downloadSize];
		double		totalSize	= [downloader totalSize];
		NSString*	str			= nil;
		float		bps;
		if (totalSize < 1024) {
			str = [NSString stringWithFormat:@"%d / %d Bytes", (int)downSize, (int)totalSize];
		}
		if (!str) {
			downSize /= 1024.0;
			totalSize /= 1024.0;
			if (totalSize < 1024) {
				str = [NSString stringWithFormat:@"%.1f / %.1f KBytes", downSize, totalSize];
			}
		}
		if (!str) {
			downSize /= 1024.0;
			totalSize /= 1024.0;
			if (totalSize < 1024) {
				str = [NSString stringWithFormat:@"%.2f / %.2f MBytes", downSize, totalSize];
			}
		}
		if (!str) {
			downSize /= 1024.0;
			totalSize /= 1024.0;
			str = [NSString stringWithFormat:@"%.2f / %.2f GBytes", downSize, totalSize];
		}
		[attachSheetSizeLabel setStringValue:str];
		bps = ((float)[downloader averageSpeed] / 1024.0f);
		if (bps < 1024) {
			[attachSheetSpeedLabel setStringValue:[NSString stringWithFormat:@"%0.1f KBytes/sec", bps]];
		} else {
			bps /= 1024.0;
			[attachSheetSpeedLabel setStringValue:[NSString stringWithFormat:@"%0.2f MBytes/sec", bps]];
		}
		attachSheetRefreshSize = NO;
	}
}

- (void)downloadWillStart {
	[attachSheetTitleLabel setStringValue:NSLocalizedString(@"RecvDlg.AttachSheet.Start", nil)];
	[attachSheetFileNameLabel setStringValue:@""];
	attachSheetRefreshTitle			= NO;
	attachSheetRefreshFileName		= NO;
	attachSheetRefreshFileNum		= YES;
	attachSheetRefreshDirNum		= YES;
	attachSheetRefreshPercentage	= YES;
	attachSheetRefreshSize			= YES;
	[self downloadSheetRefresh:nil];
}

- (void)downloadDidFinished:(DownloadResult)result {
	[attachSheetTitleLabel setStringValue:NSLocalizedString(@"RecvDlg.AttachSheet.Finish", nil)];
	[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
	[NSApp endSheet:attachSheet returnCode:NSOKButton];
	if ((result != DL_SUCCESS) && (result != DL_STOP)) {
		NSString* msg = nil;
		switch (result) {
            case DL_TIMEOUT:				// 通信タイムアウト
                msg = NSLocalizedString(@"RecvDlg.DownloadError.TimeOut", nil);
                break;
            case DL_CONNECT_ERROR:			// 接続セラー
                msg = NSLocalizedString(@"RecvDlg.DownloadError.Connect", nil);
                break;
            case DL_DISCONNECTED:
                msg = NSLocalizedString(@"RecvDlg.DownloadError.Disconnected", nil);
                break;
            case DL_SOCKET_ERROR:			// ソケットエラー
                msg = NSLocalizedString(@"RecvDlg.DownloadError.Socket", nil);
                break;
            case DL_COMMUNICATION_ERROR:	// 送受信エラー
                msg = NSLocalizedString(@"RecvDlg.DownloadError.Communication", nil);
                break;
            case DL_FILE_OPEN_ERROR:		// ファイルオープンエラー
                msg = NSLocalizedString(@"RecvDlg.DownloadError.FileOpen", nil);
                break;
            case DL_INVALID_DATA:			// 異常データ受信
                msg = NSLocalizedString(@"RecvDlg.DownloadError.InvalidData", nil);
                break;
            case DL_INTERNAL_ERROR:			// 内部エラー
                msg = NSLocalizedString(@"RecvDlg.DownloadError.Internal", nil);
                break;
            case DL_SIZE_NOT_ENOUGH:		// ファイルサイズ以上
                msg = NSLocalizedString(@"RecvDlg.DownloadError.FileSize", nil);
                break;
            case DL_OTHER_ERROR:			// その他エラー
            default:
                msg = NSLocalizedString(@"RecvDlg.DownloadError.OtherError", nil);
                break;
		}
		NSBeginCriticalAlertSheet(	NSLocalizedString(@"RecvDlg.DownloadError.Title", nil),
                                  NSLocalizedString(@"RecvDlg.DownloadError.OK", nil),
                                  nil, nil, window, nil, nil, nil, nil, msg, result);
	}
}

- (void)downloadFileChanged {
	attachSheetRefreshFileName = YES;
}

- (void)downloadNumberOfFileChanged {
	attachSheetRefreshFileNum = YES;
}

- (void)downloadNumberOfDirectoryChanged {
	attachSheetRefreshDirNum = YES;
}

- (void)downloadIndexOfTargetChanged {
	attachSheetRefreshTitle	= YES;
}

- (void)downloadTotalSizeChanged {
	[attachSheetProgress setMaxValue:[downloader totalSize]];
	attachSheetRefreshSize = YES;
}

- (void)downloadDownloadedSizeChanged {
	[attachSheetProgress setDoubleValue:[downloader downloadSize]];
	attachSheetRefreshSize = YES;
}

- (void)downloadPercentageChanged {
	attachSheetRefreshPercentage = YES;
}

- (void)setAttachHeader {
	NSString*		format	= NSLocalizedString(@"RecvDlg.Attach.Header", nil);
	NSString*		title	= [NSString stringWithFormat:format, [[recvMsg attachments] count]];
	[[[attachTable tableColumnWithIdentifier:@"Attachment"] headerCell] setStringValue:title];
}


- (void)sheetDidEnd:(NSWindow*)sheet returnCode:(int)code contextInfo:(void*)aInfo {
	if (aInfo == attachSaveButton) {
		if (code == NSOKButton) {
			NSFileManager*	fileManager	= [NSFileManager defaultManager];
			NSString*		directory	= [(NSOpenPanel*)sheet directory];
			NSIndexSet*		indexes		= [attachTable selectedRowIndexes];
			NSUInteger index;
			[downloader release];
			downloader = [[AttachmentClient alloc] initWithRecvMessage:recvMsg saveTo:directory];
            index = [indexes firstIndex];
			while (index != NSNotFound) {
				NSString*	path;
				Attachment*	attach;
				attach = [[recvMsg attachments] objectAtIndex:index];
				if (!attach) {
					index = [indexes indexGreaterThanIndex:index];
					continue;
				}
				path = [directory stringByAppendingPathComponent:[[attach file] name]];
				// ファイル存在チェック
				if ([fileManager fileExistsAtPath:path]) {
					// 上書き確認
					int result;
					WRN(@"file exists(%@)", path);
					if ([[attach file] isDirectory]) {
						result = NSRunAlertPanel(	NSLocalizedString(@"RecvDlg.AttachDirOverwrite.Title", nil),
                                                 NSLocalizedString(@"RecvDlg.AttachDirOverwrite.Msg", nil),
                                                 NSLocalizedString(@"RecvDlg.AttachDirOverwrite.OK", nil),
                                                 NSLocalizedString(@"RecvDlg.AttachDirOverwrite.Cancel", nil),
                                                 nil,
                                                 [[attach file] name]);
					} else {
						result = NSRunAlertPanel(	NSLocalizedString(@"RecvDlg.AttachFileOverwrite.Title", nil),
                                                 NSLocalizedString(@"RecvDlg.AttachFileOverwrite.Msg", nil),
                                                 NSLocalizedString(@"RecvDlg.AttachFileOverwrite.OK", nil),
                                                 NSLocalizedString(@"RecvDlg.AttachFileOverwrite.Cancel", nil),
                                                 nil,
                                                 [[attach file] name]);
					}
					switch (result) {
                        case NSAlertDefaultReturn:
                            DBG(@"overwrite ok.");
                            break;
                        case NSAlertAlternateReturn:
                            DBG(@"overwrite canceled.");
                            [attachTable deselectRow:index];	// 選択解除
                            index = [indexes indexGreaterThanIndex:index];
                            continue;
                        default:
                            ERR(@"inernal error.");
                            break;
					}
				}
				[downloader addTarget:attach];
				index = [indexes indexGreaterThanIndex:index];
			}
			[sheet orderOut:self];
			if ([downloader numberOfTargets] == 0) {
				WRN(@"downloader has no targets");
				[downloader release];
				downloader = nil;
				return;
			}
			// ダウンロード準備（UI）
			[attachSaveButton setEnabled:NO];
			[attachTable setEnabled:NO];
			[attachSheetProgress setIndeterminate:NO];
			[attachSheetProgress setMaxValue:[downloader totalSize]];
			[attachSheetProgress setDoubleValue:0];
			// シート表示
			[NSApp beginSheet:attachSheet
			   modalForWindow:window
				modalDelegate:self
			   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
				  contextInfo:nil];
			// ダウンロード（スレッド）開始
			attachSheetRefreshTitle			= NO;
			attachSheetRefreshFileName		= NO;
			attachSheetRefreshPercentage	= NO;
			attachSheetRefreshFileNum		= NO;
			attachSheetRefreshDirNum		= NO;
			attachSheetRefreshSize			= NO;
			[downloader startDownload:self];
			attachSheetRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
																	   target:self
																	 selector:@selector(downloadSheetRefresh:)
																	 userInfo:nil
																	  repeats:YES];
		} else {
			[attachSaveButton setEnabled:([attachTable numberOfSelectedRows] > 0)];
		}
	} else if (sheet == attachSheet) {
		[attachSheetRefreshTimer invalidate];
		attachSheetRefreshTimer = nil;
		[recvMsg removeDownloadedAttachments];
		[sheet orderOut:self];
		[attachSaveButton setEnabled:([attachTable numberOfSelectedRows] > 0)];
		[attachTable reloadData];
		[self setAttachHeader];
		[attachTable setEnabled:YES];
		if ([[recvMsg attachments] count] <= 0) {
            //			[attachDrawer performSelectorOnMainThread:@selector(close:) withObject:self waitUntilDone:YES];
			[attachDrawer close];
			//[attachButton setEnabled:NO];
		}
		[downloader autorelease];
		downloader = nil;
	}
}

@end



