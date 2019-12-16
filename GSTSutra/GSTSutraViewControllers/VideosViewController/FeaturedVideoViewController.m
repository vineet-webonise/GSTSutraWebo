//
//  FeaturedVideoViewController.m
//  GSTSutra
//
//  Created by niyuj on 1/28/17.
//  Copyright © 2017 niyuj. All rights reserved.
//

#import "FeaturedVideoViewController.h"

#import "videoTableViewCell.h"
#import "HeaderVideoTableViewCell.h"
#import "AdvertiseTableViewCell.h"
#import "NewRequest.h"
#import "videoPlayerViewController.h"
#import "UIImageView+WebCache.h"

@interface FeaturedVideoViewController ()<NewRequestDelegate>{
    NSMutableArray *videosArray;
    BOOL isFromLocalNotification,isViewDidloadCall;
     NSString *lowerLimit,*upperLimit;
    BOOL stopPagination;
    
}
@property (weak, nonatomic) IBOutlet UITableView *videoTableView;

@end

@implementation FeaturedVideoViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    isFromLocalNotification = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveVideoNotification:)name:@"VideoNotification" object:nil];
    if (!isViewDidloadCall) {
        if(self.isHomePageLoaded){
            self.isHomePageLoaded = NO ;
            if (videosArray.count == 0) {
                [Utility showMessage:@"No videos available" withTitle:@""];
            }
        }
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBarTitleLabel:@"Videos"];
    lowerLimit = @"0";
    upperLimit = @"20";
    isFromLocalNotification = YES;
    isViewDidloadCall = YES;
    stopPagination = YES;
    videosArray = [[NSMutableArray alloc] initWithCapacity:0];
    [self.videoTableView registerNib:[UINib nibWithNibName:@"videoTableViewCell" bundle:nil] forCellReuseIdentifier:@"videoTableViewCell"];
    [self.videoTableView registerNib:[UINib nibWithNibName:@"HeaderVideoTableViewCell" bundle:nil] forCellReuseIdentifier:@"HeaderVideoTableViewCell"];
    [self.videoTableView registerNib:[UINib nibWithNibName:@"AdvertiseTableViewCell" bundle:nil] forCellReuseIdentifier:@"AdvertiseTableViewCell"];
    //[self startProgressHUD];
    [self getVideoUrlApiCall];
}

#pragma mark - NSNotification Center

- (void) receiveVideoNotification:(NSNotification *) notification{
    
    if ([notification.name isEqualToString:@"VideoNotification"]){
        
        NSDictionary* userInfo = notification.userInfo;
        NSNumber* total = (NSNumber*)userInfo[@"indexNumber"];
        if (total.intValue == 1){
            //NSLog(@"latest Stories");
            
            [self stopProgressHUD];
            if ([self checkReachability]) {
                
                //NSLog(@"IsfromLoginValue %d",isFromLocalNotification);
                if (isFromLocalNotification) {
                    [videosArray removeAllObjects];
                    [self getVideoUrlApiCall];
                }
                
            }
            else {
                [self stopProgressHUD];
                [self noInternetAlert];
                
            }
        }
    }
}


-(void)getVideoUrlApiCall{
    if ([self checkReachability]) {
        [self startProgressHUD];
//        if (!isViewDidloadCall) {
//            [[NSNotificationCenter defaultCenter]
//             postNotificationName:@"startVideoHUDWheelNotification"
//             object:self ];
//        }
        isFromLocalNotification = NO;
        NewRequest *req = [[NewRequest alloc] init];
        req.delegate = self;
         [req getVideoUrlsWithLowerLimit:lowerLimit withUpperLimit:upperLimit videoType:@"featured"];
    } else {
        [self noInternetAlert];
    }
}

-(void)VideoRequestSuccessfulWithResult:(NSArray *)result{
//    [self stopProgressHUD];
//    [[NSNotificationCenter defaultCenter]
//     postNotificationName:@"StopVideoHUDWheelNotification"
//     object:self ];
//    [MBProgressHUD hideHUDForView:self.view animated:YES];
    stopPagination = YES;
    isViewDidloadCall = NO;
    [videosArray addObjectsFromArray: [result mutableCopy]];
    [self.videoTableView reloadData];
    [self performSelectorOnMainThread:@selector(stopAnimationForActivityIndicator) withObject:nil waitUntilDone:NO];
}

-(void)videoRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    //    [self stopProgressHUD];
    //    [[NSNotificationCenter defaultCenter]
    //     postNotificationName:@"StopVideoHUDWheelNotification"
    //     object:self ];
    lowerLimit = @"0";
    upperLimit = @"20";
    stopPagination = NO;
    [self performSelectorOnMainThread:@selector(stopAnimationForActivityIndicator) withObject:nil waitUntilDone:NO];
    
    if (isViewDidloadCall) {
        //no need to show alert Data.
        isViewDidloadCall = NO;
        
    } else if (videosArray.count==0 && !stopPagination) {
        [Utility showMessage:@"No videos available" withTitle:@""];
    } else {
        [Utility showMessage:error withTitle:@""];
    }

    
}

-(void)stopAnimationForActivityIndicator
{
    [self stopProgressHUD];
}

#pragma mark - UITable view Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [videosArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *NewsHeadercellIdentifier = @"HeaderVideoTableViewCell";
    HeaderVideoTableViewCell *NewsHeadercell = (HeaderVideoTableViewCell*)[tableView dequeueReusableCellWithIdentifier:NewsHeadercellIdentifier];
    
    static NSString *NewscellIdentifier = @"videoTableViewCell";
    videoTableViewCell *Newscell = (videoTableViewCell*)[tableView dequeueReusableCellWithIdentifier:NewscellIdentifier];
    
    static NSString *ADVCellIdentifier = @"AdvertiseTableViewCell";
    AdvertiseTableViewCell *ADVCell = (AdvertiseTableViewCell*)[tableView dequeueReusableCellWithIdentifier:ADVCellIdentifier];
    
    Newscell.selectionStyle = UITableViewCellSelectionStyleNone;
    NewsHeadercell.selectionStyle = UITableViewCellSelectionStyleNone;
    ADVCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    @try {
        if (indexPath.row == 0) {
            
            NewsHeadercell.headeLabel.text = [[videosArray objectAtIndex:indexPath.row] objectForKey:@"event_title"];
            NewsHeadercell.headeLabel.font = [UIFont fontWithName:centuryGothicBold size:titleFont];
            [NewsHeadercell.headerVideoImageview sd_setImageWithURL:[NSURL URLWithString:[self getYoutubeVideoThumbnail:[[videosArray objectAtIndex:indexPath.row] objectForKey:@"event_code"]]]placeholderImage:[UIImage imageNamed:@"userimage.png"]];
            return NewsHeadercell;
        } else {
            
            Newscell.videoTitleLabel.text = [[videosArray objectAtIndex:indexPath.row] objectForKey:@"event_title"];
            Newscell.videoTitleLabel.font = [UIFont fontWithName:centuryGothicBold size:titleFont];
            Newscell.videoDateLabel.text = [[videosArray objectAtIndex:indexPath.row] objectForKey:@"my_timestamp"];
            [Newscell.videoThumbnailImageView sd_setImageWithURL:[NSURL URLWithString:[self getYoutubeVideoThumbnail:[[videosArray objectAtIndex:indexPath.row] objectForKey:@"event_code"]]]placeholderImage:[UIImage imageNamed:@"userimage.png"]];
            
            return Newscell;
            
        }

    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
}

//-(NSString*)getYoutubeVideoThumbnail:(NSString*)youTubeUrl
//{
//    NSString* video_id = @"";
//    
//    if (youTubeUrl.length > 0)
//    {
//        NSError *error = NULL;
//        NSRegularExpression *regex =
//        [NSRegularExpression regularExpressionWithPattern:@"(?<=watch\\?v=|/videos/|embed\\/)[^#\\&\\?]*"
//                                                  options:NSRegularExpressionCaseInsensitive
//                                                    error:&error];
//        NSTextCheckingResult *match = [regex firstMatchInString:youTubeUrl
//                                                        options:0
//                                                          range:NSMakeRange(0, [youTubeUrl length])];
//        if (match)
//        {
//            NSRange videoIDRange = [match rangeAtIndex:0];
//            video_id = [youTubeUrl substringWithRange:videoIDRange];
//            
//            //NSLog(@"%@",video_id);
//        }
//    }
//    
//    NSString* thumbImageUrl = [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/maxresdefault.jpg",video_id];
//    
//    return thumbImageUrl;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    videoPlayerViewController *vPlayer = [self.storyboard instantiateViewControllerWithIdentifier:@"videoPlayerViewController"];
    vPlayer.selectedIndex = indexPath.row;
    vPlayer.videoPlayerArray = videosArray;
    [self.navigationController pushViewController:vPlayer animated:YES];
    
    
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
            if (indexPath.row > [videosArray count] - 2) {
                
                lowerLimit = upperLimit;
                upperLimit = [NSString stringWithFormat:@"%d",([upperLimit integerValue] + 20)];
                isViewDidloadCall = NO;
                [self getVideoUrlApiCall];
                
            }
        }
    }
}


@end
