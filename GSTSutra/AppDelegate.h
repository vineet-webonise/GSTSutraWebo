//
//  AppDelegate.h
//  GSTSutra
//
//  Created by niyuj on 10/20/16.
//  Copyright © 2016 niyuj. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "SSKeychain.h"
#import "Constants.h"
#import "MFSideMenuContainerViewController.h"
#import "FMDatabase.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MFSideMenuContainerViewController *container;
@property (nonatomic , assign) BOOL isNotLoginOrRegister;
@property (strong, nonatomic) FMDatabase *database;
@property (nonatomic , assign) BOOL isFromNotification;
@property (nonatomic , assign) BOOL isFromNotificationAndLogin;
@property (nonatomic , strong) NSString *sid;
@property (nonatomic , assign) int stype;
@property (nonatomic , strong) NSString *msg;


@end
