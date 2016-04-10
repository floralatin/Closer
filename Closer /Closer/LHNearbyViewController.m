//
//  LHNearbyViewController.m
//  mpp
//
//  Created by 李辉 on 16/3/12.
//  Copyright © 2016年 李辉. All rights reserved.
//

#import "LHNearbyViewController.h"
#import "LHNearbyTableViewCell.h"
#import "LHMapViewController.h"
#import "LHLoactionTool.h"
#import "LHDisplayNearbyViewController.h"
#import "LHnearbyModelForDistance.h"
#import "LHnearbyTool.h"

@interface LHNearbyViewController ()<UITableViewDataSource,UITableViewDelegate,sendLocationDelegate>

@property(nonatomic,strong)UITableView*tableView;
@property(nonatomic,strong)NSIndexPath*indexpath;

@property(nonatomic,strong)NSArray*userArr;

@property(nonatomic,strong)UITextField*textFiledNum;
@property(nonatomic,strong)UITextField*textFiledDistance;
@property(nonatomic,strong)UIView*searchView;
@property(nonatomic,strong)UIView*searchTextView;
@property(nonatomic,assign)NSInteger number;
@property(nonatomic,assign)CGFloat  extenKm;
@property(nonatomic,assign)BOOL judgeAddView;
@property(nonatomic,strong)NSString*distancestr;
@property(nonatomic,strong)UIStepper*step;
@end

@implementation LHNearbyViewController

-(void)viewWillAppear:(BOOL)animated{
    
    [_tableView reloadData];
    
    [self setData];
    
    }

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _judgeAddView=NO;
    _tableView=[[UITableView alloc]initWithFrame:[UIScreen mainScreen].bounds style:(UITableViewStyleGrouped)];
        _tableView.delegate=self;
    _tableView.dataSource=self;
    [self.view addSubview:_tableView];
    [self.tableView registerNib:[UINib nibWithNibName:@"LHNearbyTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cell_id"];
//    _userArr=[NSArray array];
    [self setData];
    [self setViews];
    
}

-(void)setData{
    [LHLoactionTool shareLoction].delegate=self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [LHnearbyTool downLoadNearbyUserWithNumber:20 distance:0 block:^(NSArray *arr) {
            _userArr=arr;
            [_tableView reloadData];
        }];
        
    });
 
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
//    return self.arrNearby.count;
    return _userArr.count;
    
}



-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    CLLocation*anLoction=[[CLLocation alloc]initWithLatitude:31.2 longitude:121.4];
    
   
   
    
    LHNearbyTableViewCell*cell=[tableView dequeueReusableCellWithIdentifier:@"cell_id" forIndexPath:indexPath];
    cell.icon.layer.masksToBounds=YES;
    LHnearbyModelForDistance*distanceModel=_userArr[indexPath.row];
    cell.name.text=distanceModel.name;
    NSLog(@"name==%@",distanceModel.name);
    [cell.buttonGo addTarget:self action:@selector(buttonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    _indexpath=indexPath;
    NSLog(@"%ld",indexPath.row);
    cell.buttonGo.tag=2000+indexPath.row;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        
//        NSString*str=[[LHLoactionTool shareLoction]distanceChangStringWithLoctionOne:[LHLoactionTool shareLoction].loction anotherLoction:anLoction];
        NSString*str=[LHnearbyTool ReturnDistace:distanceModel.distance];
        cell.detailInfro.text=str;
        

    });

    cell.icon.image=distanceModel.icon;
    
    return cell;
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 0.1;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    LHNearbyTableViewCell *cell=[_tableView cellForRowAtIndexPath:indexPath];
    LHMapViewController *mapCV=[[LHMapViewController alloc]init];

    LHDisplayNearbyViewController*vc=[[LHDisplayNearbyViewController alloc]init];
    vc.model=_userArr[indexPath.row];
//    vc.detail=cell.detailInfro.text;
//    vc.image=cell.icon.image;
    
    
       [self.navigationController pushViewController:vc animated:NO];

    
    }




-(void)buttonAction:(UIButton*)sender{
//    NSIndexPath*indexpath=[NSIndexPath indexPathForRow:sender.tag-2000 inSection:0];
//    UITableViewCell*cell=[_tableView cellForRowAtIndexPath:indexpath];
//    LHMapViewController *mapCV=[[LHMapViewController alloc]init];
     LHnearbyModelForDistance*model =_userArr[sender.tag -2000];
    [LHnearbyTool turnByTuenWithOneLoction:[LHLoactionTool shareLoction].loction endLoction:model.loction];
 
 
    
}

//添加搜索视图；
-(void)setViews{
    _searchView=[[UIView alloc]initWithFrame:CGRectMake(100, 200, 180, 90)];
    _searchTextView=[[UIView alloc]initWithFrame:CGRectMake(0, 30, 180, 30)];
    
    UIBarButtonItem*right=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"/Users/lihui/Desktop/Closer 7/Closer/Search_16px_1190971_easyicon.net.ico"] style:(UIBarButtonItemStylePlain) target:self action:@selector(rightAction)];
    
//    [right setTintColor:[UIColor colorWithRed:0.4 green:0.6 blue:0.1 alpha:0.6]];
    [right setWidth:60];
//    self.navigationItem.rightBarButtonItem=right;
    UIBarButtonItem*itemMap=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"/Users/lihui/Desktop/Closer 7/Closer/loacte_24px_1192125_easyicon.net.ico"] style:(UIBarButtonItemStylePlain) target:self action:@selector(itemMapAction)];
    
//    [itemMap setTintColor:[UIColor colorWithRed:0.3 green:0.2 blue:0.6 alpha:0.6]];
    self.navigationItem.rightBarButtonItems=@[right,itemMap];

   _textFiledNum=[[UITextField alloc]initWithFrame:CGRectMake(0, 30, 90, 30)];
    _textFiledNum.placeholder=@"输入人数";
    _textFiledNum.backgroundColor=[UIColor whiteColor];
    _textFiledNum.borderStyle=UITextBorderStyleRoundedRect;
    
   _textFiledDistance=[[UITextField alloc]initWithFrame:CGRectMake(0, 30, 90, 30)];
    _textFiledDistance.placeholder=@"输入范围";
    _textFiledDistance.borderStyle=UITextBorderStyleRoundedRect;
    [_searchView addSubview:_searchTextView];
    _textFiledDistance.backgroundColor=[UIColor whiteColor];
    
}
-(void)itemMapAction{
    LHMapViewController*mapVC=[[LHMapViewController alloc]init];
    mapVC.userArr=_userArr;
    [self.navigationController pushViewController:mapVC animated:YES];
    
    
}

-(void)rightAction{
    if (_searchView.hidden==YES) {
        _searchView.hidden=NO;
    }else{
        _searchView.hidden=YES;
        [self al];
    }
    if (_judgeAddView==YES) {
        [self al];
        return;
    }
    UISegmentedControl* seg=[[UISegmentedControl alloc]initWithItems:@[@"按人数搜索",@"按距离搜索"]];
    
    seg.frame=CGRectMake(0, 0, 180, 30);
  
    [seg addTarget:self action:@selector(segAction:) forControlEvents:(UIControlEventValueChanged)];
    
      [_searchView addSubview:seg];
    [self.view addSubview:_searchView];
    
    _judgeAddView=YES;
    
    if (_searchView.hidden==YES) {
        _searchView.hidden=NO;
    }else{
        _searchView.hidden=YES;
        [self al];
    }

}

-(void)al{
    
    _searchView.alpha=0;
    [UIView animateWithDuration:1.2 animations:^{
        _searchView.alpha=1;
        
    }];

}
-(void)segAction:(UISegmentedControl*)sender{

   
    [self setButton];
    switch (sender.selectedSegmentIndex) {
        case 0:
        {
            [_textFiledDistance removeFromSuperview];
            [_searchView addSubview:_textFiledNum];
          
            NSLog(@"0000");
            [_step removeFromSuperview];
                       break;
        }
        case 1:
        {_step=[[UIStepper alloc]initWithFrame:CGRectMake(0, 60, 0, 0)];
            [_searchView addSubview:_step];
            _step.maximumValue=100;
            _step.minimumValue=1;
            [_textFiledNum removeFromSuperview];
            _textFiledDistance.text=[NSString stringWithFormat:@"%f",_step.value];
            [_searchView addSubview:_textFiledDistance];
            
            
            
            [_step addTarget:self action:@selector(stepAction) forControlEvents:(UIControlEventValueChanged)];
            
            break;
        }
   
            
        default:
            break;
    }
    
}
-(void)stepAction{
    _textFiledDistance.text=[NSString stringWithFormat:@"%f",_step.value];
}
-(void)setButton{
    UIButton *button=[UIButton buttonWithType:(UIButtonTypeRoundedRect)];
    button=[[UIButton alloc]initWithFrame:CGRectMake(90, 30, 90, 30)];
    [button setTitle:@"search" forState:(UIControlStateNormal)];
    button.backgroundColor=[UIColor cyanColor];
    [button addTarget:self action:@selector(searchButtonAction) forControlEvents:(UIControlEventTouchUpInside)];
    [_searchView addSubview:button];
}
-(void)searchButtonAction{
      _number=[_textFiledNum.text integerValue];
    _extenKm=[_textFiledDistance.text floatValue];
    [LHnearbyTool downLoadNearbyUserWithNumber:_number distance:_extenKm block:^(NSArray *arr) {
        _userArr=arr;
        [_tableView reloadData];
        _searchView.hidden=YES;
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
