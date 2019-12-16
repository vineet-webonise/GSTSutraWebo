//
//  searchExpertViewController.m
//  GSTSutra
//
//  Created by niyuj on 1/19/17.
//  Copyright © 2017 niyuj. All rights reserved.
//

#import "searchExpertViewController.h"
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
#import "SearchRequestDelegate.h"


@interface searchExpertViewController ()<SearchRequestDelegateMethod>{
    NSMutableArray *expertArray;
    NSString *lowerLimit,*upperLimit;
    BOOL isViewDidloadCall,noMoreItems;
    UIView *footerView;
    UIActivityIndicatorView *activityIndicator;
    NSArray *expertOfflineArray;
    
}
@property (weak, nonatomic) IBOutlet UITableView *expertCornerTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBarControl;

@end

@implementation searchExpertViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [Utility SetPanGestureOff];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSearchTextNotification:)name:@"searchNotificationWithText" object:nil];
    
    NSMutableArray * temp = [[NSMutableArray alloc] initWithArray:[self.searchResultArray mutableCopy]];
    
    [expertArray removeAllObjects];
    for (int i = 0; i< [temp count]; i++) {
        if ([[[temp objectAtIndex:i] objectForKey:@"story_type"] integerValue] == 9) {
            [expertArray addObject:[[temp mutableCopy] objectAtIndex:i]];
        }
    }
    
    [self.expertCornerTableView reloadData];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    expertArray = [[NSMutableArray alloc]init];
    [self.expertCornerTableView registerNib:[UINib nibWithNibName:@"ExpertTableViewCell" bundle:nil] forCellReuseIdentifier:@"ExpertTableViewCell"];
    [self.expertCornerTableView registerNib:[UINib nibWithNibName:@"NewsHeaderTableViewCell" bundle:nil] forCellReuseIdentifier:@"NewsHeaderTableViewCell"];
    [self.expertCornerTableView registerNib:[UINib nibWithNibName:@"AdvertiseTableViewCell" bundle:nil] forCellReuseIdentifier:@"AdvertiseTableViewCell"];
   
}
#pragma mark - NSNotification Center

- (void) receiveSearchTextNotification:(NSNotification *) notification{
    
    if ([notification.name isEqualToString:@"searchNotificationWithText"]){
        
        NSDictionary* userInfo = notification.userInfo;
        
        if ([self checkReachability]) {
            
            //[self searchAPICallWithText:(NSString*)userInfo[@"searchString"]];
            
            NSMutableArray * temp = [[NSMutableArray alloc] init];
            temp = [(NSMutableArray*)userInfo[@"searchString"] mutableCopy];
            [expertArray removeAllObjects];
            for (int i = 0; i< [temp count]; i++) {
                if ([[[temp objectAtIndex:i] objectForKey:@"story_type"] integerValue] == 9) {
                    [expertArray addObject:[[temp mutableCopy] objectAtIndex:i]];
                }
            }
            
            [self.expertCornerTableView reloadData];
            
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
    [expertArray removeAllObjects];
    for (int i = 0; i< [result count]; i++) {
        if ([[[result objectAtIndex:i] objectForKey:@"story_type"] integerValue] == 9) {
            [expertArray addObject:[[result mutableCopy] objectAtIndex:i]];
        }
    }
    
    [self.expertCornerTableView reloadData];
//    if (expertArray.count == 0) {
//        [Utility showMessage:@"No Record's found." withTitle:@""];
//    }
    
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
    
    return [expertArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *NewscellIdentifier = @"ExpertTableViewCell";
    ExpertTableViewCell *Newscell = (ExpertTableViewCell*)[tableView dequeueReusableCellWithIdentifier:NewscellIdentifier];
    
    static NSString *ADVCellIdentifier = @"AdvertiseTableViewCell";
    AdvertiseTableViewCell *ADVCell = (AdvertiseTableViewCell*)[tableView dequeueReusableCellWithIdentifier:ADVCellIdentifier];
    
    @try {
        NSString *newsImageUrl = [[NSString stringWithFormat:@"%@",ImageSERVER_API] stringByAppendingString:[[expertArray objectAtIndex:indexPath.row] objectForKey:@"image"]];
        
        Newscell.selectionStyle = UITableViewCellSelectionStyleNone;
        ADVCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // Here we use the new provided sd_setImageWithURL: method to load the web image
        [Newscell.NewsImageView sd_setImageWithURL:[NSURL URLWithString:[newsImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]placeholderImage:[UIImage imageNamed:@"userimage.png"]];
        Newscell.NewsImageView.layer.cornerRadius=Newscell.NewsImageView.frame.size.width/2;
        Newscell.NewsImageView.layer.borderWidth = 1.0f;
        Newscell.NewsImageView.layer.masksToBounds = YES;
        
        Newscell.NewsTitleLabel.font = [UIFont fontWithName:centuryGothicBold size:titleFont];
        NSString *yourString = [[[[expertArray objectAtIndex:indexPath.row] objectForKey:@"headline"] stringByAppendingString:@"\n\n"] stringByAppendingString:[[expertArray objectAtIndex:indexPath.row] objectForKey:@"expert_name"]];
        NSMutableAttributedString *yourAttributedString = [[NSMutableAttributedString alloc] initWithString:yourString];
        NSString *boldString = [[expertArray objectAtIndex:indexPath.row] objectForKey:@"expert_name"];
        NSRange boldRange = [yourString rangeOfString:boldString];
        [yourAttributedString addAttribute: NSFontAttributeName value:[UIFont fontWithName:centuryGothicRegular size:titleFont] range:boldRange];
        [Newscell.NewsTitleLabel setAttributedText: yourAttributedString];
        
        Newscell.NewsDetailLabel.text = [[expertArray objectAtIndex:indexPath.row] objectForKey:@"expert_name"];
        Newscell.NewDateLabel.text = [[expertArray objectAtIndex:indexPath.row] objectForKey:@"date"];
        //[Newscell.bookmarkButton addTarget:self action:@selector(bookmarkButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        // Newscell.bookmarkButton.tag = indexPath.row;
        
        return Newscell;

    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ExpertLongViewController *shortView = [self.storyboard instantiateViewControllerWithIdentifier:@"ExpertLongViewController"];
    shortView.selectedIndex =  indexPath.row ;
    shortView.expertLongViewNewsArray = [expertArray mutableCopy];
    [self.navigationController pushViewController:shortView animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 126;
}

@end
