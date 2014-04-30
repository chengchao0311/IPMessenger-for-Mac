//
//  History.h
//  IPMessenger
//
//  Created by jiangziqi on 14-4-23.
//
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface History : NSObject<NSTableViewDataSource,NSTableViewDelegate> {
    NSWindow *window;
    NSTableView *userIP;
    NSTableView *messageLogging;
    NSMutableArray *users;
    NSTextFieldCell *userName;
    NSTextFieldCell *usersIP;
    NSPredicate *userPredicate;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTableView *userIP;
@property (assign) IBOutlet NSTableView *messageLogging;
@property (assign) NSMutableArray *users;
@property (assign) IBOutlet NSTextFieldCell *userName;
@property (assign) IBOutlet NSTextFieldCell *usersIP;
-(void)initWindow;
@end
