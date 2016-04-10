//
//  LHDisplayNearbyViewController.h
//  mpp
//
//  Created by 李辉 on 16/3/14.
//  Copyright © 2016年 李辉. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LHnearbyModelForDistance.h"


@interface LHDisplayNearbyViewController : UIViewController

@property(nonatomic,strong)LHnearbyModelForDistance*model;

@property(nonatomic,strong)NSString*detail;

@property(nonatomic,strong)UIImage*image;




@end
