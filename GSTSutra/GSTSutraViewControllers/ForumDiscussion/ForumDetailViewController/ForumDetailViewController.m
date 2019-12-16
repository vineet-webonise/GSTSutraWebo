//
//  ForumDetailViewController.m
//  GSTSutra
//
//  Created by niyuj on 1/24/17.
//  Copyright © 2017 niyuj. All rights reserved.
//

#import "ForumDetailViewController.h"
#import "ExpertCornerRequest.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+Letters.h"

#import "ShowCommentTableViewCell.h"
#import "showChildCommentTableViewCell.h"
#import "TypeCommentTableViewCell.h"
#import "ForumReplyCommentEditViewController.h"

#import "NewRequest.h"


@interface ForumDetailViewController ()<ExpertRequestDelegate,UITableViewDelegate,UITableViewDataSource,NewRequestDelegate>{
    
    NSMutableArray  *arrayForBool,*sectionTitleArray,*resultArray,*expertsArray,*mainCommentsArray,*childCommentsArray;
    BOOL isEditComment;
    
}
@property (weak, nonatomic) IBOutlet UITableView *expandableTableView;
@property (weak, nonatomic) IBOutlet UITextView *forumDetailTextView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
- (IBAction)replyButtonClicked:(id)sender;

@end

@implementation ForumDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupBackBarButtonItems];
    [self setNavigationBarTitleLabel:@"Discussion Forum"];
    [self.expandableTableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    self.expandableTableView.contentOffset = CGPointMake(0, 0 - self.expandableTableView.contentInset.top);
    if (appD.isFromNotification) {
        appD.isFromNotification = NO;
        self.selectedForumID = appD.sid;
    }
    
    
    self.expandableTableView.dataSource = self;
    self.expandableTableView.delegate = self;
    [self.expandableTableView registerNib:[UINib nibWithNibName:@"ShowCommentTableViewCell" bundle:nil] forCellReuseIdentifier:@"ShowCommentTableViewCell"];
    
    [self.expandableTableView registerNib:[UINib nibWithNibName:@"showChildCommentTableViewCell" bundle:nil] forCellReuseIdentifier:@"showChildCommentTableViewCell"];

    
    [self.expandableTableView registerNib:[UINib nibWithNibName:@"TypeCommentTableViewCell" bundle:nil] forCellReuseIdentifier:@"TypeCommentTableViewCell"];
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    arrayForBool=[[NSMutableArray alloc]init];
    sectionTitleArray=[[NSMutableArray alloc]init];
    resultArray=[[NSMutableArray alloc]init];
    expertsArray=[[NSMutableArray alloc]init];
    mainCommentsArray=[[NSMutableArray alloc]init];
    childCommentsArray=[[NSMutableArray alloc]init];
    
    self.expandableTableView.estimatedRowHeight = 70.0;
    self.expandableTableView.rowHeight = UITableViewAutomaticDimension;
    self.expandableTableView.sectionHeaderHeight = UITableViewAutomaticDimension;
    self.expandableTableView.estimatedSectionHeaderHeight = 60;
    self.expandableTableView.backgroundColor = [UIColor whiteColor];
    [self getForumDiscusionPICall];
    [self.expandableTableView reloadData];
}
-(void)getForumDiscusionPICall{
    
    if ([self checkReachability]) {
        [self startProgressHUD];
        ExpertCornerRequest *req = [[ExpertCornerRequest alloc] init];
        req.delegate = self;
        [req getDetailForumData:self.selectedForumID];
        
    } else {
        [self noInternetAlert];
    }
}

#pragma mark - get Detail Forum Data  Delegate

-(void)getForumDetailRequestSuccessfulWithResult:(NSArray *)result{
    [self stopProgressHUD];
    [resultArray removeAllObjects];
    resultArray = [result mutableCopy];
    @try {
        if (![[[resultArray objectAtIndex:0]  objectForKey:@"shortview"] isEqual: [NSNull null]]) {
            
            self.forumDetailTextView.attributedText = [[NSAttributedString alloc] initWithData:[[[resultArray objectAtIndex:0]  objectForKey:@"shortview"] dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]} documentAttributes:nil error:nil];
            
        }
        
        self.forumDetailTextView.font = [UIFont fontWithName:centuryGothicRegular size:normalFont];
        self.forumDetailTextView.editable = NO;
        self.titleLabel.text = [[resultArray objectAtIndex:0]  objectForKey:@"title"];
        self.titleLabel.font = [UIFont fontWithName:centuryGothicBold size:titleFont];
        expertsArray = [[resultArray objectAtIndex:0]  objectForKey:@"experts"];
        
        //NSLog(@"Experts Array %@",expertsArray);
        
        if (expertsArray.count>0) {
            for (int i = 0; i< [expertsArray count]; i++) {
                [arrayForBool addObject:[NSNumber numberWithBool:YES]];
                self.expandableTableView.hidden = NO;
            }
            [self.expandableTableView reloadData];
        } else {
            self.expandableTableView.hidden = YES;
        }

         [self.expandableTableView reloadData];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

-(void)getForumDetailRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
    [Utility showMessage:error withTitle:@""];
}


#pragma mark -
#pragma mark - TableView DataSource and Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return [expertsArray count];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if ([[arrayForBool objectAtIndex:section] boolValue]) {
        if ([[[expertsArray objectAtIndex:section] objectForKey:@"threadcomment"] count] >0) {
            return [[[expertsArray objectAtIndex:section] objectForKey:@"threadcomment"] count];
        } else{
        return 0 ;
        }
    }
    else
        return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    static NSString *showChildcellIdentifier = @"showChildCommentTableViewCell";
    showChildCommentTableViewCell *showChildCommentcell = (showChildCommentTableViewCell*)[tableView dequeueReusableCellWithIdentifier:showChildcellIdentifier];

    @try {
        showChildCommentcell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        BOOL manyCells  = [[arrayForBool objectAtIndex:indexPath.section] boolValue];
        
        /********** If the section supposed to be closed *******************/
        if(!manyCells){
            
        }
        /********** If the section supposed to be Opened *******************/
        else{
            
            // Here we use the new provided sd_setImageWithURL: method to load the web image
            
            
            if ([[[expertsArray objectAtIndex:indexPath.section] objectForKey:@"threadcomment"] count]>0) {
                
                NSString *newsImageUrl = [[NSString stringWithFormat:@"%@",ImageSERVER_API] stringByAppendingString:[[[[expertsArray objectAtIndex:indexPath.section] objectForKey:@"threadcomment"] objectAtIndex:indexPath.row] objectForKey:@"image"]];
                if ([self checkImageExtensionWithImage:newsImageUrl]) {
                    [showChildCommentcell.childImageView sd_setImageWithURL:[NSURL URLWithString:newsImageUrl]placeholderImage:[UIImage imageNamed:@"userimage.png"]];
                }else if(![[[[[expertsArray objectAtIndex:indexPath.section] objectForKey:@"threadcomment"] objectAtIndex:indexPath.row] objectForKey:@"full_name"] isEqualToString:@""]){
                    [showChildCommentcell.childImageView setImageWithString:[[[[expertsArray objectAtIndex:indexPath.section] objectForKey:@"threadcomment"] objectAtIndex:indexPath.row] objectForKey:@"full_name"] color:nil circular:YES];
                } else {
                    [showChildCommentcell.childImageView setImageWithString:[[[[expertsArray objectAtIndex:indexPath.section] objectForKey:@"threadcomment"] objectAtIndex:indexPath.row] objectForKey:@"username"] color:nil circular:YES];
                }
                
                showChildCommentcell.childImageView.layer.cornerRadius = showChildCommentcell.childImageView.frame.size.height /2;
                showChildCommentcell.childImageView.layer.masksToBounds = YES;
                showChildCommentcell.childImageView.layer.borderWidth = 1.0;
                if(![[[[[expertsArray objectAtIndex:indexPath.section] objectForKey:@"threadcomment"] objectAtIndex:indexPath.row] objectForKey:@"full_name"] isEqualToString:@""]){
                    
                    showChildCommentcell.childNameLabel.text = [NSString stringWithFormat:@"%@",[[[[expertsArray objectAtIndex:indexPath.section] objectForKey:@"threadcomment"] objectAtIndex:indexPath.row] objectForKey:@"full_name"]];
                } else {
                    showChildCommentcell.childNameLabel.text = [NSString stringWithFormat:@"%@",[[[[expertsArray objectAtIndex:indexPath.section] objectForKey:@"threadcomment"] objectAtIndex:indexPath.row] objectForKey:@"username"]];
                }
                showChildCommentcell.childNameLabel.font = [UIFont fontWithName:centuryGothicBold size:titleFont];
                showChildCommentcell.childCommentLabel.attributedText = [[NSAttributedString alloc] initWithData:[[[[[expertsArray objectAtIndex:indexPath.section] objectForKey:@"threadcomment"] objectAtIndex:indexPath.row] objectForKey:@"comment"] dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]} documentAttributes:nil error:nil];
                
                showChildCommentcell.childCommentLabel.font = [UIFont fontWithName:centuryGothicRegular size:normalFont];
                
                if ([[USERDEFAULTS valueForKey:@"userid"] isEqualToString:[[[[expertsArray objectAtIndex:indexPath.section] objectForKey:@"threadcomment"] objectAtIndex:indexPath.row] objectForKey:@"userid"]]) {
                    showChildCommentcell.childDeleteButton.hidden = NO;
                    showChildCommentcell.childEditButton.hidden = NO;
                    showChildCommentcell.childReplyButton.hidden = NO;
                    showChildCommentcell.ReplyWhenAllHidden.hidden = YES;
                    
                } else {
                    showChildCommentcell.childDeleteButton.hidden = YES;
                    showChildCommentcell.childEditButton.hidden = YES;
                    showChildCommentcell.childReplyButton.hidden = YES;
                    showChildCommentcell.ReplyWhenAllHidden.hidden = NO;
                    
                }
                [showChildCommentcell.childDeleteButton addTarget:self action:@selector(deleteChildCommentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                
                [showChildCommentcell.childReplyButton addTarget:self action:@selector(replyToChildCommentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                
                [showChildCommentcell.ReplyWhenAllHidden addTarget:self action:@selector(replyToChildCommentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                
                [showChildCommentcell.childEditButton addTarget:self action:@selector(editChildCommentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                
                
            }
            return showChildCommentcell;
            
        }
        
        return showChildCommentcell;

    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([[arrayForBool objectAtIndex:indexPath.section] boolValue]) {
        
      NSString *str=  [[[[expertsArray objectAtIndex:indexPath.section] objectForKey:@"threadcomment"] objectAtIndex:indexPath.row] objectForKey:@"comment"];
        
        CGRect textRect = [str boundingRectWithSize:CGSizeMake(SCREENWIDTH, 999)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName:[UIFont fontWithName:centuryGothicBold size:14]}
                                            context:nil];
        
        CGSize size = textRect.size;
        
        return size.height + 80;

        //return UITableViewAutomaticDimension;
    } else{
        return 0;
    }
    
    
}


#pragma mark - Creating View for TableView Section

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *showCommentcellID= @"ShowCommentTableViewCell";
    ShowCommentTableViewCell *showCommentcell = (ShowCommentTableViewCell*)[tableView dequeueReusableCellWithIdentifier:showCommentcellID];
    self.expandableTableView.tableHeaderView = showCommentcell;
        // Here we use the new provided sd_setImageWithURL: method to load the web image
        NSString *newsImageUrl = [[NSString stringWithFormat:@"%@",ImageSERVER_API] stringByAppendingString:[[expertsArray objectAtIndex:section] objectForKey:@"image"]];
        if ([self checkImageExtensionWithImage:newsImageUrl]) {
            [showCommentcell.userImageView sd_setImageWithURL:[NSURL URLWithString:newsImageUrl]placeholderImage:[UIImage imageNamed:@"userimage.png"]];
        }else if(![[[expertsArray objectAtIndex:section] objectForKey:@"full_name"] isEqualToString:@""]){
            [showCommentcell.userImageView setImageWithString:[[expertsArray objectAtIndex:section] objectForKey:@"full_name"] color:nil circular:YES];
        } else {
            [showCommentcell.userImageView setImageWithString:[[expertsArray objectAtIndex:section] objectForKey:@"username"] color:nil circular:YES];
        }
        
        showCommentcell.userImageView.layer.cornerRadius = showCommentcell.userImageView.frame.size.height /2;
        showCommentcell.userImageView.layer.masksToBounds = YES;
        showCommentcell.userImageView.layer.borderWidth = 1.0;
        if(![[[expertsArray objectAtIndex:section] objectForKey:@"full_name"] isEqualToString:@""]){
            showCommentcell.nameLabel.text = [NSString stringWithFormat:@"%@",[[expertsArray objectAtIndex:section] objectForKey:@"full_name"]];
        } else {
            showCommentcell.nameLabel.text = [NSString stringWithFormat:@"%@",[[expertsArray objectAtIndex:section] objectForKey:@"username"]];
        }
        showCommentcell.nameLabel.font = [UIFont fontWithName:centuryGothicBold size:titleFont];
    showCommentcell.commentLabel.attributedText = [[NSAttributedString alloc] initWithData:[[[expertsArray objectAtIndex:section] objectForKey:@"comment"] dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]} documentAttributes:nil error:nil];
    showCommentcell.commentLabel.font = [UIFont fontWithName:centuryGothicRegular size:normalFont];

        if ([[USERDEFAULTS valueForKey:@"userid"] isEqualToString:[[expertsArray objectAtIndex:section] objectForKey:@"userid"]]) {
            showCommentcell.deleteButton.hidden = NO;
            showCommentcell.editButtonClick.hidden = NO;
            showCommentcell.replyButton.hidden = NO;
            showCommentcell.replyWhenAllHide.hidden = YES;
            
        } else {
            showCommentcell.deleteButton.hidden = YES;
            showCommentcell.editButtonClick.hidden = YES;
            showCommentcell.replyButton.hidden = YES;
            showCommentcell.replyWhenAllHide.hidden = NO;
        }
        [showCommentcell.deleteButton addTarget:self action:@selector(deleteMainCommentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
       showCommentcell.deleteButton.tag = section;
    
       [showCommentcell.replyButton addTarget:self action:@selector(replyCommentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [showCommentcell.replyWhenAllHide addTarget:self action:@selector(replyCommentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
    
        
        [showCommentcell.editButtonClick addTarget:self action:@selector(editMainCommentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        showCommentcell.editButtonClick.tag = section;
       showCommentcell.deleteButton.tag = section;
       showCommentcell.replyButton.tag = section;
       showCommentcell.replyWhenAllHide.tag = section;
    
    //return sectionHeaderCell.contentView;
    
    showCommentcell.contentView.tag = section;
    
    /********** Add a custom Separator with Section view *******************/
    UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _expandableTableView.frame.size.width, 1)];
    separatorLineView.backgroundColor = [UIColor blackColor];
    [showCommentcell.contentView addSubview:separatorLineView];
    showCommentcell.contentView.backgroundColor = [UIColor whiteColor];
    /********** Add UITapGestureRecognizer to SectionView   **************/
    
//    UITapGestureRecognizer  *headerTapped   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionHeaderTapped:)];
//    [cell.contentView addGestureRecognizer:headerTapped];
    
    return  showCommentcell.contentView;
}

#pragma mark - Table header gesture tapped

- (void)sectionHeaderTapped:(UITapGestureRecognizer *)gestureRecognizer{
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:gestureRecognizer.view.tag];
    if (indexPath.row == 0) {
        BOOL collapsed  = [[arrayForBool objectAtIndex:indexPath.section] boolValue];
        for (int i=0; i<[sectionTitleArray count]; i++) {
            if (indexPath.section==i) {
                [arrayForBool replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:!collapsed]];
            }
        }
        [_expandableTableView reloadData];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    NSString *str = [NSString stringWithFormat:@"%@",[[expertsArray objectAtIndex:section] objectForKey:@"comment"]];
    
    CGRect textRect = [str boundingRectWithSize:CGSizeMake(SCREENWIDTH, 999)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:[UIFont fontWithName:centuryGothicBold size:14]}
                                        context:nil];
    
    CGSize size = textRect.size;
    
    return size.height + 80;
    
}

#pragma mark - Delete Comment Button Clicked 

-(IBAction)deleteChildCommentButtonClicked:(UIButton*)sender{
    
    
    UIView *contentView = (UIView *)[sender superview];
    UITableViewCell *cell = (UITableViewCell *)[contentView superview];
    NSIndexPath *indexPath = [self.expandableTableView indexPathForCell:cell];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Delete Comment" message:@"Are you sure?" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if ([self checkReachability]) {
            [self startProgressHUD];
            ExpertCornerRequest *newsReq = [[ExpertCornerRequest alloc] init];
            newsReq.delegate=self;
            [newsReq deleteForumCommentWithCommentID:[[[[expertsArray objectAtIndex:indexPath.section] objectForKey:@"threadcomment"] objectAtIndex:indexPath.row] objectForKey:@"comment_id"] commentString:@"" withNID:[[resultArray objectAtIndex:0]  objectForKey:@"nid"]];
            
        }
        
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // no operation dismiss view
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
    
    
    
}
-(IBAction)deleteMainCommentButtonClicked:(UIButton*)sender{
    //NSString *tempStr = [NSString stringWithFormat:@"%ld",(long)sender.tag];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Delete Comment" message:@"Are you sure?" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if ([self checkReachability]) {
            [self startProgressHUD];
            ExpertCornerRequest *newsReq = [[ExpertCornerRequest alloc] init];
            newsReq.delegate=self;
            [newsReq deleteForumCommentWithCommentID:[[expertsArray objectAtIndex:sender.tag] objectForKey:@"comment_id"] commentString:@"" withNID:[[resultArray objectAtIndex:0]  objectForKey:@"nid"]];
        }
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // no operation dismiss view
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
    
    
    
}

#pragma mark - Edit Button Clicked

-(IBAction)editChildCommentButtonClicked:(id)sender{
    
    UIView *contentView = (UIView *)[sender superview];
    UITableViewCell *cell = (UITableViewCell *)[contentView superview];
    NSIndexPath *indexPath = [self.expandableTableView indexPathForCell:cell];
    
    ForumReplyCommentEditViewController *reply = [self.storyboard instantiateViewControllerWithIdentifier:@"ForumReplyCommentEditViewController"];
    reply.nID = [[resultArray objectAtIndex:0]  objectForKey:@"nid"];
    reply.isEditComment = YES;
    reply.commentID = [[[[expertsArray objectAtIndex:indexPath.section] objectForKey:@"threadcomment"] objectAtIndex:indexPath.row] objectForKey:@"comment_id"];
    reply.editableText = [[[[expertsArray objectAtIndex:indexPath.section] objectForKey:@"threadcomment"] objectAtIndex:indexPath.row] objectForKey:@"comment"];
    
    [self.navigationController pushViewController:reply animated:NO];
    
}

-(IBAction)editMainCommentButtonClicked:(UIButton*)sender{
    ForumReplyCommentEditViewController *reply = [self.storyboard instantiateViewControllerWithIdentifier:@"ForumReplyCommentEditViewController"];
    reply.nID = [[resultArray objectAtIndex:0]  objectForKey:@"nid"];
    reply.isEditComment = YES;
    reply.commentID = [[expertsArray objectAtIndex:sender.tag] objectForKey:@"comment_id"];
    reply.editableText = [[expertsArray objectAtIndex:sender.tag] objectForKey:@"comment"];
    
    [self.navigationController pushViewController:reply animated:NO];
    
}

#pragma mark - Reply Button Clicked

// Reply From Child

- (IBAction)replyToChildCommentButtonClicked:(UIButton*)sender {
    
    UIView *contentView = (UIView *)[sender superview];
    UITableViewCell *cell = (UITableViewCell *)[contentView superview];
    NSIndexPath *indexPath = [self.expandableTableView indexPathForCell:cell];
    
    ForumReplyCommentEditViewController *reply = [self.storyboard instantiateViewControllerWithIdentifier:@"ForumReplyCommentEditViewController"];
    reply.nID = [[resultArray objectAtIndex:0]  objectForKey:@"nid"];
    reply.isEditComment = NO;
    reply.commentID = [[[[expertsArray objectAtIndex:indexPath.section] objectForKey:@"threadcomment"] objectAtIndex:indexPath.row] objectForKey:@"comment_id"];
    reply.isReplyToComment = YES;

    [self.navigationController pushViewController:reply animated:NO];
}

// Reply From Parent

- (IBAction)replyCommentButtonClicked:(UIButton*)sender {
    ForumReplyCommentEditViewController *reply = [self.storyboard instantiateViewControllerWithIdentifier:@"ForumReplyCommentEditViewController"];
    reply.nID = [[resultArray objectAtIndex:0]  objectForKey:@"nid"];
    reply.isEditComment = NO;
    reply.commentID = [[expertsArray objectAtIndex:sender.tag] objectForKey:@"comment_id"];
    reply.isReplyToComment = YES;
    [self.navigationController pushViewController:reply animated:NO];
}

// Reply From Main Parent

- (IBAction)replyButtonClicked:(UIButton*)sender {
    
    ForumReplyCommentEditViewController *reply = [self.storyboard instantiateViewControllerWithIdentifier:@"ForumReplyCommentEditViewController"];
    reply.nID = [[resultArray objectAtIndex:0]  objectForKey:@"nid"];
    reply.isEditComment = NO;
    reply.commentID = @"";
    reply.isReplyToComment = NO;
    [self.navigationController pushViewController:reply animated:NO];
}


#pragma mark - delete comment 

-(void)deleteCommentRequestSuccessfulWithResult:(NSString *)msg{
    [self stopProgressHUD];
    [self getForumDiscusionPICall];
    [self.expandableTableView reloadData];
    [Utility showMessage:@"Comment deleted successfully" withTitle:@""];
    
}
-(void)deleteCommentRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
    [Utility showMessage:error withTitle:@""];
}
@end
