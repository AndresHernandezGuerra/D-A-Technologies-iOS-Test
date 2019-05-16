//
//  ChatClient.h
//  iOSTest
//
//  Created by D & A Technologies on 9/23/16.
//  Copyright © 2018 D & A Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message.h"

@interface ChatClient : NSObject
- (void)fetchChatData:(void (^)(NSArray<Message *> *))completion withError:(void (^)(NSString *error))errorBlock;
@end
