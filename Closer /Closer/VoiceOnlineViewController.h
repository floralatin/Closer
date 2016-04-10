//
//  VoiceOnlineViewController.h
//  Closer
//
//  Created by zhangkai on 16/3/19.
//  Copyright © 2016年 Closer_All. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EaseMobSDKFull/EaseMob.h>
@interface VoiceOnlineViewController : UIViewController
@property(nonatomic,strong)EMCallSession  *callSession;
@property(nonatomic,assign)BOOL isMakeOut;

@end
