//
//  CameraViewController.h
//  Closer
//
//  Created by zhangkai on 16/3/17.
//  Copyright © 2016年 Closer_All. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CameraViewControllerDelegate <NSObject>

-(void)sendImage:(UIImage*)image;

@end



@interface CameraViewController : UIViewController
@property(nonatomic,weak)id <CameraViewControllerDelegate>  delegate;
@end
