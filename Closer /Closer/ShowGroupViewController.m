//
//  ShowGroupViewController.m
//  Closer
//
//  Created by zhangkai on 16/3/12.
//  Copyright © 2016年 Closer_All. All rights reserved.
//

#import "ShowGroupViewController.h"
#import <EaseMobSDKFull/EaseMob.h>
#import "CreatGroupViewController.h"
#import "ChatViewController.h"
#define CELL_id @"CELL_id"
@interface ShowGroupViewController ()<UITableViewDataSource,UITableViewDelegate,IChatManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong)NSMutableArray  *dataArray;
@end

@implementation ShowGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *rightBar=[[UIBarButtonItem alloc]initWithTitle:@"+" style:UIBarButtonItemStyleDone target:self action:@selector(rightbarAction)];
    self.navigationItem.rightBarButtonItem=rightBar;
    [self addDelegate];
    [self getData];
    
}
-(void)rightbarAction{
    
    CreatGroupViewController *creatController=[[CreatGroupViewController alloc]initWithNibName:@"CreatGroupViewController" bundle:nil];
    [self.navigationController pushViewController:creatController animated:YES];
}

-(void)addDelegate{
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}
-(void)getData{
    self.dataArray =[[NSMutableArray alloc]init];
    [[EaseMob sharedInstance].chatManager asyncFetchMyGroupsListWithCompletion:^(NSArray *groups, EMError *error) {
        for (EMGroup *group  in groups) {
            [[EaseMob sharedInstance].chatManager asyncFetchGroupInfo:group.groupId includesOccupantList:NO completion:^(EMGroup *group, EMError *error) {
                
                [self.dataArray addObject:group];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            } onQueue:nil];

        }
        
    } onQueue:nil];
}

-(void)dealloc{
    self.dataArray=nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark -  tableview 代理
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:CELL_id];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CELL_id];
    }
    EMGroup   *Group=self.dataArray[indexPath.row];
      cell.textLabel.text=Group.groupSubject;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
         EMGroup   *Group=self.dataArray[indexPath.row];
         ChatViewController *chatController=[[ChatViewController alloc]initWithChatter:Group.groupId isGroup:YES];
    [self.navigationController pushViewController:chatController animated:YES];
}
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"自己加入的群";
}
@end
