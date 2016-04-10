//
//  LHMapViewController.m
//  mpp
//
//  Created by 李辉 on 16/3/11.
//  Copyright © 2016年 李辉. All rights reserved.
//

#import "LHMapViewController.h"
#import "LHLoactionTool.h"
#import "MapAnimation.h"
#import "LHDisplayNearbyViewController.h"
#import "LHnearbyTool.h"
#import "RefrashView.h"

//@class MapAnimation;


@interface LHMapViewController ()<MKMapViewDelegate>
@property(nonatomic,strong)MKMapView*mapView;

@property(nonatomic,strong)CLGeocoder*geocoder;
@property(nonatomic,strong)CLGeocoder*geoStart;
@property(nonatomic,strong)CLGeocoder*geoEnd;
@property(nonatomic,strong)RefrashView*refrashView;
@property(nonatomic,strong)NSTimer*timer;
@end

@implementation LHMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _geocoder=[[CLGeocoder alloc]init];
    _geoStart=[[CLGeocoder alloc]init];
    _geoEnd=[[CLGeocoder alloc]init];
    
    self.mapView=[[MKMapView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
    
    CLLocationCoordinate2D lo2d = CLLocationCoordinate2DMake([LHLoactionTool shareLoction].loction.coordinate.latitude, [LHLoactionTool shareLoction].loction.coordinate.longitude);//中心
    //坐标范围
    MKCoordinateSpan span = MKCoordinateSpanMake(0.7, 0.7);
    //设置地图显示的范围和中心
    MKCoordinateRegion coor = MKCoordinateRegionMake(lo2d, span);
    //设置地图种类
    self.mapView.mapType = MKMapTypeStandard;
    //设置代理
    self.mapView.delegate = self;
    
    //地图是否可以旋转
    self.mapView.rotateEnabled = NO;//不可旋转
//    /展示用户位置
    self.mapView.showsUserLocation = YES;
    
    [self.mapView setRegion:coor];
    //把地图添加到视图上
    [self.view addSubview:self.mapView];
    
    //添加大头针
    [self addAnnotation];
    
    
    _loctionSatrt=[LHLoactionTool shareLoction].loction;
  
    _loctionEnd=[[CLLocation alloc]initWithLatitude:31.2 longitude:121.4];
      NSLog(@"%@",_loctionEnd);
    NSLog(@"%@",_loctionSatrt);
    
    
    [self setRightView];
    
    // Do any additional setup after loading the view.
}
-(void)setRightView{
       UIBarButtonItem*item=[[UIBarButtonItem alloc]initWithTitle:@"刷新" style:(UIBarButtonItemStyleDone) target:self action:@selector(rightAction)];
    self.navigationItem.rightBarButtonItem=item;
}

-(void)rightAction{
//
    [LHnearbyTool downLoadNearbyUserWithNumber:0 distance:0 block:^(NSArray *arr) {
        _userArr=arr;
    }];

    [_refrashView removeFromSuperview];
    [self.timer invalidate];
    _refrashView=[[RefrashView alloc]initWithFrame:CGRectMake(0, (self.view.frame.size.height)/2-self.view.frame.size.width/2, self.view.frame.size.width,self.view.frame.size.width)];
    _refrashView.layer.cornerRadius=self.view.frame.size.width/2;
    _refrashView.layer.masksToBounds=YES;
    
    
    _refrashView.alpha=0.4;
    _refrashView.backgroundColor=[UIColor whiteColor];
    
    self.timer=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(rotationAction) userInfo:nil repeats:YES];
    
    
    _refrashView.userInteractionEnabled=NO;
    [self.view addSubview:_refrashView];
    
    __weak typeof(self) weakSelf=self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_refrashView removeFromSuperview];
        [LHnearbyTool downLoadNearbyUserWithNumber:20 distance:0 block:^(NSArray *arr) {
            _userArr=arr;
            [weakSelf addAnnotation];

        }];
    });
    
    
}

-(void)rotationAction{
    [UIView animateWithDuration:1 animations:^{
        _refrashView.transform =CGAffineTransformRotate(_refrashView.transform, M_PI/30);
    }];
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    
//
//    [self turnByTurn];
}


-(void)turnByTuenWithOneLoction:(CLLocation*)loctionStart endLoction:(CLLocation*)loctionEnd{
    
    
    
    [_geoStart reverseGeocodeLocation:loctionStart completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        CLPlacemark*clPlaceMarkStart=[placemarks firstObject];
        NSLog(@"clPlaceMarkStart==%@",clPlaceMarkStart);
        MKPlacemark*mkPlacemarkStart=[[MKPlacemark alloc]initWithPlacemark:clPlaceMarkStart];
        [_geoStart reverseGeocodeLocation:loctionEnd completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            
            
            
            CLPlacemark*clPlacemarkEed=[placemarks firstObject];
            
            NSLog(@"%@",clPlacemarkEed);
            NSLog(@"%@",loctionEnd);
            MKPlacemark *mkPlacemarkEed=[[MKPlacemark alloc]initWithPlacemark:clPlacemarkEed];
            
                NSDictionary*options=@{MKLaunchOptionsMapTypeKey:@(MKMapTypeStandard),MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving};
                MKMapItem*mapItemStart=[[MKMapItem alloc]initWithPlacemark:mkPlacemarkStart];
                MKMapItem*mapItemEnd=[[MKMapItem alloc]initWithPlacemark:mkPlacemarkEed];
                [MKMapItem openMapsWithItems:@[mapItemStart,mapItemEnd] launchOptions:options];

        }];
        
        
    }];
    
    
}

//add annotation;
-(void)addAnnotation{
    CLLocationCoordinate2D location1=[LHLoactionTool shareLoction].loction.coordinate;
    
//      MapAnimation *annotation1=[[ MapAnimation alloc]init];
//    annotation1.title=@"我的位置";
//    annotation1.index=1;
////    annotation1.subtitle=@"Kenshin Cui's Studios";
//    annotation1.coordinate=location1;
//    [_mapView addAnnotation:annotation1];
    
    for (int i=0; i<_userArr.count; i++) {
        LHnearbyModelForDistance*model=_userArr[i];
       
        MapAnimation *annotation=[[MapAnimation alloc]init];
        annotation.title=model.name;
        annotation.coordinate=model.loction.coordinate;
        annotation.index=i;
        [_mapView addAnnotation:annotation];
    }
    
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    if (![view.annotation isKindOfClass:[MapAnimation class]]) {
        return;
    }
    MapAnimation*anomationmy=view.annotation;
    LHDisplayNearbyViewController*disVC=[[LHDisplayNearbyViewController alloc]init];
    disVC.model=_userArr[anomationmy.index];
    disVC.detail=[LHnearbyTool ReturnDistace:disVC.model.distance ];
    
    [self.navigationController pushViewController:disVC animated:YES];
    
}

//-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
//    if ([annotation isKindOfClass:[MapAnimation class]]) {
//        
//        static NSString*key=@"mapAnkey";
//        MKAnnotationView *annotationView=[_mapView dequeueReusableAnnotationViewWithIdentifier:key];
//        
//        if (!annotationView) {
//            annotationView=[[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:key];
//            annotationView.canShowCallout=true;
//            
//        }
//        
//        annotationView.annotation=annotation;
//        annotationView.image=[UIImage imageNamed:@""];
//        return annotationView;
//    }else{
//        
//        return nil;
//    }
//    
//    
//    
//    
//}






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
