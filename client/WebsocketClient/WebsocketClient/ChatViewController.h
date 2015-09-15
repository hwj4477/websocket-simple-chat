//
//  ChatViewController.h
//  WebSocketTest
//
//  Created by wjhong on 2015. 9. 10..
//  Copyright (c) 2015년 wjhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatViewController : UIViewController

@property (copy) NSString *userName;
@property (copy) NSString *roomID;

- (IBAction)clickSend:(id)sender;
- (IBAction)clickReconnect:(id)sender;
- (IBAction)clickOut:(id)sender;

@end
