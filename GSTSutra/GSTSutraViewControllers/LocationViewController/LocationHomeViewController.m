//
//  LocationHomeViewController.m
//  GSTSutra
//
//  Created by niyuj on 2/13/17.
//  Copyright © 2017 niyuj. All rights reserved.
//

#import "LocationHomeViewController.h"
#import "LocNewsViewController.h"
#import "LocLawsViewController.h"
#import "LocFormsViewController.h"
#import "LocExpertViewController.h"

@interface LocationHomeViewController ()

@end

@implementation LocationHomeViewController

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
    [self setNavigationBarTitleLabel:[USERDEFAULTS objectForKey:@"locationName"]];
    [self setUpViewControllers];
}

-(void)setUpViewControllers{
    // SetUp ViewControllers
    
#import "LocNewsViewController.h"
#import "LocLawsViewController.h"
#import "LocFormsViewController.h"
#import "LocExpertViewController.h"
    
    LocNewsViewController *news = [self.storyboard instantiateViewControllerWithIdentifier:@"LocNewsViewController"];
    news.title = @"News";
    news.isHomePageLoaded = YES;
    
    LocLawsViewController *laws = [self.storyboard instantiateViewControllerWithIdentifier:@"LocLawsViewController"];
    laws.title = @"GST Laws";
    laws.isHomePageLoaded = YES;
    
    LocFormsViewController *forms = [self.storyboard instantiateViewControllerWithIdentifier:@"LocFormsViewController"];
    forms.title = @"GST Forms";
    forms.isHomePageLoaded = YES;
    
//    LocExpertViewController *experts= [self.storyboard instantiateViewControllerWithIdentifier:@"LocExpertViewController"];
//    experts.title = @"Experts";
    
    YSLContainerViewController *containerVC = [[YSLContainerViewController alloc]initWithControllers:@[laws,forms,news]
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
