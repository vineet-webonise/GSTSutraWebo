//
//  NewsHomeViewController.m
//  GSTSutra
//
//  Created by niyuj on 3/28/17.
//  Copyright © 2017 niyuj. All rights reserved.
//

#import "NewsHomeViewController.h"
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

@interface NewsHomeViewController ()<YSLContainerViewControllerDelegate,NewRequestDelegate,LoginForgotAndChangePasswordRequestDelegate>

@end

@implementation NewsHomeViewController

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
    NewsViewController *topStories = [self.storyboard instantiateViewControllerWithIdentifier:@"NewsViewController"];
    topStories.title = @"Top Stories";
    topStories.isHomePageLoaded = YES;
    
    LatestNewsViewController *latest = [self.storyboard instantiateViewControllerWithIdentifier:@"LatestNewsViewController"];
    latest.title = @"Latest";
    latest.isHomePageLoaded = YES;
    
    TrendingViewController *trending = [self.storyboard instantiateViewControllerWithIdentifier:@"TrendingViewController"];
    trending.title = @"Trending";
    trending.isHomePageLoaded = YES;
    
    YSLContainerViewController *containerVC = [[YSLContainerViewController alloc]initWithControllers:@[topStories,latest]
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
        
        [self setupMenuBarButtonItems];
        [self setNavigationBarTitleLabel:@"News"];
        [self setUpViewControllers];
        
        
    } @catch (NSException *exception) {
        
    } @finally {
        
    }

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
