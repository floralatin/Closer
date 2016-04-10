//
//  MenuViewController.h
//  Closer
//
//  Created by zhangkai on 16/3/14.
//  Copyright © 2016年 Closer_All. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MenuViewControllerDelegate <NSObject>

-(void)sliderAction;
-(void)sendImageForslider:(UIImage*)image;

@end

@interface MenuViewController : UITabBarController

@property(nonatomic,weak,nullable)id <MenuViewControllerDelegate>  delegate;

@end
