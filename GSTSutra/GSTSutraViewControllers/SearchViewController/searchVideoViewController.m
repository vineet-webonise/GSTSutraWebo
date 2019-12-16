//
//  searchVideoViewController.m
//  GSTSutra
//
//  Created by niyuj on 1/19/17.
//  Copyright © 2017 niyuj. All rights reserved.
//

#import "searchVideoViewController.h"
#import "videoTableViewCell.h"
#import "HeaderVideoTableViewCell.h"
#import "AdvertiseTableViewCell.h"
#import "NewRequest.h"
#import "videoPlayerViewController.h"
#import "UIImageView+WebCache.h"
#import "SearchRequestDelegate.h"

@interface searchVideoViewController ()<SearchRequestDelegateMethod>{
    NSMutableArray *videosArray;
}
@property (weak, nonatomic) IBOutlet UITableView *videoTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBarControl;

@end

@implementation searchVideoViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSearchTextNotification:)name:@"searchNotificationWithText" object:nil];
    
    NSMutableArray * temp = [[NSMutableArray alloc] initWithArray:[self.searchResultArray mutableCopy]];
    [videosArray removeAllObjects];
    for (int i = 0; i< [temp count]; i++) {
        if ([[[temp objectAtIndex:i] objectForKey:@"story_type"] integerValue] == 25) {
            [videosArray addObject:[[temp mutableCopy] objectAtIndex:i]];
        }
    }
    
    [self.videoTableView reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    videosArray = [[NSMutableArray alloc] init];
    [self.videoTableView registerNib:[UINib nibWithNibName:@"videoTableViewCell" bundle:nil] forCellReuseIdentifier:@"videoTableViewCell"];
    [self.videoTableView registerNib:[UINib nibWithNibName:@"HeaderVideoTableViewCell" bundle:nil] forCellReuseIdentifier:@"HeaderVideoTableViewCell"];
    [self.videoTableView registerNib:[UINib nibWithNibName:@"AdvertiseTableViewCell" bundle:nil] forCellReuseIdentifier:@"AdvertiseTableViewCell"];
}

#pragma mark - NSNotification Center

- (void) receiveSearchTextNotification:(NSNotification *) notification{
    
    if ([notification.name isEqualToString:@"searchNotificationWithText"]){
        
        NSDictionary* userInfo = notification.userInfo;
        
        if ([self checkReachability]) {
            
            //[self searchAPICallWithText:(NSString*)userInfo[@"searchString"]];
            NSMutableArray * temp = [[NSMutableArray alloc] init];
            temp = [(NSMutableArray*)userInfo[@"searchString"] mutableCopy];
            [videosArray removeAllObjects];
            for (int i = 0; i< [temp count]; i++) {
                if ([[[temp objectAtIndex:i] objectForKey:@"story_type"] integerValue] == 25) {
                    [videosArray addObject:[[temp mutableCopy] objectAtIndex:i]];
                }
            }
            
            [self.videoTableView reloadData];
//            if (videosArray.count == 0) {
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
    [videosArray removeAllObjects];
    for (int i = 0; i< [result count]; i++) {
        if ([[[result objectAtIndex:i] objectForKey:@"story_type"] integerValue] == 25) {
            [videosArray addObject:[[result mutableCopy] objectAtIndex:i]];
        }
    }
    
    [self.videoTableView reloadData];
    
}
-(void)searchRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
    [Utility showMessage:error withTitle:@""];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [videosArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    

    static NSString *NewscellIdentifier = @"videoTableViewCell";
    videoTableViewCell *Newscell = (videoTableViewCell*)[tableView dequeueReusableCellWithIdentifier:NewscellIdentifier];
    
    @try {
        Newscell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        Newscell.videoTitleLabel.text = [[videosArray objectAtIndex:indexPath.row] objectForKey:@"event_title"];
        Newscell.videoTitleLabel.font = [UIFont fontWithName:centuryGothicBold size:titleFont];
        Newscell.videoDateLabel.text = [[videosArray objectAtIndex:indexPath.row] objectForKey:@"my_timestamp"];
        [Newscell.videoThumbnailImageView sd_setImageWithURL:[NSURL URLWithString:[self getYoutubeVideoThumbnail:[[videosArray objectAtIndex:indexPath.row] objectForKey:@"event_code"]]]placeholderImage:[UIImage imageNamed:@"userimage.png"]];
        
        return Newscell;

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
    videoPlayerViewController *vPlayer = [self.storyboard instantiateViewControllerWithIdentifier:@"videoPlayerViewController"];
    vPlayer.selectedIndex = indexPath.row;
    vPlayer.videoPlayerArray = videosArray;
    [self.navigationController pushViewController:vPlayer animated:YES];
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
            return 132;
    
}

@end
