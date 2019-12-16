//
//  BookMarksViewController.m
//  GSTSutra
//
//  Created by niyuj on 12/6/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import "BookMarksViewController.h"
#import "NewsTableViewCell.h"
#import "HeaderTableViewCell.h"
#import "NewsHeaderTableViewCell.h"
#import "ExpertTableViewCell.h"

#import "NewsHeaderTableViewCell.h"
#import "NewsTableViewCell.h"
#import "AdvertiseTableViewCell.h"
#import "ShortNewsViewController.h"
#import "HomeViewController.h"
#import "ExpertCornerRequest.h"
#import "ExpertLongViewController.h"
#import "NewRequest.h"
#import "AppData.h"
#import "UIImageView+WebCache.h"
#import "ShortNewsViewController.h"
#import "ExpertTableViewCell.h"
#import "videoTableViewCell.h"
#import "HeaderVideoTableViewCell.h"
#import "AdvertiseTableViewCell.h"
#import "NewRequest.h"
#import "videoPlayerViewController.h"
#import "UIImageView+WebCache.h"
#import "LongNewsViewController.h"

@interface BookMarksViewController ()<NewRequestDelegate,ExpertRequestDelegate>{
    NSMutableArray *bookmarkArray;
    NSString *lowerLimit,*upperLimit;
    BOOL isViewDidloadCall,noMoreItems;
    UIView *footerView;
    UIActivityIndicatorView *activityIndicator;
    NSArray  *bookmarkOfflineArray;
     BOOL stopPagination;
    
}

@property (weak, nonatomic) IBOutlet UITableView *bookmarkTableView;
@end

@implementation BookMarksViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [bookmarkArray removeAllObjects];
    if ([self checkReachability]) {
        [self getBookmarksAPICall];
    }
    else {
        [self stopProgressHUD];
        // [self noInternetAlert];
        [self setDataBaseDataToTable];
    }
    

}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBarTitleLabel:@"Bookmarks"];
    isViewDidloadCall = YES;
    stopPagination = YES;
    noMoreItems = NO;
    bookmarkArray = [[NSMutableArray alloc]init];
    bookmarkOfflineArray = [[NSArray alloc]init];
    lowerLimit = @"0";
    upperLimit = @"20";
    [self tableViewXibCellToLoad];
       //[self initFooterView];
}

#pragma mark - getBookmark Delegate 

-(void)getBookmarkRequestSuccessfulWithResult:(NSArray *)result{
    stopPagination = YES;
    [bookmarkArray addObjectsFromArray:result];
    [self storeDataIntoDataBase];
    [self.bookmarkTableView reloadData];
    [self performSelectorOnMainThread:@selector(stopAnimationForActivityIndicator) withObject:nil waitUntilDone:NO];
}

-(void)getBookmarkRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    noMoreItems = YES;
    stopPagination = NO;
    lowerLimit = @"0";
    upperLimit = @"20";
    [self.bookmarkTableView reloadData];
    //[Utility showMessage:error withTitle:@""];
    [self performSelectorOnMainThread:@selector(stopAnimationForActivityIndicator) withObject:nil waitUntilDone:NO];
    
    if (bookmarkArray.count == 0) {
        [Utility showMessage:@"No bookmarks available" withTitle:@""];
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
    [appD.database executeUpdate:@"DROP TABLE IF EXISTS `bookmarksTable`;"];
    [appD.database executeUpdate:@"create table IF NOT EXISTS bookmarksTable(news blob primary key)"];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:bookmarkArray];
    [appD.database executeUpdate:@"insert into bookmarksTable values (?)",data];
    FMResultSet *results = [appD.database executeQuery:@"select * from bookmarksTable"];
    while([results next]) {
        bookmarkOfflineArray = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:@"news"]];
        //NSLog(@"News Array from DB : %@ ",bookmarkOfflineArray);
    }
    [appD.database close];
}

-(void)setDataBaseDataToTable{
    [appD.database open];
    FMResultSet *results = [appD.database executeQuery:@"select * from bookmarksTable"];
    while([results next]) {
        bookmarkOfflineArray = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:@"news"]];
        //NSLog(@"News Array from DB : %@ ",bookmarkOfflineArray);
    }
    [bookmarkArray removeAllObjects];
    [bookmarkArray addObjectsFromArray:bookmarkOfflineArray];
    [self.bookmarkTableView reloadData];
    [appD.database close];
    
}


-(void)initFooterView
{
    footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, SCREENWIDTH, 40.0)];
    
    UIActivityIndicatorView * actInd = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    actInd.tag = 10;
    [actInd setColor:[UIColor redColor]];
    
    actInd.frame = CGRectMake(SCREENWIDTH / 2 - 20 , 5.0, 20.0, 20.0);
    
    actInd.hidesWhenStopped = YES;
    
    [footerView addSubview:actInd];
    
    actInd = nil;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //BOOL endOfTable = (scrollView.contentOffset.y >= ((bookmarkArray.count * 120) - scrollView.frame.size.height)); // Here 40 is row height
    self.bookmarkTableView.tableFooterView = footerView;
    [(UIActivityIndicatorView *)[footerView viewWithTag:10] startAnimating];
    
    //    if (self.hasMoreData && endOfTable && !self.isLoading && !scrollView.dragging && !scrollView.decelerating)
    //    {
    //        self.bookmarkTableView.tableFooterView = footerView;
    //
    //        [(UIActivityIndicatorView *)[footerView viewWithTag:10] startAnimating];
    //    }
    
}

-(void)getBookmarksAPICall{
    [self startProgressHUD];
    ExpertCornerRequest *req = [[ExpertCornerRequest alloc] init];
    req.delegate = self;
    [req getBookmarksWithLowerLimit:lowerLimit withUpperLimit:upperLimit];
}

-(void)tableViewXibCellToLoad{
    
    [self.bookmarkTableView registerNib:[UINib nibWithNibName:@"NewsTableViewCell" bundle:nil] forCellReuseIdentifier:@"NewsTableViewCell"];
    
    [self.bookmarkTableView registerNib:[UINib nibWithNibName:@"ExpertTableViewCell" bundle:nil] forCellReuseIdentifier:@"ExpertTableViewCell"];
    
    [self.bookmarkTableView registerNib:[UINib nibWithNibName:@"videoTableViewCell" bundle:nil] forCellReuseIdentifier:@"videoTableViewCell"];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [bookmarkArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *NewscellIdentifier = @"NewsTableViewCell";
    NewsTableViewCell *Newscell = (NewsTableViewCell*)[tableView dequeueReusableCellWithIdentifier:NewscellIdentifier];
    
    static NSString *expertCellIdentifier = @"ExpertTableViewCell";
    ExpertTableViewCell *expertCell = (ExpertTableViewCell*)[tableView dequeueReusableCellWithIdentifier:expertCellIdentifier];
    
    static NSString *videoCellIdentifier = @"videoTableViewCell";
    videoTableViewCell *videoCell = (videoTableViewCell*)[tableView dequeueReusableCellWithIdentifier:videoCellIdentifier];
    
    Newscell.selectionStyle = UITableViewCellSelectionStyleNone;
    expertCell.selectionStyle = UITableViewCellSelectionStyleNone;
    videoCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // Cell display on the basis of type
    
    @try {
        if ([[[bookmarkArray objectAtIndex:indexPath.row] objectForKey:@"story_type"] integerValue] == 8) {
            NSString *newsImageUrl = [[NSString stringWithFormat:@"%@",ImageSERVER_API] stringByAppendingString:[[bookmarkArray objectAtIndex:indexPath.row] objectForKey:@"image"]];
            
            [Newscell.NewsImageView sd_setImageWithURL:[NSURL URLWithString:[newsImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]placeholderImage:[UIImage imageNamed:@"userimage.png"]];
            Newscell.NewsTitleLabel.text = [[bookmarkArray objectAtIndex:indexPath.row] objectForKey:@"headline"];
            Newscell.NewsTitleLabel.font = [UIFont fontWithName:centuryGothicBold size:titleFont];
            Newscell.NewsDetailLabel.text = [[bookmarkArray objectAtIndex:indexPath.row] objectForKey:@"shortview"];
            Newscell.NewDateLabel.text = [[bookmarkArray objectAtIndex:indexPath.row] objectForKey:@"date"];
            return Newscell;
            
        } else if ([[[bookmarkArray objectAtIndex:indexPath.row] objectForKey:@"story_type"] integerValue] == 9){
            
            
            NSString *newsImageUrl = [[NSString stringWithFormat:@"%@",ImageSERVER_API] stringByAppendingString:[[bookmarkArray objectAtIndex:indexPath.row] objectForKey:@"image"]];
            
            // Here we use the new provided sd_setImageWithURL: method to load the web image
            [expertCell.NewsImageView sd_setImageWithURL:[NSURL URLWithString:[newsImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]placeholderImage:[UIImage imageNamed:@"userimage.png"]];
            expertCell.NewsImageView.layer.cornerRadius=Newscell.NewsImageView.frame.size.width/2;
            expertCell.NewsImageView.layer.borderWidth = 1.0f;
            expertCell.NewsImageView.layer.masksToBounds = YES;
            
            
            [expertCell.NewsTitleLabel setFont:[UIFont fontWithName:centuryGothicBold size:titleFont]];
            NSString *yourString = [[[[bookmarkArray objectAtIndex:indexPath.row] objectForKey:@"headline"] stringByAppendingString:@"\n\n"] stringByAppendingString:[[bookmarkArray objectAtIndex:indexPath.row] objectForKey:@"expert_name"]];
            NSMutableAttributedString *yourAttributedString = [[NSMutableAttributedString alloc] initWithString:yourString];
            NSString *boldString = [[bookmarkArray objectAtIndex:indexPath.row] objectForKey:@"expert_name"];
            NSRange boldRange = [yourString rangeOfString:boldString];
            [yourAttributedString addAttribute: NSFontAttributeName value:[UIFont fontWithName:centuryGothicRegular size:titleFont] range:boldRange];
            [expertCell.NewsTitleLabel setAttributedText: yourAttributedString];
            
            expertCell.NewsDetailLabel.text = [[bookmarkArray objectAtIndex:indexPath.row] objectForKey:@"expert_name"];
            expertCell.NewDateLabel.text = [[bookmarkArray objectAtIndex:indexPath.row] objectForKey:@"date"];
            
            return expertCell;
            
        } else{
            videoCell.videoTitleLabel.text = [[bookmarkArray objectAtIndex:indexPath.row] objectForKey:@"event_title"];
            videoCell.videoTitleLabel.font = [UIFont fontWithName:centuryGothicBold size:titleFont];
            videoCell.videoDateLabel.text = [[bookmarkArray objectAtIndex:indexPath.row] objectForKey:@"my_timestamp"];
            [videoCell.videoThumbnailImageView sd_setImageWithURL:[NSURL URLWithString:[self getYoutubeVideoThumbnail:[[bookmarkArray objectAtIndex:indexPath.row] objectForKey:@"event_code"]]]placeholderImage:[UIImage imageNamed:@"userimage.png"]];
            
            
            
            return videoCell;
        }

    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

//-(NSString*)getYoutubeVideoThumbnail:(NSString*)youTubeUrl
//{
//    NSString* video_id = @"";
//    
//    if (youTubeUrl.length > 0)
//    {
//        NSError *error = NULL;
//        NSRegularExpression *regex =
//        [NSRegularExpression regularExpressionWithPattern:@"(?<=watch\\?v=|/videos/|embed\\/)[^#\\&\\?]*"
//                                                  options:NSRegularExpressionCaseInsensitive
//                                                    error:&error];
//        NSTextCheckingResult *match = [regex firstMatchInString:youTubeUrl
//                                                        options:0
//                                                          range:NSMakeRange(0, [youTubeUrl length])];
//        if (match)
//        {
//            NSRange videoIDRange = [match rangeAtIndex:0];
//            video_id = [youTubeUrl substringWithRange:videoIDRange];
//            
//            //NSLog(@"%@",video_id);
//        }
//    }
//    
//    NSString* thumbImageUrl = [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/maxresdefault.jpg",video_id];
//    
//    return thumbImageUrl;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self checkReachability]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if ([[[bookmarkArray objectAtIndex:indexPath.row] objectForKey:@"story_type"] integerValue] == 8) {
            
            LongNewsViewController *shortView = [self.storyboard instantiateViewControllerWithIdentifier:@"LongNewsViewController"];
            shortView.selectedIndex =  indexPath.row ;
            shortView.longViewNewsArray = [bookmarkArray mutableCopy];
            [self.navigationController pushViewController:shortView animated:YES];
        } else if ([[[bookmarkArray objectAtIndex:indexPath.row] objectForKey:@"story_type"] integerValue] == 9) {
            
            ExpertLongViewController *shortView = [self.storyboard instantiateViewControllerWithIdentifier:@"ExpertLongViewController"];
            shortView.selectedIndex =  indexPath.row ;
            shortView.expertLongViewNewsArray = [bookmarkArray mutableCopy];
            [self.navigationController pushViewController:shortView animated:YES];
            
        } else {
            videoPlayerViewController *vPlayer = [self.storyboard instantiateViewControllerWithIdentifier:@"videoPlayerViewController"];
            vPlayer.selectedIndex = indexPath.row;
            vPlayer.videoPlayerArray = bookmarkArray;
            vPlayer.isFromBookmarks = YES;
            [self.navigationController pushViewController:vPlayer animated:YES];
        }

    } else {
        [self noInternetAlert];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 126;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    //NSLog(@"indexpath %ld",(long)indexPath.row);
    
    if (stopPagination) {
        if (indexPath.row > 15) {
            if (indexPath.row >  [bookmarkArray count] -2) {
                //NSLog(@"Bookmark api call");
                lowerLimit = upperLimit;
                upperLimit = [NSString stringWithFormat:@"%ld",([upperLimit integerValue] + 20)];
                [self getBookmarksAPICall];
                
            }
        }
    }
}

@end
