//
//  searchAllTypesViewController.m
//  GSTSutra
//
//  Created by niyuj on 1/23/17.
//  Copyright © 2017 niyuj. All rights reserved.
//

#import "searchAllTypesViewController.h"

#import "SearchRequestDelegate.h"

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
#import "ExpertTakesTableViewCell.h"
#import "FAQHeaderTableViewCell.h"
#import "ExpertTakeLngViewController.h"
#import "FAQDetailViewController.h"
@interface searchAllTypesViewController ()<SearchRequestDelegateMethod,UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray *dataArray;
    NSString *lowerLimit,*upperLimit;
    BOOL isViewDidloadCall,noMoreItems;
    UIView *footerView;
    UIActivityIndicatorView *activityIndicator;
    BOOL stopPagination;
    
}
@property (weak, nonatomic) IBOutlet UITableView *searchAllTableview;

@end

@implementation searchAllTypesViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSearchTextNotification:)name:@"searchNotificationWithText" object:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    dataArray = [[NSMutableArray alloc] init];
    [self.searchAllTableview registerNib:[UINib nibWithNibName:@"NewsTableViewCell" bundle:nil] forCellReuseIdentifier:@"NewsTableViewCell"];
    
    [self.searchAllTableview registerNib:[UINib nibWithNibName:@"ExpertTableViewCell" bundle:nil] forCellReuseIdentifier:@"ExpertTableViewCell"];
    
    [self.searchAllTableview registerNib:[UINib nibWithNibName:@"videoTableViewCell" bundle:nil] forCellReuseIdentifier:@"videoTableViewCell"];
    
     [self.searchAllTableview registerNib:[UINib nibWithNibName:@"ExpertTakesTableViewCell" bundle:nil] forCellReuseIdentifier:@"ExpertTakesTableViewCell"];
    
    [self.searchAllTableview registerNib:[UINib nibWithNibName:@"FAQHeaderTableViewCell" bundle:nil] forCellReuseIdentifier:@"FAQHeaderTableViewCell"];
    
    self.searchAllTableview.delegate = self;
    self.searchAllTableview.dataSource = self;
    
    
}

#pragma mark - NSNotification Center

- (void) receiveSearchTextNotification:(NSNotification *) notification{
    
    if ([notification.name isEqualToString:@"searchNotificationWithText"]){
        
        NSDictionary* userInfo = notification.userInfo;
        
        if ([self checkReachability]) {
            
            //[self searchAPICallWithText:(NSString*)userInfo[@"searchString"]];
            
            NSMutableArray * temp = [[NSMutableArray alloc] init];
            temp = [(NSMutableArray*)userInfo[@"searchString"] mutableCopy];

            [dataArray removeAllObjects];
            
            for (int i = 0; i< [temp count]; i++) {
                if ([[[temp objectAtIndex:i] objectForKey:@"story_type"] integerValue] == 25) {
                    [dataArray addObject:[[temp mutableCopy] objectAtIndex:i]];
                } else if ([[[temp objectAtIndex:i] objectForKey:@"story_type"] integerValue] == 8) {
                    [dataArray addObject:[[temp mutableCopy] objectAtIndex:i]];
                }else if ([[[temp objectAtIndex:i] objectForKey:@"story_type"] integerValue] == 9) {
                    [dataArray addObject:[[temp mutableCopy] objectAtIndex:i]];
                }else if ([[[temp objectAtIndex:i] objectForKey:@"story_type"] integerValue] == 11) {
                    [dataArray addObject:[[temp mutableCopy] objectAtIndex:i]];
                }else if ([[[temp objectAtIndex:i] objectForKey:@"story_type"] integerValue] == 24) {
                    [dataArray addObject:[[temp mutableCopy] objectAtIndex:i]];
                }
                
            }
            
            
            
            [self.searchAllTableview reloadData];
//            if (dataArray.count == 0) {
//                [Utility showMessage:@"No Record's found." withTitle:@""];
//            }

            
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
        if ([[[result objectAtIndex:i] objectForKey:@"story_type"] integerValue] == 25) {
            [dataArray addObject:[[result mutableCopy] objectAtIndex:i]];
        } else if ([[[result objectAtIndex:i] objectForKey:@"story_type"] integerValue] == 8) {
            [dataArray addObject:[[result mutableCopy] objectAtIndex:i]];
        }else if ([[[result objectAtIndex:i] objectForKey:@"story_type"] integerValue] == 9) {
            [dataArray addObject:[[result mutableCopy] objectAtIndex:i]];
        } else if ([[[result objectAtIndex:i] objectForKey:@"story_type"] integerValue] == 11) {
            [dataArray addObject:[[result mutableCopy] objectAtIndex:i]];
        }else if ([[[result objectAtIndex:i] objectForKey:@"story_type"] integerValue] == 24) {
            [dataArray addObject:[[result mutableCopy] objectAtIndex:i]];
        }
        
    }
    
    
    [self.searchAllTableview reloadData];
    
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
    
    return [dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *NewscellIdentifier = @"NewsTableViewCell";
    NewsTableViewCell *Newscell = (NewsTableViewCell*)[tableView dequeueReusableCellWithIdentifier:NewscellIdentifier];
    
    static NSString *expertCellIdentifier = @"ExpertTableViewCell";
    ExpertTableViewCell *expertCell = (ExpertTableViewCell*)[tableView dequeueReusableCellWithIdentifier:expertCellIdentifier];
    
    static NSString *videoCellIdentifier = @"videoTableViewCell";
    videoTableViewCell *videoCell = (videoTableViewCell*)[tableView dequeueReusableCellWithIdentifier:videoCellIdentifier];
    
    static NSString *expertTakecellIdentifier = @"ExpertTakeTableviewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:expertTakecellIdentifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:expertTakecellIdentifier];
    }
    
    static NSString *cellid=@"FAQHeaderCell";
    UITableViewCell *faqcell=[tableView dequeueReusableCellWithIdentifier:cellid];
    if (faqcell==nil) {
        faqcell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
    }

    
    Newscell.selectionStyle = UITableViewCellSelectionStyleNone;
    expertCell.selectionStyle = UITableViewCellSelectionStyleNone;
    videoCell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    faqcell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // Cell display on the basis of type
    
    @try {
        if ([[[dataArray objectAtIndex:indexPath.row] objectForKey:@"story_type"] integerValue] == 8) {
            NSString *newsImageUrl = [[NSString stringWithFormat:@"%@",ImageSERVER_API] stringByAppendingString:[[dataArray objectAtIndex:indexPath.row] objectForKey:@"image"]];
            
            [Newscell.NewsImageView sd_setImageWithURL:[NSURL URLWithString:[newsImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]placeholderImage:[UIImage imageNamed:@"userimage.png"]];
            Newscell.NewsTitleLabel.text = [[dataArray objectAtIndex:indexPath.row] objectForKey:@"headline"];
            [Newscell.NewsTitleLabel setFont:[UIFont fontWithName:centuryGothicBold size:titleFont]];
            Newscell.NewsDetailLabel.text = [[dataArray objectAtIndex:indexPath.row] objectForKey:@"shortview"];
            Newscell.NewDateLabel.text = [[dataArray objectAtIndex:indexPath.row] objectForKey:@"date"];
            return Newscell;
            
        } else if ([[[dataArray objectAtIndex:indexPath.row] objectForKey:@"story_type"] integerValue] == 9){
            
            
            NSString *newsImageUrl = [[NSString stringWithFormat:@"%@",ImageSERVER_API] stringByAppendingString:[[dataArray objectAtIndex:indexPath.row] objectForKey:@"image"]];
            
            // Here we use the new provided sd_setImageWithURL: method to load the web image
            [expertCell.NewsImageView sd_setImageWithURL:[NSURL URLWithString:[newsImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]placeholderImage:[UIImage imageNamed:@"userimage.png"]];
            expertCell.NewsImageView.layer.cornerRadius=Newscell.NewsImageView.frame.size.width/2;
            expertCell.NewsImageView.layer.borderWidth = 1.0f;
            expertCell.NewsImageView.layer.masksToBounds = YES;
            
            [expertCell.NewsTitleLabel setFont:[UIFont fontWithName:centuryGothicBold size:titleFont]];
            NSString *yourString = [[[[dataArray objectAtIndex:indexPath.row] objectForKey:@"headline"] stringByAppendingString:@"\n\n"] stringByAppendingString:[[dataArray objectAtIndex:indexPath.row] objectForKey:@"expert_name"]];
            NSMutableAttributedString *yourAttributedString = [[NSMutableAttributedString alloc] initWithString:yourString];
            NSString *boldString = [[dataArray objectAtIndex:indexPath.row] objectForKey:@"expert_name"];
            NSRange boldRange = [yourString rangeOfString:boldString];
            [yourAttributedString addAttribute: NSFontAttributeName value:[UIFont fontWithName:centuryGothicRegular size:titleFont] range:boldRange];
            [expertCell.NewsTitleLabel setAttributedText: yourAttributedString];
            
            expertCell.NewsDetailLabel.text = [[dataArray objectAtIndex:indexPath.row] objectForKey:@"expert_name"];
            expertCell.NewDateLabel.text = [[dataArray objectAtIndex:indexPath.row] objectForKey:@"date"];
            
            return expertCell;
            
        } else if ([[[dataArray objectAtIndex:indexPath.row] objectForKey:@"story_type"] integerValue] == 11){
            
            // Configure Cell
            UILabel *label = (UILabel *)[cell.contentView viewWithTag:10];
            label.text = [[dataArray objectAtIndex:indexPath.row] objectForKey:@"title"];
            
            [label setFont:[UIFont fontWithName:centuryGothicBold size:titleFont]];
            
            return cell;
            
            
        }else if ([[[dataArray objectAtIndex:indexPath.row] objectForKey:@"story_type"] integerValue] == 24){
            UILabel *queLabel = (UILabel*)[faqcell viewWithTag:1];
            UILabel *queDisLabel = (UILabel*)[faqcell viewWithTag:2];
            queLabel.text = @"  Q";
            //        queDisLabel.text = [[dataArray objectAtIndex:indexPath.row] objectForKey:@"question"];
            
            queDisLabel.attributedText = [[NSAttributedString alloc] initWithData:[[[dataArray objectAtIndex:indexPath.row] objectForKey:@"question"] dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]} documentAttributes:nil error:nil];
            
            queLabel.font = [UIFont fontWithName:centuryGothicBold size:titleFont];
            queDisLabel.font = [UIFont fontWithName:centuryGothicBold size:titleFont];
            cell.contentView.backgroundColor = [UIColor whiteColor];
            queDisLabel.lineBreakMode = NSLineBreakByWordWrapping;
            return faqcell;
        }else{
            videoCell.videoTitleLabel.text = [[dataArray objectAtIndex:indexPath.row] objectForKey:@"event_title"];
            videoCell.videoTitleLabel.font = [UIFont fontWithName:centuryGothicBold size:titleFont];
            
            videoCell.videoDateLabel.text = [[dataArray objectAtIndex:indexPath.row] objectForKey:@"my_timestamp"];
            [videoCell.videoThumbnailImageView sd_setImageWithURL:[NSURL URLWithString:[self getYoutubeVideoThumbnail:[[dataArray objectAtIndex:indexPath.row] objectForKey:@"event_code"]]]placeholderImage:[UIImage imageNamed:@"userimage.png"]];
            
            
            
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
        if ([[[dataArray objectAtIndex:indexPath.row] objectForKey:@"story_type"] integerValue] == 8) {
            LongNewsViewController *shortView = [self.storyboard instantiateViewControllerWithIdentifier:@"LongNewsViewController"];
            shortView.selectedIndex =  indexPath.row ;
            shortView.longViewNewsArray = [dataArray mutableCopy];
            [self.navigationController pushViewController:shortView animated:YES];
        } else if ([[[dataArray objectAtIndex:indexPath.row] objectForKey:@"story_type"] integerValue] == 9) {
            
            ExpertLongViewController *shortView = [self.storyboard instantiateViewControllerWithIdentifier:@"ExpertLongViewController"];
            shortView.selectedIndex =  indexPath.row ;
            shortView.expertLongViewNewsArray = [dataArray mutableCopy];
            [self.navigationController pushViewController:shortView animated:YES];
            
        }else if ([[[dataArray objectAtIndex:indexPath.row] objectForKey:@"story_type"] integerValue] == 11) {
            
            ExpertTakeLngViewController *expertTalk = [self.storyboard instantiateViewControllerWithIdentifier:@"ExpertTakeLngViewController"];
            expertTalk.selectedIndex = indexPath.row;
            expertTalk.expertTakeArray = [dataArray mutableCopy];
            [self.navigationController pushViewController:expertTalk animated:YES];
            
        }else if ([[[dataArray objectAtIndex:indexPath.row] objectForKey:@"story_type"] integerValue] == 24) {
            
            FAQDetailViewController *shortView = [self.storyboard instantiateViewControllerWithIdentifier:@"FAQDetailViewController"];
            shortView.QueString =  [[dataArray objectAtIndex:indexPath.row] objectForKey:@"question"];
            shortView.AnsString = [[dataArray objectAtIndex:indexPath.row] objectForKey:@"answer"];
            [self.navigationController pushViewController:shortView animated:YES];
            
        } else if ([[[dataArray objectAtIndex:indexPath.row] objectForKey:@"story_type"] integerValue] == 25){
            videoPlayerViewController *vPlayer = [self.storyboard instantiateViewControllerWithIdentifier:@"videoPlayerViewController"];
            vPlayer.selectedIndex = indexPath.row;
            vPlayer.videoPlayerArray = dataArray;
            vPlayer.isFromBookmarks = YES;
            [self.navigationController pushViewController:vPlayer animated:YES];
        }
        
    } else {
        [self noInternetAlert];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([[[dataArray objectAtIndex:indexPath.row] objectForKey:@"story_type"] integerValue] == 24) {
        NSString *str = [[dataArray objectAtIndex:indexPath.row] objectForKey:@"question"];
        
        CGRect textRect = [str boundingRectWithSize:CGSizeMake(SCREENWIDTH, 999)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName:[UIFont fontWithName:centuryGothicBold size:titleFont]}
                                            context:nil];
        
        CGSize size = textRect.size;
        
        return size.height + 30;
    } else if ([[[dataArray objectAtIndex:indexPath.row] objectForKey:@"story_type"] integerValue] == 11) {
        NSString *str = [[dataArray objectAtIndex:indexPath.row] objectForKey:@"title"];
        
        CGRect textRect = [str boundingRectWithSize:CGSizeMake(SCREENWIDTH, 999)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName:[UIFont fontWithName:centuryGothicBold size:14]}
                                            context:nil];
        
        CGSize size = textRect.size;
        
        return size.height + 30;
    }else {
    return 126;
    }
}


@end
