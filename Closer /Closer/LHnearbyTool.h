//
//  LHnearbyTool.h
//  mpp
//
//  Created by 李辉 on 16/3/17.
//  Copyright © 2016年 李辉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

typedef void(^sendImagaBlock)(UIImage*image);
typedef void(^sendArrBlock)(NSArray*arr);
@interface LHnearbyTool : NSObject






//计算两个坐标之间的距离
+(double)distanceBettonLoctionOne:(CLLocation *)loctionOne anotherLoction:(CLLocation*)loctionAnother;
+(NSString*)ReturnDistace:(CGFloat)distance;

// 返回用户的排序
+(NSMutableArray*)sortByDistanceWithUserArray:(NSArray*)array;

//根据相应数量或者距离下载相应的用户位置
+(void)downLoadNearbyUserWithNumber:(NSInteger)number distance:(CGFloat)distace block:(sendArrBlock)block;
//go

+(void)turnByTuenWithOneLoction:(CLLocation*)loctionStart endLoction:(CLLocation*)loctionEnd;

//图片下载
+(void)downLoadUserImage:(NSString*)name block:(sendImagaBlock)block;

//图片分割
+(UIImage*)captureView:(UIView *)theView frame:(CGRect)fra;








@end
