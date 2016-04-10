//
//  MessageCell.m
//  Closer
//
//  Created by zhangkai on 16/3/20.
//  Copyright © 2016年 Closer_All. All rights reserved.
//

#import "MessageCell.h"
#import "LHnearbyTool.h"


@interface MessageCell ()
@end


@implementation MessageCell

- (void)awakeFromNib {
 
    
    
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

-(void)setConversation:(EMConversation *)conversation{
    if (_conversation!=conversation&&conversation!=nil) {
        _conversation=conversation;
    }
    
    _countLabel.layer.masksToBounds=YES;
    if (_conversation.unreadMessagesCount==0) {
        _countLabel.hidden=YES;
    }
    if (_conversation .isGroup) {
//        self.imageView.image=[UIImage imageNamed:@"many.jpg"];
        self.mImv.image=[UIImage imageNamed:@"many.jpg"];
        self.countLabel.text= [NSString stringWithFormat:@"%ld",[_conversation unreadMessagesCount]];
      
       
    }else{
    
//       self.imageView.image=[UIImage imageNamed:@"single.jpg"];
        
         self.mImv.image=[UIImage imageNamed:@"single.jpg"];
         self.countLabel.text= [NSString stringWithFormat:@"%ld",[_conversation unreadMessagesCount]];
        EMMessage *message= _conversation.latestMessageFromOthers;
        [LHnearbyTool downLoadUserImage:message.from block:^(UIImage *image) {
            
            self.mImv.image=image;
        }];
        
       
    }
//    self.textLabel.text=_conversation.chatter;
    _fName.text=_conversation.chatter;
    [NSString stringWithFormat:@"%ld",  _conversation.unreadMessagesCount];
    _conversation.enableUnreadMessagesCountEvent=YES;
   EMMessage *message= _conversation. latestMessage;
    
    self.detailTextLabel.text=message.from;
}

@end
