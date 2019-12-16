//
//  LocNewsViewController.m
//  GSTSutra
//
//  Created by niyuj on 2/13/17.
//  Copyright © 2017 niyuj. All rights reserved.
//

#import "LocNewsViewController.h"
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
#import "NatureOfIssueRequest.h"

@interface LocNewsViewController ()<NatureOfIssueRequestDelegate>{
    NSMutableArray *newsArray;
    NSString *lowerLimit,*upperLimit;
    BOOL isViewDidloadCall;
    UIView *footerView;
    UIActivityIndicatorView *activityIndicator;
    NSArray *newsOfflineArray;
    BOOL stopPagination;
    BOOL isFromLocalNotification;
    
}
@property (nonatomic, assign) BOOL noMoreItems;
@property (nonatomic, assign) BOOL isPulledToRefreshData;
@property (weak, nonatomic) IBOutlet UITableView *locationNewsTableView;

@end

@implementation LocNewsViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [Utility SetPanGestureOff];
    isFromLocalNotification = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveVideoNotification:)name:@"VideoNotification" object:nil];
    if (!isViewDidloadCall) {
        if(self.isHomePageLoaded){
            self.isHomePageLoaded = NO ;
            if (newsArray.count == 0) {
                [Utility showMessage:@"No stories available" withTitle:@""];
            }
        }
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBarTitleLabel:@"News"];
    [self stopProgressHUD];
    isViewDidloadCall = YES;
    stopPagination = NO;
    isFromLocalNotification = YES;
    newsArray = [[NSMutableArray alloc]init];
    newsOfflineArray = [[NSArray alloc]init];
    lowerLimit = @"0";
    upperLimit = @"20";
    [self.locationNewsTableView registerNib:[UINib nibWithNibName:@"NewsTableViewCell" bundle:nil] forCellReuseIdentifier:@"NewsTableViewCell"];
    [self.locationNewsTableView registerNib:[UINib nibWithNibName:@"NewsHeaderTableViewCell" bundle:nil] forCellReuseIdentifier:@"NewsHeaderTableViewCell"];
    [self.locationNewsTableView registerNib:[UINib nibWithNibName:@"AdvertiseTableViewCell" bundle:nil] forCellReuseIdentifier:@"AdvertiseTableViewCell"];
   
        
        if ([self checkReachability]) {
            //[self startProgressHUD];
            [self latestAPICall];
        }
        else {
            [self stopProgressHUD];
            //[self noInternetAlert];
            [self setDataBaseDataToTable];
        }
    
}

#pragma  mark - Sqlite Database

-(void)storeDataIntoDataBase{
    [appD.database open];
    [appD.database executeUpdate:@"DROP TABLE IF EXISTS `locationNewsTable`;"];
    [appD.database executeUpdate:@"create table IF NOT EXISTS locationNewsTable(news blob primary key)"];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:newsArray];
    [appD.database executeUpdate:@"insert into locationNewsTable values (?)",data];
    FMResultSet *results = [appD.database executeQuery:@"select * from locationNewsTable"];
    while([results next]) {
        newsOfflineArray = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:@"news"]];
        //NSLog(@"News Array from DB : %@ ",newsOfflineArray);
    }
    [appD.database close];
}

-(void)setDataBaseDataToTable{
    [appD.database open];
    FMResultSet *results = [appD.database executeQuery:@"select * from locationNewsTable"];
    while([results next]) {
        newsOfflineArray = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:@"news"]];
        //NSLog(@"News Array from DB : %@ ",newsOfflineArray);
    }
    [newsArray removeAllObjects];
    [newsArray addObjectsFromArray:newsOfflineArray];
    [self.locationNewsTableView reloadData];
    [appD.database close];
    
}


-(void)initFooterView
{
    footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, SCREENWIDTH, 40.0)];
    
    UIActivityIndicatorView * actInd = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    actInd.tag = 10;
    [actInd setColor:[UIColor redColor]];
    
    actInd.frame = CGRectMake(150.0, 5.0, 20.0, 20.0);
    
    actInd.hidesWhenStopped = YES;
    
    [footerView addSubview:actInd];
    
    actInd = nil;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //BOOL endOfTable = (scrollView.contentOffset.y >= ((newsArray.count * 120) - scrollView.frame.size.height)); // Here 40 is row height
    self.locationNewsTableView.tableFooterView = footerView;
    [(UIActivityIndicatorView *)[footerView viewWithTag:10] startAnimating];
    
    //    if (self.hasMoreData && endOfTable && !self.isLoading && !scrollView.dragging && !scrollView.decelerating)
    //    {
    //        self.locationNewsTableView.tableFooterView = footerView;
    //
    //        [(UIActivityIndicatorView *)[footerView viewWithTag:10] startAnimating];
    //    }
    
}

#pragma mark - NSNotification Center

- (void) receiveVideoNotification:(NSNotification *) notification{
    
    if ([notification.name isEqualToString:@"VideoNotification"]){
        
        NSDictionary* userInfo = notification.userInfo;
        NSNumber* total = (NSNumber*)userInfo[@"indexNumber"];
        if (total.intValue == 2){
            //NSLog(@"latest Stories");
            
            [self stopProgressHUD];
            if ([self checkReachability]) {
                
                //NSLog(@"IsfromLoginValue %d",isFromLocalNotification);
                if (isFromLocalNotification) {
                    [newsArray removeAllObjects];
                    [self latestAPICall];
                }
                
            }
            else {
                [self stopProgressHUD];
                [self noInternetAlert];
                
            }
        }
    }
}




-(void)latestAPICall{
    
    if (!isViewDidloadCall) {
        //[self startProgressHUD];
//        [[NSNotificationCenter defaultCenter]
//         postNotificationName:@"startVideoHUDWheelNotification"
//         object:self ];
    }
//    [[NSNotificationCenter defaultCenter]
//     postNotificationName:@"startVideoHUDWheelNotification"
//     object:self ];
    isFromLocalNotification = NO;
    [self startProgressHUD];
     NatureOfIssueRequest *req = [[NatureOfIssueRequest alloc]init];
    req.delegate = self;
    //NSLog(@"Selected location index in Latest Story %@",[USERDEFAULTS objectForKey:@"locationID"]);
    
    if ([[USERDEFAULTS objectForKey:@"locationID"] isEqualToString:@"0"] ||([[USERDEFAULTS objectForKey:@"locationID"] length] == 0)) {
       
        [req locationDataWithLowerLimit:lowerLimit withUpperLimit:upperLimit locationType:@"all" isFormsType:@"0" storyType:@"8"];
    } else {
        [req locationDataWithLowerLimit:lowerLimit withUpperLimit:upperLimit locationType:[USERDEFAULTS objectForKey:@"locationID"] isFormsType:@"0" storyType:@"8"];
    }
    
    
}



#pragma mark -
#pragma mark - Location Delegate.
#pragma mark -

-(void)locationDataRequestSuccessfulWithResult:(NSArray *)result{
//    [[NSNotificationCenter defaultCenter]
//     postNotificationName:@"StopVideoHUDWheelNotification"
//     object:self ];
//    [MBProgressHUD hideHUDForView:self.view animated:YES];
//    [self stopProgressHUD];
    isViewDidloadCall = NO;
    stopPagination = YES;
    [newsArray addObjectsFromArray:[result mutableCopy]];
    [self.locationNewsTableView reloadData];
    
    [self performSelectorOnMainThread:@selector(stopAnimationForActivityIndicator) withObject:nil waitUntilDone:NO];
    
}

-(void)locationDataRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    //[self stopProgressHUD];
    lowerLimit = @"0";
    upperLimit = @"20";
    stopPagination = NO;
    [self performSelectorOnMainThread:@selector(stopAnimationForActivityIndicator) withObject:nil waitUntilDone:NO];
    if (isViewDidloadCall) {
        //no need to show alert Data.
        isViewDidloadCall = NO;
        
    } else if (newsArray.count==0 && !stopPagination) {
        [Utility showMessage:@"No stories available" withTitle:@""];
    } else {
        [Utility showMessage:error withTitle:@""];
    }
    
}

-(void)stopAnimationForActivityIndicator
{
    [self stopProgressHUD];
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
        
        
        
        if (indexPath.row == 0) {
            
            // Here we use the new provided sd_setImageWithURL: method to load the web image
            if ([[[newsArray objectAtIndex:indexPath.row] objectForKey:@"small_image"] boolValue]) {
                NewsHeadercell.NewsHeaderImageView.contentMode = UIViewContentModeScaleAspectFit;
                [NewsHeadercell.NewsHeaderImageView sd_setImageWithURL:[NSURL URLWithString:[newsImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]placeholderImage:[UIImage imageNamed:@"userimage.png"]];
                CIFilter *gaussianBlurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
                [gaussianBlurFilter setDefaults];
                CIImage *inputImage = [CIImage imageWithCGImage:[NewsHeadercell.NewsHeaderImageView.image CGImage]];
                [gaussianBlurFilter setValue:inputImage forKey:kCIInputImageKey];
                [gaussianBlurFilter setValue:@10 forKey:kCIInputRadiusKey];
                
                CIImage *outputImage = [gaussianBlurFilter outputImage];
                CIContext *context   = [CIContext contextWithOptions:nil];
                CGImageRef cgimg     = [context createCGImage:outputImage fromRect:[inputImage extent]];  // note, use input image extent if you want it the same size, the output image extent is larger
                UIImage *image = [UIImage imageWithCGImage:cgimg];
                NewsHeadercell.backgroundColor = [UIColor colorWithPatternImage:[Utility imageWithImage:image scaledToSize:CGSizeMake(SCREENWIDTH, 190)]];
                
                CGImageRelease(cgimg);
                
                
                
            } else {
                [NewsHeadercell.NewsHeaderImageView sd_setImageWithURL:[NSURL URLWithString:[newsImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]placeholderImage:[UIImage imageNamed:@"userimage.png"]];
            }
            
            NewsHeadercell.NewsHeaderLabel.text = [[newsArray objectAtIndex:indexPath.row] objectForKey:@"headline"];
            NewsHeadercell.NewsHeaderLabel.font = [UIFont fontWithName:centuryGothicBold size:titleFont + 3];
            NewsHeadercell.bookmarkButtonClicked.tag = indexPath.row;
            return NewsHeadercell;
        } else {
            
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
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ShortNewsViewController *shortView = [self.storyboard instantiateViewControllerWithIdentifier:@"ShortNewsViewController"];
    shortView.selectedIndex =  indexPath.row ;
    shortView.shortViewNewsArray = [newsArray mutableCopy];
    shortView.selectedNewsType = @"Location";
    [self.navigationController pushViewController:shortView animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IPAD) {
        if (indexPath.row==0) {
            return 260;
        } else {
            return 132;
        }
        
    } else {
        if (indexPath.row==0) {
            return 190;
        } else {
            return 132;
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    //NSLog(@"indexpath %ld",(long)indexPath.row);
    
        
        if (stopPagination) {
            
            if (indexPath.row > 18) {
                if (indexPath.row > [newsArray count]-2) {
                    self.isPulledToRefreshData = YES;
                    lowerLimit = upperLimit;
                    upperLimit = [NSString stringWithFormat:@"%ld",([upperLimit integerValue] + 20)];
                    [self latestAPICall];
                    
                }
            }
        }
    
}

@end
