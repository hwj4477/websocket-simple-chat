//
//  Message.m
//  WebSocketTest
//
//  Created by wjhong on 2015. 9. 10..
//  Copyright (c) 2015년 wjhong. All rights reserved.
//

#import "Message.h"

@implementation Message

- (id)initWithUser:(NSString*)user
           message:(NSString*)message
{
    if((self = [super init]))
    {
        self.user = user;
        self.message = message;
    }
    
    return self;
}

@end
