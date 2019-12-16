//
//  SearchViewController.m
//  GSTSutra
//
//  Created by niyuj on 1/18/17.
//  Copyright © 2017 niyuj. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchRequestDelegate.h"


#import "searchAllTypesViewController.h"
#import "searchNewsViewController.h"
#import "searchVideoViewController.h"
#import "searchExpertViewController.h"
#import "searchCoExpertViewController.h"
#import "searchLawViewController.h"
#import "SearchFAQViewController.h"


@interface SearchViewController ()<YSLContainerViewControllerDelegate,SearchRequestDelegateMethod>{
    searchNewsViewController *news;
    searchVideoViewController *video;
    searchExpertViewController *exprt;
    searchCoExpertViewController *coexp;
    SearchFAQViewController *faq;
    
}
@property (weak, nonatomic) IBOutlet UISearchBar *searchBarControl;

@end

@implementation SearchViewController

#pragma mark - Page lifecycle 

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [Utility SetPanGestureOff];
    
    self.navigationController.navigationBarHidden = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
   [self setNavigationBarTitleLabel:@"Search"];
    self.navigationItem.rightBarButtonItem.enabled=NO;
    self.navigationItem.rightBarButtonItem=nil;
    self.ResultForAllArray = [[NSMutableArray alloc] init];
    
    
    searchAllTypesViewController *all = [self.storyboard instantiateViewControllerWithIdentifier:@"searchAllTypesViewController"];
    all.title = @"All";
    
    news = [self.storyboard instantiateViewControllerWithIdentifier:@"searchNewsViewController"];
    news.title = @"News";
    
    video = [self.storyboard instantiateViewControllerWithIdentifier:@"searchVideoViewController"];
    video.title = @"GSTtube";
    
    exprt = [self.storyboard instantiateViewControllerWithIdentifier:@"searchExpertViewController"];
    exprt.title = @"Experts";
    
    coexp = [self.storyboard instantiateViewControllerWithIdentifier:@"searchCoExpertViewController"];
    coexp.title = @"Tax Ring";
    
    faq = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchFAQViewController"];
    faq.title = @"CBEC FAQs";
    
    YSLContainerViewController *containerVC = [[YSLContainerViewController alloc]initWithControllers:@[all,news,exprt,coexp,video,faq]
                                                                                        topBarHeight:0
                                                                                parentViewController:self];
    containerVC.delegate = self;
    containerVC.menuItemFont = [UIFont fontWithName:@"Futura-Medium" size:16];
    containerVC.isFromSearch = YES;
    
    [self.view addSubview:containerVC.view];
    [self.view bringSubviewToFront:self.searchBarControl];
}

#pragma mark -- YSLContainerViewControllerDelegate

- (void)containerViewItemIndex:(NSInteger)index currentController:(UIViewController *)controller
{
       
    NSDictionary *searchText = @{@"searchString": self.ResultForAllArray};
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"searchNotificationWithText"
     object:self userInfo:searchText];
    
    [controller viewWillAppear:YES];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    //NSLog(@"Cancel");
    [searchBar resignFirstResponder];
}


-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    //NSLog(@"GO");
    [searchBar resignFirstResponder];
    [self searchAPICallWithText:self.searchBarControl.text];
    
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    //NSLog(@"End editing");
    return YES;
}


-(void)searchAPICallWithText:(NSString*)searchText{
    if ([self checkReachability]) {
        [self startProgressHUD];
        SearchRequestDelegate *req = [[SearchRequestDelegate alloc] init];
        req.delegate = self;
        
        [req searchText:searchText];
    } else {
        [self noInternetAlert];
    }
}

-(void)searchRequestSuccessfulWithResult:(NSArray *)result{
    [self stopProgressHUD];
    
    @try {
        [self.ResultForAllArray removeAllObjects];
        self.ResultForAllArray =  [result mutableCopy];
        news.searchResultArray =  [result mutableCopy];
        video.searchResultArray = [result mutableCopy];
        faq.searchResultArray =   [result mutableCopy];
        exprt.searchResultArray = [result mutableCopy];
        coexp.searchResultArray = [result mutableCopy];
        
        NSDictionary *searchText = @{@"searchString": self.ResultForAllArray};
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"searchNotificationWithText"
         object:self userInfo:searchText];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}
-(void)searchRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
    NSMutableArray *result = [[NSMutableArray alloc] init];
    [self.ResultForAllArray removeAllObjects];
    self.ResultForAllArray =  [result mutableCopy];
    news.searchResultArray =  [result mutableCopy];
    video.searchResultArray = [result mutableCopy];
    faq.searchResultArray =   [result mutableCopy];
    exprt.searchResultArray = [result mutableCopy];
    coexp.searchResultArray = [result mutableCopy];
    NSDictionary *searchText = @{@"searchString": self.ResultForAllArray};
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"searchNotificationWithText"
     object:self userInfo:searchText];
    [Utility showMessage:error withTitle:@""];
}


@end
