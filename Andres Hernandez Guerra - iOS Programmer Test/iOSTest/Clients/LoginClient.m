//
//  LoginClient.m
//  iOSTest
//
//  Created by D & A Technologies on 9/23/16.
//  Copyright © 2018 D & A Technologies. All rights reserved.
//

#import "LoginClient.h"

@interface LoginClient ()
@property (nonatomic, strong) NSURLSession *session;
@end

@implementation LoginClient

/**
 * =========================================================================================
 * INSTRUCTIONS
 * =========================================================================================
 * 1) Make a request here to login.
 *
 * 2) Using the following endpoint, make a request to login
 *    URL: http://dev.datechnologies.co/Tests/scripts/login.php
 *
 * 3) Don't forget, the endpoint takes two parameters 'username' and 'password'
 *
 * 4) A valid email is 'info@datechnologies.co'
 *    A valid password is 'Test123'
 **/

- (void)loginWithUsername:(NSString *)username password:(NSString *)password completion:(void (^)(NSDictionary *))completion
{
    
}

@end
