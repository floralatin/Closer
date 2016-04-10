//
//  ChatViewController.m
//  Closer
//
//  Created by zhangkai on 16/3/10.
//  Copyright © 2016年 Closer_All. All rights reserved.
//

#import "ChatViewController.h"
#import <EaseMobSDKFull/EaseMob.h>
#import <AVFoundation/AVFoundation.h>
#import "ChatCell.h"
#import "CameraViewController.h"

#import "VoiceOnlineViewController.h"
#import "LHVideoViewController.h"

#import "LHLoactionTool.h"
#import "LHnearbyTool.h"
#define ChatCell_id @"ChatCell_id"
@interface ChatViewController ()<EMChatManagerDelegate,EMCallManagerDelegate,UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CameraViewControllerDelegate,ChatCellDelegate,UITextFieldDelegate
>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *inputText;
@property (weak, nonatomic) IBOutlet UIView *buttomView;
@property (weak, nonatomic) IBOutlet UIButton *recordbutton;
- (IBAction)showManyButton:(UIButton *)sender;

//- (IBAction)showAvatarButton:(UIButton *)sender;
- (IBAction)voiceButton:(UIButton *)sender;
- (IBAction)photoButton:(UIButton *)sender;
- (IBAction)cameraButton:(UIButton *)sender;
- (IBAction)locationButton:(UIButton *)sender;
- (IBAction)voiceChatButton:(UIButton *)sender;





@property(nonatomic,strong)NSMutableArray  *dataArray;
@property(nonatomic,strong)EMConversation *conversation ;

@property(nonatomic,strong)UIImagePickerController *pickController  ;
@property(nonatomic,strong)AVAudioRecorder  *audioRecorder;
@property(nonatomic,strong)AVAudioPlayer  *audioPlayer;
@property(nonatomic,strong)NSTimer  *timer;

@property(nonatomic,strong)NSDate  *dateStart;

@property(nonatomic,strong)UITapGestureRecognizer  *tapGesture;
@property(nonatomic,strong)UIImageView  *ImageView;
@property(nonatomic,assign)CGRect  rectOfImageView;


@property(nonatomic,assign)BOOL  isMakeOut;
@property(nonatomic,assign)BOOL isAideoCall;
@end
@implementation ChatViewController

- (instancetype)initWithChatter:(NSString *)chatter isGroup:(BOOL)isGroup{
    
    EMConversationType type=isGroup?eConversationTypeGroupChat:eConversationTypeChat;
    self =[self initWithChatter:chatter conversationType:type];
    return self;
}
-(instancetype)initWithChatter:(NSString *)chatter conversationType:(EMConversationType)conversationType{
    
    self=[super initWithNibName:@"ChatViewController" bundle:nil];
    if (self) {
        
        _conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:chatter  conversationType:conversationType];
        _conversation.enableUnreadMessagesCountEvent=YES;
        [_conversation markAllMessagesAsRead:YES];
    }
    return self;
}
-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //键盘观察者
    [self addObserverOfTextField];
    
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"ChatCell" bundle:nil] forCellReuseIdentifier:ChatCell_id];
    //建立连接
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    [[ EaseMob sharedInstance].callManager addDelegate:self delegateQueue:nil];
    
    
    //录音会话
    AVAudioSession  *audioSession=[AVAudioSession sharedInstance];
    NSError *error=nil;
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    [audioSession setActive:YES error:nil];
    
    //录音按钮
    [self.buttomView bringSubviewToFront:self.recordbutton];
    self.recordbutton.hidden=YES;
    [self.recordbutton addTarget:self action:@selector(recordTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.recordbutton addTarget:self action:@selector(recordTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    [self.recordbutton addTarget:self action:@selector(recordTouchDown:) forControlEvents:UIControlEventTouchDown];
    
    self.inputText.returnKeyType=UIReturnKeySend;
    self.inputText.delegate=self;
    
    
    //实时语音
    self.isMakeOut=NO;
    //
    self.isAideoCall=NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    long long timestamp = [[NSDate date] timeIntervalSince1970] * 1000 + 1;
    self.dataArray=[NSMutableArray arrayWithArray:[self.conversation loadNumbersOfMessages:10 before:timestamp ]];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.view.frame=CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height);
    
}
#pragma mark - 观察者通知键盘事件
-(void)addObserverOfTextField{
    NSNotificationCenter *notificationCenter=[NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
}
-(void)keyboardShow:(NSNotification*)notification{
    
    CGRect rect=[[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] ;
    
    [UIView animateWithDuration:2 animations:^{
        self.view.frame=CGRectMake(0,-rect.size.height+49,self.view.bounds.size.width,self.view.bounds.size.height);
    }];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [UIView animateWithDuration:0.2 animations:^{
        [self.inputText resignFirstResponder];
        self.view.frame=CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height);
    }];
}
#pragma  mark  - table 代理事件
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ChatCell *chatCell=[tableView dequeueReusableCellWithIdentifier:ChatCell_id];
    chatCell.leftImv.layer.masksToBounds=YES;
    chatCell.rightImv.layer.masksToBounds=YES;
    if (indexPath.row<self.dataArray.count) {
        chatCell.delegate=self;
        chatCell.rightImv.image=[LHLoactionTool shareLoction].icon;
        NSUserDefaults*user=[NSUserDefaults standardUserDefaults];
       NSData*data=[user valueForKey:@"icon"];
        chatCell.rightImv.image=[UIImage imageWithData:data];
        chatCell.leftImv.image=_frindeIcon;
        EMMessage *message= self.dataArray[indexPath.row];
        [chatCell  setMessageAll:message withFrom:self.conversation.chatter];
    }
    return chatCell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  [ChatCell GetHeight]+30;
}
#pragma mark - 显示button
- (IBAction)showManyButton:(UIButton *)sender {
    if ( [self.inputText isFirstResponder]) {
        [self.inputText resignFirstResponder];
    }else{
        [self.inputText becomeFirstResponder];
    }
    
}
#pragma mark - 接受在线消息
- (void)didReceiveMessage:(EMMessage *)message{
    NSLog(@"用户消息%@",self.conversation.chatter);
    if ([self.conversation.chatter isEqualToString:message.from]) {
        [self.dataArray addObject: message];
        [self.tableView reloadData];
    }
}
#pragma mark - 发送消息
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"]) {
        EMChatText *txtChat = [[EMChatText alloc] initWithText:self.inputText.text];
        EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithChatObject:txtChat];
        EMMessage *message = [[EMMessage alloc] initWithReceiver:self.conversation.chatter bodies:@[body]];
        [self sendMessage:message];
        return NO;
    }
    return YES;
    
}

-(void)sendMessage:(EMMessage*)message{
    message.messageType =[self messageTypeFromConversationType:self.conversation.conversationType];
    EMError *error=nil;
    [[EaseMob sharedInstance].chatManager sendMessage:message progress:nil error:&error];
    if (!error) {
        [self.dataArray addObject: message];
        if (self.dataArray.count>=10) {
            [self.dataArray removeObjectAtIndex:0];
        }
        [self.tableView reloadData];
    }
    else{
        NSLog(@"%@",error);
    }
}

-(EMMessageType)messageTypeFromConversationType:(EMConversationType)conversationType{
    switch (self.conversation.conversationType) {
        case eConversationTypeGroupChat:
            return  eMessageTypeGroupChat;
            break;
        case eConversationTypeChatRoom:
            return  eMessageTypeChatRoom;
            break;
        default:
            return eMessageTypeChat;
            break;
    }
}
#pragma mark - 语音消息
- (IBAction)voiceButton:(UIButton *)sender {
    NSLog(@"语音");
    sender.selected=!sender.selected;
    if (sender.selected) {
        self.inputText.hidden=YES;
        [self.inputText  resignFirstResponder];
        [UIView animateWithDuration:0.2 animations:^{
            self.view.frame=CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height);
        }];
        self.recordbutton.hidden=NO;
    }
    else {
        [UIView animateWithDuration:0.2 animations:^{
            self.view.frame=CGRectMake(0,-222,self.view.bounds.size.width,self.view.bounds.size.height);
        }];
        
        self.inputText.hidden=NO;
        [self.inputText becomeFirstResponder];
        self.recordbutton.hidden=YES;
    }
}
-(void)recordTouchDown:(UIButton*)sender{
    [self performSelector:@selector(lazyButtontouchDown) withObject:nil afterDelay:0.5];
}

-(void)recordTouchUpInside:(UIButton*)sender{
    
    [self.audioRecorder stop];
    self.timer.fireDate=[NSDate distantFuture];
    EMChatVoice *voice = [[EMChatVoice alloc] initWithFile:[self getSavePath]displayName:@"audio"];
    voice.duration =[[NSDate date] timeIntervalSinceDate:self.dateStart];
    EMVoiceMessageBody *body = [[EMVoiceMessageBody alloc] initWithChatObject:voice];
    EMMessage *message = [[EMMessage alloc] initWithReceiver:self.conversation.chatter bodies:@[body]];
    [self sendMessage:message];
    
}
-(void)recordTouchUpOutside:(UIButton*)sender{
    [self.audioRecorder stop];
    self.timer.fireDate=[NSDate distantFuture];
}
-(void)lazyButtontouchDown{
    if (![self.audioRecorder isRecording]) {
        self.dateStart=[NSDate date];
        [self.audioRecorder record];
        self.timer.fireDate=[NSDate distantPast];
    }
}
-(NSString*)getSavePath{
    NSString *string=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *urlString=[string stringByAppendingString:@"/myRecord.caf"];
    return urlString;
}
-(NSDictionary *)getAudioSetting{
    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    [dicM setObject:@(8000) forKey:AVSampleRateKey];
    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
    [dicM setObject:@(8) forKey:AVLinearPCMBitDepthKey];
    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    return dicM;
}
-(AVAudioRecorder *)audioRecorder{
    if (!_audioRecorder) {
        NSURL *url= [NSURL URLWithString:[self getSavePath]] ;
        NSDictionary *setting=[self getAudioSetting];
        NSError *error=nil;
        _audioRecorder=[[AVAudioRecorder alloc]initWithURL:url settings:setting error:&error];
        _audioRecorder.meteringEnabled=YES;
        
        if (error) {
            NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioRecorder;
}
-(NSTimer *)timer{
    if (!_timer) {
        _timer=[NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(audioPowerChange) userInfo:nil repeats:YES];
    }
    return _timer;
}

-(void)audioPowerChange{
    [self.audioRecorder updateMeters];
}
//chatCell 代理
-(void)playWithPathUrl:(NSURL *)url isRemate:(BOOL)isRemate {
    
    if ([_audioPlayer isPlaying]) {
        [_audioPlayer stop];
    }
    NSLog(@"%@",url);
    NSError *error=nil;
    if (isRemate) {
        _audioPlayer=[[AVAudioPlayer alloc]initWithData:[NSData dataWithContentsOfURL:url]  error:&error];
    }
    else{
        _audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
    }
    _audioPlayer.numberOfLoops=0;
    [_audioPlayer prepareToPlay];
    if (error) {
        NSLog(@"%@",error);
    }else {
        [self.audioPlayer play];
    }
}
#pragma mark - 图片消息
- (IBAction)photoButton:(UIButton *)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        _pickController=[[UIImagePickerController alloc]init];
        _pickController.allowsEditing=YES;
        _pickController.delegate=self;
        [self presentViewController:_pickController animated:YES completion:^{
            
        }];
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    EMChatImage *imgChat = [[EMChatImage alloc] initWithUIImage:image displayName:@"displayName"];
    EMImageMessageBody *body = [[EMImageMessageBody alloc] initWithChatObject:imgChat];
    EMMessage *message = [[EMMessage alloc] initWithReceiver:self.conversation.chatter bodies:@[body]];
    [self sendMessage:message];
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}
//chatcell 图片代理
-(void)zoomImageWithImage:(UIImage *)image rect:(CGRect)rect{
    
    self.rectOfImageView=rect;
    _ImageView.center=self.view.center;
    
    self.ImageView.userInteractionEnabled=YES;
    self.ImageView.image=image;
    
    [self.ImageView addGestureRecognizer:self.tapGesture];
    
    [UIView animateWithDuration:1.0 animations:^{
        self.ImageView.frame=self.view.bounds  ;
        [self.view addSubview:self.ImageView];
    }];
}
-(UIImageView*)ImageView{
    if (!_ImageView) {
        _ImageView=[[UIImageView alloc]initWithFrame:_rectOfImageView];
        _ImageView.center=self.view.center;
    }
    return _ImageView;
}
-(UITapGestureRecognizer*)tapGesture{
    if (!_tapGesture) {
        _tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    }
    return _tapGesture;
}
-(void)tapAction:(UITapGestureRecognizer*)tapGestureRecognizer{
    [UIView animateWithDuration:0.5 animations:^{
        _ImageView.center=self.view.center;
        self.ImageView.frame=CGRectMake(0, 0, 0, 0);
    }];
    
    
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

#pragma  mark  - 照相
- (IBAction)cameraButton:(UIButton *)sender {
    
    
    
    
    
    CameraViewController *cameraViewController=[[CameraViewController    alloc]initWithNibName:@"CameraViewController" bundle:nil];
    cameraViewController.delegate=self;
    [self.navigationController pushViewController:cameraViewController animated:YES];
}
#pragma  mark  - CameraControllerdelegate
-(void)sendImage:(UIImage *)image{
    EMChatImage *imgChat = [[EMChatImage alloc] initWithUIImage:image displayName:@"displayName"];
    EMImageMessageBody *body = [[EMImageMessageBody alloc] initWithChatObject:imgChat];
    EMMessage *message = [[EMMessage alloc] initWithReceiver:self.conversation.chatter bodies:@[body]];
    [self sendMessage:message];
}


#pragma mark - 实时通话
- (IBAction)voiceChatButton:(UIButton *)sender {
    [[EaseMob sharedInstance].callManager asyncMakeVoiceCall:self.conversation.chatter timeout:10 error:nil];
    _isMakeOut=YES;
}



-(void)callSessionStatusChanged:(EMCallSession *)callSession changeReason:(EMCallStatusChangedReason)reason error:(EMError *)error{
    
//    callSession.type=
//    if (callSession.status == eCallSessionStatusConnected) {
        if (callSession.type ==eCallSessionTypeVideo ) {
            LHVideoViewController*vc=[[LHVideoViewController alloc]init];
            vc.isMakeOut=self.isAideoCall;
            vc.callSession=callSession;
            self.isAideoCall=NO;
            [self presentViewController:vc animated:YES completion:nil];
            
        }else{
        
        VoiceOnlineViewController *voiceOnlineController = [[VoiceOnlineViewController alloc]init];
        voiceOnlineController.callSession = callSession;
        voiceOnlineController.isMakeOut=self.isMakeOut;
        self.isMakeOut=NO;
        [self presentViewController:voiceOnlineController animated:YES completion:nil];
        }
//    }
    if ([error isEqual:@"The other side is not online."]) {
        [self alertMessage:@"The other side is not online."];
    }
   
}

-(void)alertMessage:(NSString*)message{
    UIAlertController *alertController=[UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alertController animated:YES completion:^{
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }];
}

#pragma 视频

- (IBAction)audioPlayAction:(id)sender {
    
    [[EaseMob sharedInstance].callManager asyncMakeVideoCall:self.conversation.chatter timeout:10 error:nil];
    self.isAideoCall=YES;
}



#pragma  mark  - //显示图像
//- (IBAction)showAvatarButton:(UIButton *)sender {
//    if ( [self.inputText isFirstResponder]) {
//        [self.inputText resignFirstResponder];
//    }else{
//        [self.inputText becomeFirstResponder];
//    }
//}
- (IBAction)locationButton:(UIButton *)sender {
    
    
}

@end
