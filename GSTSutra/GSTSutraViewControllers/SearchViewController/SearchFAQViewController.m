//
//  SearchFAQViewController.m
//  GSTSutra
//
//  Created by niyuj on 1/19/17.
//  Copyright © 2017 niyuj. All rights reserved.
//

#import "SearchFAQViewController.h"
#import "SearchRequestDelegate.h"
#import "FAQDetailViewController.h"

@interface SearchFAQViewController ()<SearchRequestDelegateMethod,UITableViewDelegate,UITableViewDataSource>{
    
    NSMutableArray  *dataArray;
    NSString *lowerLimit,*upperLimit;
    BOOL stopPagination;
    
}
@property (weak, nonatomic) IBOutlet UITableView *expandableTableView;

@end

@implementation SearchFAQViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBarTitleLabel:@"CBEC FAQs"];
   
    dataArray=[[NSMutableArray alloc]init];
    stopPagination = YES;
    self.expandableTableView.dataSource = self;
    self.expandableTableView.delegate = self;
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [Utility SetPanGestureOff];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSearchTextNotification:)name:@"searchNotificationWithText" object:nil];
    
    self.expandableTableView.estimatedRowHeight = 70.0; // for example. Set your average height
    self.expandableTableView.rowHeight = UITableViewAutomaticDimension;
    
    self.expandableTableView.sectionHeaderHeight = UITableViewAutomaticDimension;
    self.expandableTableView.estimatedSectionHeaderHeight = 60;
    [self.expandableTableView reloadData];
    
    NSMutableArray * temp = [[NSMutableArray alloc] initWithArray:[self.searchResultArray mutableCopy]];
    [dataArray removeAllObjects];
    for (int i = 0; i< [temp count]; i++) {
        if ([[[temp objectAtIndex:i] objectForKey:@"story_type"] integerValue] == 24) {
            [dataArray addObject:[[temp mutableCopy] objectAtIndex:i]];
        }
    }
    
    [self.expandableTableView reloadData];

}

#pragma mark - NSNotification Center

- (void) receiveSearchTextNotification:(NSNotification *) notification{
    
    if ([notification.name isEqualToString:@"searchNotificationWithText"]){
        
        NSDictionary* userInfo = notification.userInfo;
        
        if ([self checkReachability]) {
            
            //[self searchAPICallWithText:(NSString*)userInfo[@"searchString"]];
            
            NSMutableArray * temp = [[NSMutableArray alloc] init];
            [dataArray removeAllObjects];
            temp = [(NSMutableArray*)userInfo[@"searchString"] mutableCopy];
            
            for (int i = 0; i< [temp count]; i++) {
                if ([[[temp objectAtIndex:i] objectForKey:@"story_type"] integerValue] == 24) {
                    [dataArray addObject:[[temp mutableCopy] objectAtIndex:i]];
                }
            }
            
            [self.expandableTableView reloadData];
    
        }
        else {
            [self stopProgressHUD];
            [self noInternetAlert];
            
        }
    }
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
    [dataArray removeAllObjects];
    for (int i = 0; i< [result count]; i++) {
        if ([[[result objectAtIndex:i] objectForKey:@"story_type"] integerValue] == 24) {
            [dataArray addObject:[[result mutableCopy] objectAtIndex:i]];
        }
    }
    
    
        [self.expandableTableView reloadData];
//    if (dataArray.count == 0) {
//        [Utility showMessage:@"No Record's found." withTitle:@""];
//    }
    
    
}
-(void)searchRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
    [Utility showMessage:error withTitle:@""];
}

#pragma mark -
#pragma mark TableView DataSource and Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
           return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    static NSString *cellid=@"FAQHeaderCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
    }
    
    @try {
        UILabel *queLabel = (UILabel*)[cell viewWithTag:1];
        UILabel *queDisLabel = (UILabel*)[cell viewWithTag:2];
        
        queLabel.text = @" Q ";
        
        queDisLabel.attributedText = [[NSAttributedString alloc] initWithData:[[[dataArray objectAtIndex:indexPath.row] objectForKey:@"question"] dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]} documentAttributes:nil error:nil];
        
        queLabel.font = [UIFont fontWithName:centuryGothicBold size:titleFont];
        queDisLabel.font = [UIFont fontWithName:centuryGothicBold size:titleFont];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        queDisLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        return cell;

    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FAQDetailViewController *shortView = [self.storyboard instantiateViewControllerWithIdentifier:@"FAQDetailViewController"];
shortView.QueString =  [[dataArray objectAtIndex:indexPath.row] objectForKey:@"question"];
shortView.AnsString = [[dataArray objectAtIndex:indexPath.row] objectForKey:@"answer"];
[self.navigationController pushViewController:shortView animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *str = [[dataArray objectAtIndex:indexPath.row] objectForKey:@"question"];
    
    CGRect textRect = [str boundingRectWithSize:CGSizeMake(SCREENWIDTH, 999)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:[UIFont fontWithName:centuryGothicBold size:titleFont]}
                                        context:nil];
    
    CGSize size = textRect.size;
    
    return size.height + 40;
    
}


//-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    //minimum size of your cell, it should be single line of label if you are not clear min. then return UITableViewAutomaticDimension;
//    return UITableViewAutomaticDimension;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
//    NSString *str = [[dataArray objectAtIndex:section] objectForKey:@"question"];
//    
//    CGRect textRect = [str boundingRectWithSize:CGSizeMake(SCREENWIDTH, 999)
//                                        options:NSStringDrawingUsesLineFragmentOrigin
//                                     attributes:@{NSFontAttributeName:[UIFont fontWithName:centuryGothicBold size:14]}
//                                        context:nil];
//    
//    CGSize size = textRect.size;
//    
//    return size.height + 30;
    return 0;
}


@end
