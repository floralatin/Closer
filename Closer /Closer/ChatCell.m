//
//  ChatCell.m
//  Closer
//
//  Created by zhangkai on 16/3/11.
//  Copyright © 2016年 Closer_All. All rights reserved.
//

#import "ChatCell.h"
static CGFloat height=0;

@interface ChatCell ()

@property (weak, nonatomic) IBOutlet UILabel *putChatText;
@property (weak, nonatomic) IBOutlet UILabel *getChatText;

@property (weak, nonatomic) IBOutlet UIButton *putButton;
@property (weak, nonatomic) IBOutlet UIImageView *getImageView;
@property (weak, nonatomic) IBOutlet UIButton *getButton;
- (IBAction)getButton:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIImageView *putImageView;
- (IBAction)putVideoButton:(UIButton *)sender;

@property(nonatomic,strong)NSString  *voicePath;
@property(nonatomic,strong)UIImage  *imagePath;
@end

@implementation ChatCell

- (void)awakeFromNib {
   
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)setMessageAll:(EMMessage*)message withFrom:(NSString*)chatter{
   
    
    id<IEMMessageBody> msgBody = message.messageBodies.firstObject;
    _putImageView.hidden=YES;
    _getImageView.hidden=YES;
    _putChatText.hidden=YES;
    _getChatText.hidden=YES;
    _putButton.hidden=YES;
    _getButton.hidden=YES;
    
    _leftImv.hidden=YES;
    _rightImv.hidden=YES;
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureAction:)];
    
    switch (msgBody.messageBodyType) {
        case eMessageBodyType_Text:

            if ([message.from isEqualToString:chatter]) {
                  _getChatText.text=((EMTextMessageBody *)msgBody).text;
                 _getChatText.hidden=NO;
                _leftImv.hidden=NO;
                
                _getChatText.textAlignment=NSTextAlignmentLeft;
                  [self setAutoHeight:_getChatText];
            }else{
                 _putChatText.hidden=NO;
                _rightImv.hidden=NO;
                  _putChatText.text=((EMTextMessageBody *)msgBody).text;
                _putChatText.textAlignment=NSTextAlignmentRight;
                  [self setAutoHeight:_putChatText];
            }
            [self layoutIfNeeded];
            break;
        case eMessageBodyType_Image:
            if ([message.from isEqualToString:chatter]) {
                _getImageView.hidden=NO;
                _leftImv.hidden=NO;
                _getImageView.image=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:((EMImageMessageBody*)msgBody).thumbnailRemotePath]]];
                self.imagePath=_getImageView.image;
                [_getImageView addGestureRecognizer:tap];
            }else{
                _putImageView.hidden=NO;
                _rightImv.hidden=NO;
                _putImageView.image=[UIImage imageWithContentsOfFile:((EMImageMessageBody*)msgBody).thumbnailLocalPath];
                self.imagePath=_putImageView.image;
                
                [_putImageView addGestureRecognizer:tap];
            }
            height=100;
            break;
        case eMessageBodyType_Voice:
         
            if ([message.from isEqualToString:chatter]) {
                _getButton.hidden=NO;
                self.voicePath= ((EMVoiceMessageBody *)msgBody).remotePath;
                NSLog(@"-------path-------%@",self.voicePath);
            }else{
                _putButton.hidden=NO;
                self.voicePath= ((EMVoiceMessageBody *)msgBody).localPath;
            }
            
            break;
        case eMessageBodyType_Location:
            
            break;
        case eMessageBodyType_Video:
            
            break;
        case eMessageBodyType_File:
            
            break;
        default:
            break;
    }
}
-(void)setAutoHeight:(UILabel*)label{
    label.numberOfLines=0;
    height=  [label.text boundingRectWithSize:CGSizeMake(self.frame.size.width-10, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17]}context:nil].size.height;
}
+(CGFloat)GetHeight{
    return height;
}

- (IBAction)putVideoButton:(UIButton *)sender {
    if (self.delegate&&[self.delegate respondsToSelector:@selector(playWithPathUrl:isRemate: )]) {
        [self.delegate playWithPathUrl:  [NSURL URLWithString:self.voicePath ] isRemate:NO ];
    }
}
- (IBAction)getButton:(UIButton *)sender {
    if (self.delegate&&[self.delegate respondsToSelector:@selector(playWithPathUrl:isRemate:)]) {
        [self.delegate playWithPathUrl:  [NSURL URLWithString:self.voicePath ] isRemate:YES ];
    }
}
-(void)tapGestureAction:(UITapGestureRecognizer*)tapGesture{
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(zoomImageWithImage: rect:)]) {
        [self.delegate zoomImageWithImage:self.imagePath rect:_putImageView.bounds];
    }
}

@end
