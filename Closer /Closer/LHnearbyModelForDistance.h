//
//  LHnearbyModelForDistance.h
//  mpp
//
//  Created by 李辉 on 16/3/15.
//  Copyright © 2016年 李辉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface LHnearbyModelForDistance : NSObject

@property(nonatomic,strong)NSString*name;

@property(nonatomic,assign)CGFloat distance;

@property(nonatomic,strong)CLLocation*loction;

@property(nonatomic,strong)UIImage*icon;

@end
