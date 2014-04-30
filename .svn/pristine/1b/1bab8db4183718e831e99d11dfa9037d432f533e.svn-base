//
//  History.m
//  IPMessenger
//
//  Created by jiangziqi on 14-4-23.
//
//

#import "History.h"
#import "UserManager.h"
#import "UserInfo.h"
#import "RecvMessage.h"
#import "SendMessage.h"
#import "Config.h"
#import "MessageCenter.h"
#import "LogManager.h"
#import "WindowManager.h"

@implementation History
@synthesize window;
@synthesize userIP;
@synthesize messageLogging;
@synthesize users;
@synthesize userName;
@synthesize usersIP;

- (void)initWindow {
    // Nibファイルロード
	if (![NSBundle loadNibNamed:@"Histroy" owner:self]) {
        return nil;
	}
    users = [[[UserManager sharedManager] users] mutableCopy];
    [window setTitle:@"聊天记录"];
    [userIP setDataSource:self];
    [userIP setDelegate:self];
    [messageLogging setDataSource:self];
    [messageLogging setDelegate:self];
    
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
		   selector:@selector(userListChanged:)
			   name:NOTICE_USER_LIST_CHANGED
			 object:nil];
    
}
- (int)numberOfRowsInTableView:(NSTableView*)aTableView {
	return users.count;
}
- (id)tableView:(NSTableView*)aTableView objectValueForTableColumn:(NSTableColumn*)aTableColumn
            row:(int)rowIndex {
	if (aTableView == userIP) {
		UserInfo* info = [users objectAtIndex:rowIndex];
		NSString* iden = [aTableColumn identifier];
		if ([iden isEqualToString:@"UserName"]) {
			return info.userName;
		} else if ([iden isEqualToString:@"IPAddress"]) {
			return info.ipAddress;
		} else{
		}
	} 	return nil;
    
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
	[users sortUsingDescriptors:[userIP sortDescriptors]];
	[userIP  reloadData];
	[userIP deselectAll:self];
}



@end
