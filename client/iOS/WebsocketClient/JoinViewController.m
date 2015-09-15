//
//  JoinViewController.m
//  WebSocketTest
//
//  Created by wjhong on 2015. 9. 11..
//  Copyright (c) 2015년 wjhong. All rights reserved.
//

#import "JoinViewController.h"
#import "ChatViewController.h"

#define SEG_ID_CONNECT  @"REQUEST_CONNECT"

@interface JoinViewController () {
    
    __weak IBOutlet UITextField *tfName;
    __weak IBOutlet UITextField *tfRoomID;
    
}

@end

@implementation JoinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.destinationViewController isKindOfClass:[ChatViewController class]])
    {
        ChatViewController *viewController = (ChatViewController*)segue.destinationViewController;
        viewController.userName = tfName.text;
        viewController.roomID = tfRoomID.text;
    }
}

- (IBAction)clickConnect:(id)sender
{
    if([tfName.text length] > 0 && [tfRoomID.text length] > 0)
    {
        [self performSegueWithIdentifier:SEG_ID_CONNECT sender:self];
    }
}
@end
