//
//  VIdeoHomeViewController.m
//  GSTSutra
//
//  Created by niyuj on 1/28/17.
//  Copyright © 2017 niyuj. All rights reserved.
//

#import "VIdeoHomeViewController.h"
#import "VideosViewController.h"
#import "FeaturedVideoViewController.h"
#import "MostViewedVideoViewController.h"

@interface VIdeoHomeViewController ()

@end

@implementation VIdeoHomeViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveStopVideoWheelNotification:)name:@"StopVideoHUDWheelNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveStartVideoWheelNotification:)name:@"startVideoHUDWheelNotification" object:nil];
    
}

- (void) receiveStartVideoWheelNotification:(NSNotification *) notification{
    [self startProgressHUD];
    
}

- (void) receiveStopVideoWheelNotification:(NSNotification *) notification{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self stopProgressHUD];
    [self stopProgressHUD];
    [self stopProgressHUD];
    [self stopProgressHUD];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMenuBarButtonItems];
    [self setNavigationBarTitleLabel:@"GSTtube"];
    [self setUpViewControllers];
}

-(void)setUpViewControllers{
    // SetUp ViewControllers
    VideosViewController *topStories = [self.storyboard instantiateViewControllerWithIdentifier:@"VideosViewController"];
    topStories.title = @"Latest";
    topStories.isHomePageLoaded = YES;
    
    FeaturedVideoViewController *latest = [self.storyboard instantiateViewControllerWithIdentifier:@"FeaturedVideoViewController"];
    latest.title = @"Featured";
    latest.isHomePageLoaded = YES;
    
    MostViewedVideoViewController *trending = [self.storyboard instantiateViewControllerWithIdentifier:@"MostViewedVideoViewController"];
    trending.title = @"Most Viewed";
    trending.isHomePageLoaded = YES;
    
    YSLContainerViewController *containerVC = [[YSLContainerViewController alloc]initWithControllers:@[topStories,latest,trending]
                                                                                        topBarHeight:0
                                                                                parentViewController:self];
    containerVC.delegate = self;
    containerVC.menuItemFont = [UIFont fontWithName:centuryGothicBold size:titleFont];
    containerVC.isFromSearch = NO;
    [self.view addSubview:containerVC.view];
    
}

#pragma mark -- YSLContainerViewControllerDelegate
- (void)containerViewItemIndex:(NSInteger)index currentController:(UIViewController *)controller
{
    //[USERDEFAULTS setInteger:index forKey:@"selectedPageIndex"];
    //[self startProgressHUD];
    NSDictionary *selectedIndexDict = @{@"indexNumber": @(index)};
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"VideoNotification"
     object:self userInfo:selectedIndexDict];
    [controller viewWillAppear:YES];
}
@end
