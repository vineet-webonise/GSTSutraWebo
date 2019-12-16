//
//  NatureOfIssuesViewController.m
//  GSTSutra
//
//  Created by niyuj on 1/2/17.
//  Copyright © 2017 niyuj. All rights reserved.
//

#import "NatureOfIssuesViewController.h"
#import "NatureOfIssueHomeViewController.h"
#import "NOITableViewCell.h"
#import "IndustriesTableViewCell.h"
#import "NatureOfIssueRequest.h"
#import "Constants.h"
@interface NatureOfIssuesViewController ()<NatureOfIssueRequestDelegate>{
    
    
    NSMutableArray *NOIArray,*selectedIndexArray;
}

@property (weak, nonatomic) IBOutlet UITableView *NatureOfIssueTableView;
- (IBAction)submitButtonClicked:(id)sender;

- (IBAction)clearFilterButtonClicked:(id)sender;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bootomViewHeightConstrain;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@end

@implementation NatureOfIssuesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    @try {
        NOIArray = [[NSMutableArray alloc] init];
        self.selectedIDs = [[NSMutableArray alloc] init];
        selectedIndexArray = [[NSMutableArray alloc] init];
        if ([USERDEFAULTS objectForKey:@"selectedIndexes"]!=nil) {
            NSData *data = [USERDEFAULTS objectForKey:@"selectedIndexes"];
            selectedIndexArray =  [NSKeyedUnarchiver unarchiveObjectWithData:data];
        } else {
            [USERDEFAULTS removeObjectForKey:@"selectedIndexes"];
        }
        
        if ([USERDEFAULTS objectForKey:@"NOIID"]!=nil) {
            self.selectedIDs =  [[USERDEFAULTS objectForKey:@"NOIID"] mutableCopy];
        } else {
            [USERDEFAULTS removeObjectForKey:@"NOIID"];
        }
        if (_isFromHomeScreen) {
            [self setupBackBarButtonItems];
            self.NatureOfIssueTableView.allowsMultipleSelection = NO;
            self.bootomViewHeightConstrain.constant = 0.0;
            self.bottomView.hidden = YES;
        }
        if(self.isIndustriesSelected){
            [self setNavigationBarTitleLabel:@"Industry"];
            self.NatureOfIssueTableView.allowsMultipleSelection = YES;
            [NOIArray addObjectsFromArray:[USERDEFAULTS objectForKey:@"IndustriesArray"]];
            
            [self.NatureOfIssueTableView reloadData];
        } else {
            self.bootomViewHeightConstrain.constant = 50.0;
            self.bottomView.hidden = NO;
            [self setNavigationBarTitleLabel:@"Search by Issues"];
            [self getNOIListingAPICall];
        }

    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

#pragma mark - NOI Listing 

-(void)getNOIListingAPICall{
    
    if ([self checkReachability]) {
        [self startProgressHUD];
        NatureOfIssueRequest *req = [[NatureOfIssueRequest alloc] init];
        req.delegate = self;
        [req getNatureOfIssuesListing];
        
    } else {
        [self stopProgressHUD];
        [Utility showMessage:@"No Internet " withTitle:@"Error"];
    }
}

-(void)getNOIListingRequestSuccessfulWithResult:(NSArray *)result{
    [self stopProgressHUD];
    NOIArray = [result mutableCopy];
     [self.NatureOfIssueTableView reloadData];
    
}

-(void)getNOIListingRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
    [Utility showMessage:error withTitle:@""];
}

#pragma mark -
#pragma mark TableView DataSource and Delegate Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [NOIArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NOITableViewCell *cell=(NOITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"NOITableViewCell"];
    
    IndustriesTableViewCell *cellind=(IndustriesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"IndustriesTableViewCell"];
    
    if (cell==nil) {
        cell=[[NOITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NOITableViewCell"];
    }
    
    if (cellind==nil) {
        cellind=[[IndustriesTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IndustriesTableViewCell"];
    }
    
    @try {
        if (_isIndustriesSelected) {
            cellind.industriesTitleLabel.text = [[NOIArray  objectAtIndex:indexPath.row] objectForKey:@"name"];
            cellind.industriesTitleLabel.font = [UIFont fontWithName:centuryGothicRegular size:normalFont];
            return cellind;
        } else {
            
            cell.checkBoxButton.userInteractionEnabled = NO;
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            cell.NOITitleLabel.text = [[NOIArray  objectAtIndex:indexPath.row] objectForKey:@"name"];
            cell.NOITitleLabel.font = [UIFont fontWithName:centuryGothicRegular size:normalFont];
            if([selectedIndexArray containsObject:indexPath]){
                [cell.checkBoxButton setImage:[UIImage imageNamed:@"chkboxtic"] forState:UIControlStateNormal];
                
            }else {
                [cell.checkBoxButton setImage:[UIImage imageNamed:@"checkbox"] forState:UIControlStateNormal];
            }
            return cell;
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    @try {
        if (self.isIndustriesSelected) {
            
            NatureOfIssueHomeViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"NatureOfIssueHomeViewController"];
            if (_isFromHomeScreen) {
                home.isIndustriesSelected = NO;
                //[self.selectedIDs addObject:[[NOIArray  objectAtIndex:indexPath.row] objectForKey:@"id"]];
                
            } else {
                home.isIndustriesSelected = YES;
            }
            
            [USERDEFAULTS setObject:[[NOIArray  objectAtIndex:indexPath.row] objectForKey:@"id"] forKey:@"inDustriesID"];
            [self.navigationController pushViewController:home animated:YES];
            
        } else {
            if (![selectedIndexArray containsObject:indexPath] ){
                [selectedIndexArray addObject:indexPath];
                [self.selectedIDs addObject:[[NOIArray  objectAtIndex:indexPath.row] objectForKey:@"id"]];
            }else{
                [selectedIndexArray removeObject:indexPath];
                
                [self.selectedIDs removeObject:[[NOIArray  objectAtIndex:indexPath.row] objectForKey:@"id"]];
            }
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [USERDEFAULTS removeObjectForKey:@"selectedIndexes"];
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:selectedIndexArray];
            [USERDEFAULTS setObject:data forKey:@"selectedIndexes"];
        }
        

    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
}


- (IBAction)submitButtonClicked:(id)sender {
    
    @try {
        [USERDEFAULTS removeObjectForKey:@"NOIID"];
        NatureOfIssueHomeViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"NatureOfIssueHomeViewController"];
        if (_isFromHomeScreen) {
            home.isIndustriesSelected = YES;
            [USERDEFAULTS setObject:[self.selectedIDs mutableCopy] forKey:@"NOIID"];
            if (selectedIndexArray.count>0) {
                [self.navigationController pushViewController:home animated:YES];
            } else {
                [Utility showMessage:@"Please select at least one issue" withTitle:@""];
            }
            
            //[self.navigationController pushViewController:home animated:YES];
        } else {
            if (selectedIndexArray.count>0) {
                home.isIndustriesSelected = NO;
                [USERDEFAULTS setObject:[self.selectedIDs mutableCopy] forKey:@"NOIID"];
                [self.navigationController pushViewController:home animated:YES];
            } else {
                [Utility showMessage:@"Please select at least one issue" withTitle:@""];
            }
            
        }

    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
    }

- (IBAction)clearFilterButtonClicked:(id)sender {
    
    @try {
        [USERDEFAULTS removeObjectForKey:@"NOIID"];
        [USERDEFAULTS removeObjectForKey:@"selectedIndexes"];
        [selectedIndexArray removeAllObjects];
        [self.NatureOfIssueTableView reloadData];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}
@end
