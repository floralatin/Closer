//
//  MessageCell.h
//  Closer
//
//  Created by zhangkai on 16/3/20.
//  Copyright © 2016年 Closer_All. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EMConversation.h>

#import <EMMessage.h>
@interface MessageCell : UITableViewCell
@property(nonatomic,strong)EMConversation  *conversation;

@property (weak, nonatomic) IBOutlet UIImageView *mImv;

@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property (weak, nonatomic) IBOutlet UILabel *fName;



@end
