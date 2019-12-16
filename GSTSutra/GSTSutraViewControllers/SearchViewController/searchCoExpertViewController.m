//
//  searchCoExpertViewController.m
//  GSTSutra
//
//  Created by niyuj on 1/19/17.
//  Copyright © 2017 niyuj. All rights reserved.
//

#import "searchCoExpertViewController.h"
#import "ExpertTakeLngViewController.h"
#import "SearchRequestDelegate.h"

@interface searchCoExpertViewController ()<SearchRequestDelegateMethod>{
    NSMutableArray *expertTakeArray;
}
@property (weak, nonatomic) IBOutlet UITableView *expertTakeTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBarControl;

@end

@implementation searchCoExpertViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [Utility SetPanGestureOff];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSearchTextNotification:)name:@"searchNotificationWithText" object:nil];
    
    NSMutableArray * temp = [[NSMutableArray alloc] initWithArray:[self.searchResultArray mutableCopy]];
    [expertTakeArray removeAllObjects];
    for (int i = 0; i< [temp count]; i++) {
        if ([[[temp objectAtIndex:i] objectForKey:@"story_type"] integerValue] == 11) {
            [expertTakeArray addObject:[[temp mutableCopy] objectAtIndex:i]];
        }
    }
    
    [self.expertTakeTableView reloadData];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBarTitleLabel:@"Tax Ring"];
    expertTakeArray = [[NSMutableArray alloc]init];
}

#pragma mark - NSNotification Center

- (void) receiveSearchTextNotification:(NSNotification *) notification{
    
    if ([notification.name isEqualToString:@"searchNotificationWithText"]){
        
        NSDictionary* userInfo = notification.userInfo;
        
        if ([self checkReachability]) {
            
            //[self searchAPICallWithText:(NSString*)userInfo[@"searchString"]];
            
            NSMutableArray * temp = [[NSMutableArray alloc] init];
            temp = [(NSMutableArray*)userInfo[@"searchString"] mutableCopy];
            [expertTakeArray removeAllObjects];
            for (int i = 0; i< [temp count]; i++) {
                if ([[[temp objectAtIndex:i] objectForKey:@"story_type"] integerValue] == 11) {
                    [expertTakeArray addObject:[[temp mutableCopy] objectAtIndex:i]];
                }
            }
           
            [self.expertTakeTableView reloadData];
//            if (expertTakeArray.count == 0) {
//                [Utility showMessage:@"No Record's found." withTitle:@""];
//            }
            
            
            
        }
        else {
            [self stopProgressHUD];
            [self noInternetAlert];
            
        }
    }
}


-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    //NSLog(@"Cancel");
    [searchBar resignFirstResponder];
}


-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    //NSLog(@"GO");
    [searchBar resignFirstResponder];
    //[self searchAPICall];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    //NSLog(@"End editing");
    return YES;
}


-(void)searchAPICallWithText:(NSString*)searchText{
    if ([self checkReachability]) {
        [self startProgressHUD];
        SearchRequestDelegate *req = [[SearchRequestDelegate alloc] init];
        req.delegate = self;
        
        [req searchText:searchText];
    } else {
        [self noInternetAlert];
    }
}

-(void)searchRequestSuccessfulWithResult:(NSArray *)result{
    [self stopProgressHUD];
    [expertTakeArray removeAllObjects];
    for (int i = 0; i< [result count]; i++) {
        if ([[[result objectAtIndex:i] objectForKey:@"story_type"] integerValue] == 11) {
            [expertTakeArray addObject:[[result mutableCopy] objectAtIndex:i]];
        }
    }
    
    [self.expertTakeTableView reloadData];
    
}
-(void)searchRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
    [Utility showMessage:error withTitle:@""];
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
    
    return size.height + 30;
}

@end
