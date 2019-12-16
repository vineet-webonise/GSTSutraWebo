//
//  ExpertsCornerViewController.m
//  GSTSutra
//
//  Created by niyuj on 11/22/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import "ExpertsCornerViewController.h"
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

@interface ExpertsCornerViewController ()<NewRequestDelegate,ExpertRequestDelegate>{
    NSMutableArray *expertArray;
    NSString *lowerLimit,*upperLimit;
    BOOL isViewDidloadCall,noMoreItems;
    UIView *footerView;
    UIActivityIndicatorView *activityIndicator;
    NSArray *expertOfflineArray;
     BOOL stopPagination;
    
}

@property (nonatomic, assign) BOOL isPulledToRefreshData;
@property (weak, nonatomic) IBOutlet UITableView *expertCornerTableView;

@end

@implementation ExpertsCornerViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [Utility SetPanGestureOff];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self stopProgressHUD];
    [self setNavigationBarTitleLabel:@"Expert Columns"];
    isViewDidloadCall = YES;
    noMoreItems = NO;
    stopPagination = YES ;
    expertArray = [[NSMutableArray alloc]init];
    expertOfflineArray = [[NSArray alloc]init];
    lowerLimit = @"0";
    upperLimit = @"20";
    [self.expertCornerTableView registerNib:[UINib nibWithNibName:@"ExpertTableViewCell" bundle:nil] forCellReuseIdentifier:@"ExpertTableViewCell"];
    //[self.expertCornerTableView registerNib:[UINib nibWithNibName:@"NewsTableViewCell" bundle:nil] forCellReuseIdentifier:@"NewsTableViewCell"];
    
    [self.expertCornerTableView registerNib:[UINib nibWithNibName:@"NewsHeaderTableViewCell" bundle:nil] forCellReuseIdentifier:@"NewsHeaderTableViewCell"];
    [self.expertCornerTableView registerNib:[UINib nibWithNibName:@"AdvertiseTableViewCell" bundle:nil] forCellReuseIdentifier:@"AdvertiseTableViewCell"];
    
    if ([self checkReachability]) {

        [self expertAPICall];
    }
    else {
        [self stopProgressHUD];
       // [self noInternetAlert];
        [self setDataBaseDataToTable];
    }
    //[self initFooterView];
}


#pragma  mark - Sqlite Database

-(void)storeDataIntoDataBase{
    [appD.database open];
    [appD.database executeUpdate:@"DROP TABLE IF EXISTS `expertCornerTable`;"];
    [appD.database executeUpdate:@"create table IF NOT EXISTS expertCornerTable(news blob primary key)"];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:expertArray];
    [appD.database executeUpdate:@"insert into expertCornerTable values (?)",data];
    FMResultSet *results = [appD.database executeQuery:@"select * from expertCornerTable"];
    while([results next]) {
        expertOfflineArray = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:@"news"]];
        //NSLog(@"News Array from DB : %@ ",expertOfflineArray);
    }
    [appD.database close];
}

-(void)setDataBaseDataToTable{
    [appD.database open];
    FMResultSet *results = [appD.database executeQuery:@"select * from expertCornerTable"];
    while([results next]) {
        expertOfflineArray = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:@"news"]];
        //NSLog(@"News Array from DB : %@ ",expertOfflineArray);
    }
    [expertArray removeAllObjects];
    [expertArray addObjectsFromArray:expertOfflineArray];
    [self.expertCornerTableView reloadData];
    [appD.database close];
    
}


-(void)initFooterView
{
    footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, SCREENWIDTH, 40.0)];
    
    UIActivityIndicatorView * actInd = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    actInd.tag = 10;
    [actInd setColor:[UIColor redColor]];
    
    actInd.frame = CGRectMake(SCREENWIDTH / 2 - 20 , 5.0, 20.0, 20.0);
    
    actInd.hidesWhenStopped = YES;
    
    [footerView addSubview:actInd];
    
    actInd = nil;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //BOOL endOfTable = (scrollView.contentOffset.y >= ((expertArray.count * 120) - scrollView.frame.size.height)); // Here 40 is row height
    self.expertCornerTableView.tableFooterView = footerView;
    [(UIActivityIndicatorView *)[footerView viewWithTag:10] startAnimating];
    
    //    if (self.hasMoreData && endOfTable && !self.isLoading && !scrollView.dragging && !scrollView.decelerating)
    //    {
    //        self.expertCornerTableView.tableFooterView = footerView;
    //
    //        [(UIActivityIndicatorView *)[footerView viewWithTag:10] startAnimating];
    //    }
    
}


-(void)expertAPICall{

    if ([self checkReachability]) {
        [self startProgressHUD];
        ExpertCornerRequest *req = [[ExpertCornerRequest alloc] init];
        req.delegate = self;
        [req expertWithLowerLimit:lowerLimit withUpperLimit:upperLimit];
    } else {
        [self noInternetAlert];
    }
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
    
    NSString *newsImageUrl = [[NSString stringWithFormat:@"%@",ImageSERVER_API] stringByAppendingString:[[expertArray objectAtIndex:indexPath.row] objectForKey:@"image"]];
    
    Newscell.selectionStyle = UITableViewCellSelectionStyleNone;
    ADVCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
        // Here we use the new provided sd_setImageWithURL: method to load the web image
    @try {
        [Newscell.NewsImageView sd_setImageWithURL:[NSURL URLWithString:[newsImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]placeholderImage:[UIImage imageNamed:@"userimage.png"]];
        Newscell.NewsImageView.layer.cornerRadius=Newscell.NewsImageView.frame.size.width/2;
        Newscell.NewsImageView.layer.borderWidth = 1.0f;
        Newscell.NewsImageView.layer.masksToBounds = YES;
        [Newscell.NewsTitleLabel setFont:[UIFont fontWithName:centuryGothicBold size:titleFont]];
        NSString *yourString = [[[[expertArray objectAtIndex:indexPath.row] objectForKey:@"headline"] stringByAppendingString:@"\n\n"] stringByAppendingString:[[expertArray objectAtIndex:indexPath.row] objectForKey:@"expert_name"]];
        NSMutableAttributedString *yourAttributedString = [[NSMutableAttributedString alloc] initWithString:yourString];
        NSString *boldString = [[expertArray objectAtIndex:indexPath.row] objectForKey:@"expert_name"];
        NSRange boldRange = [yourString rangeOfString:boldString];
        [yourAttributedString addAttribute: NSFontAttributeName value:[UIFont fontWithName:centuryGothicRegular size:titleFont] range:boldRange];
        [Newscell.NewsTitleLabel setAttributedText: yourAttributedString];
        
        
        
        Newscell.NewsDetailLabel.text = [[expertArray objectAtIndex:indexPath.row] objectForKey:@"expert_name"];
        Newscell.NewDateLabel.text = [[expertArray objectAtIndex:indexPath.row] objectForKey:@"date"];
        
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    //NSLog(@"indexpath %ld",(long)indexPath.row);
    
    if (stopPagination) {
        
        if (indexPath.row > 18) {
            
            if (indexPath.row > [expertArray count]-2) {
                lowerLimit = upperLimit;
                upperLimit = [NSString stringWithFormat:@"%d",([upperLimit integerValue] + 20)];
                [self expertAPICall];
                
            }
        }

    }
    
}

#pragma mark -
#pragma mark - News Delegate.
#pragma mark -

-(void)expertRequestSuccessfulWithResult:(NSArray *)result{
    [self stopProgressHUD];
    [expertArray addObjectsFromArray:result];
    stopPagination = YES;
    [self storeDataIntoDataBase];
    [self.expertCornerTableView reloadData];
    [self performSelectorOnMainThread:@selector(stopAnimationForActivityIndicator) withObject:nil waitUntilDone:NO];
    
}

-(void)expertRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
    noMoreItems = YES;
    stopPagination = NO ;
    [self.expertCornerTableView reloadData];
    lowerLimit = @"0";
    upperLimit = @"20";
    [self performSelectorOnMainThread:@selector(stopAnimationForActivityIndicator) withObject:nil waitUntilDone:NO];
    if (expertArray.count == 0) {
        [Utility showMessage:@"No expert columns available" withTitle:@""];
    }else{
        [Utility showMessage:error withTitle:@""];
    }
}

-(void)stopAnimationForActivityIndicator
{
    [self stopProgressHUD];
}

@end
