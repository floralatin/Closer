//
//  LHVideoViewController.h
//  Closer
//
//  Created by 李辉 on 16/3/21.
//  Copyright © 2016年 Closer_All. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EaseMobSDKFull/EaseMob.h>
#import <AVFoundation/AVFoundation.h>


@interface LHVideoViewController : UIViewController

@property(nonatomic,strong)EMCallSession  *callSession;
@property(nonatomic,assign)BOOL isMakeOut;


@end
