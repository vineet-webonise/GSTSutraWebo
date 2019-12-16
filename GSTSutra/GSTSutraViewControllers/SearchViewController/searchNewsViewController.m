//
//  searchNewsViewController.m
//  GSTSutra
//
//  Created by niyuj on 1/18/17.
//  Copyright © 2017 niyuj. All rights reserved.
//

#import "searchNewsViewController.h"

#import "SearchRequestDelegate.h"

#import "NewsTableViewCell.h"
#import "HeaderTableViewCell.h"
#import "NewsHeaderTableViewCell.h"
#import "ExpertTableViewCell.h"

#import "NewsHeaderTableViewCell.h"
#import "NewsTableViewCell.h"
#import "AdvertiseTableViewCell.h"
#import "ShortNewsViewController.h"
#import "HomeViewController.h"
#import "ExpertCornerRequest.h"
#import "ExpertLongViewController.h"
#import "NewRequest.h"
#import "AppData.h"
#import "UIImageView+WebCache.h"
#import "ShortNewsViewController.h"
#import "ExpertTableViewCell.h"
#import "videoTableViewCell.h"
#import "HeaderVideoTableViewCell.h"
#import "AdvertiseTableViewCell.h"
#import "NewRequest.h"
#import "videoPlayerViewController.h"
#import "UIImageView+WebCache.h"
#import "LongNewsViewController.h"

@interface searchNewsViewController ()<SearchRequestDelegateMethod>{
    
    NSMutableArray *newsArray;
    NSString *lowerLimit,*upperLimit;
    BOOL isViewDidloadCall;
    UIView *footerView;
    UIActivityIndicatorView *activityIndicator;
    NSArray *newsOfflineArray;
    BOOL stopPagination,isFromLocalNotification;
}

@property (weak, nonatomic) IBOutlet UITableView *newsTableView;
@property (strong,nonatomic) NSIndexPath *selectedPath;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBarControl;

@end

@implementation searchNewsViewController

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [Utility SetPanGestureOff];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSearchTextNotification:)name:@"searchNotificationWithText" object:nil];
    [newsArray removeAllObjects];
    NSMutableArray * temp = [[NSMutableArray alloc] initWithArray:[self.searchResultArray mutableCopy]];
    
    for (int i = 0; i< [temp count]; i++) {
        if ([[[temp objectAtIndex:i] objectForKey:@"story_type"] integerValue] == 8) {
            [newsArray addObject:[[temp mutableCopy] objectAtIndex:i]];
        }
    }
    
    [self.newsTableView reloadData];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self stopProgressHUD];
    
    newsArray = [[NSMutableArray alloc]init];
    
    [self.newsTableView registerNib:[UINib nibWithNibName:@"NewsTableViewCell" bundle:nil] forCellReuseIdentifier:@"NewsTableViewCell"];
    [self.newsTableView registerNib:[UINib nibWithNibName:@"NewsHeaderTableViewCell" bundle:nil] forCellReuseIdentifier:@"NewsHeaderTableViewCell"];
    [self.newsTableView registerNib:[UINib nibWithNibName:@"AdvertiseTableViewCell" bundle:nil] forCellReuseIdentifier:@"AdvertiseTableViewCell"];
}

#pragma mark - NSNotification Center

- (void) receiveSearchTextNotification:(NSNotification *) notification{
    
    if ([notification.name isEqualToString:@"searchNotificationWithText"]){
        
        NSDictionary* userInfo = notification.userInfo;
        
            if ([self checkReachability]) {
    
                //[self searchAPICallWithText:(NSString*)userInfo[@"searchString"]];
                NSMutableArray * temp = [[NSMutableArray alloc] init];
                [newsArray removeAllObjects];
                temp = [(NSMutableArray*)userInfo[@"searchString"] mutableCopy];
                
                for (int i = 0; i< [temp count]; i++) {
                    if ([[[temp objectAtIndex:i] objectForKey:@"story_type"] integerValue] == 8) {
                        [newsArray addObject:[[temp mutableCopy] objectAtIndex:i]];
                    }
                }
                
                
                [self.newsTableView reloadData];
//                if (newsArray.count == 0) {
//                    [Utility showMessage:@"No Record's found." withTitle:@""];
//                }

    
            }
            else {
                [self stopProgressHUD];
                [self noInternetAlert];
                
            }
    }
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
    [newsArray removeAllObjects];
    for (int i = 0; i< [result count]; i++) {
        if ([[[result objectAtIndex:i] objectForKey:@"story_type"] integerValue] == 8) {
            [newsArray addObject:[[result mutableCopy] objectAtIndex:i]];
        }
    }
    
    [self.newsTableView reloadData];
    
}
-(void)searchRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
    [Utility showMessage:error withTitle:@""];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [newsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *NewsHeadercellIdentifier = @"NewsHeaderTableViewCell";
    NewsHeaderTableViewCell *NewsHeadercell = (NewsHeaderTableViewCell*)[tableView dequeueReusableCellWithIdentifier:NewsHeadercellIdentifier];
    
    static NSString *NewscellIdentifier = @"NewsTableViewCell";
    NewsTableViewCell *Newscell = (NewsTableViewCell*)[tableView dequeueReusableCellWithIdentifier:NewscellIdentifier];
    
    static NSString *ADVCellIdentifier = @"AdvertiseTableViewCell";
    AdvertiseTableViewCell *ADVCell = (AdvertiseTableViewCell*)[tableView dequeueReusableCellWithIdentifier:ADVCellIdentifier];
    
    @try {
        NSString *newsImageUrl = [[NSString stringWithFormat:@"%@",ImageSERVER_API] stringByAppendingString:[[newsArray objectAtIndex:indexPath.row] objectForKey:@"image"]];
        
        Newscell.selectionStyle = UITableViewCellSelectionStyleNone;
        NewsHeadercell.selectionStyle = UITableViewCellSelectionStyleNone;
        ADVCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        {
            
            // Here we use the new provided sd_setImageWithURL: method to load the web image
            [Newscell.NewsImageView sd_setImageWithURL:[NSURL URLWithString:[newsImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]placeholderImage:[UIImage imageNamed:@"userimage.png"]];
            Newscell.NewsTitleLabel.text = [[newsArray objectAtIndex:indexPath.row] objectForKey:@"headline"];
            Newscell.NewsTitleLabel.font = [UIFont fontWithName:centuryGothicBold size:titleFont];
            Newscell.NewsDetailLabel.text = [[newsArray objectAtIndex:indexPath.row] objectForKey:@"shortview"];
            Newscell.NewDateLabel.text = [[newsArray objectAtIndex:indexPath.row] objectForKey:@"date"];
            
            Newscell.bookmarkButton.tag = indexPath.row;
            
            return Newscell;
            
        }

    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedPath = indexPath;
     {
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
         LongNewsViewController  *LongView = [self.storyboard instantiateViewControllerWithIdentifier:@"LongNewsViewController"];
         LongView.selectedIndex =  indexPath.row ;
         LongView.longViewNewsArray = [newsArray mutableCopy];
         [self.navigationController pushViewController:LongView animated:YES];
        
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 132;
}

@end
