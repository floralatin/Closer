//
//  SliderViewController.h
//  Closer
//
//  Created by zhangkai on 16/3/15.
//  Copyright © 2016年 Closer_All. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol sendUserCancelInforDelegate <NSObject>

-(void)sendUserCancel;

@end

@interface SliderViewController : UIViewController

@property(nonatomic,weak)id<sendUserCancelInforDelegate>delegate;


@property (weak, nonatomic) IBOutlet UIButton *iconButton;




@end
