//
//  LeanCloudTools.h
//  Closer
//
//  Created by zhangkai on 16/3/11.
//  Copyright © 2016年 Closer_All. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,TypeOfLeanCloud) {
    
        userIsExistedError=101,
        userRegisterError=102,
        userLoginError=103,
        userIsNotExisted=104,
    
    userRegisterSuccess=120,
    userLoginSuccess=121,
};

@interface LeanCloudTools : NSObject

+(TypeOfLeanCloud)registerUserWith:(NSString*)username and:(NSString*)password;

+(TypeOfLeanCloud)loginUserWith:(NSString*)username and:(NSString*)password;

+(NSArray*)getAllUser;
+(TypeOfLeanCloud)queryWithUsername:(NSString*)username;

@end
