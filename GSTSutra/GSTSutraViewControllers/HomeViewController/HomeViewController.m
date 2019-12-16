//
//  HomeViewController.m
//  GSTSutra
//
//  Created by niyuj on 10/20/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import "HomeViewController.h"
#import "NewsViewController.h"
#import "ShortNewsViewController.h"
#import "YSLContainerViewController.h"
#import "LatestNewsViewController.h"
#import "TrendingViewController.h"
#import "NewRequest.h"
#import "purchaseRequest.h"
#import "demoViewController.h"
#import "LoginViewController.h"
#import "LoginForgotAndChangePasswordRequest.h"
#import "VideosViewController.h"
#import "ExpertsCornerViewController.h"


@interface HomeViewController ()<YSLContainerViewControllerDelegate,NewRequestDelegate,PurchaseRequestDelegate,LoginForgotAndChangePasswordRequestDelegate> {
    
    NSMutableArray *userLikesArray,*userBookmarksArray;
}


@end

@implementation HomeViewController

#pragma mark -
#pragma mark - Controller Life Cycle
#pragma mark -

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [Utility SetPanGestureOff];
    
    self.navigationController.navigationBarHidden = NO;
    //self.navigationController.navigationBar.hidden = NO;
    [self setChildViewControllerWithCurrentIndex:[USERDEFAULTS integerForKey:@"selectedPageIndex"]];
     [self stopProgressHUD];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveStopWheelNotification:)name:@"StopHUDWheelNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveStartWheelNotification:)name:@"startHUDWheelNotification" object:nil];
   
}

- (void) receiveStartWheelNotification:(NSNotification *) notification{
    [self startProgressHUD];
    
}

- (void) receiveStopWheelNotification:(NSNotification *) notification{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
       [self stopProgressHUD];
       [self stopProgressHUD];
       [self stopProgressHUD];
       [self stopProgressHUD];
    
}


-(void)setUpViewControllers{
    // SetUp ViewControllers
    LatestNewsViewController *latest = [self.storyboard instantiateViewControllerWithIdentifier:@"LatestNewsViewController"];
    latest.title = @"News";
    latest.isHomePageLoaded = YES;
    
    ExpertsCornerViewController *experts = [self.storyboard instantiateViewControllerWithIdentifier:@"ExpertsCornerViewController"];
    experts.title = @"Experts";
    //experts.isHomePageLoaded = YES;
    
    VideosViewController *video = [self.storyboard instantiateViewControllerWithIdentifier:@"VideosViewController"];
    video.title = @"GSTtubes";
    video.isHomePageLoaded = YES;
    
    TrendingViewController *trending = [self.storyboard instantiateViewControllerWithIdentifier:@"TrendingViewController"];
    trending.title = @"Editors Pick";
    trending.isHomePageLoaded = YES;
    
    
    YSLContainerViewController *containerVC = [[YSLContainerViewController alloc]initWithControllers:@[latest,experts,video,trending]
                                                                                        topBarHeight:0
                                                                                parentViewController:self];
    containerVC.delegate = self;
    containerVC.menuItemFont = [UIFont fontWithName:centuryGothicBold size:titleFont];
    containerVC.isFromSearch = NO;
    [self.view addSubview:containerVC.view];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    @try {
        
        [USERDEFAULTS  setValue:@"https://itunes.apple.com/us/app/gstsutra/id1194977517?ls=1&mt=8" forKey:@"shareURL"];
        userLikesArray = [[NSMutableArray alloc] init];
        userBookmarksArray = [[NSMutableArray alloc] init];
        [self storeDataIntoNewsCommentDataBase];
        [self storeDataIntoNewsLikeCountDataBase];
        
        if ([USERDEFAULTS boolForKey:@"appLaunch"]) {
            [self getuserBookmarkAPICall];
        }
        
        if (![USERDEFAULTS boolForKey:@"isNotRegisterOrLoginUser"]) {
            if ([USERDEFAULTS boolForKey:@"appLaunch"]) {
                
                // Call  checkUserSubscriptionAPI  for payment purpose
                [self checkUserSubscriptionAPI];
            }
        }
        [self setupMenuBarButtonItems];
        [self setNavigationBarTitleLabel:@"Home"];
        [self setUpViewControllers];
        

    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
}

-(void)checkUserSubscriptionAPI{
    if ([self checkReachability]) {
        purchaseRequest *req = [[purchaseRequest alloc] init];
        req.delegate = self;
        [req checkUserSubscription];
    }
}

// status code 1

-(void)isUserPaidRequestSuccessfulWithResult:(NSString *)result{
    [self stopProgressHUD];
    
}
// status code 2
-(void)isBlockedRequestSuccessfulWithResult:(NSString *)result{
    
    [self openBlockAlertWithError:result];
    
}
// status code 0
-(void)isUserPaidRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
    NSString *temp = [NSString stringWithFormat:@"%@",status];
    if ([temp isEqualToString:@"3"]) {
        self.view.userInteractionEnabled = NO;
    [self openSubscriptionAlertWithError:error];
    } else {
        [Utility showMessage:error withTitle:@""];
    }
    
   
}



-(void)openSubscriptionAlertWithError:(NSString*)msg{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"PAYMENT"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
 [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"demoViewController"] animated:YES];
                                                         ;
                                                     }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"CANCEL"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                          
                                                             [self openLoginScreen];
                                                         }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}


-(void)openBlockAlertWithError:(NSString*)msg{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         [self openLoginScreen];
                                                     }];
    
    [alert addAction:okAction];
   
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Logout Operation

-(void)openLoginScreen{
    
    LoginForgotAndChangePasswordRequest *req = [[LoginForgotAndChangePasswordRequest alloc] init];
    req.delegate = self;
    [req getLogout];
    if(![USERDEFAULTS boolForKey:@"isRememberUsername"]){
        [USERDEFAULTS removeObjectForKey:@"userName"];
    }
    
    [USERDEFAULTS removeObjectForKey:@"password"];
    [USERDEFAULTS removeObjectForKey:@"userToken"];
    [USERDEFAULTS removeObjectForKey:@"fullName"];
    [USERDEFAULTS  setValue:@"Login/Register" forKey:@"fullName"];
    [USERDEFAULTS  removeObjectForKey:@"profileImage"];
    [USERDEFAULTS setBool:YES forKey:@"isNotRegisterOrLoginUser"];
    [USERDEFAULTS setValue:@"6cc466b19a4d77920b3707d0636f57ca" forKey:@"userToken"];
    [USERDEFAULTS setBool:YES forKey:@"isLogin"];
    [USERDEFAULTS synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadDrawerData" object:self ];
    
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"] animated:YES];
    
}



-(void)getuserBookmarkAPICall{
    if ([self checkReachability]) {
    NewRequest *req = [[NewRequest alloc] init];
    req.delegate = self;
    [req getUserBookmarks];
    }
}

-(void)getUserLikeAPICall{
    
    if ([self checkReachability]) {
        NewRequest *req = [[NewRequest alloc] init];
        req.delegate = self;
        [req getUserLikes];
    }
}

-(void)getUserLikeRequestSuccessfulWithResult:(NSArray *)result{
    [USERDEFAULTS setBool:NO forKey:@"appLaunch"];
    [userLikesArray removeAllObjects];
    [userLikesArray addObjectsFromArray:result];
    [self storeDataIntoLikeDataBase];
    
}

-(void)getUserLikeRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    
}

-(void)getUserBookmarkRequestSuccessfulWithResult:(NSArray *)result{
     [self getUserLikeAPICall];
    [USERDEFAULTS setBool:NO forKey:@"appLaunch"];
    [userBookmarksArray removeAllObjects];
    [userBookmarksArray addObjectsFromArray:result];
    [self storeDataIntoBookmarkDataBase];
    
}
-(void)getUserBookmarkRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    
}

-(void)storeDataIntoNewsCommentDataBase{
    [appD.database open];
    [appD.database executeUpdate:@"create table IF NOT EXISTS newsCommentCountTable(id INTEGER PRIMARY KEY   AUTOINCREMENT,newstype text,newsid text,newsCommentCount text,postComment text,deleteComment text)"];
    
    
    [appD.database close];
}


-(void)storeDataIntoNewsLikeCountDataBase{
    [appD.database open];
    //[appD.database executeUpdate:@"DROP TABLE IF EXISTS `newsLikeCountTable`;"];
    [appD.database executeUpdate:@"create table IF NOT EXISTS newsLikeCountTable(id INTEGER PRIMARY KEY   AUTOINCREMENT,newstype text,newsid text,newsLikeCount text,newsLikeCacheCount text)"];
    
    
    [appD.database close];
}

#pragma  mark - Sqlite Database

-(void)storeDataIntoBookmarkDataBase{
    [appD.database open];
    [appD.database executeUpdate:@"DROP TABLE IF EXISTS `userBookmarksTable`;"];
    [appD.database executeUpdate:@"create table IF NOT EXISTS userBookmarksTable(type text,id text,isBookmark text)"];
    for (int i = 0; i<[userBookmarksArray count]; i++) {
        [appD.database executeUpdate:@"insert into userBookmarksTable (type, id, isBookmark) values (?, ?, ?)",[[userBookmarksArray objectAtIndex:i] objectForKey:@"type"],[[userBookmarksArray objectAtIndex:i] objectForKey:@"id"],[[userBookmarksArray objectAtIndex:i] objectForKey:@"is_bookmarks"]];
    }
    
    [appD.database close];
}

-(void)storeDataIntoLikeDataBase{
    [appD.database open];
    [appD.database executeUpdate:@"DROP TABLE IF EXISTS `userLikeTable`;"];
    [appD.database executeUpdate:@"create table IF NOT EXISTS userLikeTable(type text,id text,isLike text)"];
    for (int i = 0; i<[userLikesArray count]; i++) {
        [appD.database executeUpdate:@"insert into userLikeTable (type , id , isLike ) values (?, ?, ?)",[[userLikesArray objectAtIndex:i] objectForKey:@"type"],[[userLikesArray objectAtIndex:i] objectForKey:@"id"],[[userLikesArray objectAtIndex:i] objectForKey:@"is_likes"]];
    }
    
    [appD.database close];
}




#pragma mark -- YSLContainerViewControllerDelegate
- (void)containerViewItemIndex:(NSInteger)index currentController:(UIViewController *)controller
{
    [USERDEFAULTS setInteger:index forKey:@"selectedPageIndex"];
    //[self startProgressHUD];
    NSDictionary *selectedIndexDict = @{@"indexNumber": @(index)};
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"NewsNotification"
     object:self userInfo:selectedIndexDict];
    [controller viewWillAppear:YES];
}

@end
