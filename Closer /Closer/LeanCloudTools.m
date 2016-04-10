//
//  LeanCloudTools.m
//  Closer
//
//  Created by zhangkai on 16/3/11.
//  Copyright © 2016年 Closer_All. All rights reserved.
//

#import "LeanCloudTools.h"
#import <AVQuery.h>
@implementation LeanCloudTools

+(TypeOfLeanCloud)registerUserWith:(NSString*)username and:(NSString*)password{

        AVObject *addUser = [[AVObject alloc] initWithClassName:@"Closer_user"];// 构建对象
        [addUser setObject:username  forKey:@"username"];
        [addUser setObject:password forKey:@"password"];
        NSError *error=nil;
        [addUser save:&error];// 保存到服务端
        if (!error) {
            NSLog(@"注册成功");
            return userRegisterSuccess;
        }else{
            NSLog(@"注册失败");
            return userRegisterError;
        }
    
}

+(TypeOfLeanCloud)queryWithUsername:(NSString*)username{

    AVQuery *query =[AVQuery queryWithClassName:@"Closer_user"];
    [query whereKey:@"username" equalTo:username];
    if ( [query getFirstObject]) {
        return userIsExistedError;
    }
    else{
        return userIsNotExisted;
    }
}

+(NSArray*)getAllUser{
    AVQuery  *query=[AVQuery queryWithClassName:@"Closer_user"];
    [query whereKey:@"username"  notEqualTo:@""];
    NSError *error;
   NSArray *array= [query findObjects:&error];
    if (!error) {
        NSLog(@"%@",array);
        return array;
    }
    else {
        NSLog(@"sdasdasdasd%@",error);
        return nil;
    }
}

+(TypeOfLeanCloud)loginUserWith:(NSString*)username and:(NSString*)password{
    AVQuery  *query=[AVQuery queryWithClassName:@"Closer_user"];
    [query whereKey:@"username"  equalTo:username];
    [query whereKey:@"password"  equalTo:password];
    NSError *error;
     [query getFirstObject:&error];
    
    if (!error) {
        NSLog(@"登陆成功");
        return userLoginSuccess;
    }
    else {
         NSLog(@"登陆失败");
        return userLoginError;
    }
}

@end
