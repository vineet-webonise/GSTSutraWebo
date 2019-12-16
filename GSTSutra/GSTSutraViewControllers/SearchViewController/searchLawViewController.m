//
//  searchLawViewController.m
//  GSTSutra
//
//  Created by niyuj on 1/19/17.
//  Copyright © 2017 niyuj. All rights reserved.
//

#import "searchLawViewController.h"
#import "NewsHeaderTableViewCell.h"
#import "NewsTableViewCell.h"
#import "AdvertiseTableViewCell.h"
#import "ShortNewsViewController.h"
#import "HomeViewController.h"
#import "NewRequest.h"
#import "NewsModel.h"
#import "AppData.h"
#import "UIImageView+WebCache.h"
#import "ShortNewsViewController.h"
#import "LawsLongViewController.h"
#import "ExpertCornerRequest.h"
#import "SearchRequestDelegate.h"


@interface searchLawViewController ()<SearchRequestDelegateMethod>{
    NSMutableArray *lawsArray;
    NSString *lowerLimit,*upperLimit;
}
@property (weak, nonatomic) IBOutlet UITableView *lawsTableview;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBarControl;


@end

@implementation searchLawViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [Utility SetPanGestureOff];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSearchTextNotification:)name:@"searchNotificationWithText" object:nil];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBarTitleLabel:@"Laws"];
    [self stopProgressHUD];
    lawsArray = [[NSMutableArray alloc]init];
    [self.lawsTableview registerNib:[UINib nibWithNibName:@"NewsTableViewCell" bundle:nil] forCellReuseIdentifier:@"NewsTableViewCell"];
    [self.lawsTableview registerNib:[UINib nibWithNibName:@"NewsHeaderTableViewCell" bundle:nil] forCellReuseIdentifier:@"NewsHeaderTableViewCell"];
    [self.lawsTableview registerNib:[UINib nibWithNibName:@"AdvertiseTableViewCell" bundle:nil] forCellReuseIdentifier:@"AdvertiseTableViewCell"];
}

#pragma mark - NSNotification Center

- (void) receiveSearchTextNotification:(NSNotification *) notification{
    
    if ([notification.name isEqualToString:@"searchNotificationWithText"]){
        
        NSDictionary* userInfo = notification.userInfo;
        
        if ([self checkReachability]) {
            
            //[self searchAPICallWithText:(NSString*)userInfo[@"searchString"]];
            NSMutableArray * temp = [[NSMutableArray alloc] init];
            [lawsArray removeAllObjects];
            temp = [(NSMutableArray*)userInfo[@"searchString"] mutableCopy];
            
            for (int i = 0; i< [temp count]; i++) {
                if ([[[temp objectAtIndex:i] objectForKey:@"story_type"] integerValue] == 10) {
                    [lawsArray addObject:[[temp mutableCopy] objectAtIndex:i]];
                }
            }
            
            [self.lawsTableview reloadData];

            
            
        }
        else {
            [self stopProgressHUD];
            [self noInternetAlert];
            
        }
    }
}


-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    //NSLog(@"Cancel");
    [searchBar resignFirstResponder];
}


-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    //NSLog(@"GO");
    [searchBar resignFirstResponder];
    //[self searchAPICall];
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
    [lawsArray removeAllObjects];
    for (int i = 0; i< [result count]; i++) {
        if ([[[result objectAtIndex:i] objectForKey:@"story_type"] integerValue] == 10) {
            [lawsArray addObject:[[result mutableCopy] objectAtIndex:i]];
        }
    }
    
    [self.lawsTableview reloadData];
    
}
-(void)searchRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [lawsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *NewscellIdentifier = @"NewsTableViewCell";
    NewsTableViewCell *Newscell = (NewsTableViewCell*)[tableView dequeueReusableCellWithIdentifier:NewscellIdentifier];
    
    static NSString *ADVCellIdentifier = @"AdvertiseTableViewCell";
    AdvertiseTableViewCell *ADVCell = (AdvertiseTableViewCell*)[tableView dequeueReusableCellWithIdentifier:ADVCellIdentifier];
    
    Newscell.selectionStyle = UITableViewCellStyleDefault;
    ADVCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    Newscell.NewsImageView.hidden=true;
    Newscell.NewsTitleLabel.hidden=true;
    Newscell.NewsDetailLabel.hidden=true;
    Newscell.NewDateLabel.hidden=true;
    
    
    Newscell.textLabel.text = [[lawsArray objectAtIndex:indexPath.row] objectForKey:@"title"];
    Newscell.textLabel.numberOfLines = 0;
    Newscell.textLabel.textAlignment = NSTextAlignmentLeft;
    Newscell.textLabel.font = [UIFont fontWithName:centuryGothicBold size:13];
    
    return Newscell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LawsLongViewController *lawLongView = [self.storyboard instantiateViewControllerWithIdentifier:@"LawsLongViewController"];
    lawLongView.selectedIndex =  indexPath.row ;
    lawLongView.longViewLawsArray = [lawsArray mutableCopy];
    [self.navigationController pushViewController:lawLongView animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

@end
