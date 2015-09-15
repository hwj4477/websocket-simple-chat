//
//  ChatViewController.m
//  WebSocketTest
//
//  Created by wjhong on 2015. 9. 10..
//  Copyright (c) 2015년 wjhong. All rights reserved.
//

#import "ChatViewController.h"
#import "SRWebSocket.h"
#import "Message.h"

@interface ChatViewController () <UITableViewDataSource, UITableViewDataSource, SRWebSocketDelegate> {
    
    NSMutableArray *messages;
    SRWebSocket *chatSocket;

    __weak IBOutlet UILabel *lblStatus;
    __weak IBOutlet UITableView *chatTableView;
    __weak IBOutlet UITextField *tfUser;
    __weak IBOutlet UITextField *tfMessage;
}

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    messages = [[NSMutableArray alloc] init];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    tfUser.text = self.userName;
    
    [self connectSocket];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    chatSocket.delegate = nil;
    [chatSocket close];
    chatSocket = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)connectSocket
{
    chatSocket.delegate = nil;
    [chatSocket close];
    
    chatSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"ws://localhost:8080?room_id=%@&user_name=%@", self.roomID, self.userName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
    chatSocket.delegate = self;
    
    [chatSocket open];
}

#pragma mark - WebSocket Delegate Function.
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding]
                                                         options:NSJSONReadingMutableContainers
                                                           error:nil];
    
    Message *msg = [[Message alloc] initWithUser:[json objectForKey:@"user"]
                                         message:[json objectForKey:@"message"]
                    ];
    
    [messages addObject:msg];
    
    [chatTableView reloadData];
    
    if (chatTableView.contentSize.height > chatTableView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, chatTableView.contentSize.height - chatTableView.frame.size.height);
        [chatTableView setContentOffset:offset animated:YES];
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    // connected
    lblStatus.text = [NSString stringWithFormat:@"Connected - %@", self.roomID];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@"failed : %@", [error description]);
    lblStatus.text = @"Disconnected - failed";
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    // Disconnected
    lblStatus.text = @"Disconnected";
}

#pragma mark - UITableView Delegate Function.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = NULL;
    
    Message *msg = [messages objectAtIndex:indexPath.row];
    
    if([msg.user isEqualToString:tfUser.text])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CELL_SEND" forIndexPath:indexPath];
        if (cell == NULL) cell = [tableView dequeueReusableCellWithIdentifier:@"CELL_SEND" forIndexPath:indexPath];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CELL_RECIVED" forIndexPath:indexPath];
        if (cell == NULL) cell = [tableView dequeueReusableCellWithIdentifier:@"CELL_RECIVED" forIndexPath:indexPath];
    }
    
    UILabel *lblMsg = (UILabel*)[cell viewWithTag:1];
    lblMsg.text = [NSString stringWithFormat:@"%@ : %@", msg.user, msg.message];
    
    return cell;
}

- (IBAction)clickSend:(id)sender
{
    if([tfUser.text length] > 0 && [tfMessage.text length] > 0)
    {
        NSDictionary *dicMsg = [NSDictionary dictionaryWithObjectsAndKeys: self.userName, @"user", tfMessage.text, @"message", nil];
        
        NSString *jsonMessage = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dicMsg options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
        
        [chatSocket send:jsonMessage];
        
        tfMessage.text = @"";
    }
}

- (IBAction)clickReconnect:(id)sender
{
    [self connectSocket];
}

- (IBAction)clickOut:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
