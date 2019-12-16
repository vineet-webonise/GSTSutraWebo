//
//  LatestNewsViewController.m
//  GSTSutra
//
//  Created by niyuj on 11/18/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import "LatestNewsViewController.h"
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
#import "BounceEffectViewController.h"
@import FirebaseAnalytics;



@interface LatestNewsViewController ()<NewRequestDelegate>{
    NSMutableArray *newsArray,*ADVArray;
    NSString *lowerLimit,*upperLimit;
    UIView *footerView;
    UIActivityIndicatorView *activityIndicator;
    NSArray *newsOfflineArray;
    BOOL stopPagination,isFromLocalNotification,isViewDidloadCall;
    
}

@property (nonatomic, assign) BOOL noMoreItems;
@property (nonatomic, assign) BOOL isPulledToRefreshData;
@property (weak, nonatomic) IBOutlet UITableView *newsTableView;
@property (strong,nonatomic) NSIndexPath *selectedPath;
@end

@implementation LatestNewsViewController

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    
    lowerLimit = @"0";
    upperLimit = @"20";
    isFromLocalNotification = YES;
    [Utility SetPanGestureOff];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTestNotification:)name:@"NewsNotification" object:nil];
    
    //I added this if clause to select the row that was last selected
    if (self.selectedPath != nil) {
        [self.newsTableView selectRowAtIndexPath:self.selectedPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
    if (!isViewDidloadCall) {
        if(self.isHomePageLoaded){
            self.isHomePageLoaded = NO ;
            if (newsArray.count == 0) {
                //[Utility showMessage:@"No stories available" withTitle:@""];
            }
        }
    }
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self stopProgressHUD];
    isViewDidloadCall = YES;
    stopPagination = YES;
    isFromLocalNotification = YES;
    newsArray = [[NSMutableArray alloc]init];
    ADVArray = [[NSMutableArray alloc]init];
    newsOfflineArray = [[NSArray alloc]init];
    lowerLimit = @"0";
    upperLimit = @"20";
    
    [self.newsTableView registerNib:[UINib nibWithNibName:@"NewsTableViewCell" bundle:nil] forCellReuseIdentifier:@"NewsTableViewCell"];
    [self.newsTableView registerNib:[UINib nibWithNibName:@"NewsHeaderTableViewCell" bundle:nil] forCellReuseIdentifier:@"NewsHeaderTableViewCell"];
    [self.newsTableView registerNib:[UINib nibWithNibName:@"AdvertiseTableViewCell" bundle:nil] forCellReuseIdentifier:@"AdvertiseTableViewCell"];
    
      //[self initFooterView];
    if ([self checkReachability]) {
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
    [appD.database executeUpdate:@"DROP TABLE IF EXISTS `latestNewsTable`;"];
    [appD.database executeUpdate:@"create table IF NOT EXISTS latestNewsTable(news blob primary key)"];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:newsArray];
    [appD.database executeUpdate:@"insert into latestNewsTable values (?)",data];
    FMResultSet *results = [appD.database executeQuery:@"select * from latestNewsTable"];
    while([results next]) {
        newsOfflineArray = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:@"news"]];
        //NSLog(@"News Array from DB : %@ ",newsOfflineArray);
    }
    [appD.database close];
}

-(void)setDataBaseDataToTable{
    [appD.database open];
    FMResultSet *results = [appD.database executeQuery:@"select * from latestNewsTable"];
    while([results next]) {
        newsOfflineArray = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:@"news"]];
        //NSLog(@"News Array from DB : %@ ",newsOfflineArray);
    }
    [newsArray removeAllObjects];
    [newsArray addObjectsFromArray:newsOfflineArray];
    [self.newsTableView reloadData];
    [appD.database close];
    
}

-(void)initFooterView
{
    footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, SCREENWIDTH, 40.0)];
    
    UIActivityIndicatorView * actInd = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    actInd.tag = 10;
    [actInd setColor:[UIColor redColor]];
    
    actInd.frame = CGRectMake(SCREENWIDTH/2, 5.0, 20.0, 20.0);
    
    actInd.hidesWhenStopped = YES;
    
    [footerView addSubview:actInd];
    
    actInd = nil;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //BOOL endOfTable = (scrollView.contentOffset.y >= ((newsArray.count * 120) - scrollView.frame.size.height)); // Here 40 is row height
    self.newsTableView.tableFooterView = footerView;
    [(UIActivityIndicatorView *)[footerView viewWithTag:10] startAnimating];
    
//    if (self.hasMoreData && endOfTable && !self.isLoading && !scrollView.dragging && !scrollView.decelerating)
//    {
//        self.newsTableView.tableFooterView = footerView;
//        
//        [(UIActivityIndicatorView *)[footerView viewWithTag:10] startAnimating];
//    }
    
}

-(void)getADVAPICALL{
    if ([self checkReachability]) {
    NewRequest *req = [[NewRequest alloc] init];
    req.delegate = self;
    [req getAllAdvertisements];
    } else {
        [self noInternetAlert];
    }
}

-(void)getAllADVRequestSuccessfulWithResult:(NSArray *)result{
    [self stopProgressHUD];
    
    //NSLog(@"ADV Array %@",result);
    ADVArray = [result mutableCopy];
    
    int j=0;
    for (int i = 0; i< [newsArray count];) {
        if (j<[result count]) {
            [newsArray insertObject:[result objectAtIndex:j] atIndex:i+3];
            j++;
        }
        i = i+4;
    }
    [self storeDataIntoDataBase];
    [self.newsTableView reloadData];
    [self performSelectorOnMainThread:@selector(stopAnimationForActivityIndicator) withObject:nil waitUntilDone:NO];
}

-(void)getAllADVRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
    [self storeDataIntoDataBase];
    [self.newsTableView reloadData];
   // [Utility showMessage:error withTitle:@""];
    
}


#pragma mark - NSNotification Center

- (void) receiveTestNotification:(NSNotification *) notification{
    
    if ([notification.name isEqualToString:@"NewsNotification"]){
        
        NSDictionary* userInfo = notification.userInfo;
        NSNumber* total = (NSNumber*)userInfo[@"indexNumber"];
         if (total.intValue == 1){
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
                //[self noInternetAlert];
                [self setDataBaseDataToTable];
            }
        }
    }
}


-(void)latestAPICall{
    
    [self startProgressHUD];
    isFromLocalNotification = NO;
//    if (!isViewDidloadCall) {
//        [[NSNotificationCenter defaultCenter]
//         postNotificationName:@"startHUDWheelNotification"
//         object:self ];
//    }
    NewRequest *req = [[NewRequest alloc]init];
    req.delegate = self;
    [req newsWithLowerLimit:lowerLimit withUpperLimit:upperLimit newsType:@"latest_news" locationType:@"all"];
}

#pragma mark -
#pragma mark - News Delegate.
#pragma mark -

-(void)newsRequestSuccessfulWithResult:(NSArray *)result{
//    [[NSNotificationCenter defaultCenter]
//     postNotificationName:@"StopHUDWheelNotification"
//     object:self ];
//    [MBProgressHUD hideHUDForView:self.view animated:YES];
//    
//    [self stopProgressHUD];
    [newsArray addObjectsFromArray:result];
    
    int j= 0;
    for (int i = 0; i< [newsArray count]; i++) {
        
                if ([[[newsArray objectAtIndex:i] objectForKey:@"story_type"] integerValue] == 26){
                    [newsArray removeObjectAtIndex:i];
                }
    }
    
    if([ADVArray count]>0){
        for (int i = 0; i< [newsArray count];) {
            if (j<[ADVArray count]) {
                [newsArray insertObject:[ADVArray objectAtIndex:j] atIndex:i+3];
                j++;
            }
            i = i+4;
        }
        [self storeDataIntoDataBase];
        [self.newsTableView reloadData];
    }
    
    if ([ADVArray count]==0) {
        [self getADVAPICALL];
        
    } else {
        [self storeDataIntoDataBase];
        [self.newsTableView reloadData];
    }
    isViewDidloadCall = NO;
    //[self storeDataIntoDataBase];
    //[self.newsTableView reloadData];
    
    [self performSelectorOnMainThread:@selector(stopAnimationForActivityIndicator) withObject:nil waitUntilDone:NO];
}
-(void)newsRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
    
//    [[NSNotificationCenter defaultCenter]
//     postNotificationName:@"StopHUDWheelNotification"
//     object:self ];
    stopPagination = NO;
    [self.newsTableView reloadData];
    lowerLimit = @"0";
    upperLimit = @"20";
//    [[NSNotificationCenter defaultCenter]
//     postNotificationName:@"StopHUDWheelNotification"
//     object:self ];
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
                if (IPAD) {
                    NewsHeadercell.backgroundColor = [UIColor colorWithPatternImage:[Utility imageWithImage:image scaledToSize:CGSizeMake(SCREENWIDTH, 260)]];
                } else {
                    NewsHeadercell.backgroundColor = [UIColor colorWithPatternImage:[Utility imageWithImage:image scaledToSize:CGSizeMake(SCREENWIDTH, 190)]];
                }
                
                
                CGImageRelease(cgimg);
                
                
                
            } else {
                [NewsHeadercell.NewsHeaderImageView sd_setImageWithURL:[NSURL URLWithString:[newsImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]placeholderImage:[UIImage imageNamed:@"userimage.png"]];
            }
            
            NewsHeadercell.NewsHeaderLabel.text = [[newsArray objectAtIndex:indexPath.row] objectForKey:@"headline"];
            NewsHeadercell.NewsHeaderLabel.font = [UIFont fontWithName:centuryGothicBold size:titleFont + 3];
            
            NewsHeadercell.bookmarkButtonClicked.tag = indexPath.row;
            return NewsHeadercell;
        } else if ([[[newsArray objectAtIndex:indexPath.row] objectForKey:@"story_type"] integerValue] == 26){
            
            // Here we use the new provided sd_setImageWithURL: method to load the web image
            [ADVCell.advertiseImageView sd_setImageWithURL:[NSURL URLWithString:[newsImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]placeholderImage:[UIImage imageNamed:@"userimage.png"]];
            //NSLog(@"NewsADVImageURl %@",newsImageUrl);
            if ([[[newsArray objectAtIndex:indexPath.row] objectForKey:@"headline"] isEqualToString:@""]) {
                [ADVCell.advertiseImageView sd_setImageWithURL:[NSURL URLWithString:[newsImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]placeholderImage:[UIImage imageNamed:@"userimage.png"]];
                //NSLog(@"NewsADVImageURl %@",newsImageUrl);
                ADVCell.advertiseTitle.hidden = YES;
                
            } else {
                ADVCell.advertiseTitle.hidden = NO;
                ADVCell.advertiseTitle.text = [[newsArray objectAtIndex:indexPath.row] objectForKey:@"headline"];
            }
            [ADVCell bringSubviewToFront:ADVCell.advLabel];
            return ADVCell;
            
        }else {
            
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.selectedPath = indexPath;
    
    if ([USERDEFAULTS boolForKey:@"isNotRegisterOrLoginUser"]) {
        [self openLoginViewControllerAlertOnLeftMenuOrView:NO];
    }else if ([[[newsArray objectAtIndex:indexPath.row] objectForKey:@"story_type"] integerValue] == 26){
        
        @try {
            NSURL *url = [NSURL URLWithString:[[newsArray objectAtIndex:indexPath.row] objectForKey:@"link"]];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            } else{
                //[Utility showMessage:@"Invalid Url" withTitle:@"Error!"];
            }

        } @catch (NSException *exception) {
            
        } @finally {
            
        }
        
    }else{
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        ShortNewsViewController *shortView = [self.storyboard instantiateViewControllerWithIdentifier:@"ShortNewsViewController"];
        shortView.selectedIndex =  indexPath.row;
        shortView.shortViewNewsArray = [newsArray mutableCopy];
        shortView.selectedNewsType = @"Latest";
        [self.navigationController pushViewController:shortView animated:YES];
        
    }

    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
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
    static NSString *NewsHeadercellIdentifier = @"NewsHeaderTableViewCell";
    NewsHeaderTableViewCell *NewsHeadercell = (NewsHeaderTableViewCell*)[tableView dequeueReusableCellWithIdentifier:NewsHeadercellIdentifier];
    
    
    NSString *newsImageUrl = [[NSString stringWithFormat:@"%@",ImageSERVER_API] stringByAppendingString:[[newsArray objectAtIndex:indexPath.row] objectForKey:@"image"]];
    
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
            
            if (IPAD) {
                NewsHeadercell.backgroundColor = [UIColor colorWithPatternImage:[Utility imageWithImage:image scaledToSize:CGSizeMake(SCREENWIDTH, 260)]];
            } else {
                NewsHeadercell.backgroundColor = [UIColor colorWithPatternImage:[Utility imageWithImage:image scaledToSize:CGSizeMake(SCREENWIDTH, 190)]];
            }
            
            
            CGImageRelease(cgimg);
            
            
            
        } else {
            [NewsHeadercell.NewsHeaderImageView sd_setImageWithURL:[NSURL URLWithString:[newsImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]placeholderImage:[UIImage imageNamed:@"userimage.png"]];
        }
    }
    
    if (indexPath.row > 16) {
        
        if ([USERDEFAULTS boolForKey:@"isNotRegisterOrLoginUser"]) {
            [self openLoginViewControllerAlertOnLeftMenuOrView:NO];
        } else {
            if (stopPagination) {
                if ([self checkReachability]) {
                    //[self startProgressHUD];
                    if (indexPath.row >  [newsArray count] - 2) {
                        self.isPulledToRefreshData = YES;
                        lowerLimit = upperLimit;
                        upperLimit = [NSString stringWithFormat:@"%ld",([upperLimit integerValue] + 20)];
                        [self latestAPICall];
                    }
                }else {
                    //[self noInternetAlert];
                }
                
            }
        }
    }
    
}


@end
