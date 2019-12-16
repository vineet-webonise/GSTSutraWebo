//
//  ForumListViewController.m
//  GSTSutra
//
//  Created by niyuj on 1/24/17.
//  Copyright © 2017 niyuj. All rights reserved.
//

#import "ForumListViewController.h"
#import "ExpertTakeLngViewController.h"
#import "ExpertCornerRequest.h"
#import "ForumDetailViewController.h"

@interface ForumListViewController ()<ExpertRequestDelegate>{
    NSMutableArray *forumArray;
    NSString *lowerLimit,*upperLimit;
    NSArray *forumOfflineArray;
    BOOL stopPagination;
}
@property (weak, nonatomic) IBOutlet UITableView *forumDiscusionTableView;

@end

@implementation ForumListViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [Utility SetPanGestureOff];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self stopProgressHUD];
    [self setNavigationBarTitleLabel:@"Discussion Forum"];
     stopPagination = YES;
    
//    self.navigationItem.rightBarButtonItem.enabled=NO;
//    self.navigationItem.rightBarButtonItem=nil;
    
    self.forumDiscusionTableView.rowHeight = UITableViewAutomaticDimension;
    self.forumDiscusionTableView.estimatedRowHeight = 90.0;
    forumArray = [[NSMutableArray alloc]init];
    forumOfflineArray = [[NSMutableArray alloc]init];
    lowerLimit = @"0";
    upperLimit = @"20";
    if ([self checkReachability]) {
        //[self startProgressHUD];
        [self ForumDiscussionAPICall];
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
    [appD.database executeUpdate:@"DROP TABLE IF EXISTS `forumDiscusionTable`;"];
    [appD.database executeUpdate:@"create table IF NOT EXISTS forumDiscusionTable(news blob primary key)"];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:forumArray];
    [appD.database executeUpdate:@"insert into forumDiscusionTable values (?)",data];
    FMResultSet *results = [appD.database executeQuery:@"select * from forumDiscusionTable"];
    while([results next]) {
        forumOfflineArray = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:@"news"]];
        //NSLog(@"Experts Array from DB : %@ ",forumOfflineArray);
    }
    [appD.database close];
}

-(void)setDataBaseDataToTable{
    [appD.database open];
    FMResultSet *results = [appD.database executeQuery:@"select * from forumDiscusionTable"];
    while([results next]) {
        forumOfflineArray = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:@"news"]];
        //NSLog(@"Experts Array from DB : %@ ",forumOfflineArray);
    }
    [forumArray removeAllObjects];
    [forumArray addObjectsFromArray:forumOfflineArray];
    [self.forumDiscusionTableView reloadData];
    [appD.database close];
    
}


-(void)ForumDiscussionAPICall{
    [self startProgressHUD];
    ExpertCornerRequest *req = [[ExpertCornerRequest alloc] init];
    req.delegate = self;
    [req forumListWithLowerLimit:lowerLimit withUpperLimit:upperLimit];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [forumArray count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *NewscellIdentifier = @"ExpertTakeTableviewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NewscellIdentifier];
    
    // Configure Cell
    @try {
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:1];
        label.text = [[forumArray objectAtIndex:indexPath.row] objectForKey:@"title"];
        label.font = [UIFont fontWithName:centuryGothicBold size:titleFont];
        return cell;
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ForumDetailViewController *forum = [self.storyboard instantiateViewControllerWithIdentifier:@"ForumDetailViewController"];
    forum.selectedForumID = [[forumArray objectAtIndex:indexPath.row] objectForKey:@"nid"];
    forum.selectedForumTitle = [[forumArray objectAtIndex:indexPath.row] objectForKey:@"title"];
    [self.navigationController pushViewController:forum animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 90;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (stopPagination) {
        if (indexPath.row > 18) {
            if (indexPath.row > [forumArray count]-2) {
                lowerLimit = upperLimit;
                upperLimit = [NSString stringWithFormat:@"%d",([upperLimit integerValue] + 20)];
                [self ForumDiscussionAPICall];
                
            }
        }
    }
    
}

#pragma mark -
#pragma mark - expert Take Delegate.
#pragma mark -

-(void)getForumListRequestSuccessfulWithResult:(NSArray *)result{
    [self stopProgressHUD];
    stopPagination = YES;
    [forumArray addObjectsFromArray:result];
    [self storeDataIntoDataBase];
    [self.forumDiscusionTableView reloadData];
    [self performSelectorOnMainThread:@selector(stopAnimationForActivityIndicator) withObject:nil waitUntilDone:NO];
    
}

-(void)getForumListRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
    stopPagination = NO;
    [self.forumDiscusionTableView reloadData];
    lowerLimit = @"0";
    upperLimit = @"20";
    [self performSelectorOnMainThread:@selector(stopAnimationForActivityIndicator) withObject:nil waitUntilDone:NO];
    if (forumArray.count == 0) {
        [Utility showMessage:@"No discussion available" withTitle:@""];
    }else{
        [Utility showMessage:error withTitle:@""];
    }
}

-(void)stopAnimationForActivityIndicator
{
    [self stopProgressHUD];
}

@end
