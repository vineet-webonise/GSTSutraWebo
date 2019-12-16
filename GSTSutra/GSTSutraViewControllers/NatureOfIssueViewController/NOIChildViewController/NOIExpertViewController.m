//
//  NOIExpertViewController.m
//  GSTSutra
//
//  Created by niyuj on 2/10/17.
//  Copyright © 2017 niyuj. All rights reserved.
//

#import "NOIExpertViewController.h"
#import "videoTableViewCell.h"
#import "HeaderVideoTableViewCell.h"
#import "AdvertiseTableViewCell.h"
#import "NewRequest.h"
#import "videoPlayerViewController.h"
#import "UIImageView+WebCache.h"
#import "NatureOfIssueRequest.h"
#import "ExpertTableViewCell.h"
#import "ExpertLongViewController.h"

@interface NOIExpertViewController ()<NewRequestDelegate,NatureOfIssueRequestDelegate>{
    NSMutableArray *expertArray;
    BOOL isFromLocalNotification,isViewDidloadCall,stopPagination;
    NSString *lowerLimit,*upperLimit;
    
    BOOL noMoreItems;
    UIView *footerView;
    UIActivityIndicatorView *activityIndicator;
}
@property (weak, nonatomic) IBOutlet UITableView *expertTableView;

@end

@implementation NOIExpertViewController

-(void)viewWillAppear:(BOOL)animated{

    @try {
        [super viewWillAppear:animated];
        isFromLocalNotification = YES;
        lowerLimit = @"0";
        upperLimit = @"20";
        stopPagination = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveVideoNotification:)name:@"VideoNotification" object:nil];
        if (!isViewDidloadCall) {
            if(self.isHomePageLoaded){
                self.isHomePageLoaded = NO ;
                if (expertArray.count == 0) {
                    [Utility showMessage:@"No expert columns available" withTitle:@""];
                }
            }
        }

    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    @try {
        [self setNavigationBarTitleLabel:@"Videos"];
        lowerLimit = @"0";
        upperLimit = @"20";
        isFromLocalNotification = YES;
        isViewDidloadCall = YES;
        expertArray = [[NSMutableArray alloc] initWithCapacity:0];
        [self.expertTableView registerNib:[UINib nibWithNibName:@"ExpertTableViewCell" bundle:nil] forCellReuseIdentifier:@"ExpertTableViewCell"];
        //[self.expertTableView registerNib:[UINib nibWithNibName:@"NewsTableViewCell" bundle:nil] forCellReuseIdentifier:@"NewsTableViewCell"];
        
        [self.expertTableView registerNib:[UINib nibWithNibName:@"NewsHeaderTableViewCell" bundle:nil] forCellReuseIdentifier:@"NewsHeaderTableViewCell"];
        [self.expertTableView registerNib:[UINib nibWithNibName:@"AdvertiseTableViewCell" bundle:nil] forCellReuseIdentifier:@"AdvertiseTableViewCell"];
        // [self startProgressHUD];
        [self getFilterExpertsApiCall];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

#pragma mark - NSNotification Center

- (void) receiveVideoNotification:(NSNotification *) notification{
    
    if ([notification.name isEqualToString:@"VideoNotification"]){
        
        NSDictionary* userInfo = notification.userInfo;
        NSNumber* total = (NSNumber*)userInfo[@"indexNumber"];
        if (total.intValue == 1){
            //NSLog(@"NOI Experts");
            
            [self stopProgressHUD];
            if ([self checkReachability]) {
                
                //NSLog(@"IsfromLoginValue %d",isFromLocalNotification);
                if (isFromLocalNotification) {
                    [expertArray removeAllObjects];
                    [self getFilterExpertsApiCall];
                }
                
            }
            else {
                [self stopProgressHUD];
                [self noInternetAlert];
                
            }
        }
    }
}



-(void)getFilterExpertsApiCall{
    
    @try {
        if ([self checkReachability]) {
            [self startProgressHUD];
            //        if (!isViewDidloadCall) {
            //            [[NSNotificationCenter defaultCenter]
            //             postNotificationName:@"startVideoHUDWheelNotification"
            //             object:self ];
            //        }
            isFromLocalNotification = NO;
            NatureOfIssueRequest *req = [[NatureOfIssueRequest alloc] init];
            req.delegate = self;
            NSArray *temp = [USERDEFAULTS objectForKey:@"NOIID"];
            if ([USERDEFAULTS objectForKey:@"inDustriesID"] != nil && [USERDEFAULTS objectForKey:@"NOIID"] != nil && [temp count]!=0) {
                //NSArray *temp = [USERDEFAULTS objectForKey:@"NOIID"];
                NSString *joinedComponents = [temp componentsJoinedByString:@","];
                [req filterWithLowerLimit:lowerLimit withUpperLimit:upperLimit IndustryType:[USERDEFAULTS objectForKey:@"inDustriesID"] issueType:joinedComponents storyType:@"9"];
            } else if ([USERDEFAULTS objectForKey:@"inDustriesID"] != nil){
                [req filterWithLowerLimit:lowerLimit withUpperLimit:upperLimit IndustryType:[USERDEFAULTS objectForKey:@"inDustriesID"] issueType:@"all" storyType:@"9"];
            }else if ([USERDEFAULTS objectForKey:@"NOIID"] != nil) {
                NSString *joinedComponents = [temp componentsJoinedByString:@","];
                [req filterWithLowerLimit:lowerLimit withUpperLimit:upperLimit IndustryType:@"all" issueType:joinedComponents storyType:@"9"];
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
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"StopVideoHUDWheelNotification"
         object:self ];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self stopProgressHUD];
        isViewDidloadCall = NO;
         [expertArray addObjectsFromArray:[result mutableCopy]];
        
        [self.expertTableView reloadData];
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
        if (isViewDidloadCall) {
            //no need to show alert Data.
            isViewDidloadCall = NO;
            
        } else if (expertArray.count==0 && !stopPagination) {
            [Utility showMessage:@"No expert columns available" withTitle:@""];
        } else {
            [Utility showMessage:error withTitle:@""];
        }

    } @catch (NSException *exception) {
        
    } @finally {
        
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
    @try {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        ExpertLongViewController *shortView = [self.storyboard instantiateViewControllerWithIdentifier:@"ExpertLongViewController"];
        shortView.selectedIndex =  indexPath.row ;
        shortView.expertLongViewNewsArray = [expertArray mutableCopy];
        [self.navigationController pushViewController:shortView animated:YES];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 126;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    //NSLog(@"indexpath %ld",(long)indexPath.row);
    
    
    @try {
        if (stopPagination) {
            if (indexPath.row > 18) {
                if (indexPath.row > [expertArray count]-2) {
                    lowerLimit = upperLimit;
                    upperLimit = [NSString stringWithFormat:@"%d",([upperLimit integerValue] + 20)];
                    [self getFilterExpertsApiCall];
                    
                }
            }
        }

    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
}
@end
