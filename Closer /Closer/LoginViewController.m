//
//  LoginViewController.m
//  Closer
//
//  Created by zhangkai on 16/3/10.
//  Copyright © 2016年 Closer_All. All rights reserved.
//

#import "LoginViewController.h"
#import <EaseMobSDKFull/EaseMob.h>
#import "RegisterViewController.h"
#import "LeanCloudTools.h"
#import <AVOSCloud/AVOSCloud.h>
#import "LHLoactionTool.h"
@interface LoginViewController ()<EMChatManagerLoginDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameText;
@property (weak, nonatomic) IBOutlet UIView *usernameLine;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@property (strong, nonatomic) IBOutlet UIView *passwordLine;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

- (IBAction)findLostPasswordButton:(UIButton *)sender;
- (IBAction)goRegisterButton:(UIButton *)sender;
- (IBAction)LoginButton:(UIButton *)sender;

@end

@implementation LoginViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addObserverOfTextField];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
-(void)loadViewIfNeeded{

}
-(void)addObserverOfTextField{
    NSNotificationCenter *notificationCenter=[NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(keyboardHidden:) name:UIKeyboardWillHideNotification object:nil];

}
-(void)keyboardHidden:(NSNotification*)notification{
    
    [UIView animateWithDuration:0.5 animations:^{
        self.view.frame=CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height);
    }];
}
-(void)keyboardShow:(NSNotification*)notification{
    
    CGRect rect=[[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] ;
    [UIView animateWithDuration:2 animations:^{
        self.view.frame=CGRectMake(0,-rect.size.height-40+HEIGHT-CGRectGetMaxY(self.loginButton.frame),self.view.bounds.size.width,self.view.bounds.size.height);
    }];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.usernameText resignFirstResponder];
    [self.passwordText resignFirstResponder];
    [UIView animateWithDuration:0.2 animations:^{
        self.view.frame=CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height);
    }];
}
#pragma mark - 找回密码
- (IBAction)findLostPasswordButton:(UIButton *)sender {
    
   
}
#pragma mark - 新用户
- (IBAction)goRegisterButton:(UIButton *)sender {
    RegisterViewController *registerViewController  = [[RegisterViewController alloc]init];
    [self presentViewController:registerViewController animated:YES completion:^{
    }];
}
#pragma mark - 登陆
- (IBAction)LoginButton:(UIButton *)sender {
    
    [self.usernameText resignFirstResponder];
    [self.passwordText resignFirstResponder];
    if (self.usernameText.text.length==0) {
           [self.usernameText becomeFirstResponder];
            [self alertMessage:@"用户名不能为空"];
            return;
    }
    if (self.passwordText.text.length==0) {
        [self.passwordText becomeFirstResponder];
        [self alertMessage:@"密码不能为空"];
        return;
    }
 
    TypeOfLeanCloud flag=  [LeanCloudTools loginUserWith:self.usernameText.text and:self.passwordText.text];
//
    if (flag==userLoginSuccess) {
        [self searObjectId];
        [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:self.usernameText.text password:self.passwordText.text completion:^(NSDictionary *loginInfo, EMError *error) {
            if (!error && loginInfo) {
                 [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
                 [LHLoactionTool shareLoction];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    NSLog(@"%f",[LHLoactionTool shareLoction].loction.coordinate.latitude);
                      [self saveaLoction:loginInfo];
                });
               
                [LHLoactionTool shareLoction].userName=_usernameText.text;
                [self alertMessage:@"登陆成功"];
                
                
            }
        } onQueue:nil];
    }else{
        [self alertMessage:@"登录失败"];
    }
}
-(void)alertMessage:(NSString*)message{
    UIAlertController *alertController=[UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alertController animated:YES completion:^{
        [self dismissViewControllerAnimated:YES completion:^{
            
            if ([message isEqualToString:@"登陆成功"]) {
                
                NSNotification *notification=[NSNotification notificationWithName:@"登陆成功" object:nil userInfo:nil ];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
            }
        }];
    }];
}



-(void)searObjectId{
    AVQuery *query = [AVQuery queryWithClassName:@"UserLoction"];
    [query whereKey:@"name" equalTo:self.usernameText.text];
    [query getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        [LHLoactionTool shareLoction].objectId=object.objectId;
        AVFile*file=object[@"icon"];
        NSData*data=[file getData];
        UIImage*image=[UIImage imageWithData:data];
        NSLog(@"%@",image);
        
        NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
        
        [user setValue:data forKey:@"icon"];
        
        
//        [LHLoactionTool shareLoction].icon=image;
    }];
}
-(void)saveaLoction:(NSDictionary*)loginInfo{
    
    AVGeoPoint*point=[AVGeoPoint geoPointWithLatitude:[LHLoactionTool shareLoction].loction.coordinate.latitude longitude:[LHLoactionTool shareLoction].loction.coordinate.longitude];
    NSLog(@"%f",[LHLoactionTool shareLoction].loction.coordinate.latitude);
           AVObject *post=[AVObject objectWithoutDataWithClassName:@"UserLoction" objectId:[LHLoactionTool shareLoction].objectId];
    
    
        [post setObject:loginInfo[@"username"] forKey:@"name"];
        [post setObject:point forKey:@"loction"];
        NSLog(@"%f",point.latitude);
        [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                
            }
        }];

}


//-(BOOL)textFieldShouldReturn:(UITextField *)textField{
//    
//    [textField resignFirstResponder];
//    
//    return YES;
//}


@end
