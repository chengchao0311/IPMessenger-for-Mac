//
//  MemberListController.h
//  IPMessenger
//
//  Created by Xinqi Chan on 14-4-18.
//
//
#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

@interface MemberListController : NSObject<NSTableViewDataSource, NSTableViewDelegate> {
    NSWindow*               window;
    NSTableView*            tableView;
    NSMutableArray*         users;
    NSPanel *chatPanel;
    NSTextFieldCell *memberCountLabel;
    NSPredicate*			userPredicate;
    NSMutableArray * messageViewArray;
    NSTextView *sendedTextView;
    NSTextView *editingTextView;

}
@property (assign) IBOutlet NSTableView *tableView;
@property (assign) IBOutlet NSWindow *window;
@property (assign) NSMutableArray *users;
@property (assign) IBOutlet NSPanel *chatPanel;
@property (assign) IBOutlet NSTextView *sendedTextView;
@property (assign) IBOutlet NSTextView *editingTextView;
@property (assign) IBOutlet NSTextFieldCell *memberCountLabel;

- (IBAction)refrechMemberListAction:(id)sender;

-(void)initWindow;

@property (nonatomic,strong)NSMutableArray * messageViewArray;

@end
