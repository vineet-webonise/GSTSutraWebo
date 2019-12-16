//
//  AppDelegate.m
//  GSTSutra
//
//  Created by niyuj on 10/20/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "HomeViewController.h"
#import "Constants.h"
#import <UserNotifications/UserNotifications.h>
#import "FMDatabase.h"
#import "videoPlayerViewController.h"
#import "AGPushNoteView.h"
@import Firebase;


@interface AppDelegate ()<UNUserNotificationCenterDelegate>{
    UIStoryboard  *storyboard;
    UINavigationController *navigationController;
}

@end

@implementation AppDelegate

#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#pragma mark -
#pragma mark - Application Life Cycle.
#pragma mark -

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //sleep(1.5);
    
    // Use Firebase library to configure APIs
    [FIRApp configure];
    
    //NSLog(@"Devide Token %@", [ USERDEFAULTS valueForKey:@"deviceID"]);
    [USERDEFAULTS setBool:YES forKey:@"appLaunch"];

    //change status bar color white
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    self.container = (MFSideMenuContainerViewController *)self.window.rootViewController;
    navigationController = [storyboard instantiateViewControllerWithIdentifier:@"navigationController"];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:42/255.0 green:49/255.0 blue:73/255.0 alpha:1.0]];
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    
    // Create data base in Document Directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *path = [docsPath stringByAppendingPathComponent:@"GSTSutraFMDB.sqlite"];
   self.database = [FMDatabase databaseWithPath:path];
    
    if ([USERDEFAULTS boolForKey:@"HasLaunchedOnce"])
    {
        // app already launched.
        //NSLog(@" Not first launched");
        
        if ([USERDEFAULTS boolForKey:@"isLogin"] ){
            // open login screen.
            [self registerForPushNotification];
            //NSLog(@"Device Token %@",[USERDEFAULTS valueForKey:@"deviceID"]);
            if ([USERDEFAULTS boolForKey:@"isNotRegisterOrLoginUser"]) {
                [navigationController setViewControllers:[NSArray arrayWithObjects:[storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"],nil]];
            }else if ([USERDEFAULTS boolForKey:@"isVerified"]) {
                [navigationController setViewControllers:[NSArray arrayWithObjects:[storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"],nil]];
            } else {
                [navigationController setViewControllers:[NSArray arrayWithObjects:[storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"],nil]];
            }
            
            
        } else {
            self.isNotLoginOrRegister = YES;
            [navigationController setViewControllers:[NSArray arrayWithObjects:[storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"],nil]];
        }
        
    }else{
        [USERDEFAULTS setBool:YES forKey:@"HasLaunchedOnce"];
        [USERDEFAULTS setBool:YES forKey:@"isNotRegisterOrLoginUser"];
        [USERDEFAULTS setValue:@"6cc466b19a4d77920b3707d0636f57ca" forKey:@"userToken"];
        [USERDEFAULTS setBool:YES forKey:@"isLogin"];
        [USERDEFAULTS  setValue:@"Login/Register" forKey:@"fullName"];
        [USERDEFAULTS synchronize];
        // Set medium fotn to app  
        [USERDEFAULTS setObject:@"medium" forKey:@"font"];
        [USERDEFAULTS setObject:@"14" forKey:@"titleFont"];
        [USERDEFAULTS setObject:@"12" forKey:@"normalFont"];
        
        //NSLog(@"first time launched");
        NSString *appName=[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
        NSString *strApplicationUUID = [SSKeychain passwordForService:appName account:@"incoding"];
        if (strApplicationUUID == nil)
        {
            strApplicationUUID  = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
            [SSKeychain setPassword:strApplicationUUID forService:appName account:@"incoding"];
        }
        //        store Device ID
        [USERDEFAULTS setValue:strApplicationUUID forKey:@"macID"];
        [USERDEFAULTS synchronize];
        
        [navigationController setViewControllers:[NSArray arrayWithObjects:[storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"],nil]];
        
        
        
    }
    
    //[self.window setRootViewController:navigationController];
    UIViewController *leftSideMenuViewController = [storyboard instantiateViewControllerWithIdentifier:@"LeftSideViewController"];
    [self.container setLeftMenuViewController:leftSideMenuViewController];
    [self.container setCenterViewController:navigationController];
    // Register for pushNotification .
    [self registerForPushNotification];
    
    return YES;
}

#pragma mark Register for Push notification

-(void)registerForPushNotification {
    if(SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            if( !error ){
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            }
        }];
    }
    else {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}


- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *deviceTokenString = [NSString stringWithFormat:@"%@",deviceToken];
    deviceTokenString = [deviceTokenString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceTokenString = [deviceTokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
    deviceTokenString = [deviceTokenString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceTokenString = [deviceTokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (deviceTokenString.length!=0 || deviceTokenString != (id)[NSNull null]) {
        [ USERDEFAULTS setValue:deviceTokenString forKey:@"deviceID"];
        [USERDEFAULTS synchronize];
    } else{
        [ USERDEFAULTS setValue:@"665df2b09903480fed39a48b742316ecd72e745c658c691fa22a9c0eedaba583" forKey:@"deviceID"];
        [USERDEFAULTS synchronize];
        
    }
    
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    if (notificationSettings.types != UIUserNotificationTypeNone) {
        [application registerForRemoteNotifications];
    }
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(currentUserNotificationSettings)]){
        
        UIUserNotificationSettings *grantedSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
        
        if (grantedSettings.types == UIUserNotificationTypeNone) {
            //NSLog(@"No permiossion granted");
            [ USERDEFAULTS setValue:@"665df2b09903480fed39a48b742316ecd72e745c658c691fa22a9c0eedaba583" forKey:@"deviceID"];
            [USERDEFAULTS synchronize];
        }
        else if (grantedSettings.types & UIUserNotificationTypeSound & UIUserNotificationTypeAlert ){
            //NSLog(@"Sound and alert permissions ");
        }
        else if (grantedSettings.types  & UIUserNotificationTypeAlert){
            //NSLog(@"Alert Permission Granted");
            
        }
    }
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSString *str = [NSString stringWithFormat: @"Error: %@", err];
    //NSLog(@"Error %@",str);
}



- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"Notification Data %@",userInfo);
    
    if([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive){
            // News == 8
        if ([[[userInfo valueForKey:@"aps"] valueForKey:@"type"] integerValue] == 8){
            
            _isFromNotification = YES;
            _sid = [NSString stringWithFormat:@"%@",[[userInfo valueForKey:@"aps"] valueForKey:@"sid"]];
            if ([USERDEFAULTS boolForKey:@"isNotRegisterOrLoginUser"]) {
                
                _stype = 8;
                _isFromNotificationAndLogin = YES;
                [self openLoginViewController];
            }else{
                [navigationController pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"LongNewsViewController"] animated:YES];
            }
        } // expert corner  == 9
        
        else if ([[[userInfo valueForKey:@"aps"] valueForKey:@"type"] integerValue] ==9){
            _isFromNotification = YES;
            _sid = [NSString stringWithFormat:@"%@",[[userInfo valueForKey:@"aps"] valueForKey:@"sid"]];
            if ([USERDEFAULTS boolForKey:@"isNotRegisterOrLoginUser"]) {
                
                _stype = 9;
                _isFromNotificationAndLogin = YES;
                [self openLoginViewController];
            }else{
                [navigationController pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"ExpertLongViewController"] animated:YES];
            }
        }
        
        // Expert Take == 11
        
        else if ([[[userInfo valueForKey:@"aps"] valueForKey:@"type"] integerValue] ==11){
            _isFromNotification = YES;
            _sid = [NSString stringWithFormat:@"%@",[[userInfo valueForKey:@"aps"] valueForKey:@"sid"]];
            if ([USERDEFAULTS boolForKey:@"isNotRegisterOrLoginUser"]) {
                
                _stype = 11;
                _isFromNotificationAndLogin = YES;
                [self openLoginViewController];
            }else{
                [navigationController pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"ExpertTakeLngViewController"] animated:YES];
            }
        }
        
        // Video == 25
        
        else if ([[[userInfo valueForKey:@"aps"] valueForKey:@"type"] integerValue] ==25){
            _isFromNotification = YES;
            _sid = [NSString stringWithFormat:@"%@",[[userInfo valueForKey:@"aps"] valueForKey:@"sid"]];
            if ([USERDEFAULTS boolForKey:@"isNotRegisterOrLoginUser"]) {
                
                
                _stype = 25;
                _isFromNotificationAndLogin = YES;
                [self openLoginViewController];
            }else{
                [navigationController pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"videoPlayerViewController"] animated:YES];
            }
        }
        
        // site link == 22
        
        else if ([[[userInfo valueForKey:@"aps"] valueForKey:@"type"] integerValue] ==22){
            _isFromNotification = YES;
            _sid = [NSString stringWithFormat:@"%@",[[userInfo valueForKey:@"aps"] valueForKey:@"sid"]];
            if ([USERDEFAULTS boolForKey:@"isNotRegisterOrLoginUser"]) {
                
                _stype = 22;
                _isFromNotificationAndLogin = YES;
                [self openLoginViewController];
            }else{
                [navigationController pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"SiteLinksViewController"] animated:YES];
            }
        }
        
        // Forum Discussion == 23
        
        else if ([[[userInfo valueForKey:@"aps"] valueForKey:@"type"] integerValue] ==23){
            _isFromNotification = YES;
            _sid = [NSString stringWithFormat:@"%@",[[userInfo valueForKey:@"aps"] valueForKey:@"sid"]];
            if ([USERDEFAULTS boolForKey:@"isNotRegisterOrLoginUser"]) {
                
                _stype = 23;
                _isFromNotificationAndLogin = YES;
                [self openLoginViewController];
            }else{
                [navigationController pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"ForumDetailViewController"] animated:YES];
                
            }
        }
        
        // for any other type of Notification send to Home screen
        
        else {
            if ([USERDEFAULTS boolForKey:@"isNotRegisterOrLoginUser"]) {
            }else{
                [navigationController pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"] animated:YES];
            }
        }

        
    } else {
        
        // app is active
        
        [AGPushNoteView showWithNotificationMessage:[[[userInfo valueForKey:@"aps"] valueForKey:@"alert"] objectForKey:@"body"]];
        
        [AGPushNoteView setMessageAction:^(NSString *message) {
            // News == 8
            if ([[[userInfo valueForKey:@"aps"] valueForKey:@"type"] integerValue] == 8){
                
                _isFromNotification = YES;
                _sid = [NSString stringWithFormat:@"%@",[[userInfo valueForKey:@"aps"] valueForKey:@"sid"]];
                if ([USERDEFAULTS boolForKey:@"isNotRegisterOrLoginUser"]) {
                    
                    _stype = 8;
                    _isFromNotificationAndLogin = YES;
                    [self openLoginViewController];
                }else{
                    [navigationController pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"LongNewsViewController"] animated:YES];
                }
            } // expert corner  == 9
            
            else if ([[[userInfo valueForKey:@"aps"] valueForKey:@"type"] integerValue] ==9){
                _isFromNotification = YES;
                _sid = [NSString stringWithFormat:@"%@",[[userInfo valueForKey:@"aps"] valueForKey:@"sid"]];
                if ([USERDEFAULTS boolForKey:@"isNotRegisterOrLoginUser"]) {
                    
                    _stype = 9;
                    _isFromNotificationAndLogin = YES;
                    [self openLoginViewController];
                }else{
                    [navigationController pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"ExpertLongViewController"] animated:YES];
                }
            }
            
            // Expert Take == 11
            
            else if ([[[userInfo valueForKey:@"aps"] valueForKey:@"type"] integerValue] ==11){
                _isFromNotification = YES;
                _sid = [NSString stringWithFormat:@"%@",[[userInfo valueForKey:@"aps"] valueForKey:@"sid"]];
                if ([USERDEFAULTS boolForKey:@"isNotRegisterOrLoginUser"]) {
                    [self openLoginViewController];
                    _stype = 11;
                    _isFromNotificationAndLogin = YES;
                }else{
                    [navigationController pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"ExpertTakeLngViewController"] animated:YES];
                }
            }
            
            // Video == 25
            
            else if ([[[userInfo valueForKey:@"aps"] valueForKey:@"type"] integerValue] ==25){
                _isFromNotification = YES;
                _sid = [NSString stringWithFormat:@"%@",[[userInfo valueForKey:@"aps"] valueForKey:@"sid"]];
                
                if ([USERDEFAULTS boolForKey:@"isNotRegisterOrLoginUser"]) {
                    
                    [self openLoginViewController];
                    _stype = 25;
                    _isFromNotificationAndLogin = YES;
                }else{
                    [navigationController pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"videoPlayerViewController"] animated:YES];
                }
            }
            
            // site link == 22
            
            else if ([[[userInfo valueForKey:@"aps"] valueForKey:@"type"] integerValue] ==22){
                _isFromNotification = YES;
                _sid = [NSString stringWithFormat:@"%@",[[userInfo valueForKey:@"aps"] valueForKey:@"sid"]];
                _msg = [[[userInfo valueForKey:@"aps"] valueForKey:@"alert"] objectForKey:@"body"];
                if ([USERDEFAULTS boolForKey:@"isNotRegisterOrLoginUser"]) {
                    [self openLoginViewController];
                    _stype = 22;
                    _isFromNotificationAndLogin = YES;
                }else{
                    [navigationController pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"SiteLinksViewController"] animated:YES];
                }
            }
            
            // Forum Discussion == 23
            
            else if ([[[userInfo valueForKey:@"aps"] valueForKey:@"type"] integerValue] ==23){
                _isFromNotification = YES;
                _sid = [NSString stringWithFormat:@"%@",[[userInfo valueForKey:@"aps"] valueForKey:@"sid"]];
                if ([USERDEFAULTS boolForKey:@"isNotRegisterOrLoginUser"]) {
                    [self openLoginViewController];
                    _stype = 23;
                    _isFromNotificationAndLogin = YES;
                }else{
                    [navigationController pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"ForumDetailViewController"] animated:YES];
                    
                }
            }
            
            // for any other type of Notification send to Home screen
            
            else {
                if ([USERDEFAULTS boolForKey:@"isNotRegisterOrLoginUser"]) {
                }else{
                    [navigationController pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"] animated:YES];
                }
            }
            
            
        }];
    }
}


#pragma mark - iOS 10 Notification Method

//====================For iOS 10====================

-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    
    
    //NSLog(@"Userinfo %@",notification.request.content.userInfo);
    
    [AGPushNoteView showWithNotificationMessage:[[[notification.request.content.userInfo valueForKey:@"aps"] valueForKey:@"alert"] objectForKey:@"body"]];
    [AGPushNoteView setMessageAction:^(NSString *message) {
        // News == 8
        if ([[[notification.request.content.userInfo valueForKey:@"aps"] valueForKey:@"type"] integerValue] == 8){
            
            _isFromNotification = YES;
            _stype = 8;
            _sid = [NSString stringWithFormat:@"%@",[[notification.request.content.userInfo valueForKey:@"aps"] valueForKey:@"sid"]];
            if ([USERDEFAULTS boolForKey:@"isNotRegisterOrLoginUser"]) {
                
                
            }else{
                [navigationController pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"LongNewsViewController"] animated:YES];
            }
        } // expert corner  == 9
        
        else if ([[[notification.request.content.userInfo valueForKey:@"aps"] valueForKey:@"type"] integerValue] ==9){
            _isFromNotification = YES;
            _sid = [NSString stringWithFormat:@"%@",[[notification.request.content.userInfo valueForKey:@"aps"] valueForKey:@"sid"]];
            if ([USERDEFAULTS boolForKey:@"isNotRegisterOrLoginUser"]) {
                
            }else{
                [navigationController pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"ExpertLongViewController"] animated:YES];
            }
        }
        
        // Expert Take == 11
        
        else if ([[[notification.request.content.userInfo valueForKey:@"aps"] valueForKey:@"type"] integerValue] ==11){
            _isFromNotification = YES;
            _sid = [NSString stringWithFormat:@"%@",[[notification.request.content.userInfo valueForKey:@"aps"] valueForKey:@"sid"]];
            if ([USERDEFAULTS boolForKey:@"isNotRegisterOrLoginUser"]) {
                
            }else{
                [navigationController pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"ExpertTakeLngViewController"] animated:YES];
            }
        }
        
        // Video == 25
        
        else if ([[[notification.request.content.userInfo valueForKey:@"aps"] valueForKey:@"type"] integerValue] ==25){
            _isFromNotification = YES;
            _sid = [NSString stringWithFormat:@"%@",[[notification.request.content.userInfo valueForKey:@"aps"] valueForKey:@"sid"]];
            
            if ([USERDEFAULTS boolForKey:@"isNotRegisterOrLoginUser"]) {
                
            }else{
                [navigationController pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"videoPlayerViewController"] animated:YES];
            }
        }
        
        // site link == 22
        
        else if ([[[notification.request.content.userInfo valueForKey:@"aps"] valueForKey:@"type"] integerValue] ==22){
            _isFromNotification = YES;
            _sid = [NSString stringWithFormat:@"%@",[[notification.request.content.userInfo valueForKey:@"aps"] valueForKey:@"sid"]];
            _msg = [[[notification.request.content.userInfo valueForKey:@"aps"] valueForKey:@"alert"] objectForKey:@"body"];
            if ([USERDEFAULTS boolForKey:@"isNotRegisterOrLoginUser"]) {
                
                }else{
                [navigationController pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"SiteLinksViewController"] animated:YES];
            }
        }
        
        // Forum Discussion == 23
        
        else if ([[[notification.request.content.userInfo valueForKey:@"aps"] valueForKey:@"type"] integerValue] ==23){
            _isFromNotification = YES;
            _sid = [NSString stringWithFormat:@"%@",[[notification.request.content.userInfo valueForKey:@"aps"] valueForKey:@"sid"]];
            if ([USERDEFAULTS boolForKey:@"isNotRegisterOrLoginUser"]) {
                
            }else{
                [navigationController pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"ForumDetailViewController"] animated:YES];
                
            }
        }
        
        // for any other type of Notification send to Home screen
        
        else {
            if ([USERDEFAULTS boolForKey:@"isNotRegisterOrLoginUser"]) {
            }else{
                [navigationController pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"] animated:YES];
            }
        }
        
        
    }];
    
    
}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
    
    //Called to let your app know which action was selected by the user for a given notification.
    
    //NSLog(@"Userinfo %@",response.notification.request.content.userInfo);
    
    if([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive){
        // News == 8
        if ([[[response.notification.request.content.userInfo valueForKey:@"aps"] valueForKey:@"type"] integerValue] == 8){
            
            _isFromNotification = YES;
            _sid = [NSString stringWithFormat:@"%@",[[response.notification.request.content.userInfo valueForKey:@"aps"] valueForKey:@"sid"]];
            if ([USERDEFAULTS boolForKey:@"isNotRegisterOrLoginUser"]) {
                
                _stype = 8;
                _isFromNotificationAndLogin = YES;
                [self openLoginViewController];
                
            }else{
                [navigationController pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"LongNewsViewController"] animated:YES];
            }
        } // expert corner  == 9
        
        else if ([[[response.notification.request.content.userInfo valueForKey:@"aps"] valueForKey:@"type"] integerValue] ==9){
            _isFromNotification = YES;
            _sid = [NSString stringWithFormat:@"%@",[[response.notification.request.content.userInfo valueForKey:@"aps"] valueForKey:@"sid"]];
            if ([USERDEFAULTS boolForKey:@"isNotRegisterOrLoginUser"]) {
                
                _stype = 9;
                _isFromNotificationAndLogin = YES;
                [self openLoginViewController];
            }else{
                [navigationController pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"ExpertLongViewController"] animated:YES];
            }
        }
        
        // Expert Take == 11
        
        else if ([[[response.notification.request.content.userInfo valueForKey:@"aps"] valueForKey:@"type"] integerValue] ==11){
            _isFromNotification = YES;
            _sid = [NSString stringWithFormat:@"%@",[[response.notification.request.content.userInfo valueForKey:@"aps"] valueForKey:@"sid"]];
            if ([USERDEFAULTS boolForKey:@"isNotRegisterOrLoginUser"]) {
                
                _stype = 11;
                _isFromNotificationAndLogin = YES;
                [self openLoginViewController];
            }else{
                [navigationController pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"ExpertTakeLngViewController"] animated:YES];
            }
        }
        
        // Video == 25
        
        else if ([[[response.notification.request.content.userInfo valueForKey:@"aps"] valueForKey:@"type"] integerValue] ==25){
            _isFromNotification = YES;
            _sid = [NSString stringWithFormat:@"%@",[[response.notification.request.content.userInfo valueForKey:@"aps"] valueForKey:@"sid"]];
           
            if ([USERDEFAULTS boolForKey:@"isNotRegisterOrLoginUser"]) {
                
                _stype = 25;
                _isFromNotificationAndLogin = YES;
                [self openLoginViewController];
            }else{
                [navigationController pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"videoPlayerViewController"] animated:YES];
            }
        }
        
        // site link == 22
        
        else if ([[[response.notification.request.content.userInfo valueForKey:@"aps"] valueForKey:@"type"] integerValue] ==22){
            _isFromNotification = YES;
            _sid = [NSString stringWithFormat:@"%@",[[response.notification.request.content.userInfo valueForKey:@"aps"] valueForKey:@"sid"]];
            _msg = [[[response.notification.request.content.userInfo valueForKey:@"aps"] valueForKey:@"alert"] objectForKey:@"body"];
            if ([USERDEFAULTS boolForKey:@"isNotRegisterOrLoginUser"]) {
                
                _stype = 22;
                _isFromNotificationAndLogin = YES;
                [self openLoginViewController];
            }else{
                [navigationController pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"SiteLinksViewController"] animated:YES];
            }
        }
        
        // Forum Discussion == 23
        
        else if ([[[response.notification.request.content.userInfo valueForKey:@"aps"] valueForKey:@"type"] integerValue] ==23){
            _isFromNotification = YES;
            _sid = [NSString stringWithFormat:@"%@",[[response.notification.request.content.userInfo valueForKey:@"aps"] valueForKey:@"sid"]];
            if ([USERDEFAULTS boolForKey:@"isNotRegisterOrLoginUser"]) {
                
                _stype = 23;
                _isFromNotificationAndLogin = YES;
                [self openLoginViewController];
            }else{
                [navigationController pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"ForumDetailViewController"] animated:YES];
                
            }
        }
        
        // for any other type of Notification send to Home screen
        
        else {
            if ([USERDEFAULTS boolForKey:@"isNotRegisterOrLoginUser"]) {
            }else{
                [navigationController pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"] animated:YES];
            }
        }
        
        
    }
    
}



//====================For iOS 10====================

-(void)openLoginViewController{
    [navigationController pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"] animated:YES];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - Orientation

//- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
//{
//    
////    if ([self.window.rootViewController.presentedViewController isKindOfClass:[videoPlayerViewController class]]){
////        
////        videoPlayerViewController *secondController = (videoPlayerViewController *) self.window.rootViewController.presentedViewController;
////        
////        if (secondController.isPresented)
////        {
////            return UIInterfaceOrientationMaskLandscapeLeft;
////        }
////        else return UIInterfaceOrientationMaskPortrait;
////    }
////    else return UIInterfaceOrientationMaskPortrait;
//}

@end
