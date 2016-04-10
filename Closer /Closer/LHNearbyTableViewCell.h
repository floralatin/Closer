//
//  LHNearbyTableViewCell.h
//  mpp
//
//  Created by 李辉 on 16/3/12.
//  Copyright © 2016年 李辉. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LHNearbyTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *icon;

@property (weak, nonatomic) IBOutlet UILabel *name;

@property (weak, nonatomic) IBOutlet UILabel *detailInfro;

@property (weak, nonatomic) IBOutlet UIButton *buttonGo;




@end
