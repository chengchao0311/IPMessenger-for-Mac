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
    
}


- (int)numberOfRowsInTableView:(NSTableView*)aTableView {
	return users.count;
}


- (id)tableView:(NSTableView*)aTableView
objectValueForTableColumn:(NSTableColumn*)aTableColumn
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
	[users sortUsingDescriptors:[tableView sortDescriptors]];
	[tableView reloadData];
	[tableView deselectAll:self];
}


- (void)doubleClick:(id)object {
    NSInteger rowIndex = [tableView clickedRow];
    UserInfo* info = [users objectAtIndex:rowIndex];
    [chatPanel setTitle:info.userName];
    [chatPanel setIsVisible:YES];
}






@end
