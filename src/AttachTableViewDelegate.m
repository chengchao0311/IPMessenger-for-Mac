//
//  AttachTableViewDelegate.m
//  IPMessenger
//
//  Created by Huanghg on 14-4-28.
//
//

#import "AttachTableViewDelegate.h"
#import "Attachment.h"
#import "AttachmentFile.h"
@implementation AttachTableViewDelegate
@synthesize attachArr;

- (id)tableView:(NSTableView *)atableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
		NSString* iden = [tableColumn identifier];
        if ([iden isEqualToString:@"Attachment"]) {
            Attachment *attach = [attachArr objectAtIndex:row];
            return attach.file.name;
		}
    return nil;

}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)atableView{
    return attachArr.count;
}

@end
