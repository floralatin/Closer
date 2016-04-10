//
//  AddfriendViewController.m
//  Closer
//
//  Created by zhangkai on 16/3/11.
//  Copyright © 2016年 Closer_All. All rights reserved.
//

#import "AddfriendViewController.h"
#import "LeanCloudTools.h"
#import <EaseMob.h>
#import <AVObject.h>
#define Cell_id @"Cell_id"


@interface AddfriendViewController ()<UISearchBarDelegate,UISearchResultsUpdating,UITableViewDataSource,UITableViewDelegate,IChatManagerDelegate>

- (IBAction)backButton:(UIBarButtonItem *)sender;
@property(nonatomic,strong)UISearchController  *searchController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic ,strong) NSMutableArray *dataList;
@property(nonatomic,strong)NSMutableArray  *searchList;
@end

@implementation AddfriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.dataList=[[NSMutableArray alloc]init];
    self.searchController=[[UISearchController alloc]initWithSearchResultsController:nil];
    self.searchController.dimsBackgroundDuringPresentation=NO;
    self.searchController.hidesNavigationBarDuringPresentation=NO;
    self.tableView.tableHeaderView =self.searchController.searchBar;
    
    for (AVObject  *object in [LeanCloudTools getAllUser]) {
        [self.dataList addObject:[object objectForKey:@"username"]];
    }
    self.searchController.searchResultsUpdater=self;
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - tableView 代理

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.searchController.active) {
        return self.searchList.count;
    }else{
     return    0;
    }
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:Cell_id ];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:Cell_id];
    }
    if (self.searchController.active) {
        
        cell.textLabel.text=self.searchList[indexPath.row];
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIAlertController *alertController=[UIAlertController alertControllerWithTitle:@"添加好友" message: self.searchList[indexPath.row]preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancleAction=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        NSLog(@"取消");
    }];
    UIAlertAction *sureAction=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"确定");
        EMError *error=nil;
        BOOL isSuccess = [[EaseMob sharedInstance].chatManager addBuddy:self.searchList[indexPath.row] message:@"我想加您为好友" error:&error];
        if (isSuccess && !error) {
            NSLog(@"等待对方验证");
        }
        
    }];
    [alertController addAction:cancleAction];
    [alertController addAction:sureAction];
    [self.searchController presentViewController:alertController animated:YES completion:^{
        
    }];
}

#pragma  mark - searchController
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    NSString *searchString=self.searchController.searchBar.text;
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"SELF CONTAINS[c] %@ ", searchString];
//    if (self.searchList) {
//        [self.searchList removeAllObjects];
//    }
    self.searchList=[NSMutableArray arrayWithArray:[self.dataList filteredArrayUsingPredicate:predicate]];
    [self.tableView reloadData];
}
- (IBAction)backButton:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
@end
