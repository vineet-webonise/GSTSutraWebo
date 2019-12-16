//
//  FAQViewController.m
//  GSTSutra
//
//  Created by niyuj on 11/9/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import "FAQViewController.h"
#import "ExpertCornerRequest.h"

@interface FAQViewController ()<ExpertRequestDelegate,UITableViewDelegate,UITableViewDataSource>{
    
    NSMutableArray  *arrayForBool,*sectionTitleArray,*sectionTitleOfflineArray;
    NSString *lowerLimit,*upperLimit;
    BOOL stopPagination;
    
}
@property (weak, nonatomic) IBOutlet UITableView *expandableTableView;

@end

@implementation FAQViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    lowerLimit = @"0";
    upperLimit = @"20";
    [self setNavigationBarTitleLabel:@"CBEC FAQs"];
    arrayForBool=[[NSMutableArray alloc]init];
    sectionTitleArray=[[NSMutableArray alloc]init];
    sectionTitleOfflineArray = [[NSMutableArray alloc]init];
    stopPagination = YES;
    self.expandableTableView.dataSource = self;
    self.expandableTableView.delegate = self;
    self.expandableTableView.backgroundColor = [UIColor whiteColor];
    
    [self getFAQAPICall];
    
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.expandableTableView.estimatedRowHeight = 70.0; // for example. Set your average height
    self.expandableTableView.rowHeight = UITableViewAutomaticDimension;
    
    self.expandableTableView.sectionHeaderHeight = UITableViewAutomaticDimension;
    self.expandableTableView.estimatedSectionHeaderHeight = 60;
    [self.expandableTableView reloadData];
}

#pragma  mark - Sqlite Database

-(void)storeDataIntoDataBase{
    [appD.database open];
    [appD.database executeUpdate:@"DROP TABLE IF EXISTS `faqsTable`;"];
    [appD.database executeUpdate:@"create table IF NOT EXISTS faqsTable(news blob primary key)"];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:sectionTitleArray];
    [appD.database executeUpdate:@"insert into faqsTable values (?)",data];
    FMResultSet *results = [appD.database executeQuery:@"select * from faqsTable"];
    while([results next]) {
        sectionTitleOfflineArray = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:@"news"]];
        //NSLog(@"Experts Array from DB : %@ ",expertOfflineArray);
    }
    [appD.database close];
}

-(void)setDataBaseDataToTable{
    [appD.database open];
    FMResultSet *results = [appD.database executeQuery:@"select * from faqsTable"];
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

-(void)getFAQAPICall{
    
    if ([self checkReachability]) {
        [self startProgressHUD];
        ExpertCornerRequest *req = [[ExpertCornerRequest alloc] init];
        req.delegate = self;
        [req faqsWithLowerLimit:lowerLimit withUpperLimit:upperLimit];
        
    } else {
        [self noInternetAlert];
        [self setDataBaseDataToTable];
    }
}

#pragma mark - FAQ Delegate 

-(void)getFAQRequestSuccessfulWithResult:(NSArray *)result{
    //[self stopProgressHUD];
    stopPagination = YES;
    [sectionTitleArray addObjectsFromArray:result];
    [self storeDataIntoDataBase];
    [self setDataToTableview];
    
    [self performSelectorOnMainThread:@selector(stopAnimationForActivityIndicator) withObject:nil waitUntilDone:NO];
}

-(void)getFAQRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    //[self stopProgressHUD];
    stopPagination = NO;
   // [sectionTitleArray removeAllObjects];
    lowerLimit = @"0";
    upperLimit = @"20";
    [self performSelectorOnMainThread:@selector(stopAnimationForActivityIndicator) withObject:nil waitUntilDone:NO];
    if (sectionTitleArray.count == 0) {
        [Utility showMessage:@"No FAQ available" withTitle:@""];
    }else{
        [Utility showMessage:error withTitle:@""];
    }
}

-(void)stopAnimationForActivityIndicator
{
    [self stopProgressHUD];
}

-(void)setDataToTableview{
    
    for (int i = 0; i< [sectionTitleArray count]; i++) {
        [arrayForBool addObject:[NSNumber numberWithBool:NO]];
    }
    [self.expandableTableView reloadData];
    
}

#pragma mark -
#pragma mark - TableView DataSource and Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if ([[arrayForBool objectAtIndex:section] boolValue]) {
        return  1;
    }
    else
        return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    static NSString *cellid=@"FAQRowCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
    }
    
    @try {
        UILabel *ansLabel = (UILabel*)[cell viewWithTag:3];
        UILabel *ansDisLabel = (UILabel*)[cell viewWithTag:4];
        
        BOOL manyCells  = [[arrayForBool objectAtIndex:indexPath.section] boolValue];
        
        /********** If the section supposed to be closed *******************/
        if(!manyCells){
            cell.backgroundColor=[UIColor clearColor];
            
            ansLabel.text=@"";
            ansDisLabel.text=@"";
        }
        /********** If the section supposed to be Opened *******************/
        else{
            
            //cell.textLabel.text= [[sectionTitleArray objectAtIndex:indexPath.section] objectForKey:@"answer"];
            //NSString *temp = [@"Ans:" stringByAppendingString:[[sectionTitleArray objectAtIndex:indexPath.section] objectForKey:@"answer"]];
            NSString *temp = [[sectionTitleArray objectAtIndex:indexPath.section] objectForKey:@"answer"];
            NSAttributedString *tempAtributedString =  [[NSAttributedString alloc] initWithData:[temp dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]} documentAttributes:nil error:nil];
            //cell.textLabel.text = [tempAtributedString string];
            ansLabel.text = @"Ans:" ;
            ansLabel.font=[UIFont fontWithName:centuryGothicBold size:titleFont];
            ansDisLabel.text = [tempAtributedString string];
            ansDisLabel.font=[UIFont fontWithName:centuryGothicRegular size:normalFont];
            //cell.textLabel.font=[UIFont systemFontOfSize:15.0f];
            cell.backgroundColor=[UIColor whiteColor];
            cell.selectionStyle=UITableViewCellSelectionStyleNone ;
            //cell.textLabel.numberOfLines = 0;
        }
        cell.textLabel.textColor=[UIColor blackColor];
        
        /********** Add a custom Separator with cell *******************/
        //    UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, cell.frame.size.height + 5, SCREENWIDTH, 1)];
        //    separatorLineView.backgroundColor = [UIColor blackColor];
        //    [cell.contentView addSubview:separatorLineView];
        
        return cell;
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [sectionTitleArray count];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
   
    if (stopPagination) {
            if (section > [sectionTitleArray count] -2) {
                lowerLimit = upperLimit;
                upperLimit = [NSString stringWithFormat:@"%ld",([upperLimit integerValue] + 20)];
                [self getFAQAPICall];
            }
        
    }
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    @try {
        /*************** Close the section, once the data is selected ***********************************/
        // [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"ViewController2"] animated:YES completion:nil];
        
        [arrayForBool replaceObjectAtIndex:indexPath.section withObject:[NSNumber numberWithBool:NO]];
        
        //[_expandableTableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
        [_expandableTableView reloadData];
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
    
    @try {
        UILabel *queLabel = (UILabel*)[cell viewWithTag:1];
        UILabel *queDisLabel = (UILabel*)[cell viewWithTag:2];
        queLabel.text = [@"Q" stringByAppendingString: [NSString stringWithFormat:@"%ld. ",section + 1]];
        queDisLabel.attributedText = [[NSAttributedString alloc] initWithData:[[[sectionTitleArray objectAtIndex:section] objectForKey:@"question"] dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]} documentAttributes:nil error:nil];
        queLabel.font = [UIFont fontWithName:centuryGothicBold size:titleFont];
        queDisLabel.font = [UIFont fontWithName:centuryGothicBold size:titleFont];
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
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

#pragma mark - Table header gesture tapped

- (void)sectionHeaderTapped:(UITapGestureRecognizer *)gestureRecognizer{
    
    @try {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:gestureRecognizer.view.tag];
        if (indexPath.row == 0) {
            BOOL collapsed  = [[arrayForBool objectAtIndex:indexPath.section] boolValue];
            for (int i=0; i<[sectionTitleArray count]; i++) {
                if (indexPath.section==i) {
                    [arrayForBool replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:!collapsed]];
                }
            }
            //[_expandableTableView reloadSections:[NSIndexSet indexSetWithIndex:gestureRecognizer.view.tag] withRowAnimation:UITableViewRowAnimationNone];
            [_expandableTableView reloadData];
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}



-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //minimum size of your cell, it should be single line of label if you are not clear min. then return UITableViewAutomaticDimension;
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    NSString *str = [[sectionTitleArray objectAtIndex:section] objectForKey:@"question"];

    CGRect textRect = [str boundingRectWithSize:CGSizeMake(SCREENWIDTH, 999)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:[UIFont fontWithName:centuryGothicBold size:titleFont]}
                                         context:nil];
    
    CGSize size = textRect.size;
    
    return size.height + 30;
    
}


@end
