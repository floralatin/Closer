//
//  RoomViewController.m
//  Closer
//
//  Created by zhangkai on 16/3/16.
//  Copyright © 2016年 Closer_All. All rights reserved.
//

#import "RoomViewController.h"
#import "CreatRoomViewController.h"
#import <EaseMobSDKFull/EaseMob.h>
#define  cell_id @"cell_id"
@interface RoomViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong)NSArray  *dataArray;
@end

@implementation RoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setAllView];
    [self setAllDelegate];
 
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
   [self setAllData];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.dataArray=nil;
}
-(void)setAllView{
    UIBarButtonItem *rightBar=[[UIBarButtonItem alloc]initWithTitle:@"+" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarAction)];
    self.navigationItem.rightBarButtonItem=rightBar;

}
-(void)setAllDelegate{
    self.tableView.delegate=self;
    self.tableView.dataSource=self;

}
-(void)setAllData{
    [[EaseMob sharedInstance].chatManager asyncFetchChatroomsFromServerWithCursor:nil pageSize:5 andCompletion:^(EMCursorResult *result, EMError *error) {
        self.dataArray=result.list;
        NSLog(@"%@",self.dataArray);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.tableView reloadData];
        });
    }];
    
}
-(void)rightBarAction{
    CreatRoomViewController *creatRoomController=[[CreatRoomViewController alloc]initWithNibName:@"CreatGroupViewController" bundle:nil];
    [self.navigationController pushViewController:creatRoomController animated:YES];
}


#pragma mark - tableview
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cell_id];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cell_id];
    }
    
    
    return cell;
}
@end
