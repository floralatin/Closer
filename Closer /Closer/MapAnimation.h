//
//  MapAnimation.h
//  mpp
//
//  Created by 李辉 on 16/3/15.
//  Copyright © 2016年 李辉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface MapAnimation : NSObject<MKAnnotation>

@property (nonatomic,assign) CLLocationCoordinate2D coordinate;//本身是一个结构体
@property (nonatomic,  copy) NSString *title;
@property (nonatomic,  copy) NSString *subtitle;
@property (nonatomic,  copy) NSString * icon;

@property(nonatomic,assign) NSInteger index;


@end
