//
//  DisplayUserViewController.m
//  Closer
//
//  Created by zhangkai on 16/3/10.
//  Copyright © 2016年 Closer_All. All rights reserved.
//

#import "DisplayUserViewController.h"
#import <EaseMobSDKFull/EaseMob.h>
#import "ChatViewController.h"
#import "AddfriendViewController.h"
#import "ShowGroupViewController.h"
#import "RoomViewController.h"
#import "VoiceOnlineViewController.h"
#import "LHnearbyTool.h"
#import "DisplayTableViewCell.h"

#pragma mark - 网络监测
#import "Reachability.h"

#define cell_id @"cell_id"
@interface DisplayUserViewController ()<IChatManagerDelegate,UITableViewDataSource,UITableViewDelegate,EMChatManagerDelegate,EMCallManagerDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong)NSMutableArray   *userDataArray;
@property(nonatomic,strong)NSArray  *groupDataArray;
@property(nonatomic,strong)NSMutableArray  *blackDataArray;

@property(nonatomic,strong)UILongPressGestureRecognizer  *longPressGesture;
@property(nonatomic,strong)Reachability  *NetState;
@end
@implementation DisplayUserViewController
- (void)viewDidLoad {
    [super viewDidLoad];
        
        UIBarButtonItem *rightBar=[[UIBarButtonItem alloc]initWithTitle:@"+" style:UIBarButtonItemStyleDone target:self action:@selector(rightBarAction)];
    self.navigationItem.rightBarButtonItem=rightBar;
    
    self.longPressGesture =[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(letTableViewEdting)];
    
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.tableView registerNib:[UINib nibWithNibName:@"DisplayTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cellFriend_id"];
    
//    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cell_id];
    //加载网络监视状态观察者
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkingNetState) name:kReachabilityChangedNotification object:nil];
    //初始化网络监测对象
    self.NetState=[Reachability reachabilityForInternetConnection];
    [self.NetState startNotifier];
    
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
     [[ EaseMob sharedInstance].callManager addDelegate:self delegateQueue:nil];
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
    self.userDataArray=[NSMutableArray arrayWithArray:[[EaseMob sharedInstance].chatManager buddyList]] ;
    self.blackDataArray =[NSMutableArray arrayWithArray:[[EaseMob sharedInstance].chatManager blockedList]];
    [self.tableView reloadData];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)dealloc{
    self.userDataArray=nil;
    self.groupDataArray=nil;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noNetwork:) name:@"没有网络" object:nil];
    [self updateData];
}

-(void)updateData{
    [[EaseMob sharedInstance].chatManager asyncFetchBuddyListWithCompletion:^(NSArray *buddyList, EMError *error) {
        if (!error) {
            
            self.userDataArray=[NSMutableArray arrayWithArray:buddyList]  ;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.tableView reloadData];
            });
        }
    } onQueue:nil];
    
    [[EaseMob sharedInstance].chatManager asyncFetchBlockedListWithCompletion:^(NSArray *blockedList, EMError *error) {
        if (!error) {
            NSLog(@"获取成功 -- %@",blockedList);
            self.blackDataArray=[NSMutableArray arrayWithArray:blockedList];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    } onQueue:nil];

}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.userDataArray=nil;
}
-(void)rightBarAction{
    
    AddfriendViewController *addfriendConreoller=[[AddfriendViewController alloc]initWithNibName:@"AddfriendViewController" bundle:nil];
    [self.navigationController pushViewController:addfriendConreoller animated:YES];
    
}
-(void)letTableViewEdting{
    
    self.tableView.editing=YES;
}

#pragma mark - tableview代理
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0){
        return 3;
    }
    else if (section==1) {
        return self.userDataArray.count;
    }else{
        return self.blackDataArray.count;
    }
    
    
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cell_id];
    DisplayTableViewCell*cell=[tableView dequeueReusableCellWithIdentifier:@"cellFriend_id" forIndexPath:indexPath];
    cell.Imv.layer.masksToBounds=YES;
//    UITableViewCell*cell=[tableView dequeueReusableCellWithIdentifier:cell_id];
//    if (!cell) {
//        
//        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cell_id];
//        
//    }
    [cell addGestureRecognizer:self.longPressGesture];
    if (indexPath.section==0){
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text=@"申请与通知";
                break;
            case 1:
                cell.textLabel.text=@"群组";
                break;
            case 2:
                cell.textLabel.text=@"聊天室";
                break;
                
            default:
                break;
        }
    }
     if (indexPath.section==1) {
//         cell.Imv.image=[UIImage imageNamed:@"/Users/lihui/Desktop/Closer 7/Closer/56c2c6121089b325.jpg!600x600.jpg"];
         
         cell.Imv.image=[UIImage imageNamed:@"072A2E9E-82C2-4502-B117-9773431A7665.png"];
        EMBuddy *buddy=self.userDataArray[indexPath.row];
        cell.nameLabel.text=buddy.username;
        
         if (cell.Imv.image!=nil) {
             
         }else{
             [LHnearbyTool downLoadUserImage:buddy.username block:^(UIImage *image) {
                 cell.Imv.image=image;
                 
             }];

         }
         
         
         
    }
    if (indexPath.section==2)  {
        NSString* buddy=self.blackDataArray[indexPath.row];
        cell.textLabel.text=buddy;
    }
//    cell.backgroundColor=[UIColor clearColor];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 80;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
    if (indexPath.section==0) {
        if (indexPath.row==1) {
            ShowGroupViewController *showGroupController=[[ShowGroupViewController alloc]initWithNibName:@"ShowGroupViewController" bundle:nil];
            [self.navigationController pushViewController:showGroupController animated:YES];
            return;
        }if (indexPath.row==2) {
            RoomViewController *roomController=[[RoomViewController alloc]initWithNibName:@"RoomViewController" bundle:nil];
            [self.navigationController pushViewController:roomController animated:YES];
        }
    }
    else if (indexPath.section==1) {
        EMBuddy  *buddy=  self.userDataArray[indexPath.row];
        
        ChatViewController *chatController=[[ChatViewController alloc]initWithChatter:buddy.username isGroup:NO];
        DisplayTableViewCell*cell=[tableView cellForRowAtIndexPath:indexPath];
        chatController.frindeIcon=cell.Imv.image;
        [self.navigationController pushViewController:chatController animated:YES];
    }
    else{
        NSLog(@"黑名单");
    }
}
#pragma mark -编辑状态
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        return NO;
    }
    else{
        return YES;
    }
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewCellEditingStyleDelete;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section==1) {
        EMError *error = nil;
        EMBuddy *buddy=self.userDataArray[indexPath.row];
        BOOL isSuccess = [[EaseMob sharedInstance].chatManager removeBuddy:buddy.username removeFromRemote:YES error:&error];
        if (isSuccess && !error) {
            [self.userDataArray removeObjectAtIndex:indexPath.row];
        }
    }
    if (indexPath.section==2){
        NSString *buddy_username=self.blackDataArray[indexPath.row];
        EMError *error = [[EaseMob sharedInstance].chatManager unblockBuddy:buddy_username];
        if (!error) {
             [self.blackDataArray  removeObjectAtIndex: indexPath .row];
        }else{
            
         NSLog(@"---黑名单移除发送失败------%@",error.debugDescription);
        }
    }
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                     withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - tableview 移动
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    
    NSLog(@"sourceIndexPath.section---%ld   sourceIndexPath.row---%ld ",sourceIndexPath.section,sourceIndexPath.row);
    
    NSLog(@"destinationIndexPath.section---%ld   destinationIndexPath.row---%ld ",destinationIndexPath.section,destinationIndexPath.row);
    
    if (sourceIndexPath.section==1) {
        if (destinationIndexPath.section==2) {
         
            EMBuddy *buddy=self.userDataArray[sourceIndexPath.row];
            
            EMError *error = [[EaseMob sharedInstance].chatManager blockBuddy:buddy.username	relationship:eRelationshipBoth];
            if (!error) {
                NSLog(@"黑名单发送成功");
                BOOL isSuccess = [[EaseMob sharedInstance].chatManager removeBuddy:buddy.username removeFromRemote:YES error:&error];
                if (isSuccess && !error) {
                    [self.userDataArray removeObjectAtIndex:sourceIndexPath.row];
                }
            }else{
              NSLog(@"---黑名单发送失败------%@",error.debugDescription);//Already existed.
            }
        }
    }
    if (sourceIndexPath.section==2) {
        if (destinationIndexPath.section==1) {
            NSString *buddy_username=self.blackDataArray[sourceIndexPath.row];
            NSLog(@"%@",buddy_username);
            
            EMError *error = [[EaseMob sharedInstance].chatManager unblockBuddy:buddy_username];
            if (!error) {
                NSLog(@"---黑名单移除发送chengfong------%@",error.debugDescription);
                [self.blackDataArray  removeObjectAtIndex: sourceIndexPath .row];
                BOOL isSuccess = [[EaseMob sharedInstance].chatManager addBuddy:buddy_username message:@"我想加您为好友" error:&error];
                if (isSuccess && !error) {
                
                }
            }
            else{
               
            }
        }
    }
   self.tableView.editing=NO;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    switch (section) {
        case 0:
            
            return @"群组";
            break;
        case 1:
            return @"好友";
            break;
        case 2:
            sleep(1);
            return @"黑名单";
            break;
        default:
            return nil;
            break;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

//回调
- (void)didAcceptedByBuddy:(NSString *)username{
    NSLog(@"好友接受回调监听");
    [self updateData];

}
- (void)didRejectedByBuddy:(NSString *)username{

    NSLog(@"好友拒绝回调监听");

}
- (void)didBlockBuddy:(EMBuddy *)buddy error:(EMError **)pError{

    NSLog(@"添加好友到黑名单成功");
}
- (void)didUnblockBuddy:(EMBuddy *)buddy error:(EMError **)pError{

    NSLog(@"移除好友到黑名单成功");

}
-(void)callSessionStatusChanged:(EMCallSession *)callSession changeReason:(EMCallStatusChangedReason)reason error:(EMError *)error{
    if (callSession.status == eCallSessionStatusConnected) {
        VoiceOnlineViewController *voiceOnlineController = [[VoiceOnlineViewController alloc]init];
        
        voiceOnlineController.callSession = callSession;
        
        [self presentViewController:voiceOnlineController animated:YES completion:nil];
    }
}
@end
