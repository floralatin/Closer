//
//  MessageViewController.m
//  Closer
//
//  Created by zhangkai on 16/3/15.
//  Copyright © 2016年 Closer_All. All rights reserved.
//

#import "MessageViewController.h"
#import <EaseMobSDKFull/EaseMob.h>
#import "ChatViewController.h"
#import "MessageCell.h"
#import "Reachability.h"
#import "VoiceOnlineViewController.h"
#define  cell_id @"cell_id"

@interface MessageViewController ()<IChatManagerConversation,IChatManagerDelegate,UITableViewDataSource,UITableViewDelegate,EMChatManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong)NSMutableArray  *dataArray;
@property(nonatomic,strong)Reachability  *NetState;
@end

@implementation MessageViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.tableView registerNib:[UINib nibWithNibName:@"MessageCell" bundle:nil] forCellReuseIdentifier:cell_id];
    [[EaseMob sharedInstance].chatManager  addDelegate:self delegateQueue:nil];
    [[ EaseMob sharedInstance].callManager addDelegate:self delegateQueue:nil];
    //加载网络监视状态观察者
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkingNetState) name:kReachabilityChangedNotification object:nil];
    //初始化网络监测对象
    self.NetState=[Reachability reachabilityForInternetConnection];
    [self.NetState startNotifier];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.dataArray=[NSMutableArray arrayWithArray:[[EaseMob sharedInstance].chatManager  loadAllConversationsFromDatabaseWithAppend2Chat:YES]] ;
    [self.tableView reloadData];
}

//--------------------------网络状态---------------------------
-(void)checkingNetState{
    
    Reachability *Wifi=[Reachability reachabilityForLocalWiFi];
    Reachability *Grcs=[Reachability reachabilityForInternetConnection];
    
    NSLog(@"hashd");
    
    if ([Wifi currentReachabilityStatus]!=NotReachable) {
        NSLog(@"有wifi");
        
        
    }else if ([Grcs currentReachabilityStatus]!=NotReachable){
        NSLog(@"有3/4G");
        
        
    }else{
        NSLog(@"没有网络");
        [self noNetwork];
    }
}
-(void)noNetwork{
    
    self.dataArray=[NSMutableArray arrayWithArray:[[EaseMob sharedInstance].chatManager conversations]] ;
    [self.tableView reloadData];
    
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
 
    self.dataArray=nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - tableView 的
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageCell *cell=[tableView dequeueReusableCellWithIdentifier:cell_id ];
     cell.mImv.layer.masksToBounds=YES;
    cell.conversation=self.dataArray[indexPath.row];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    EMConversation*  conversation=self.dataArray[indexPath.row];
    MessageCell*cell=[tableView cellForRowAtIndexPath:indexPath];
   
    ChatViewController *chatController=[[ChatViewController alloc]initWithChatter:conversation.chatter isGroup:[self getIsGAroup:conversation]];
       chatController.frindeIcon=cell.mImv.image;
    [self.navigationController pushViewController:chatController animated:YES];
        
}

-(BOOL)getIsGAroup:(EMConversation*)conversation{
    
    switch (conversation.conversationType) {
        case eConversationTypeGroupChat:
            return YES;
            break;
        case eConversationTypeChat:
            return NO;
            break;
        default:
            return NO;
            break;
    }
}


#pragma mark - 未读在线消息
- (void)didUnreadMessagesCountChanged{
    NSLog(@"未读消息发生变化");
}
#pragma mark - 接受离线消息
- (void)willReceiveOfflineMessages{
    NSLog(@"将要接受离线消息");
}
- (void)didReceiveOfflineMessages:(NSArray *)offlineMessages{
    NSLog(@"将要接受离线列表");
}
- (void)didFinishedReceiveOfflineMessages{
    NSLog(@"完成接受离线消息");
    
}
-(void)callSessionStatusChanged:(EMCallSession *)callSession changeReason:(EMCallStatusChangedReason)reason error:(EMError *)error{
    if (callSession.status == eCallSessionStatusConnected) {
        VoiceOnlineViewController *voiceOnlineController = [[VoiceOnlineViewController alloc]init];
        
        voiceOnlineController.callSession = callSession;
        
        [self presentViewController:voiceOnlineController animated:YES completion:nil];
    }
}
@end
