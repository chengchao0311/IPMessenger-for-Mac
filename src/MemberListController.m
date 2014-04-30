//
//  MemberListController.m
//  IPMessenger
//
//  Created by Xinqi Chan on 14-4-18.
//
//

#import "MemberListController.h"
#import "UserManager.h"
#import "UserInfo.h"
#import "RecvMessage.h"
#import "SendMessage.h"
#import "Config.h"
#import "MessageCenter.h"
#import "LogManager.h"
#import "WindowManager.h"
#import "MessageView.h"
#import "PrefControl.h"

//NSString* const kIPMsgUserInfoUserNamePropertyIdentifier	= @"UserName";
//NSString* const kIPMsgUserInfoGroupNamePropertyIdentifier	= @"GroupName";
//NSString* const kIPMsgUserInfoHostNamePropertyIdentifier	= @"HostName";
//NSString* const kIPMsgUserInfoLogOnNamePropertyIdentifier	= @"LogOnName";
//NSString* const kIPMsgUserInfoVersionPropertyIdentifer		= @"Version";
//NSString* const kIPMsgUserInfoIPAddressPropertyIdentifier	= @"IPAddress";

@implementation MemberListController
@synthesize tableView;
@synthesize window;
@synthesize users;
@synthesize chatPanel;
@synthesize memberCountLabel;
@synthesize messageViewArray;
@synthesize sendedTextView;
@synthesize editingTextView;


#pragma mark - InitWindow

- (IBAction)refrechMemberListAction:(id)sender {
    [[UserManager sharedManager] removeAllUsers];
    [[MessageCenter sharedCenter] broadcastEntry];
    users = [[[UserManager sharedManager] users] mutableCopy];
    [tableView reloadData];
    
    
}

-(void)initWindow{
    
	// Nibファイルロード
	if (![NSBundle loadNibNamed:@"MemeberListWindow" owner:self]) {
        return nil;
	}
    
    users = [[[UserManager sharedManager] users] mutableCopy];
    [window setTitle:@"在线列表"];
    [tableView setDataSource:self];
    [tableView setDelegate:self];
    
    [tableView setDoubleAction:@selector(doubleClick:)];
    [chatPanel setIsVisible:NO];
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
		   selector:@selector(userListChanged:)
			   name:NOTICE_USER_LIST_CHANGED
			 object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recvMessage:) name:@"RecvMessage" object:nil];
    messageViewArray = [[NSMutableArray alloc] init];
    [memberCountLabel setStringValue:[NSString stringWithFormat:@"Memeber Count : %i/%i",[users count],[users count]]];
}


#pragma mark - TableView

- (int)numberOfRowsInTableView:(NSTableView*)aTableView {
	return users.count;
}


- (id)tableView:(NSTableView*)aTableView objectValueForTableColumn:(NSTableColumn*)aTableColumn
            row:(int)rowIndex {
	if (aTableView == tableView) {
		UserInfo* info = [users objectAtIndex:rowIndex];
		NSString* iden = [aTableColumn identifier];
		if ([iden isEqualToString:@"UserName"]) {
			return info.userName;
		} else if ([iden isEqualToString:@"IPAddress"]) {
			return info.ipAddress;
		} else {
		}
        
	}
    
    return nil;
}

// ソートの変更
- (void)tableView:(NSTableView *)aTableView sortDescriptorsDidChange:(NSArray *)oldDescriptors {
	[users sortUsingDescriptors:[aTableView sortDescriptors]];
	[aTableView reloadData];
}


// ユーザ一覧変更時処理
- (void)userListChanged:(NSNotification*)aNotification
{
	[users setArray:[[UserManager sharedManager] users]];
	NSInteger totalNum = [users count];
	if (userPredicate) {
		[users filterUsingPredicate:userPredicate];
	}
	[users sortUsingDescriptors:[tableView sortDescriptors]];
	[tableView reloadData];
	[tableView deselectAll:self];
    [memberCountLabel setStringValue:[NSString stringWithFormat:@"Memeber Count : %i/%i",[users count],[users count]]];
}


- (void)doubleClick:(id)object {
    NSInteger rowIndex = [tableView clickedRow];
    UserInfo* info = [users objectAtIndex:rowIndex];
    //显示聊天窗口, 如果存在,如果不存在
    BOOL isExist = NO;
    for (int i = 0; i<[messageViewArray count]; i++) {
        MessageView * msgView = [messageViewArray objectAtIndex:i];
        UserInfo *user = msgView.info;
        if ([user.ipAddress isEqualToString:info.ipAddress]) {
            [msgView showWindow];
            isExist = YES;
            break;
        }
    }
    if (!isExist) {
        MessageView *msgView = [[MessageView alloc] initWithUserInfo:info receiveMessage:nil];
        [messageViewArray addObject:msgView];
    }
    
}


#pragma mark - ReceiveMessage(接收消息)

- (void)recvMessage:(NSNotification *)notification{
    RecvMessage * msg = [notification object];
    UserInfo *info = [msg fromUser];
    BOOL isExist = NO;
    for (int i = 0; i<[messageViewArray count]; i++) {
        MessageView * msgView = [messageViewArray objectAtIndex:i];
        if ([msgView.info.ipAddress isEqualToString:info.ipAddress]) {
            isExist = YES;
           // [msgView.window makeKeyAndOrderFront:msgView];
            [msgView receiveMessage:msg];
        }
    }
    if (!isExist) {
        MessageView * msgView = [[MessageView alloc] initWithUserInfo:info receiveMessage:msg];
        [messageViewArray addObject:msgView];
    }
    
    //存消息
    NSManagedObjectContext *context = [[NSApp delegate] managedObjectContext];
    NSManagedObjectContext *message = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:context];
    [message setValue:@"self" forKey:@"to"];
    [message setValue:msg.fromUser.ipAddress forKey:@"from"];
    [message setValue:[NSDate date] forKey:@"sendTime"];
    [message setValue:msg.appendix forKey:@"content"];
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    
}


@end
