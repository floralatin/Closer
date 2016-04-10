//
//  ChatCell.h
//  Closer
//
//  Created by zhangkai on 16/3/11.
//  Copyright © 2016年 Closer_All. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EaseMobSDKFull/EaseMob.h>

@protocol ChatCellDelegate <NSObject>

-(void)playWithPathUrl:(NSURL*)url isRemate:(BOOL)isRemate;
-(void)zoomImageWithImage:(UIImage*)image rect:(CGRect)rect;
@end




@interface ChatCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UIImageView *leftImv;

@property (weak, nonatomic) IBOutlet UIImageView *rightImv;


@property(nonatomic,weak)id<ChatCellDelegate>  delegate;

-(void)setMessageAll:(EMMessage*)message withFrom:(NSString*)chatter;
+(CGFloat)GetHeight;

@end
