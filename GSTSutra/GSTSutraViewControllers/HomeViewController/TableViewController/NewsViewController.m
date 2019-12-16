//
//  NewsViewController.m
//  GSTSutra
//
//  Created by niyuj on 11/11/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import "NewsViewController.h"
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
#import "AppDelegate.h"


@interface NewsViewController ()<NewRequestDelegate>{
    NSMutableArray *newsArray;
    NSString *lowerLimit,*upperLimit;
    NSArray *newsOfflineArray;
}
@property (weak, nonatomic) IBOutlet UITableView *newsTableView;
@property (strong,nonatomic) NSIndexPath *selectedPath;

@end

@implementation NewsViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [Utility SetPanGestureOff];
    [USERDEFAULTS setBool:YES forKey:@"isLogin"];
    self.view.translatesAutoresizingMaskIntoConstraints = true;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTestNotification:)name:@"NewsNotification" object:nil];
    
    //I added this if clause to select the row that was last selected
    if (self.selectedPath != nil) {
        [self.newsTableView selectRowAtIndexPath:self.selectedPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
[self performSelectorOnMainThread:@selector(stopAnimationForActivityIndicator) withObject:nil waitUntilDone:NO];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self stopProgressHUD];
    newsArray = [[NSMutableArray alloc]init];
    newsOfflineArray = [[NSArray alloc]init];
    lowerLimit = @"0";
    upperLimit = @"20";
    [self.newsTableView registerNib:[UINib nibWithNibName:@"NewsTableViewCell" bundle:nil] forCellReuseIdentifier:@"NewsTableViewCell"];
    [self.newsTableView registerNib:[UINib nibWithNibName:@"NewsHeaderTableViewCell" bundle:nil] forCellReuseIdentifier:@"NewsHeaderTableViewCell"];
    [self.newsTableView registerNib:[UINib nibWithNibName:@"AdvertiseTableViewCell" bundle:nil] forCellReuseIdentifier:@"AdvertiseTableViewCell"];
    if ([self checkReachability]) {
        [self startProgressHUD];
        NewRequest *req = [[NewRequest alloc]init];
        req.delegate = self;
        [req newsWithLowerLimit:@"0" withUpperLimit:@"0" newsType:@"top_stories" locationType:@"all"];
        
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
    [appD.database executeUpdate:@"DROP TABLE IF EXISTS `newsTable`;"];
    [appD.database executeUpdate:@"create table IF NOT EXISTS newsTable(news blob primary key)"];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:newsArray];
    [appD.database executeUpdate:@"insert into newsTable values (?)",data];
    FMResultSet *results = [appD.database executeQuery:@"select * from newsTable"];
    while([results next]) {
       newsOfflineArray = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:@"news"]];
        //NSLog(@"News Array from DB : %@ ",newsOfflineArray);
    }
    [appD.database close];
}

-(void)setDataBaseDataToTable{
    [appD.database open];
    FMResultSet *results = [appD.database executeQuery:@"select * from newsTable"];
    while([results next]) {
        newsOfflineArray = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:@"news"]];
        //NSLog(@"News Array from DB : %@ ",newsOfflineArray);
    }
    [newsArray removeAllObjects];
    [newsArray addObjectsFromArray:newsOfflineArray];
    [self.newsTableView reloadData];
    [appD.database close];

}
#pragma mark - NSNotification Center

- (void) receiveTestNotification:(NSNotification *) notification{
    
       [self stopProgressHUD];
    
    if ([notification.name isEqualToString:@"NewsNotification"]){
        
        NSDictionary* userInfo = notification.userInfo;
        NSNumber* total = (NSNumber*)userInfo[@"indexNumber"];
        NSLog (@"Successfully received test notification! %i", total.intValue);
        
        if (total.intValue == 0) {
            //NSLog(@"top Stories");
            [self stopProgressHUD];
            if ([self checkReachability]) {
                
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"startHUDWheelNotification"
                 object:self ];
                NewRequest *req = [[NewRequest alloc]init];
                req.delegate = self;
                [req newsWithLowerLimit:@"0" withUpperLimit:@"0" newsType:@"top_stories" locationType:@"all"];
                
            }
            else {
                [self stopProgressHUD];
                //[self noInternetAlert];
                [self setDataBaseDataToTable];
            }
        
        }
    }
}

#pragma mark -
#pragma mark - News Delegate.
#pragma mark -

-(void)newsRequestSuccessfulWithResult:(NSArray *)result{
    [self stopProgressHUD];
    [newsArray removeAllObjects];
    //newsArray = [result mutableCopy];
    [newsArray addObjectsFromArray:result];
    [self storeDataIntoDataBase];
    [self.newsTableView reloadData];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"StopHUDWheelNotification"
     object:self ];
    [self performSelectorOnMainThread:@selector(stopAnimationForActivityIndicator) withObject:nil waitUntilDone:NO];
    
}
-(void)newsRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
    //[newsArray removeAllObjects];
    lowerLimit = @"0";
    upperLimit = @"20";
    [self.newsTableView reloadData];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"StopHUDWheelNotification"
     object:self ];
    [self performSelectorOnMainThread:@selector(stopAnimationForActivityIndicator) withObject:nil waitUntilDone:NO];
    
    if (newsArray.count==0) {
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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
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
            
            
            //[NewsHeadercell.NewsHeaderImageView sizeToFit];
            NewsHeadercell.NewsHeaderLabel.text = [[newsArray objectAtIndex:indexPath.row] objectForKey:@"headline"];
            
            //        NewsHeadercell.NewsHeaderLabel.font = [UIFont fontWithName:centuryGothicBold size:[[USERDEFAULTS objectForKey:@"titleFont"] integerValue]];
            
            NewsHeadercell.NewsHeaderLabel.font = [UIFont fontWithName:centuryGothicBold size:titleFont + 3];
            
            NewsHeadercell.bookmarkButtonClicked.tag = indexPath.row;
            return NewsHeadercell;
        } else {
            
            // Here we use the new provided sd_setImageWithURL: method to load the web image
            
            [Newscell.NewsImageView sd_setImageWithURL:[NSURL URLWithString:[newsImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]placeholderImage:[UIImage imageNamed:@"userimage.png"]];
            Newscell.NewsTitleLabel.text = [[newsArray objectAtIndex:indexPath.row] objectForKey:@"headline"];
            Newscell.NewsTitleLabel.font = [UIFont fontWithName:centuryGothicBold size:titleFont];
            Newscell.NewsDetailLabel.text = [[newsArray objectAtIndex:indexPath.row] objectForKey:@"shortview"];
            Newscell.NewsDetailLabel.font = [UIFont fontWithName:centuryGothicBold size:[[USERDEFAULTS objectForKey:@"normalFont"] integerValue]];
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
    @try {
        
        self.selectedPath = indexPath;
        if ([USERDEFAULTS boolForKey:@"isNotRegisterOrLoginUser"]) {
            [self openLoginViewControllerAlertOnLeftMenuOrView:NO];
        }else {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            ShortNewsViewController *shortView = [self.storyboard instantiateViewControllerWithIdentifier:@"ShortNewsViewController"];
            shortView.selectedIndex =  indexPath.row ;
            shortView.shortViewNewsArray = [newsArray mutableCopy];
            [self.navigationController pushViewController:shortView animated:YES];
        }
        
    } @catch (NSException *exception) {
        
        
    } @finally {
        
    }
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
@end
