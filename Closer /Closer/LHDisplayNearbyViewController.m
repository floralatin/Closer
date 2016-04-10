//
//  LHDisplayNearbyViewController.m
//  mpp
//
//  Created by 李辉 on 16/3/14.
//  Copyright © 2016年 李辉. All rights reserved.
//

#import "LHDisplayNearbyViewController.h"
#import <EaseMob.h>
#import "ChatViewController.h"
#import "LHnearbyTool.h"

@interface LHDisplayNearbyViewController ()

//@property (weak, nonatomic) IBOutlet UIImageView *imv;
//@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
//
//@property (weak, nonatomic) IBOutlet UILabel *disataceLabel;

@property (weak, nonatomic) IBOutlet UIImageView *icon;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@property (weak, nonatomic) IBOutlet UILabel *loction;
@property(nonatomic,strong)UITextField*sendMessage;

@end

@implementation LHDisplayNearbyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _icon.layer.masksToBounds=YES;
    _nameLabel.text=self.model.name;
    NSLog(@"%@",_model.name);
    _distanceLabel.text=[LHnearbyTool ReturnDistace:_model.distance];
    NSLog(@"%@",_distanceLabel);
    _icon.image=self.model.icon;
    // Do any additional setup after loading the view from its nib.
    NSLog(@"%@",_nameLabel.text);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sayHi:(id)sender {
//    [self sendMessageText];
//    
//    [self sendMessage];
//    if ([_sendMessage.text isEqual:@""]||_sendMessage.text==nil) {
//        return;
//    }
//    EMChatText *txtChat = [[EMChatText alloc] initWithText:_sendMessage.text];
//    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithChatObject:txtChat];
//    
//    // 生成message
//    EMMessage *message = [[EMMessage alloc] initWithReceiver:_model.name bodies:@[body]];
//    message.messageType = eMessageTypeChat; // 设置为单聊消息
//    
//    [_sendMessage removeFromSuperview];
    
    ChatViewController*chatVC=[[ChatViewController alloc]initWithChatter:_model.name isGroup:NO];
    [self.navigationController pushViewController:chatVC animated:YES];

}


- (IBAction)addFriend:(id)sender {
    
    NSString*str=[NSString stringWithFormat:@"添加%@为好友",_model.name];
    UIAlertController*alertVC=[UIAlertController alertControllerWithTitle:_model.name message:str preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction*cancel=[UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction*ensure=[UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        EMError*error=nil;
      BOOL isSuccess=  [[EaseMob sharedInstance].chatManager addBuddy:_model.name message:@"想加你为好友" error:&error];
        if (isSuccess&&!error) {
            
            
        }
        
        
    }];
    
    [alertVC addAction:ensure];
    [alertVC addAction:cancel];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

-(void)sendMessageText{
    
    _sendMessage=[[UITextField alloc]initWithFrame:CGRectMake(200, 200, 200, 30)];
    _sendMessage.borderStyle=UITextBorderStyleRoundedRect;
    _sendMessage.placeholder=@"输入想说的话";
    _sendMessage.backgroundColor=[UIColor redColor];
    _sendMessage.backgroundColor=[UIColor colorWithRed:0.6 green:0.1 blue:0.2 alpha:0.2];
    [self.view addSubview:_sendMessage];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
