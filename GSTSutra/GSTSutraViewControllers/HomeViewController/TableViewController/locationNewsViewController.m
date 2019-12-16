//
//  locationNewsViewController.m
//  GSTSutra
//
//  Created by niyuj on 11/22/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import "locationNewsViewController.h"
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

@interface locationNewsViewController ()<NewRequestDelegate>{
    NSMutableArray *newsArray;
    NSString *lowerLimit,*upperLimit;
    BOOL isViewDidloadCall;
    UIView *footerView;
    UIActivityIndicatorView *activityIndicator;
    NSArray *newsOfflineArray;
    BOOL stopPagination;
    
}

@property (nonatomic, assign) BOOL noMoreItems;
@property (nonatomic, assign) BOOL isPulledToRefreshData;
@property (weak, nonatomic) IBOutlet UITableView *locationNewsTableView;

@end

@implementation locationNewsViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [Utility SetPanGestureOff];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTestNotification:)name:@"NewsNotification" object:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBarTitleLabel:@"News"];
    [self stopProgressHUD];
    isViewDidloadCall = YES;
    stopPagination = YES;
    newsArray = [[NSMutableArray alloc]init];
    newsOfflineArray = [[NSArray alloc]init];
    lowerLimit = @"0";
    upperLimit = @"20";
    [self.locationNewsTableView registerNib:[UINib nibWithNibName:@"NewsTableViewCell" bundle:nil] forCellReuseIdentifier:@"NewsTableViewCell"];
    [self.locationNewsTableView registerNib:[UINib nibWithNibName:@"NewsHeaderTableViewCell" bundle:nil] forCellReuseIdentifier:@"NewsHeaderTableViewCell"];
    [self.locationNewsTableView registerNib:[UINib nibWithNibName:@"AdvertiseTableViewCell" bundle:nil] forCellReuseIdentifier:@"AdvertiseTableViewCell"];
    if (self.isIndustriesSelected) {
        
        if ([self checkReachability]) {
            [self startProgressHUD];
            [self IndustriesAPICall];
        }
        else {
            [self stopProgressHUD];
            [self noInternetAlert];
        }

    } else {
        
        if ([self checkReachability]) {
            [self startProgressHUD];
            [self latestAPICall];
        }
        else {
            [self stopProgressHUD];
            //[self noInternetAlert];
            [self setDataBaseDataToTable];
        }

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

-(void)latestAPICall{
    NewRequest *req = [[NewRequest alloc]init];
    req.delegate = self;
    //NSLog(@"Selected location index in Latest Story %@",[USERDEFAULTS objectForKey:@"locationID"]);
    
    if ([[USERDEFAULTS objectForKey:@"locationID"] isEqualToString:@"0"] ||([[USERDEFAULTS objectForKey:@"locationID"] length] == 0)) {
        [req newsWithLowerLimit:lowerLimit withUpperLimit:upperLimit newsType:@"latest_news" locationType:@"all"];
    } else {
        [req newsWithLowerLimit:lowerLimit withUpperLimit:upperLimit newsType:@"latest_news" locationType:[USERDEFAULTS objectForKey:@"locationID"]];
    }
    
}


-(void)IndustriesAPICall{
    NewRequest *req = [[NewRequest alloc]init];
    req.delegate = self;
    [req newsWithLowerLimit:lowerLimit withUpperLimit:upperLimit newsType:@"latest" industryType:[USERDEFAULTS objectForKey:@"inDustriesID"]];
}

#pragma mark -
#pragma mark - Location Delegate.
#pragma mark -

-(void)newsRequestSuccessfulWithResult:(NSArray *)result{
    [self stopProgressHUD];
    [newsArray addObjectsFromArray:result];
     [self storeDataIntoDataBase];
    [self.locationNewsTableView reloadData];
    
}
-(void)newsRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
    stopPagination = NO;
    [self.locationNewsTableView reloadData];
    [Utility showMessage:error withTitle:@""];

}


#pragma mark -
#pragma mark - Industries  Delegate.
#pragma mark -

-(void)newsForIndustriesRequestSuccessfulWithResult:(NSArray *)result{
    [self stopProgressHUD];
    [newsArray addObjectsFromArray:result];
    [self storeDataIntoDataBase];
    [self.locationNewsTableView reloadData];
    
    
}
-(void)newsForIndustriesRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
    stopPagination = NO;
    [self.locationNewsTableView reloadData];
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
            NewsHeadercell.bookmarkButtonClicked.tag = indexPath.row;
            return NewsHeadercell;
        } else {
            
            // Here we use the new provided sd_setImageWithURL: method to load the web image
            [Newscell.NewsImageView sd_setImageWithURL:[NSURL URLWithString:[newsImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]placeholderImage:[UIImage imageNamed:@"userimage.png"]];
            Newscell.NewsTitleLabel.text = [[newsArray objectAtIndex:indexPath.row] objectForKey:@"headline"];
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
    
    if (indexPath.row > 18) {
        
        if (stopPagination) {
            
            if (self.isIndustriesSelected) {
                if (indexPath.row > [newsArray count]-2) {
                    self.isPulledToRefreshData = YES;
                    lowerLimit = upperLimit;
                    upperLimit = [NSString stringWithFormat:@"%ld",([upperLimit integerValue] + 20)];
                    [self IndustriesAPICall];
                    
                }
            } else {
                if (indexPath.row >= [newsArray count]-2) {
                    self.isPulledToRefreshData = YES;
                    lowerLimit = upperLimit;
                    upperLimit = [NSString stringWithFormat:@"%ld",([upperLimit integerValue] + 20)];
                    [self latestAPICall];
                    
                }
            }
            
        } else {
            
            //footerView.hidden = YES;
        }

        }
    
}


@end
