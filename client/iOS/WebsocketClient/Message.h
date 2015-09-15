//
//  Message.h
//  WebSocketTest
//
//  Created by wjhong on 2015. 9. 10..
//  Copyright (c) 2015년 wjhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject

- (id)initWithUser:(NSString*)user
           message:(NSString*)message;

@property (copy) NSString* user;
@property (copy) NSString* message;

@end
