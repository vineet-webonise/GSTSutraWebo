//
//  ExpertTakeViewController.m
//  GSTSutra
//
//  Created by niyuj on 11/24/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import "ExpertTakeViewController.h"
#import "ExpertTakeLngViewController.h"
#import "ExpertCornerRequest.h"


@interface ExpertTakeViewController ()<ExpertRequestDelegate>{
    NSMutableArray *expertTakeArray;
    NSString *lowerLimit,*upperLimit;
    NSArray *expertOfflineArray;
    
    BOOL stopPagination;
}
@property (weak, nonatomic) IBOutlet UITableView *expertTakeTableView;

@end

@implementation ExpertTakeViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [Utility SetPanGestureOff];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self stopProgressHUD];
    [self setNavigationBarTitleLabel:@"Tax Ring"];
    self.expertTakeTableView.rowHeight = UITableViewAutomaticDimension;
    self.expertTakeTableView.estimatedRowHeight = 90.0;
    expertTakeArray = [[NSMutableArray alloc]init];
    expertOfflineArray = [[NSMutableArray alloc]init];
    lowerLimit = @"0";
    upperLimit = @"20";
    stopPagination = YES;
    if ([self checkReachability]) {
        [self expertTakeAPICall];
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
    [appD.database executeUpdate:@"DROP TABLE IF EXISTS `expertTakeTable`;"];
    [appD.database executeUpdate:@"create table IF NOT EXISTS expertTakeTable(news blob primary key)"];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:expertTakeArray];
    [appD.database executeUpdate:@"insert into expertTakeTable values (?)",data];
    FMResultSet *results = [appD.database executeQuery:@"select * from expertTakeTable"];
    while([results next]) {
        expertOfflineArray = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:@"news"]];
        //NSLog(@"Experts Array from DB : %@ ",expertOfflineArray);
    }
    [appD.database close];
}

-(void)setDataBaseDataToTable{
    [appD.database open];
    FMResultSet *results = [appD.database executeQuery:@"select * from expertTakeTable"];
    while([results next]) {
        expertOfflineArray = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:@"news"]];
        //NSLog(@"Experts Array from DB : %@ ",expertOfflineArray);
    }
    [expertTakeArray removeAllObjects];
    [expertTakeArray addObjectsFromArray:expertOfflineArray];
    [self.expertTakeTableView reloadData];
    [appD.database close];
    
}


-(void)expertTakeAPICall{
    
    if ([self checkReachability]) {
        [self startProgressHUD];
        ExpertCornerRequest *req = [[ExpertCornerRequest alloc] init];
        req.delegate = self;
        [req expertTakeWithLowerLimit:lowerLimit withUpperLimit:upperLimit];
    } else {
        [self noInternetAlert];
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [expertTakeArray count];
   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *NewscellIdentifier = @"ExpertTakeTableviewCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NewscellIdentifier];
   
    @try {
        
        // Configure Cell
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:1];
        label.text = [[expertTakeArray objectAtIndex:indexPath.row] objectForKey:@"title"];
        label.font = [UIFont fontWithName:centuryGothicBold size:titleFont];
        
        //return Newscell;
        return cell;
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ExpertTakeLngViewController *expertTalk = [self.storyboard instantiateViewControllerWithIdentifier:@"ExpertTakeLngViewController"];
    expertTalk.selectedIndex = indexPath.row;
    expertTalk.expertTakeArray = [expertTakeArray mutableCopy];
    [self.navigationController pushViewController:expertTalk animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *str = [[expertTakeArray objectAtIndex:indexPath.row] objectForKey:@"title"];
    
    CGRect textRect = [str boundingRectWithSize:CGSizeMake(SCREENWIDTH, 999)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:[UIFont fontWithName:centuryGothicBold size:14]}
                                        context:nil];
    
    CGSize size = textRect.size;
    
    return size.height + 20;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (stopPagination) {
        
        if(indexPath.row > 18)
            if (indexPath.row >  [expertTakeArray count]- 2) {
                lowerLimit = upperLimit;
                upperLimit = [NSString stringWithFormat:@"%ld",([upperLimit integerValue] + 20)];
                [self expertTakeAPICall];
                
            }
    }
}

#pragma mark -
#pragma mark - expert Take Delegate.
#pragma mark -

-(void)expertTakeRequestSuccessfulWithResult:(NSArray *)result{
    //NSLog(@"Expert Take API Data %@",result);
    
    stopPagination = YES;
    [expertTakeArray addObjectsFromArray:result];
    [self storeDataIntoDataBase];
    [self.expertTakeTableView reloadData];
    
    [self performSelectorOnMainThread:@selector(stopAnimationForActivityIndicator) withObject:nil waitUntilDone:NO];
    
}

-(void)expertTakeRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    stopPagination = NO;
    [self.expertTakeTableView reloadData];
    lowerLimit = @"0";
    upperLimit = @"20";
    
    
    [self performSelectorOnMainThread:@selector(stopAnimationForActivityIndicator) withObject:nil waitUntilDone:NO];
    
    if (expertTakeArray.count == 0) {
        [Utility showMessage:@"No tax ring available" withTitle:@""];
    }else{
        [Utility showMessage:error withTitle:@""];
    }
}

-(void)stopAnimationForActivityIndicator
{
    [self stopProgressHUD];
}


@end
