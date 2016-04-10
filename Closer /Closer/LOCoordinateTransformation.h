//
//  LOCoordinateTransformation.h
//  CoreLocation_text1
//
//  Created by 杨少锋 on 16/1/19.
//  Copyright © 2016年 杨少锋. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CLLocation;

@interface LOCoordinateTransformation : NSObject

+ (CLLocation *)transformToMars:(CLLocation *)location ;

@end
