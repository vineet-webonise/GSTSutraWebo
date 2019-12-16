//
//  LocExpertViewController.m
//  GSTSutra
//
//  Created by niyuj on 2/13/17.
//  Copyright © 2017 niyuj. All rights reserved.
//

#import "LocExpertViewController.h"
#import "videoTableViewCell.h"
#import "HeaderVideoTableViewCell.h"
#import "AdvertiseTableViewCell.h"
#import "NewRequest.h"
#import "videoPlayerViewController.h"
#import "UIImageView+WebCache.h"

#import "NatureOfIssueRequest.h"
#import "ExpertTableViewCell.h"
#import "ExpertLongViewController.h"

@interface LocExpertViewController ()<NewRequestDelegate,NatureOfIssueRequestDelegate>{
    NSMutableArray *expertArray;
    BOOL isFromLocalNotification,isViewDidloadCall,stopPagination;
    NSString *lowerLimit,*upperLimit;
    
    BOOL noMoreItems;
    UIView *footerView;
    UIActivityIndicatorView *activityIndicator;
}
@property (weak, nonatomic) IBOutlet UITableView *ExpertTableView;

@end

@implementation LocExpertViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    isFromLocalNotification = YES;
    lowerLimit = @"0";
    upperLimit = @"20";
    stopPagination = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveVideoNotification:)name:@"VideoNotification" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBarTitleLabel:@"Videos"];
    lowerLimit = @"0";
    upperLimit = @"20";
    isFromLocalNotification = YES;
    isViewDidloadCall = YES;
    expertArray = [[NSMutableArray alloc] initWithCapacity:0];
    [self.ExpertTableView registerNib:[UINib nibWithNibName:@"ExpertTableViewCell" bundle:nil] forCellReuseIdentifier:@"ExpertTableViewCell"];
    //[self.ExpertTableView registerNib:[UINib nibWithNibName:@"NewsTableViewCell" bundle:nil] forCellReuseIdentifier:@"NewsTableViewCell"];
    
    [self.ExpertTableView registerNib:[UINib nibWithNibName:@"NewsHeaderTableViewCell" bundle:nil] forCellReuseIdentifier:@"NewsHeaderTableViewCell"];
    [self.ExpertTableView registerNib:[UINib nibWithNibName:@"AdvertiseTableViewCell" bundle:nil] forCellReuseIdentifier:@"AdvertiseTableViewCell"];
    [self startProgressHUD];
    [self getExpertApiCall];
}

#pragma mark - NSNotification Center

- (void) receiveVideoNotification:(NSNotification *) notification{
    
    if ([notification.name isEqualToString:@"VideoNotification"]){
        
        NSDictionary* userInfo = notification.userInfo;
        NSNumber* total = (NSNumber*)userInfo[@"indexNumber"];
        if (total.intValue == 0){
            //NSLog(@"latest Stories");
            
            [self stopProgressHUD];
            if ([self checkReachability]) {
                
                //NSLog(@"IsfromLoginValue %d",isFromLocalNotification);
                if (isFromLocalNotification) {
                    [expertArray removeAllObjects];
                    [self getExpertApiCall];
                }
                
            }
            else {
                [self stopProgressHUD];
                [self noInternetAlert];
                
            }
        }
    }
}



-(void)getExpertApiCall{
    NatureOfIssueRequest *req = [[NatureOfIssueRequest alloc]init];
    req.delegate = self;
    //NSLog(@"Selected location index in Latest Story %@",[USERDEFAULTS objectForKey:@"locationID"]);
    
    if ([[USERDEFAULTS objectForKey:@"locationID"] isEqualToString:@"0"] ||([[USERDEFAULTS objectForKey:@"locationID"] length] == 0)) {
        
        [req locationDataWithLowerLimit:lowerLimit withUpperLimit:upperLimit locationType:@"all" isFormsType:@"0" storyType:@"9"];
    } else {
        [req locationDataWithLowerLimit:lowerLimit withUpperLimit:upperLimit locationType:[USERDEFAULTS objectForKey:@"locationID"] isFormsType:@"0" storyType:@"9"];
    }
    
}

-(void)locationDataRequestSuccessfulWithResult:(NSArray *)result{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"StopVideoHUDWheelNotification"
     object:self ];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self stopProgressHUD];
    isViewDidloadCall = NO;
    expertArray = [result mutableCopy];
    [self.ExpertTableView reloadData];
}

-(void)locationDataRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
    lowerLimit = @"0";
    upperLimit = @"20";
    stopPagination = NO;
    if (isViewDidloadCall) {
        //no need to show alert Data.
        isViewDidloadCall = NO;
        
    } else {
        [Utility showMessage:error withTitle:@""];
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
    [Newscell.NewsImageView sd_setImageWithURL:[NSURL URLWithString:[newsImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]placeholderImage:[UIImage imageNamed:@"userimage.png"]];
    Newscell.NewsImageView.layer.cornerRadius=Newscell.NewsImageView.frame.size.width/2;
    Newscell.NewsImageView.layer.borderWidth = 1.0f;
    Newscell.NewsImageView.layer.masksToBounds = YES;
    Newscell.NewsTitleLabel.text = [[[[expertArray objectAtIndex:indexPath.row] objectForKey:@"headline"] stringByAppendingString:@"\n\n"] stringByAppendingString:[[expertArray objectAtIndex:indexPath.row] objectForKey:@"expert_name"]];
    Newscell.NewsDetailLabel.text = [[expertArray objectAtIndex:indexPath.row] objectForKey:@"expert_name"];
    Newscell.NewDateLabel.text = [[expertArray objectAtIndex:indexPath.row] objectForKey:@"date"];
    //[Newscell.bookmarkButton addTarget:self action:@selector(bookmarkButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    // Newscell.bookmarkButton.tag = indexPath.row;
    
    return Newscell;
    
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
    
    if (indexPath.row > 18) {
        if (indexPath.row >= [expertArray count]-2) {
            lowerLimit = upperLimit;
            upperLimit = [NSString stringWithFormat:@"%d",([upperLimit integerValue] + 20)];
            [self getExpertApiCall];
            
        }
    } else {
        
        //footerView.hidden = YES;
    }
    
    
}

@end
