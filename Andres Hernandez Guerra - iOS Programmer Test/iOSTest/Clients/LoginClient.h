//
//  LoginClient.h
//  iOSTest
//
//  Created by D & A Technologies on 9/23/16.
//  Copyright © 2018 D & A Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginClient : NSObject
- (void)loginWithUsername:(NSString *)username password:(NSString *)password completion:(void (^)(NSDictionary *))completion;
@end
