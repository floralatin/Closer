//
//  AppDelegate.m
//  Closer
//
//  Created by zhangkai on 16/3/10.
//  Copyright © 2016年 Closer_All. All rights reserved.
//

#import "AppDelegate.h"

//环信
#import <EaseMobSDKFull/EaseMob.h>
//leancloud
#import <AVOSCloud/AVOSCloud.h>


#pragma mark - 环信AppKey
#define HuanXinAppKey @"1973#closer"

#pragma mark - LeanCloudAppKey
#define LeanCloudAppID @"66I2RkERytvBIDrndHJT75xs-gzGzoHsz"
#define LeanCloudAppKey @"Y15iEOyQ9XFldHfFvwMg1sNr"


#import "LoginViewController.h"
#import "LHLoactionTool.h"

@interface AppDelegate ()<IChatManagerDelegate,UIAlertViewDelegate>

@property(nonatomic,strong)NSString  *username;
@property(nonatomic,strong)NSString  *message;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
   

    
  
    
#pragma mark - 连接环信
    @try {
        //registerSDKWithAppKey:注册的appKey
        //apnsCertName:推送证书名
        [[EaseMob sharedInstance] registerSDKWithAppKey:HuanXinAppKey apnsCertName:nil];
        
        [[EaseMob sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    }
    @catch (NSException *exception) {
        
    }
#pragma mark - 连接leanCloud
    @try {
        [AVOSCloud setApplicationId:LeanCloudAppID
                          clientKey:LeanCloudAppKey];
    }
    @catch (NSException *exception) {
        NSLog(@"LeanCloud服务器连接错误");
    }
    //注册监听对象
    [[EaseMob sharedInstance].chatManager  addDelegate:self delegateQueue:nil];
    return YES;
}

-(void)didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error{
    [LHLoactionTool shareLoction].userName=loginInfo[@"username"];
    NSLog(@"ppppppppp");
    NSLog(@"%@",loginInfo[@"username"]);
    
}
//接受到好友请求
- (void)didReceiveBuddyRequest:(NSString *)username
                       message:(NSString *)message{
    self.username=username;
    self.message=message;
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:username message:message delegate:self cancelButtonTitle:@"拒绝" otherButtonTitles: @"接受",nil];
    
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        EMError *error = nil;
        BOOL isSuccess = [[EaseMob sharedInstance].chatManager acceptBuddyRequest:self.username error:&error];
        if (isSuccess && !error) {
            NSLog(@"发送同意成功");
        }
    }
    else{
        EMError *error = nil;
        BOOL isSuccess = [[EaseMob sharedInstance].chatManager rejectBuddyRequest:self.username reason:@"你是谁？" error:&error];
        if (isSuccess && !error) {
            NSLog(@"发送拒绝成功");
            
        }
    }
}
//接受好友请求处理的信息
- (void)didAcceptedByBuddy:(NSString *)username{
    
    NSLog(@"接受到%@好友的处理结果为---接受",username);
}
- (void)didRejectedByBuddy:(NSString *)username{
    
    NSLog(@"接受到%@好友的处理结果为---拒绝",username);
}

- (void)applicationWillResignActive:(UIApplication *)application{
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
    
    //进入后台
    [[EaseMob sharedInstance] applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    //进入前台
    [[EaseMob sharedInstance] applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    //加载时间
    [[EaseMob sharedInstance] applicationWillTerminate:application];
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "Closer-Unit.Closer" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Closer" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Closer.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
