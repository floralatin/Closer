//
//  LHMapViewController.h
//  mpp
//
//  Created by 李辉 on 16/3/11.
//  Copyright © 2016年 李辉. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "LHnearbyModelForDistance.h"



@interface LHMapViewController : UIViewController

@property(nonatomic,strong)CLLocation*loctionSatrt;
@property(nonatomic,strong)CLLocation*loctionEnd;

@property(nonatomic,strong)LHnearbyModelForDistance*model;
@property(nonatomic,strong)NSArray*userArr;
@property(nonatomic,strong)NSString*detail;


@end

