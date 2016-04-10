//
//  ChatViewController.h
//  Closer
//
//  Created by zhangkai on 16/3/10.
//  Copyright © 2016年 Closer_All. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EaseMobSDKFull/EaseMob.h>


@interface ChatViewController : UIViewController
- (instancetype)initWithChatter:(NSString *)chatter isGroup:(BOOL)isGroup;
-(instancetype)initWithChatter:(NSString *)chatter conversationType:(EMConversationType)conversationType;


@property(nonatomic,strong)UIImage*frindeIcon;



@end
