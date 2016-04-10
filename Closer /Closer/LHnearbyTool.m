//
//  LHnearbyTool.m
//  mpp
//
//  Created by 李辉 on 16/3/17.
//  Copyright © 2016年 李辉. All rights reserved.
//

#import "LHnearbyTool.h"
#import "LHnearbyModelForDistance.h"
#import <AVOSCloud/AVOSCloud.h>
#import "LHLoactionTool.h"



@implementation LHnearbyTool


//计算两个坐标之间的距离
+(double)distanceBettonLoctionOne:(CLLocation *)loctionOne anotherLoction:(CLLocation*)loctionAnother{
    CLLocationDistance meters=[loctionOne distanceFromLocation:loctionAnother];
    return meters;
    
}
+(NSString*)ReturnDistace:(CGFloat)distance{
    if (distance<2000) {
        NSString* str=[NSString stringWithFormat:@"距离我%.2fm",distance];
        return str;
    }else{
        
        NSString*str=[NSString stringWithFormat:@"距离我 %.2fkm",distance/1000];
        return str;
    }
}

// 返回用户的排序
+(NSMutableArray*)sortByDistanceWithUserArray:(NSArray*)array{
    NSString*name=[LHLoactionTool shareLoction].userName;
    NSMutableArray*arr=[NSMutableArray array];
    NSMutableArray*arrFinal=[NSMutableArray array];
    for ( AVUser*user in array) {
        AVGeoPoint*point=user[@"loction"];
        CLLocation *loctionAn=[[CLLocation alloc]initWithLatitude:point.latitude longitude:point.longitude];
        CGFloat distace= [self distanceBettonLoctionOne:[LHLoactionTool shareLoction].loction anotherLoction:loctionAn];
        
        LHnearbyModelForDistance*distanceModel=[[LHnearbyModelForDistance alloc]init];
        distanceModel.name=user[@"name"];
        NSLog(@"%@",distanceModel.name);
        distanceModel.distance=distace;
        distanceModel.loction=loctionAn;
        AVFile*imageFile=user[@"icon"];
        NSData*imgdata=[imageFile getData];
        distanceModel.icon=[UIImage imageWithData:imgdata];
        [arr addObject:distanceModel];
        
    }
    
    [arr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return  [obj1 distance]>[obj2 distance];
    }];
    NSLog(@"%@",name);
    for (LHnearbyModelForDistance*model in arr ) {
        if (![model.name isEqualToString:name]) {
            
            [arrFinal addObject:model];
        }
    }
    
    //    LHnearbyModelForDistance*model =arr[0];
//    NSLog(@"%@",model.name);
    
    return arrFinal;

    
}

//根据相应数量或者距离下载相应的用户位置
+(void)downLoadNearbyUserWithNumber:(NSInteger)number distance:(CGFloat)distace block:(sendArrBlock)block{
    
//    __block NSArray*arr=[NSArray array];
    AVQuery *query = [AVQuery queryWithClassName:@"UserLoction"];
    
    AVGeoPoint *point = [AVGeoPoint geoPointWithLatitude:[LHLoactionTool shareLoction].loction.coordinate.latitude longitude:[LHLoactionTool shareLoction].loction.coordinate.longitude];
    NSLog(@"loction==%f",point.longitude);
    if (number==0) {
        number=20;
    }
    if (number==20||number>0) {
        query.limit=number;
    }if (distace>0&&number==20) {
        [query whereKey:@"loction" nearGeoPoint:point withinKilometers:distace];
    }
    
    [query whereKey:@"loction" nearGeoPoint:point];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        //        NSArray<AVObject *> *nearbyTodos = objects;// 离这个位置最近的 10 个 Todo 对象
//        NSLog(@"aaaa===%ld",objects.count);
        NSLog(@"%@",error);
        
        
       NSArray* arr= [self sortByDistanceWithUserArray:objects];
        
        if (block) {
            block(arr);
        }
        
    }];

}
+(void)turnByTuenWithOneLoction:(CLLocation*)loctionStart endLoction:(CLLocation*)loctionEnd{
    
    CLGeocoder*_geoStart=[[CLGeocoder alloc]init];
    
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




+(void)downLoadUserImage:(NSString *)name block:(sendImagaBlock)block{
    if (name==nil) {
        return;
    }
    AVQuery*query=[AVQuery queryWithClassName:@"UserLoction"];
    [query whereKey:@"name" equalTo:name];
    [query getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        AVFile *file=object[@"icon"];
        NSData*imageData=[file getData];
        UIImage*image= [UIImage imageWithData:imageData];
        block(image);
    }];
}


//图片切割；
+(UIImage*)captureView:(UIView *)theView frame:(CGRect)fra{
    UIGraphicsBeginImageContext(theView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [theView.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRef ref = CGImageCreateWithImageInRect(img.CGImage, fra);
    UIImage *i = [UIImage imageWithCGImage:ref];
    CGImageRelease(ref);
    return i;
}




@end
