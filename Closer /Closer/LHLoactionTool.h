//
//  LHLoactionTool.h
//  mpp
//
//  Created by 李辉 on 16/3/10.
//  Copyright © 2016年 李辉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@protocol sendLocationDelegate <NSObject>

//传出坐标信息和位置信息
@optional
-(void)sendLoctionWithLoction:(CLLocation*)loction dic:(NSDictionary*)dic;
//传出排序好的数组，代理方法
//-(void)sendUserArray:(NSArray*)arr;


@end


@interface LHLoactionTool : NSObject

@property(nonatomic,strong)CLLocationManager*manger;
@property(nonatomic,strong)CLGeocoder*geocoder;
@property(nonatomic,strong)CLGeocoder*reGeocoder;
@property(nonatomic,strong)NSMutableArray*array;

@property(nonatomic,strong)NSDictionary*loctionDic;

@property(nonatomic,strong)CLLocation*loction;
@property(nonatomic,weak)id<sendLocationDelegate>delegate;

@property(nonatomic,strong)NSString*objectId;

@property(nonatomic,strong)NSString*userName;

@property(nonatomic,strong)UIImage*icon;


+(instancetype)shareLoction;

//-(double)distanceBettonLoctionOne:(CLLocation *)loctionOne anotherLoction:(CLLocation*)loctionAnother;
//
//
//
//-(NSString*)distanceChangStringWithLoctionOne:(CLLocation*)loctionOne anotherLoction:(CLLocation *)loctionAnthoer;
//
////返回排序数组
//-(NSMutableArray*)sortByDistanceWithArray:(NSArray*)array;
//
////  返回距离字符串
//
//-(NSString*)ReturnDistace:(CGFloat)distance;
//
//-(void)downLoadNearbyUserWithNumber:(NSInteger)number distance:(CGFloat)distace;
////返回距离
//















@end
