//
//  LawsViewController.m
//  GSTSutra
//
//  Created by niyuj on 11/28/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import "LawsViewController.h"
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
#import "LawsLongViewController.h"
#import "ExpertCornerRequest.h"

@interface LawsViewController ()<ExpertRequestDelegate>{
    NSMutableArray *lawsArray;
    NSString *lowerLimit,*upperLimit;
     BOOL stopPagination;
}
@property (weak, nonatomic) IBOutlet UITableView *lawsTableview;

@end

@implementation LawsViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [Utility SetPanGestureOff];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.isFormsSelected) {
         [self setNavigationBarTitleLabel:@"GST Forms"];
    } else{
         [self setNavigationBarTitleLabel:@"GST Laws"];
    }
    
    [self stopProgressHUD];
    lawsArray = [[NSMutableArray alloc]init];
    lowerLimit = @"0";
    upperLimit = @"20";
    stopPagination = YES;
    [self.lawsTableview registerNib:[UINib nibWithNibName:@"NewsTableViewCell" bundle:nil] forCellReuseIdentifier:@"NewsTableViewCell"];
    [self.lawsTableview registerNib:[UINib nibWithNibName:@"NewsHeaderTableViewCell" bundle:nil] forCellReuseIdentifier:@"NewsHeaderTableViewCell"];
    [self.lawsTableview registerNib:[UINib nibWithNibName:@"AdvertiseTableViewCell" bundle:nil] forCellReuseIdentifier:@"AdvertiseTableViewCell"];
    [self getLAWSAPICall];
    
}



#pragma mark -
#pragma mark - Laws Delegate.
#pragma mark -

-(void)getLAWSAPICall{
    
    if ([self checkReachability]) {
        [self startProgressHUD];
        ExpertCornerRequest *req = [[ExpertCornerRequest alloc]init];
        req.delegate = self;
        if (self.isFormsSelected) {
            req.isForms = YES;
        } else {
            req.isForms = NO;
        }
        [req lawsWithLowerLimit:lowerLimit withUpperLimit:upperLimit];
        
    }
    else {
        [self stopProgressHUD];
        [self noInternetAlert];
    }
}


-(void)getLawsRequestSuccessfulWithResult:(NSArray *)result{
   
    [self stopProgressHUD];
    
    [lawsArray addObjectsFromArray:result];
    [self.lawsTableview reloadData];
    [self performSelectorOnMainThread:@selector(stopAnimationForActivityIndicator) withObject:nil waitUntilDone:NO];
    
}

-(void)getLawsRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
    stopPagination = NO;
    //[self.lawsTableview reloadData];
    lowerLimit = @"0";
    upperLimit = @"20";
    [self performSelectorOnMainThread:@selector(stopAnimationForActivityIndicator) withObject:nil waitUntilDone:NO];
    
    if (lawsArray.count == 0) {
        if (self.isFormsSelected) {
        [Utility showMessage:@"No GST forms available" withTitle:@""];
        } else {
            [Utility showMessage:@"No GST laws available" withTitle:@""];
        }
    } else{
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
    
    static NSString *ADVCellIdentifier = @"AdvertiseTableViewCell";
    AdvertiseTableViewCell *ADVCell = (AdvertiseTableViewCell*)[tableView dequeueReusableCellWithIdentifier:ADVCellIdentifier];
    
    
    Newscell.selectionStyle = UITableViewCellStyleDefault;
    ADVCell.selectionStyle = UITableViewCellSelectionStyleNone;
    

    @try {
        Newscell.NewsImageView.hidden=true;
        Newscell.NewsTitleLabel.hidden=true;
        Newscell.NewsDetailLabel.hidden=true;
        Newscell.NewDateLabel.hidden=true;
        
        
        Newscell.textLabel.text = [[lawsArray objectAtIndex:indexPath.row] objectForKey:@"title"];
        Newscell.textLabel.font = [UIFont fontWithName:centuryGothicBold size:titleFont];
        Newscell.textLabel.numberOfLines = 0;
        Newscell.textLabel.textAlignment = NSTextAlignmentLeft;
        
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
    lawLongView.longViewLawsArray = [lawsArray mutableCopy];
    lawLongView.isFormsSelected = _isFormsSelected;
    [self.navigationController pushViewController:lawLongView animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        //return 143;
    return 60;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (stopPagination) {
        if (indexPath.row > 15) {
            if (indexPath.row > [lawsArray count]-2) {
                lowerLimit = upperLimit;
                upperLimit = [NSString stringWithFormat:@"%ld",([upperLimit integerValue] + 20)];
                [self getLAWSAPICall];
            }

        }
        
            }
}


@end
