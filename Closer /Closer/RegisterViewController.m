//
//  RegisterViewController.m
//  Closer
//
//  Created by zhangkai on 16/3/10.
//  Copyright © 2016年 Closer_All. All rights reserved.
//

#import "RegisterViewController.h"
#import <EaseMobSDKFull/EaseMob.h>
#import "LeanCloudTools.h"

#import <AVOSCloud/AVOSCloud.h>

@interface RegisterViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameText;
@property (weak, nonatomic) IBOutlet UIView *usernameLine;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@property (weak, nonatomic) IBOutlet UIView *passwordLine;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

- (IBAction)registerButton:(UIButton *)sender;
- (IBAction)backButton:(UIButton *)sender;


//

@property (weak, nonatomic) IBOutlet UIButton *iconButton;
@property(nonatomic,strong)UIImagePickerController*pickController;
@property(nonatomic,strong)UIImage*icon;





@end

@implementation RegisterViewController

- (void)viewDidLoad {
    
        [super viewDidLoad];
     self.registerButton.enabled=NO;
    [self.usernameText addTarget:self action:@selector(requestVerifyUsername:) forControlEvents:UIControlEventEditingDidEnd];
    [self.usernameText addTarget:self action:@selector(beganAction:) forControlEvents:UIControlEventEditingDidBegin];
    [self addObserverOfTextField];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
-(void)beganAction:(UITextField*)textField{
    
    self.registerButton.enabled=NO;
}
-(void)requestVerifyUsername:(UITextField*)textFeild{
    TypeOfLeanCloud  flag=[LeanCloudTools  queryWithUsername:self.usernameText.text];
    if (flag==userIsExistedError) {
        [textFeild becomeFirstResponder];
        [self alertMessage:@"用户存在"];
        return;
    }else{
        self.registerButton.enabled=YES;
    }
}
-(void)addObserverOfTextField{
    
    NSNotificationCenter *notificationCenter=[NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(keyboardHidden:) name:UIKeyboardWillHideNotification object:nil];
}
-(void)keyboardShow:(NSNotification*)notification{
    
    CGRect rect=[[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] ;
    [UIView animateWithDuration:0.5 animations:^{
        self.view.frame=CGRectMake(0,-rect.size.height-40+HEIGHT-CGRectGetMaxY(self.registerButton.frame),self.view.bounds.size.width,self.view.bounds.size.height);
    }];
}
-(void)keyboardHidden:(NSNotification*)notification{
    
    [UIView animateWithDuration:0.5 animations:^{
        self.view.frame=CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height);
    }];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.usernameText resignFirstResponder];
        [self.passwordText resignFirstResponder];
        self.view.frame=CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height);
    }];
}
#pragma mark 注册
- (IBAction)registerButton:(UIButton *)sender {
    
    TypeOfLeanCloud  flag=[LeanCloudTools registerUserWith:self.usernameText.text and:self.passwordText.text];
    if (flag==userRegisterError) {
        [self alertMessage:@"注册失败"];
        return;
        
    }else if (flag==userRegisterSuccess){
        
        [[EaseMob sharedInstance].chatManager asyncRegisterNewAccount:self.usernameText.text password:self.passwordText.text  withCompletion:^(NSString *username, NSString *password, EMError *error) {
            if (!error) {
                [self.view endEditing:YES];
                [self alertMessage:@"注册成功"];
                
                [self setUserIconWithName:username];
            }
        } onQueue:nil];
    }
    else{
        [self alertMessage:@"注册失败"];
    }
}
#pragma mark 返回
- (IBAction)backButton:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
-(void)alertMessage:(NSString*)message{
    UIAlertController *alertController=[UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alertController animated:YES completion:^{
        [self dismissViewControllerAnimated:YES completion:^{
            if ([message isEqualToString:@"注册成功"]) {
                [self dismissViewControllerAnimated:YES completion:^{
                    
                }];
            }
            
        }];
    }];
}





-(void)setUserIconWithName:(NSString*)uername{
    
    NSData*imageData=UIImagePNGRepresentation(_icon);
    AVFile*file=[AVFile fileWithData:imageData];
    AVObject*userOB=[[AVObject alloc]initWithClassName:@"UserLoction"];
    [userOB setObject:uername forKey:@"name"];
    [userOB setObject:file forKey:@"icon"];
    [userOB saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    
        if (succeeded) {
            NSLog(@"存入图片成功");
            
        }
    }];
    
    
    
    
    
}

- (IBAction)iconButtonAction:(id)sender {
    
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        _pickController=[[UIImagePickerController alloc]init];
        _pickController.allowsEditing=YES;
        _pickController.delegate=self;
        [self presentViewController:_pickController animated:YES completion:^{
            
        }];

    
    
}
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    _icon=[info objectForKey:UIImagePickerControllerEditedImage];
//    [_iconButton setImage:_icon forState:(UIControlStateNormal)];
    [_iconButton setBackgroundImage:_icon forState:(UIControlStateNormal)];
//    [picker dismissViewControllerAnimated:YES completion:nil];
    [picker dismissViewControllerAnimated:YES completion:^{}];
    
}


-(void)viewWillAppear:(BOOL)animated{
    
    _iconButton.layer.cornerRadius=70;
    _iconButton.layer.masksToBounds=YES;
}


@end
