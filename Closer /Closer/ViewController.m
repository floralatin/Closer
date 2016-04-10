//
//  ViewController.m
//  Closer
//
//  Created by zhangkai on 16/3/10.
//  Copyright © 2016年 Closer_All. All rights reserved.
//

#import "ViewController.h"
#import "SliderViewController.h"
#import "MenuViewController.h"
#import <EaseMobSDKFull/EaseMob.h>
#import "LoginViewController.h"
#import "LHLoactionTool.h"
@interface ViewController ()<MenuViewControllerDelegate>

@property(nonatomic,strong)MenuViewController  *menuController;
@property(nonatomic,strong)SliderViewController  *sliderController;
@property(nonatomic,assign)BOOL  isShowing;

@end

@implementation ViewController


-(void)viewWillAppear:(BOOL)animated{
    
//    [self.sliderController.iconButton setBackgroundImage:[LHLoactionTool shareLoction].icon forState:(UIControlStateNormal)];
    
}
- (void)viewDidLoad {
 
  
    [super viewDidLoad];
    _isShowing=NO;
    [self addControllers];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccessAction) name:@"登陆成功" object:nil];
    [self addGesture];
    
    [self addIcon];
    
}
-(void)addIcon{
    
    NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
    NSData*data=   [user valueForKey:@"icon"];
    UIImage*image=[UIImage imageWithData:data];
    
    [self.sliderController.iconButton setBackgroundImage:image forState:(UIControlStateNormal)];
    

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"登陆成功" object:nil];
}
-(void)loginSuccessAction{
    [UIView animateWithDuration:0.5 animations:^{
        [self.view.subviews.lastObject removeFromSuperview];
    }];
}

-(void)addControllers{
   self.menuController=  [[MenuViewController alloc] init];
    self.sliderController=   [[SliderViewController alloc] initWithNibName:@"SliderViewController" bundle:nil];

    NSLog(@"self.menuController==%p",self.menuController);
    self.menuController.delegate=self;
    [self addChildViewController:self.menuController];
    [self addChildViewController:self.sliderController];
    self.sliderController.view.frame=self.view.frame;
    [self.view  addSubview:self.sliderController.view];
    self.menuController.view.layer.shadowOffset=CGSizeMake(-5, 0);
    self.menuController.view.layer.shadowColor=[UIColor blackColor].CGColor;
    self.menuController.view.layer.shadowOpacity=0.8;
    self.menuController.view.layer.shadowRadius=5;
    [self.view addSubview:self.menuController.view];
    
    if(![[EaseMob sharedInstance].chatManager loginInfo]) {

        LoginViewController *loginController=[[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
        loginController.view.frame=self.view.bounds;
        [self addChildViewController:loginController];
        [self.view addSubview:loginController.view];
    }

}
-(void)addGesture{
    UISwipeGestureRecognizer *leftSwip=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenSlider:)];
    [leftSwip setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:leftSwip];
    UISwipeGestureRecognizer *rightSwip=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(showSlider:)];
    [rightSwip setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:rightSwip];
    
//    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
//    [self.menuController.view addGestureRecognizer:tap];
}
-(void)tapAction{
    if (!_isShowing) {
        return;
    }
    [self hiddenSlider:nil];
}
-(void)hiddenSlider:(UIGestureRecognizer*)Gesture{
   
    [UIView animateWithDuration:0.5 animations:^{
        [self.menuController.view setFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
        _isShowing=NO;
        self.menuController.view.userInteractionEnabled=YES;
    }];

}
-(void)showSlider:(UIGestureRecognizer*)Gesture{
    [UIView animateWithDuration:0.5 animations:^{
          [self.menuController.view setFrame:CGRectMake(WIDTH/6*5, 0, WIDTH, HEIGHT)];
        _isShowing=YES;
        self.menuController.view.userInteractionEnabled=NO;
    }];
}
-(void)sliderAction{
    if (_isShowing) {
        return;
    }
    [self showSlider:nil];
}


//代理方法加载头像
-(void)sendImageForslider:(UIImage *)image{
    
    
    [self.sliderController.iconButton setBackgroundImage:image forState:(UIControlStateNormal)];
    NSLog(@"%@",image);
    
    
}




//代理方法；
//-(void)sendUserCancel{
//    
//    [self addControllers];
//    
//    
//}

@end
