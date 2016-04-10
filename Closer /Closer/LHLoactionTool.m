//
//  LHLoactionTool.m
//  mpp
//
//  Created by 李辉 on 16/3/10.
//  Copyright © 2016年 李辉. All rights reserved.

//
#import "LHLoactionTool.h"

#import "LOCoordinateTransformation.h"

#import "LHnearbyModelForDistance.h"
#import <AVOSCloud/AVOSCloud.h>

@interface LHLoactionTool ()<CLLocationManagerDelegate,sendLocationDelegate>

@property(nonatomic,assign)NSInteger num;

@end

@implementation LHLoactionTool

static LHLoactionTool *loctiontool=nil;
+(instancetype)shareLoction{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (loctiontool==nil) {
            
            loctiontool=[[LHLoactionTool alloc]init];
            
            [loctiontool setLoctionManger];
            
        }
        
        
    });
    
    
    
    return loctiontool;
    
}



-(void)setLoctionManger{
    self.manger=[[CLLocationManager alloc]init];
    self.manger.delegate=self;
//    self.geocoder=[[CLGeocoder alloc]init];
    self.reGeocoder=[[CLGeocoder alloc]init];
    
    //版本判断
    //    systemVersion是字符串 所以 需要 floatValue转换
    if ([[[UIDevice currentDevice] systemVersion]floatValue ]>=8.0) {
        
        //如果授权状态不是在前台使用
        if ([CLLocationManager authorizationStatus]!=kCLAuthorizationStatusAuthorizedWhenInUse) {
            
            //请求在前台使用
            [self.manger requestWhenInUseAuthorization];
            
        }
        
        
    }

    self.manger.desiredAccuracy=10;
    self.manger.distanceFilter=100;
    [self.manger startUpdatingLocation];
    
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
//    _num++;
    
    self.loction=[[CLLocation alloc]init];
    
//    self.loction=locations.firstObject.copy;

    self.loction=  [LOCoordinateTransformation transformToMars: locations.firstObject];

    [self regeocoderAction:[LOCoordinateTransformation transformToMars: locations.firstObject]];
    
    //返回objectId
    if ([LHLoactionTool shareLoction].userName==nil) {
        return;
    }
    NSLog(@"===%@",[LHLoactionTool shareLoction].userName);
    AVQuery *query = [AVQuery queryWithClassName:@"UserLoction"];
    [query whereKey:@"name" equalTo:[LHLoactionTool shareLoction].userName];
    [query getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        [LHLoactionTool shareLoction].objectId=object.objectId;
    }];
    
    
    //时时更新位置信息；
    if ([LHLoactionTool shareLoction].objectId==nil) {
        return;
    }
    AVObject *post=[AVObject objectWithoutDataWithClassName:@"UserLoction" objectId:[LHLoactionTool shareLoction].objectId];
    AVGeoPoint*point=[AVGeoPoint geoPointWithLatitude:[LHLoactionTool shareLoction].loction.coordinate.latitude longitude:[LHLoactionTool shareLoction].loction.coordinate.longitude];
    NSLog(@"%f",point.longitude);
    [post setObject:point forKey:@"loction"];
    //            [post]
    [post  saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            NSLog(@"存入成功");
        }
    }];


    
    
    //存入坐标
  
//        AVQuery*query=[AVQuery queryWithClassName:@"UserLoction"];
//        [query whereKey:@"name" equalTo:@"an"];
//        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//            AVObject *obj=[objects firstObject];
//          [LHLoactionTool shareLoction].objectId=obj[@"objectId"];
//
//            
//            NSLog(@"[LHLoactionTool shareLoction].objectId===%@",[LHLoactionTool shareLoction].objectId);
//        
//        }];
//
//    
//    if (_num==2) {
//        return;
//    }
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//    if (_num==1&&[LHLoactionTool shareLoction].objectId==nil ) {
//        AVObject*post=[AVObject objectWithoutDataWithClassName:@"UserLoction" objectId:[LHLoactionTool shareLoction].objectId];
//        [post setObject:@"an" forKey:@"name"];
//        AVGeoPoint*point=[AVGeoPoint geoPointWithLatitude:_loction.coordinate.latitude longitude:_loction.coordinate.longitude];
//        [post setObject:point forKey:@"loction"];
//        
//        [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//            
//            if (succeeded) {
//                
//                [LHLoactionTool shareLoction].objectId=post.objectId;
//            }
//        }];
//
//    }
    //    });
    
    
    
    
}


//反地理编码 （代理传出 loction dic）
-(void)regeocoderAction:(CLLocation*)loction{
     __weak typeof(self) weakself = self;
    [self.reGeocoder reverseGeocodeLocation:loction completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        CLPlacemark*placemark=placemarks.firstObject;
        self.loctionDic=placemark.addressDictionary.copy;
        NSLog(@"%@",self.loctionDic[@"City"]);
        NSLog(@"%@",placemark.addressDictionary);
        if (_delegate!=nil&&[_delegate respondsToSelector:@selector(sendLoctionWithLoction:dic:)]) {
            [weakself.delegate sendLoctionWithLoction:loction dic:placemarks.firstObject.addressDictionary];
        }
        
        
    }];
    
    
}

-(void)doA{
    
    
}


/*

//计算两个坐标之间的距离
-(double)distanceBettonLoctionOne:(CLLocation *)loctionOne anotherLoction:(CLLocation*)loctionAnother{
    
//    double dd=M_PI/180;
//    double x1=dd*loctionOne.coordinate.latitude,y1=loctionOne.coordinate.longitude*dd;
//    double x2=dd*loctionAnother.coordinate.latitude,y2=loctionAnother.coordinate.longitude*dd;
//    double R=6371004;
//    double distance = (2*R*asin(sqrt(2-2*cos(x1)*cos(x2)*cos(y1-y2) - 2*sin(x1)*sin(x2))/2));
//
    CLLocationDistance meters=[loctionOne distanceFromLocation:loctionAnother];
//    NSLog(@"3333333333");
//    NSLog(@"%@",loctionOne);
    
    return meters;
//
  //    return distance;
}

-(NSString*)distanceChangStringWithLoctionOne:(CLLocation*)loctionOne anotherLoction:(CLLocation *)loctionAnthoer{
    
    double distance=[self distanceBettonLoctionOne:loctionOne anotherLoction:loctionAnthoer];
    
    if (distance<2000) {
        NSString* str=[NSString stringWithFormat:@"距离我%.2fm",distance];
        return str;
    }else{
        
        NSString*str=[NSString stringWithFormat:@"距离我 %.2fkm",distance/1000];
        return str;
    }
    
}


-(NSString*)ReturnDistace:(CGFloat)distance{
    
    if (distance<2000) {
        NSString* str=[NSString stringWithFormat:@"距离我%.2fm",distance];
        return str;
    }else{
        
        NSString*str=[NSString stringWithFormat:@"距离我 %.2fkm",distance/1000];
        return str;
    }

    
}


//暂时没用到的方法
-(NSMutableArray*)sortByDistanceWithArray:(NSArray*)array{
    
    NSMutableArray*arr=[NSMutableArray array];
    for (LHNearByModel *model in array) {
        CLLocation *loctionAn=[[CLLocation alloc]initWithLatitude:model.litatude longitude:model.longtitude];
         CGFloat distace= [self distanceBettonLoctionOne:[LHLoactionTool shareLoction].loction anotherLoction:loctionAn];
        
        LHnearbyModelForDistance*distanceModel=[[LHnearbyModelForDistance alloc]init];
        distanceModel.name=model.name;
        distanceModel.distance=distace;
        distanceModel.loction=loctionAn;
        [arr addObject:distanceModel];

    }
    
    [arr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
       return  [obj1 distance]>[obj2 distance];
    }];
    
    return arr;
    
}

// 返回用户的排序
-(NSMutableArray*)sortByDistanceWithUserArray:(NSArray*)array{
    
    NSMutableArray*arr=[NSMutableArray array];
    for ( AVUser*user in array) {
        AVGeoPoint*point=user[@"loction"];
        CLLocation *loctionAn=[[CLLocation alloc]initWithLatitude:point.latitude longitude:point.longitude];
        CGFloat distace= [self distanceBettonLoctionOne:[LHLoactionTool shareLoction].loction anotherLoction:loctionAn];
        
        LHnearbyModelForDistance*distanceModel=[[LHnearbyModelForDistance alloc]init];
        distanceModel.name=user[@"name"];
        NSLog(@"%@",distanceModel.name);
        distanceModel.distance=distace;
        distanceModel.loction=loctionAn;
        
        [arr addObject:distanceModel];
        
    }
    
    [arr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return  [obj1 distance]>[obj2 distance];
    }];
    
    NSLog(@"%@",arr);
    return arr;
    
}

//根据相应数量或者距离下载相应的用户位置
-(void)downLoadNearbyUserWithNumber:(NSInteger)number distance:(CGFloat)distace{
   __block NSArray*arr=[NSArray array];
    AVQuery *query = [AVQuery queryWithClassName:@"UserLoction"];
    
    AVGeoPoint *point = [AVGeoPoint geoPointWithLatitude:[LHLoactionTool shareLoction].loction.coordinate.latitude longitude:[LHLoactionTool shareLoction].loction.coordinate.longitude];
    NSLog(@"loction==%f",point.longitude);
    query.limit = number;
    [query whereKey:@"loction" nearGeoPoint:point];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        NSArray<AVObject *> *nearbyTodos = objects;// 离这个位置最近的 10 个 Todo 对象
        NSLog(@"aaaa===%ld",objects.count);
        NSLog(@"%@",error);
        
        
       arr= [self sortByDistanceWithUserArray:objects];
        NSLog(@"arrr======%@",arr);
        [self performSelectorOnMainThread:@selector(mainAction:) withObject:arr waitUntilDone:YES];
        
        
    }];
  
//    return arr;
}




-(void)mainAction:(NSArray*)arr{
    [self.delegate sendUserArray:arr];
}

*/







@end
