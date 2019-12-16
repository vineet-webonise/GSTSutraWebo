//
//  SiteLinksViewController.m
//  GSTSutra
//
//  Created by niyuj on 12/30/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import "SiteLinksViewController.h"
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
#import "NewRequest.h"

@interface SiteLinksViewController ()<ExpertRequestDelegate,NewRequestDelegate>{
    NSMutableArray *shareLinksArray;
     NSMutableArray  *arrayForBool,*sectionTitleArray,*sectionTitleOfflineArray;
    NSString *lowerLimit,*upperLimit;
    BOOL stopPagination,isViewDidload;
}

@property (weak, nonatomic) IBOutlet UITableView *expandableTableView;

@end

@implementation SiteLinksViewController

// Notification

-(void)notificationAPICall{
    [self stopProgressHUD];
    if ([self checkReachability]) {
        [self startProgressHUD];
        appD.isFromNotification = NO ;
        NewRequest *req = [[NewRequest alloc] init];
        req.delegate=self;
        [req getNotificationNewsWithStoryId:@"0" withStoryType:@"22"];
    }
    else {
        [self stopProgressHUD];
        [self noInternetAlert];
    }
    
}

-(void)newsNotificationRequestSuccessfulWithResult:(NSArray *)result{
    [self stopProgressHUD];
    [self stopProgressHUD];
    [sectionTitleArray addObjectsFromArray:result];
    for (int i = 0; i< [sectionTitleArray count]; i++) {
        if (i==0) {
            [arrayForBool addObject:[NSNumber numberWithBool:YES]]; 
        } else{
            [arrayForBool addObject:[NSNumber numberWithBool:NO]];
        }
    }
    [self.expandableTableView reloadData];
}
-(void)newsNotificationRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBarTitleLabel:@"GST in Press"];
    [self stopProgressHUD];
    
    isViewDidload = YES ;
    
//    self.navigationItem.rightBarButtonItem.enabled=NO;
//    self.navigationItem.rightBarButtonItem=nil;
    
    shareLinksArray = [[NSMutableArray alloc]init];
    arrayForBool=[[NSMutableArray alloc]init];
    sectionTitleArray=[[NSMutableArray alloc]init];
    sectionTitleOfflineArray = [[NSMutableArray alloc]init];
    stopPagination = YES;
    lowerLimit = @"0";
    upperLimit = @"20";
    
    if ([USERDEFAULTS boolForKey:@"isNotRegisterOrLoginUser"]) {
        [self openLoginViewControllerAlertOnLeftMenuOrView:NO];
    }else {
        
        if (appD.isFromNotification) {
            [self notificationAPICall];
            
        } else {
            [self siteLinkesAPICall];
        }
    }
    
    
}


-(void)siteLinkesAPICall{
    if ([self checkReachability]) {
        [self startProgressHUD];
        ExpertCornerRequest *req = [[ExpertCornerRequest alloc]init];
        req.delegate = self;
        [req shareLinksWithLowerLimit:lowerLimit withUpperLimit:upperLimit];
        
    }
    else {
        [self stopProgressHUD];
        [self setDataBaseDataToTable];
        if (isViewDidload) {
            [self noInternetAlert];
            
        }
        isViewDidload = NO;
        
    }
}
#pragma mark -
#pragma mark - News Delegate.
#pragma mark -

-(void)getshareLinksRequestSuccessfulWithResult:(NSArray *)result{
    
    
        [sectionTitleArray addObjectsFromArray:result];
        [self storeDataIntoDataBase];
        [self setDataToTableview];
    
    [self performSelectorOnMainThread:@selector(stopAnimationForActivityIndicator) withObject:nil waitUntilDone:NO];
}

-(void)setDataToTableview{
    for (int i = 0; i< [sectionTitleArray count]; i++) {
        if (i==0) {
            if (isViewDidload) {
                [arrayForBool addObject:[NSNumber numberWithBool:YES]];
                isViewDidload = NO;
            }
            
        } else{
            [arrayForBool addObject:[NSNumber numberWithBool:NO]];
        }
    }
    [self.expandableTableView reloadData];
}
-(void)getshareLinksRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    //[self stopProgressHUD];
    stopPagination = NO;
    [self.expandableTableView reloadData];
    lowerLimit = @"0";
    upperLimit = @"20";
    //[Utility showMessage:error withTitle:@""];
    [self performSelectorOnMainThread:@selector(stopAnimationForActivityIndicator) withObject:nil waitUntilDone:NO];
    
    if (sectionTitleArray.count == 0) {
        [Utility showMessage:@"No press news available" withTitle:@""];
    }else{
        [Utility showMessage:error withTitle:@""];
    }
}

-(void)stopAnimationForActivityIndicator
{
    [self stopProgressHUD];
}


#pragma  mark - Sqlite Database

-(void)storeDataIntoDataBase{
    [appD.database open];
    [appD.database executeUpdate:@"DROP TABLE IF EXISTS `siteLinksTable`;"];
    [appD.database executeUpdate:@"create table IF NOT EXISTS siteLinksTable(news blob primary key)"];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:sectionTitleArray];
    [appD.database executeUpdate:@"insert into siteLinksTable values (?)",data];
    FMResultSet *results = [appD.database executeQuery:@"select * from siteLinksTable"];
    while([results next]) {
        sectionTitleOfflineArray = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:@"news"]];
        //NSLog(@"Experts Array from DB : %@ ",expertOfflineArray);
    }
    [appD.database close];
}

-(void)setDataBaseDataToTable{
    [appD.database open];
    FMResultSet *results = [appD.database executeQuery:@"select * from siteLinksTable"];
    while([results next]) {
        sectionTitleOfflineArray = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:@"news"]];
        //NSLog(@"Experts Array from DB : %@ ",expertOfflineArray);
    }
    [sectionTitleArray removeAllObjects];
    [sectionTitleArray addObjectsFromArray:sectionTitleOfflineArray];
    [self setDataToTableview];
    //[self.expandableTableView reloadData];
    [appD.database close];
    
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [sectionTitleArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    @try {
        if ([[arrayForBool objectAtIndex:section] boolValue]) {
            if ([[[sectionTitleArray objectAtIndex:section] objectForKey:@"sitelinks_data"] count]>0) {
                return  [[[sectionTitleArray objectAtIndex:section] objectForKey:@"sitelinks_data"] count];
            } else {
                return 0;
            }
        }
        else
            return 0;
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    static NSString *cellid=@"FAQRowCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
    }
    
    @try {
        UILabel *ansDisLabel = (UILabel*)[cell viewWithTag:4];
        
        BOOL manyCells  = [[arrayForBool objectAtIndex:indexPath.section] boolValue];
        
        /********** If the section supposed to be closed *******************/
        if(!manyCells){
            cell.backgroundColor=[UIColor clearColor];
            
            ansDisLabel.text=@"";
        }
        /********** If the section supposed to be Opened *******************/
        else{
            
            
            NSString *temp = [[[[sectionTitleArray objectAtIndex:indexPath.section] objectForKey:@"sitelinks_data"] objectAtIndex:indexPath.row] objectForKey:@"title"];
            NSAttributedString *tempAtributedString =  [[NSAttributedString alloc] initWithData:[temp dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]} documentAttributes:nil error:nil];
            
            ansDisLabel.attributedText = tempAtributedString; //[tempAtributedString string];
            ansDisLabel.font=[UIFont fontWithName:centuryGothicRegular size:normalFont];
            
            cell.backgroundColor=[UIColor whiteColor];
            cell.selectionStyle=UITableViewCellSelectionStyleNone ;
            
        }
        cell.textLabel.textColor=[UIColor blackColor];
        
        return cell;
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

-(NSMutableAttributedString*)buttonsWithUnderLineTitleString:(NSString*)buttonTitle{
    
    NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:buttonTitle];
    [titleString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [titleString length])];
    return titleString;
    
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    
    @try {
        
        if (stopPagination) {
            
            if (section > 18) {
                if (section > [sectionTitleArray count] -2) {
                    lowerLimit = upperLimit;
                    upperLimit = [NSString stringWithFormat:@"%ld",([upperLimit integerValue] + 20)];
                    [self siteLinkesAPICall];
                }
            }
        }
        
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    @try {
        NSURL *url = [NSURL URLWithString:[[[[sectionTitleArray objectAtIndex:indexPath.section] objectForKey:@"sitelinks_data"] objectAtIndex:indexPath.row] objectForKey:@"link"]];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        } else{
            [Utility showMessage:@"Invalid Url" withTitle:@"Error!"];
        }

    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([[arrayForBool objectAtIndex:indexPath.section] boolValue]) {
        return UITableViewAutomaticDimension;
    }
    return 0;
    
}


#pragma mark - Creating View for TableView Section

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *cellid=@"FAQHeaderCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
    }
    
   
    UILabel *queDisLabel = (UILabel*)[cell viewWithTag:2];
    UILabel *DateLabel = (UILabel*)[cell viewWithTag:20];
    queDisLabel.text = [[sectionTitleArray objectAtIndex:section] objectForKey:@"groupname"];
    queDisLabel.font = [UIFont fontWithName:centuryGothicBold size:titleFont];
    DateLabel.text = [[sectionTitleArray objectAtIndex:section] objectForKey:@"date"];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    queDisLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    //return sectionHeaderCell.contentView;
    
    cell.contentView.tag = section;
    
    /********** Add a custom Separator with Section view *******************/
    UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _expandableTableView.frame.size.width, 1)];
    separatorLineView.backgroundColor = [UIColor blackColor];
    [cell.contentView addSubview:separatorLineView];
    
    /********** Add UITapGestureRecognizer to SectionView   **************/
    
    UITapGestureRecognizer  *headerTapped   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionHeaderTapped:)];
    [cell.contentView addGestureRecognizer:headerTapped];
    
    return  cell.contentView;
}

#pragma mark - Table header gesture tapped

- (void)sectionHeaderTapped:(UITapGestureRecognizer *)gestureRecognizer{
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:gestureRecognizer.view.tag];
    if (indexPath.row == 0) {
        BOOL collapsed  = [[arrayForBool objectAtIndex:indexPath.section] boolValue];
        for (int i=1; i<[sectionTitleArray count]; i++) {
            if (indexPath.section==i) {
                [arrayForBool replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:!collapsed]];
            }
        }
        //[_expandableTableView reloadSections:[NSIndexSet indexSetWithIndex:gestureRecognizer.view.tag] withRowAnimation:UITableViewRowAnimationNone];
        [_expandableTableView reloadData];
    }
}



-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //minimum size of your cell, it should be single line of label if you are not clear min. then return UITableViewAutomaticDimension;
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    NSString *str = [[sectionTitleArray objectAtIndex:section] objectForKey:@"groupname"];
    
    CGRect textRect = [str boundingRectWithSize:CGSizeMake(SCREENWIDTH, 999)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:[UIFont fontWithName:centuryGothicBold size:titleFont]}
                                        context:nil];
    
    CGSize size = textRect.size;
    
    return size.height + 50;

}


@end
