//
//  LocFormsViewController.m
//  GSTSutra
//
//  Created by niyuj on 2/13/17.
//  Copyright © 2017 niyuj. All rights reserved.
//

#import "LocFormsViewController.h"
#import "NewsHeaderTableViewCell.h"
#import "NewsTableViewCell.h"
#import "AdvertiseTableViewCell.h"
#import "ShortNewsViewController.h"
#import "NewRequest.h"
#import "videoPlayerViewController.h"
#import "UIImageView+WebCache.h"
#import "ShortNewsViewController.h"
#import "LawsLongViewController.h"
#import "NatureOfIssueRequest.h"

@interface LocFormsViewController ()<NewRequestDelegate,NatureOfIssueRequestDelegate>{
    NSMutableArray *lawsArray;
    BOOL isFromLocalNotification,isViewDidloadCall,stopPagination;
    NSString *lowerLimit,*upperLimit;
    
}
@property (weak, nonatomic) IBOutlet UITableView *formTableView;

@end

@implementation LocFormsViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    isFromLocalNotification = YES;
    lowerLimit = @"0";
    upperLimit = @"20";
    stopPagination = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveVideoNotification:)name:@"VideoNotification" object:nil];
    if (!isViewDidloadCall) {
        if(self.isHomePageLoaded){
            self.isHomePageLoaded = NO ;
            if (lawsArray.count == 0) {
                [Utility showMessage:@"No GST Forms available" withTitle:@""];
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
    lawsArray = [[NSMutableArray alloc] initWithCapacity:0];
    [self.formTableView registerNib:[UINib nibWithNibName:@"NewsTableViewCell" bundle:nil] forCellReuseIdentifier:@"NewsTableViewCell"];
    [self.formTableView registerNib:[UINib nibWithNibName:@"NewsHeaderTableViewCell" bundle:nil] forCellReuseIdentifier:@"NewsHeaderTableViewCell"];
    [self.formTableView registerNib:[UINib nibWithNibName:@"AdvertiseTableViewCell" bundle:nil] forCellReuseIdentifier:@"AdvertiseTableViewCell"];
//    [self startProgressHUD];
    [self getFormsApiCall];
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
                    [lawsArray removeAllObjects];
                    [self getFormsApiCall];
                }
                
            }
            else {
                [self stopProgressHUD];
                [self noInternetAlert];
                
            }
        }
    }
}



-(void)getFormsApiCall{
    
    if ([self checkReachability]) {
        
        [self startProgressHUD];
        
        //    if (!isViewDidloadCall) {
        //        [[NSNotificationCenter defaultCenter]
        //         postNotificationName:@"startVideoHUDWheelNotification"
        //         object:self ];
        //    }
        //    [[NSNotificationCenter defaultCenter]
        //     postNotificationName:@"startVideoHUDWheelNotification"
        //     object:self ];
        
        isFromLocalNotification = NO;
        NatureOfIssueRequest *req = [[NatureOfIssueRequest alloc]init];
        req.delegate = self;
        //NSLog(@"Selected location index in Latest Story %@",[USERDEFAULTS objectForKey:@"locationID"]);
        
        if ([[USERDEFAULTS objectForKey:@"locationID"] isEqualToString:@"0"] ||([[USERDEFAULTS objectForKey:@"locationID"] length] == 0)) {
            
            [req locationDataWithLowerLimit:lowerLimit withUpperLimit:upperLimit locationType:@"all" isFormsType:@"1" storyType:@"10"];
        } else {
            [req locationDataWithLowerLimit:lowerLimit withUpperLimit:upperLimit locationType:[USERDEFAULTS objectForKey:@"locationID"] isFormsType:@"1" storyType:@"10"];
        }

        
    } else {
        [self noInternetAlert];
    }
}

-(void)locationDataRequestSuccessfulWithResult:(NSArray *)result{
    
//    [[NSNotificationCenter defaultCenter]
//     postNotificationName:@"StopVideoHUDWheelNotification"
//     object:self ];
//    [MBProgressHUD hideHUDForView:self.view animated:YES];
//    [self stopProgressHUD];
    isViewDidloadCall = NO;
    [ lawsArray addObjectsFromArray:[result mutableCopy]];
    [self.formTableView reloadData];
    
    [self performSelectorOnMainThread:@selector(stopAnimationForActivityIndicator) withObject:nil waitUntilDone:NO];
}

-(void)locationDataRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"StopVideoHUDWheelNotification"
     object:self ];
    lowerLimit = @"0";
    upperLimit = @"20";
    stopPagination = NO;
    
    
    [self performSelectorOnMainThread:@selector(stopAnimationForActivityIndicator) withObject:nil waitUntilDone:NO];
    
    if (isViewDidloadCall) {
        //no need to show alert Data.
        isViewDidloadCall = NO;
        
    } else if (lawsArray.count==0 && !stopPagination) {
        [Utility showMessage:@"No GST forms available" withTitle:@""];
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
    
    return [lawsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *NewscellIdentifier = @"NewsTableViewCell";
    NewsTableViewCell *Newscell = (NewsTableViewCell*)[tableView dequeueReusableCellWithIdentifier:NewscellIdentifier];
    
    @try {
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
        Newscell.textLabel.font = [UIFont fontWithName:centuryGothicBold size:titleFont];
        
        return Newscell;
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LawsLongViewController *lawLongView = [self.storyboard instantiateViewControllerWithIdentifier:@"LawsLongViewController"];
    lawLongView.selectedIndex =  indexPath.row ;
    lawLongView.isFormsSelected = YES;
    lawLongView.longViewLawsArray = [lawsArray mutableCopy];
    [self.navigationController pushViewController:lawLongView animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //return 143;
    return 60;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
            if (stopPagination) {
                
                if (indexPath.row > 18) {
                    if ([self checkReachability]) {
                        if (indexPath.row >= [lawsArray count]-2) {
                            lowerLimit = upperLimit;
                            upperLimit = [NSString stringWithFormat:@"%ld",([upperLimit integerValue] + 20)];
                            [self getFormsApiCall];
                        }
                    }else {
                        [self noInternetAlert];
                    }
                }
            }
    
}



@end
