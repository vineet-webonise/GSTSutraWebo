//
//  NOINewsViewController.m
//  GSTSutra
//
//  Created by niyuj on 2/10/17.
//  Copyright © 2017 niyuj. All rights reserved.
//

#import "NOINewsViewController.h"
#import "NewsTableViewCell.h"
#import "NewsHeaderTableViewCell.h"
#import "AdvertiseTableViewCell.h"
#import "NewRequest.h"
#import "videoPlayerViewController.h"
#import "UIImageView+WebCache.h"
#import "NatureOfIssueRequest.h"
#import "ShortNewsViewController.h"



@interface NOINewsViewController ()<NewRequestDelegate,NatureOfIssueRequestDelegate>{
    NSMutableArray *newsArray;
    BOOL isFromLocalNotification,isViewDidloadCall,stopPagination;
    NSString *lowerLimit,*upperLimit;
    UIView *footerView;
    UIActivityIndicatorView *activityIndicator;
    NSArray *newsOfflineArray;
   
}
@property (weak, nonatomic) IBOutlet UITableView *newsTableView;
@property (strong,nonatomic) NSIndexPath *selectedPath;


@end

@implementation NOINewsViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    isFromLocalNotification = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveVideoNotification:)name:@"VideoNotification" object:nil];
    //[self getFilterNewsApiCall];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBarTitleLabel:@"Videos"];
    @try {
        lowerLimit = @"0";
        upperLimit = @"20";
        stopPagination = YES;
        isFromLocalNotification = YES;
        isViewDidloadCall = YES;
        newsArray = [[NSMutableArray alloc] initWithCapacity:0];
        [self.newsTableView registerNib:[UINib nibWithNibName:@"NewsTableViewCell" bundle:nil] forCellReuseIdentifier:@"NewsTableViewCell"];
        [self.newsTableView registerNib:[UINib nibWithNibName:@"NewsHeaderTableViewCell" bundle:nil] forCellReuseIdentifier:@"NewsHeaderTableViewCell"];
        [self.newsTableView registerNib:[UINib nibWithNibName:@"AdvertiseTableViewCell" bundle:nil] forCellReuseIdentifier:@"AdvertiseTableViewCell"];
        //[self startProgressHUD];
        [self getFilterNewsApiCall];

    } @catch (NSException *exception) {
        
    } @finally {
        
    }}

#pragma mark - NSNotification Center

- (void) receiveVideoNotification:(NSNotification *) notification{
    
    if ([notification.name isEqualToString:@"VideoNotification"]){
        
        NSDictionary* userInfo = notification.userInfo;
        NSNumber* total = (NSNumber*)userInfo[@"indexNumber"];
        if (total.intValue == 0){
            //NSLog(@" News");
            
            [self stopProgressHUD];
            if ([self checkReachability]) {
                
                //NSLog(@"IsfromLoginValue %d",isFromLocalNotification);
                if (isFromLocalNotification) {
                    [newsArray removeAllObjects];
                    [self getFilterNewsApiCall];
                }
                
            }
            else {
                [self stopProgressHUD];
                [self noInternetAlert];
                
            }
        }
    }
}



-(void)getFilterNewsApiCall{

    @try {
        if ([self checkReachability]) {
            //        if (!isViewDidloadCall) {
            //            [[NSNotificationCenter defaultCenter]
            //             postNotificationName:@"startVideoHUDWheelNotification"
            //             object:self ];
            //        }
            [self startProgressHUD];
            isFromLocalNotification = NO;
            NatureOfIssueRequest *req = [[NatureOfIssueRequest alloc] init];
            req.delegate = self;
            NSArray *temp = [USERDEFAULTS objectForKey:@"NOIID"];
            if ([USERDEFAULTS objectForKey:@"inDustriesID"] != nil && [USERDEFAULTS objectForKey:@"NOIID"] != nil && [temp count]!=0) {
                //NSArray *temp = [USERDEFAULTS objectForKey:@"NOIID"];
                NSString *joinedComponents = [temp componentsJoinedByString:@","];
                [req filterWithLowerLimit:lowerLimit withUpperLimit:upperLimit IndustryType:[USERDEFAULTS objectForKey:@"inDustriesID"] issueType:joinedComponents storyType:@"8"];
            } else if ([USERDEFAULTS objectForKey:@"inDustriesID"] != nil){
                [req filterWithLowerLimit:lowerLimit withUpperLimit:upperLimit IndustryType:[USERDEFAULTS objectForKey:@"inDustriesID"] issueType:@"all" storyType:@"8"];
            }else if ([USERDEFAULTS objectForKey:@"NOIID"] != nil) {
                NSString *joinedComponents = [temp componentsJoinedByString:@","];
                [req filterWithLowerLimit:lowerLimit withUpperLimit:upperLimit IndustryType:@"all" issueType:joinedComponents storyType:@"8"];
            }
            
        } else {
            [self noInternetAlert];
        }

    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}


-(void)filterNOIRequestSuccessfulWithResult:(NSArray *)result{

    @try {
        //    [[NSNotificationCenter defaultCenter]
        //     postNotificationName:@"StopVideoHUDWheelNotification"
        //     object:self ];
        //    [MBProgressHUD hideHUDForView:self.view animated:YES];
        //    [self stopProgressHUD];
        isViewDidloadCall = NO;
        [newsArray addObjectsFromArray:[result mutableCopy]];
        [self.newsTableView reloadData];
        [self performSelectorOnMainThread:@selector(stopAnimationForActivityIndicator) withObject:nil waitUntilDone:NO];

    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

-(void)filterNOIRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    
    @try {
        [self stopProgressHUD];
        lowerLimit = @"0";
        upperLimit = @"20";
        stopPagination = NO;
        [self performSelectorOnMainThread:@selector(stopAnimationForActivityIndicator) withObject:nil waitUntilDone:NO];
        
        
        if (newsArray.count==0) {
            [Utility showMessage:@"No stories available" withTitle:@""];
        } else if (isViewDidloadCall) {
            //no need to show alert Data.
            isViewDidloadCall = NO;
            
        } else {
            [Utility showMessage:error withTitle:@""];
        }
        
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
//    if(self.isHomePageLoaded){
//        self.isHomePageLoaded = NO ;
//        if (newsArray.count == 0) {
//             [Utility showMessage:@"No news available" withTitle:@""];
//        } else{
//            [Utility showMessage:error withTitle:@""];
//        }
//    } else{
//        [Utility showMessage:error withTitle:@""];
//    }
    
}

-(void)stopAnimationForActivityIndicator
{
    [self stopProgressHUD];
}

#pragma mark -
#pragma mark - UITable view Delegate
#pragma mark -

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        self.selectedPath = indexPath;
        
        if ([USERDEFAULTS boolForKey:@"isNotRegisterOrLoginUser"]) {
            [self openLoginViewControllerAlertOnLeftMenuOrView:NO];
        }else if ([[[newsArray objectAtIndex:indexPath.row] objectForKey:@"story_type"] integerValue] == 26){
            NSURL *url = [NSURL URLWithString:[[newsArray objectAtIndex:indexPath.row] objectForKey:@"link"]];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            } else{
                [Utility showMessage:@"Invalid Url" withTitle:@"Error!"];
            }
            
        }else{
                        
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            ShortNewsViewController *shortView = [self.storyboard instantiateViewControllerWithIdentifier:@"ShortNewsViewController"];
            shortView.selectedIndex =  indexPath.row;
            shortView.shortViewNewsArray = [newsArray mutableCopy];
            shortView.selectedNewsType = @"Latest";
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
    
    if (stopPagination) {
        //[self startProgressHUD];
        if (indexPath.row > 15) {
            if (indexPath.row > [newsArray count] - 2) {
                lowerLimit = upperLimit;
                upperLimit = [NSString stringWithFormat:@"%ld",([upperLimit integerValue] + 20)];
                [self getFilterNewsApiCall];
            }
        }
    }

    
}

@end
