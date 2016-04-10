//
//  CreatGroupViewController.m
//  Closer
//
//  Created by zhangkai on 16/3/12.
//  Copyright © 2016年 Closer_All. All rights reserved.
//

#import "CreatGroupViewController.h"
 #import <EaseMobSDKFull/EaseMob.h>
#define cell_id @"cell_id"

@interface CreatGroupViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *groupNameText;
@property (weak, nonatomic) IBOutlet UITextView *groupInformationText;
@property (weak, nonatomic) IBOutlet UIButton *groupTypeButton;

@property (weak, nonatomic) IBOutlet UITableView *groupTypeTableView;
@property (weak, nonatomic) IBOutlet UITableView *groupMembersTableView;
- (IBAction)groupTypeButton:(UIButton *)sender;
- (IBAction)creatGroupButton:(UIButton *)sender;
@property(nonatomic,strong)NSArray  *userDataArray;

@property(nonatomic,strong)NSMutableArray  *groupDataArray;


@end

@implementation CreatGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.groupTypeTableView.delegate=self;
    self.groupTypeTableView.dataSource=self;
    self.groupMembersTableView.delegate=self;
    self.groupMembersTableView.dataSource=self;
    self.groupTypeTableView.hidden=YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.groupDataArray=[[NSMutableArray alloc]init];
    self.userDataArray=[[NSArray alloc]init];
    [[EaseMob sharedInstance].chatManager asyncFetchBuddyListWithCompletion:^(NSArray *buddyList, EMError *error) {
        if (!error) {
            NSLog(@"获取成功 -- %@",buddyList);
            self.userDataArray=buddyList;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.groupTypeTableView reloadData];
                [self.groupMembersTableView reloadData];
            });
        }
    } onQueue:nil];

}

-(void)viewDidDisappear:(BOOL)animated{
    _groupTypeButton.layer.masksToBounds=YES;
    [super viewDidDisappear:animated];
    self.userDataArray=nil;
    self.groupDataArray=nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma  mark - tableview代理
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if ([tableView isEqual:self.groupTypeTableView]) {
        return 4;
    }else{
        return self.userDataArray.count;
    }

}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cell_id];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cell_id];
    }
    if ([tableView isEqual:self.groupTypeTableView]) {
        cell .textLabel.text=  [self getGroupTypeByNumber:indexPath.row];
    }else{
        EMBuddy *buddy=self.userDataArray[indexPath.row];
        cell.textLabel.text =buddy.username;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView isEqual:self.groupTypeTableView]) {
        [self.groupTypeButton setTitle:[self getGroupTypeByNumber:indexPath.row] forState:UIControlStateNormal] ;
        self.groupTypeTableView.hidden=YES;
    }else{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        UITableViewCell *cell=   [tableView cellForRowAtIndexPath:indexPath];
        if (cell.accessoryType  == UITableViewCellAccessoryCheckmark) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            EMBuddy *buddy=self.userDataArray[indexPath.row];
            [self.groupDataArray removeObject:buddy.username];
        }else {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            EMBuddy *buddy=self.userDataArray[indexPath.row];
            [self.groupDataArray addObject:buddy.username];
        }
        NSLog(@" groupDataArray %ld",self.groupDataArray.count);
    }
}
#pragma mark - 获得 群组的属性
-(NSString*)getGroupTypeByNumber:(NSInteger)number{

    NSString *groupTypeString=nil;
    switch (number) {
        case eGroupStyle_PrivateOnlyOwnerInvite:
             groupTypeString=@"私有群";//
            break;
        case eGroupStyle_PrivateMemberCanInvite:
             groupTypeString=@"群成员邀请邀请群";//
            break;
        case eGroupStyle_PublicJoinNeedApproval:
            groupTypeString=@"公有群需申请";//
            break;
        case eGroupStyle_PublicOpenJoin:
             groupTypeString=@"公有群不需申请";//
            break;
        default:
            break;
    }
    return groupTypeString;
}
-(EMGroupStyle)getGroupTypeByString:(NSString *)string{

    if ([string isEqualToString:@"私有群"]) {
        return eGroupStyle_PrivateOnlyOwnerInvite;
    }
 else   if ([string isEqualToString:@"群成员邀请群"]) {
        return eGroupStyle_PrivateMemberCanInvite;
    }
  else  if ([string isEqualToString:@"公有群需申请"]) {
        return eGroupStyle_PublicJoinNeedApproval;
    }
  else{
        return eGroupStyle_PublicOpenJoin;
    }
}
#pragma mark - 创建 群
- (IBAction)creatGroupButton:(UIButton *)sender {
    EMGroupStyleSetting *groupStyleSetting = [[EMGroupStyleSetting alloc] init];
    groupStyleSetting.groupMaxUsersCount = 500;
    groupStyleSetting.groupStyle = [self getGroupTypeByString:self.groupTypeButton .titleLabel.text ];
    NSLog(@"%@",self.groupTypeButton .titleLabel.text);
    [[EaseMob sharedInstance].chatManager asyncCreateGroupWithSubject:self.groupNameText.text description:self.groupInformationText.text   invitees:self.groupDataArray   initialWelcomeMessage:@"邀请您加入群组"   styleSetting:groupStyleSetting   completion:^(EMGroup *group, EMError *error) {
        if(!error){
            NSLog(@"创建成功 -- %@",group);
        }
    } onQueue:nil];
}


- (IBAction)groupTypeButton:(UIButton *)sender {
    
    sender.selected=!sender.selected;
    if (sender.selected) {
        [UIView animateWithDuration:0.5 animations:^{
            self.groupTypeTableView.hidden=NO;
        }];
    }
    else{
        [UIView animateWithDuration:0.5 animations:^{
            self.groupTypeTableView.hidden=YES;
        }];
    }
}
@end
