//
//  Message.h
//  IPMessenger
//
//  Created by Huanghg on 14-4-21.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * from;
@property (nonatomic, retain) NSString * to;
@property (nonatomic, retain) NSDate * sendTime;
@property (nonatomic, retain) NSString * content;

@end
