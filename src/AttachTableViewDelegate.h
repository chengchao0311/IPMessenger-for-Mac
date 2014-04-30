//
//  AttachTableViewDelegate.h
//  IPMessenger
//
//  Created by Huanghg on 14-4-28.
//
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface AttachTableViewDelegate : NSObject<NSTableViewDataSource, NSTableViewDelegate>{
    NSArray * attachArr;
}
@property(assign) NSArray * attachArr;
@end
