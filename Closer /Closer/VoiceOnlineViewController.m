//
//  VoiceOnlineViewController.m
//  Closer
//
//  Created by zhangkai on 16/3/19.
//  Copyright © 2016年 Closer_All. All rights reserved.
//

#import "VoiceOnlineViewController.h"

@interface VoiceOnlineViewController ()<EMCallManagerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *reciveVutton;
@property (weak, nonatomic) IBOutlet UIButton *refuseButton;
- (IBAction)refuseButton:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property(nonatomic,strong)NSTimer  *timer;
- (IBAction)cancleButton:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *cancleButton;
@property(nonatomic)long  double time;
@end

@implementation VoiceOnlineViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [[ EaseMob sharedInstance].callManager addDelegate:self delegateQueue:nil];
     self.timer.fireDate=[NSDate distantPast];
    if (self.isMakeOut) {
        
        self.reciveVutton.hidden=YES;
        self.refuseButton.hidden=YES;
    }else{
        self.cancleButton.hidden=YES;
    }
}
-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
  }
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}
- (IBAction)refuseButton:(UIButton *)sender {
    [[EaseMob sharedInstance].callManager asyncEndCall:self.callSession.sessionId reason:eCallReasonReject];
    self.timer.fireDate=[NSDate distantFuture];
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}
- (IBAction)reciveButton:(UIButton *)sender {

    sender.selected=!sender.selected;
    if (sender) {
        [sender setTitle:@"结束" forState:UIControlStateNormal];
        EMError *error=nil;
        error=[[EaseMob sharedInstance].callManager asyncAnswerCall:self.callSession.sessionId];
        if (error) {
            
            NSLog(@"接受");
        }
        else {
            
        }
    }else{
        [sender setTitle:@"接受" forState:UIControlStateNormal];
        [[EaseMob sharedInstance].callManager asyncEndCall:self.callSession.sessionId reason:eCallReasonNull];
        self.timer.fireDate=[NSDate distantFuture];

    }
}
- (IBAction)cancleButton:(UIButton *)sender {
    [[EaseMob sharedInstance].callManager asyncEndCall:self.callSession.sessionId reason:eCallReason_Hangup];
    self.timer.fireDate=[NSDate distantFuture];
    [self dismissViewControllerAnimated:YES completion:^{
    }];
    
}
- (void)startTimer
{
    self.time ++;
    int hour = self.time/3600;
    int min = (self.time - hour * 3600)/60;
    int sec = self.time - hour* 3600 - min * 60;
    
    if (hour > 0) {
        _timeLabel.text = [NSString stringWithFormat:@"%i:%i:%i",hour,min,sec];
    }else if(min > 0){
        _timeLabel.text = [NSString stringWithFormat:@"%i:%i",min,sec];
    }else{
        _timeLabel.text = [NSString stringWithFormat:@"00:%i",sec];
    }
}

-(void)callSessionStatusChanged:(EMCallSession *)callSession changeReason:(EMCallStatusChangedReason)reason error:(EMError *)error{
    [self matchingReson:reason];
    
}
-(void)matchingReson:(EMCallStatusChangedReason)reason{
    switch (reason) {
        case eCallReasonNull:
            [ self alertMessage:@"正常挂断"];
              self.timer.fireDate=[NSDate distantFuture];
            break;
        case eCallReasonOffline:
            [ self alertMessage:@"对方不在线"];
            break;
        case eCallReasonNoResponse:
            [ self alertMessage:@"对方没有响应"];
            break;
        case eCallReasonHangup:
              self.timer.fireDate=[NSDate distantFuture];
            [ self alertMessage:@"对方挂断"];
            break;
        case eCallReasonReject:
              self.timer.fireDate=[NSDate distantFuture];
            [ self alertMessage:@"对方拒接"];
            
            break;
        case eCallReasonBusy:
            [ self alertMessage:@"对方忙碌"];
            break;
        case eCallReasonFailure:
            [ self alertMessage:@"连接失败"];
            break;
        default:
            break;
    }
}
-(void)alertMessage:(NSString*)message{
    UIAlertController *alertController=[UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alertController animated:YES completion:^{
        [self dismissViewControllerAnimated:YES completion:^{
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }];
    }];
}
-(NSTimer *)timer{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(startTimer) userInfo:nil repeats:YES];
    }
    return   _timer;
}

- (void)callSessionNetWorkStatusChanged:(EMCallSession *)callSession
                           changeReason:(EMCallStatusNetWorkChangedReason)reason
                                  error:(EMError *)error{
}
@end
