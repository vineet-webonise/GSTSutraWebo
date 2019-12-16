//
//  NatureOfIssueHomeViewController.m
//  GSTSutra
//
//  Created by niyuj on 2/10/17.
//  Copyright © 2017 niyuj. All rights reserved.
//

#import "NatureOfIssueHomeViewController.h"
#import "NOINewsViewController.h"
#import "NOIVideoViewController.h"
#import "NOIExpertViewController.h"
#import "NatureOfIssuesViewController.h"

@interface NatureOfIssueHomeViewController ()
@property (weak, nonatomic) IBOutlet UIButton *filterButton;
- (IBAction)filterButtonClicked:(id)sender;

@end

@implementation NatureOfIssueHomeViewController

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
    //NSLog(@"SelectedID Values %@" ,[USERDEFAULTS objectForKey:@"NOIID"]);
    //NSLog(@"SelectedIndustry Values %@" ,[USERDEFAULTS objectForKey:@"inDustriesID"]);
    if (self.isIndustriesSelected) {
        [self setNavigationBarTitleLabel:[USERDEFAULTS objectForKey:@"inDustriesName"]];
    } else {
        [self setNavigationBarTitleLabel:@"Search by Issues"];
    }
   
    [self setUpViewControllers];
    [self.view bringSubviewToFront:self.filterButton];
}

-(void)setUpViewControllers{
    // SetUp ViewControllers
    
    NOINewsViewController *news = [self.storyboard instantiateViewControllerWithIdentifier:@"NOINewsViewController"];
    news.title = @"News";
    news.isHomePageLoaded = YES ;
    
    NOIVideoViewController *video = [self.storyboard instantiateViewControllerWithIdentifier:@"NOIVideoViewController"];
    video.title = @"GSTtube";
    video.isHomePageLoaded = YES ;
    
    NOIExpertViewController *experts = [self.storyboard instantiateViewControllerWithIdentifier:@"NOIExpertViewController"];
    experts.title = @"Experts";
    experts.isHomePageLoaded = YES ;
    
    YSLContainerViewController *containerVC = [[YSLContainerViewController alloc]initWithControllers:@[news,experts,video]
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


- (IBAction)filterButtonClicked:(id)sender {
    
    NatureOfIssuesViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"NatureOfIssuesViewController"];
    
    if (self.isIndustriesSelected) {
        vc.isIndustriesSelected = NO;
        vc.isFromHomeScreen = YES;
    } else {
        vc.isIndustriesSelected = YES;
        vc.isFromHomeScreen = YES;
    }
    [self.navigationController pushViewController:vc animated:YES];
    
}
@end
