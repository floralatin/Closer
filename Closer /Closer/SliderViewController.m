//
//  SliderViewController.m
//  Closer
//
//  Created by zhangkai on 16/3/15.
//  Copyright © 2016年 Closer_All. All rights reserved.
//

#import "SliderViewController.h"
#import <EaseMobSDKFull/EaseMob.h>
#import "LoginViewController.h"
#import "ViewController.h"
#import <AVOSCloud/AVOSCloud.h>
#import "LHLoactionTool.h"
#import "SliderViewController.h"
#import "MenuViewController.h"
@interface SliderViewController ()<UIImagePickerControllerDelegate,MenuViewControllerDelegate>
- (IBAction)loginOut:(UIButton *)sender;




@end

@implementation SliderViewController

-(void)viewWillAppear:(BOOL)animated{
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
//    self.view .backgroundColor=[UIColor whiteColor];
    _iconButton.layer.masksToBounds=YES;
   
    

    }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}
- (IBAction)loginOut:(UIButton *)sender {
    
    if ([[EaseMob sharedInstance].chatManager isLoggedIn]) {
        NSLog(@"有用户登录");
    }
    [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:YES completion:^(NSDictionary *info, EMError *error) {
        if (!error && info) {
            
            [self alertMessage:@"退出成功"];
            

        }
        NSLog(@"%@",error);
        //代理传出注销信息；
        NSUserDefaults*user1=[NSUserDefaults standardUserDefaults];
        [user1 removeObjectForKey:@"icon"];
        [LHLoactionTool shareLoction].objectId=nil;
        [LHLoactionTool shareLoction].userName=nil;
        ViewController*vc=[[ViewController alloc]init];
        [self presentViewController:vc animated:YES completion:nil];
//        LoginViewController *vc=[[LoginViewController alloc]init];
//        [self presentViewController:vc animated:YES completion:nil];

    } onQueue:nil];
}



- (IBAction)iconButtonAction:(id)sender {
    
    
    
}




-(void)alertMessage:(NSString*)message{
    UIAlertController *alertController=[UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alertController animated:YES completion:^{
        
        [self dismissViewControllerAnimated:YES completion:^{
            
            if ([message isEqualToString:@"登陆成功"]) {
                NSLog(@"---------------------------登陆成功------------------------");
                NSNotification *notification=[NSNotification notificationWithName:@"登陆成功" object:nil userInfo:nil ];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
            }
        }];
    }];
}
@end
