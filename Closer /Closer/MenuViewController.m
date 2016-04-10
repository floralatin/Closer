//
//  MenuViewController.m
//  Closer
//
//  Created by zhangkai on 16/3/14.
//  Copyright © 2016年 Closer_All. All rights reserved.
//

#import "MenuViewController.h"
#import "DisplayUserViewController.h"
#import "MessageViewController.h"
#import "PrepositionsViewController.h"
#import "LHNearbyViewController.h"
#import "LHLoactionTool.h"
#import <AVOSCloud/AVOSCloud.h>
@interface MenuViewController ()

@end

@implementation MenuViewController
//www.pan,baidu.com/s/2gryYZ1x 

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets=YES;
    [self addChildViewControllers];
   }
-(void)addChildViewControllers{
    
    [self addChildViewController: [[MessageViewController alloc]initWithNibName:@"MessageViewController" bundle:nil] andTitle:@"消息"];
    
    [self addChildViewController:   [[DisplayUserViewController alloc]initWithNibName:@"DisplayUserViewController" bundle:nil] andTitle:@"好友"];
//     [self addChildViewController:  [[PrepositionsViewController alloc]initWithNibName:@"PrepositionsViewController" bundle:nil] andTitle:@"周边"];
    LHNearbyViewController*nearbyVC=[[LHNearbyViewController alloc]init];
    [self addChildViewController:nearbyVC andTitle:@"周边"];
    
}
-(void)addChildViewController:(UIViewController *)childController andTitle:(NSString*)title{
    childController.title=title;
    UINavigationController *navgationController=[[UINavigationController alloc]initWithRootViewController:childController];
    
    UIBarButtonItem *leftbar=[[UIBarButtonItem alloc]initWithTitle:@"用户" style:UIBarButtonItemStyleDone target:self action:@selector(leftBarAction:)];
    childController.navigationItem.leftBarButtonItem=leftbar;
    [self addChildViewController:navgationController];
}
-(void)leftBarAction:(UIBarButtonItem*)barButtonItem{
    NSLog(@"用户");
      NSLog(@"用户MenuViewController=%p",self);
    if (self.delegate&&[self.delegate respondsToSelector:@selector(sliderAction)]) {
        
        [self.delegate sliderAction];
    }
    
    __weak typeof(self) weakSelf=self;
    if (self.delegate&&[self.delegate respondsToSelector:@selector(sendImageForslider:)]) {
    
        NSString*str=[LHLoactionTool shareLoction].userName;
        if (str==nil) {
            return;
        }
        
        AVQuery*query=[AVQuery queryWithClassName:@"UserLoction"];
        [query whereKey:@"name" equalTo:str];
        [query getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
            AVFile *file=object[@"icon"];
            NSData*imageData=[file getData];
            UIImage*image= [UIImage imageWithData:imageData];
            
            [weakSelf.delegate sendImageForslider:image];
        }];
        

    }
    
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
