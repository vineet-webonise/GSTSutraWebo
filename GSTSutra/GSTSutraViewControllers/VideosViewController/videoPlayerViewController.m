//
//  videoPlayerViewController.m
//  GSTSutra
//
//  Created by niyuj on 12/26/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import "videoPlayerViewController.h"
#import "NewRequest.h"

//share
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
#import "WASWhatsAppUtil.h"
#import <SafariServices/SafariServices.h>
#import "shareView.h"
#import "shareCollectionViewCell.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <AVFoundation/AVFoundation.h>

typedef enum{
    kSendText = 0,
    kSendImage,
    kSendTextWithImage,
    kSendAudio,
    kSendCancel
} options;

@interface videoPlayerViewController ()<YTPlayerViewDelegate,UIGestureRecognizerDelegate,NewRequestDelegate,UITextViewDelegate,UIScrollViewDelegate,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate,UIActionSheetDelegate,UIDocumentInteractionControllerDelegate,SFSafariViewControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>{
    NSMutableArray *temp;
    NSString *postString,*rateValueString,*shareString,*dbBookmarkValue,*dbLikeValue,*dbLikeCountValue;
    NSMutableArray *relatedStoryArray,*commnetsArray;
    UIScrollView *helpScrollView;
    NSMutableArray *imagesArray;
    UIDocumentInteractionController *docControll;
    shareView *share;
    NSArray *shareIconArray;
}
- (IBAction)bookmarkButtonClicked:(id)sender;
- (IBAction)likeButtonClicked:(id)sender;
- (IBAction)shareButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *bookmarkButton;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;


@end

@implementation videoPlayerViewController

// Notification

-(void)notificationAPICall{
    [self stopProgressHUD];
    //[self startProgressHUD];
    if ([self checkReachability]) {
        appD.isFromNotification = NO;
        //[self startProgressHUD];
        NewRequest *req = [[NewRequest alloc] init];
        req.delegate=self;
        [req getNotificationNewsWithStoryId:appD.sid withStoryType:@"25"];
    }
    else {
        [self stopProgressHUD];
        [self noInternetAlert];
    }
    
}

-(void)newsNotificationRequestSuccessfulWithResult:(NSArray *)result{
    [self stopProgressHUD];
    self.videoPlayerArray = [result mutableCopy];
    self.selectedIndex = 0;
    [self.playerView loadWithVideoId:[self extractYoutubeIdFromLink:[[self.videoPlayerArray objectAtIndex:self.selectedIndex]objectForKey:@"event_code"]]];
}
-(void)newsNotificationRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.isPresented = YES;
    [self.view bringSubviewToFront:self.bookmarkButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationBarTitleLabel:@"GSTtube"];
    [self videoViewCountAPI];
     [self setupLocalDBData];
    
    //NSLog(@"Data Array %@",_videoPlayerArray);
    ////NSLog(@"Selected index %ld",(long)_selectedIndex);
    
    @try {
        
        
        [self setupBackBarButtonItems];
        self.playerView.delegate = self;
        
        [self.view setBackgroundColor:[UIColor blackColor]];
        //[self.playerView loadWithVideoId:[self extractYoutubeIdFromLink:[[self.videoPlayerArray objectAtIndex:self.selectedIndex]objectForKey:@"event_code"]]];
        temp = [[NSMutableArray alloc] init];
        self.playerView.delegate = self;
        
        if (appD.isFromNotification) {
            [self notificationAPICall];
            
        } else
        {
            
            if (!_isFromBookmarks) {
                
                for (int i =0; i<self.videoPlayerArray.count; i++) {
                    [temp addObject:[self extractYoutubeIdFromLink:[[self.videoPlayerArray objectAtIndex:i]objectForKey:@"event_code"]]];
                }
            }
            
            
            NSDictionary *playerVars = @{
                                         @"controls" : @1,
                                         @"playsinline" : @1,
                                         @"autohide" : @0,
                                         @"autoplay" : @1,
                                         @"modestbranding" : @0,
                                         @"rel" : @0,
                                         };
            
            if (_isFromBookmarks) {
                [self.playerView loadWithVideoId:[self extractYoutubeIdFromLink:[[self.videoPlayerArray objectAtIndex:self.selectedIndex]objectForKey:@"event_code"]]];
                
            } else {
                [self.playerView loadWithPlaylistId:[self extractYoutubeIdFromLink:[[self.videoPlayerArray objectAtIndex:self.selectedIndex]objectForKey:@"event_code"]] playerVars:playerVars];
            }
        }
        [self.playerView playVideo];
       
        [self shareDataSetUp];

    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}


-(void)setupLocalDBData{
    @try {
        [self setBookmarkImageWithSid:[NSString stringWithFormat:@"%@",[[self.videoPlayerArray objectAtIndex:self.selectedIndex] objectForKey:@"id"]] withBookmarkType:[NSString stringWithFormat:@"%@",@"25"]];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                               error:nil];
        
        if ([dbBookmarkValue isEqualToString:@"1"]) {
            //Bookmark Selected image set
            [self.bookmarkButton setImage:[UIImage imageNamed:@"bookmark_p"] forState:UIControlStateNormal];
            dbBookmarkValue = @"";
        } else {
            // Not select
            [self.bookmarkButton setImage:[UIImage imageNamed:@"bookmark_n"] forState:UIControlStateNormal];
        }
        
        
        [self setBookmarkImageWithSid:[NSString stringWithFormat:@"%@",[[self.videoPlayerArray objectAtIndex:self.selectedIndex] objectForKey:@"id"]] withBookmarkType:[NSString stringWithFormat:@"%@",@"25"]];
        
        if ([dbBookmarkValue isEqualToString:@"1"]) {
            //Bookmark Selected image set
            [self.bookmarkButton setImage:[UIImage imageNamed:@"bookmark_p"] forState:UIControlStateNormal];
            dbBookmarkValue = @"";
        } else {
            // Not select
            [self.bookmarkButton setImage:[UIImage imageNamed:@"bookmark_n"] forState:UIControlStateNormal];
        }
        
        [self setLikeImageWithSid:[NSString stringWithFormat:@"%@",[[self.videoPlayerArray objectAtIndex:self.selectedIndex] objectForKey:@"id"]] withBookmarkType:[NSString stringWithFormat:@"%@",@"25"]];
        
        if ([dbLikeValue isEqualToString:@"1"]) {
            //Bookmark Selected image set
            [self.likeButton setImage:[UIImage imageNamed:@"like_p"] forState:UIControlStateNormal];
            dbLikeValue = @"";
        } else {
            // Not select
            [self.likeButton setImage:[UIImage imageNamed:@"like_n"] forState:UIControlStateNormal];
        }
        
        [self updateLikeCountWithSid:[NSString stringWithFormat:@"%@",[[self.videoPlayerArray objectAtIndex:self.selectedIndex] objectForKey:@"id"]] withNewsType:[NSString stringWithFormat:@"%@",@"25"] withLikeCount:[NSString stringWithFormat:@"%@",[[self.videoPlayerArray objectAtIndex:self.selectedIndex] objectForKey:@"likes_count"]]];
        
        
        [self setLikeCountToLabelWithSid:[NSString stringWithFormat:@"%@",[[self.videoPlayerArray objectAtIndex:self.selectedIndex] objectForKey:@"id"]] withNewsType:[NSString stringWithFormat:@"%@",@"25"]];
        
        
        if ([dbLikeCountValue isEqualToString:@"0"]) {
            self.likeCountLabel.text = @"";
        } else {
            self.likeCountLabel.text = dbLikeCountValue;
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}
-(void)playerViewDidBecomeReady:(YTPlayerView *)playerView{
    [self.playerView cuePlaylistByVideos:temp index:self.selectedIndex startSeconds:0.0 suggestedQuality:kYTPlaybackQualityLarge];
}

-(void)videoViewCountAPI{
    
    if ([self checkReachability]) {
        
        NewRequest *req = [[NewRequest alloc] init];
        req.delegate = self;
        [req setYouTubeVideoViewCountWithID:[NSString stringWithFormat:@"%@",[[self.videoPlayerArray objectAtIndex:self.selectedIndex] objectForKey:@"id"]]];
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.isPresented = NO;
}

- (NSString *)extractYoutubeIdFromLink:(NSString *)link {
    
    NSString *regexString = @"((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)";
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:regexString
                                                                            options:NSRegularExpressionCaseInsensitive
                                                                              error:nil];
    
    NSArray *array = [regExp matchesInString:link options:0 range:NSMakeRange(0,link.length)];
    if (array.count > 0) {
        NSTextCheckingResult *result = array.firstObject;
        return [link substringWithRange:result.range];
    }
    return nil;
}

//- (IBAction)bookmarkButtonClicked:(id)sender {
//    NewRequest *req = [[NewRequest alloc]init];
//    req.delegate = self;
//    
//    if ([[sender imageForState:UIControlStateNormal] isEqual:[UIImage imageNamed:@"bookmark_n"]]){
//        [sender setImage:[UIImage imageNamed:@"bookmark_p"] forState:UIControlStateNormal];
//        
//        if ([self checkReachability]) {
//            [self startProgressHUD];
//            [req bookMarkNewsWithStoryId: [[self.videoPlayerArray objectAtIndex:self.selectedIndex] objectForKey:@"id"] withStoryType:@"25" withBookmarkValue:@"1"];
//        }
//        else {
//            [self stopProgressHUD];
//            [self noInternetAlert];
//        }
//    } else{
//        [sender setImage:[UIImage imageNamed:@"bookmark_n"] forState:UIControlStateNormal];
//        if ([self checkReachability]) {
//            [self startProgressHUD];
//            [req bookMarkNewsWithStoryId: [[self.videoPlayerArray objectAtIndex:self.selectedIndex] objectForKey:@"id"] withStoryType:@"25" withBookmarkValue:@"0"];
//        }
//        else {
//            [self stopProgressHUD];
//            [self noInternetAlert];
//        }
//        
//    }
//    
//}
//
//-(void)bookmarkNewsRequestSuccessfulWithStatus:(NSString *)status{
//    
//    [self updateBookmarkWithSid:[NSString stringWithFormat:@"%@",[[self.videoPlayerArray objectAtIndex:self.selectedIndex] objectForKey:@"id"]] withBookmarkType:[NSString stringWithFormat:@"%@",@"25"]];
//    [self stopProgressHUD];
//    
//}
//
//-(void)setBookmarkImageWithSid:(NSString*)Bsid withBookmarkType : (NSString *)Btype{
//    [appD.database open];
//    
//    NSString *tempQuery  = [[[@"select isBookmark from userBookmarksTable Where type = " stringByAppendingString:Btype] stringByAppendingString: @" and id = "] stringByAppendingString:Bsid];
//    
//    FMResultSet *results = [appD.database executeQuery:tempQuery];
//    while([results next]) {
//        dbBookmarkValue = [results stringForColumn:@"isBookmark"];
//    }
//}
//-(void)updateBookmarkWithSid:(NSString*)Bsid withBookmarkType : (NSString *)Btype{
//    BOOL resultSuccess = NO;
//    NSString *tempResult = @"";
//    [appD.database open];
//    
//    NSString *tempQuery  = [[[@"select isBookmark from userBookmarksTable Where type = " stringByAppendingString:Btype] stringByAppendingString: @" and id = "] stringByAppendingString:Bsid];
//    
//    FMResultSet *results = [appD.database executeQuery:tempQuery];
//    while([results next]) {
//        resultSuccess = YES;
//        [results stringForColumn:@"isBookmark"];
//        tempResult = [results stringForColumn:@"isBookmark"];
//    }
//    
//    if (!resultSuccess) {
//        //NSLog(@"Execute Insert ");
//        [appD.database executeUpdate:@"insert into userBookmarksTable (type, id, isBookmark) values (?, ?, ?)",Btype,Bsid,@"1"];
//    } else {
//        //NSLog(@"Execute Update ");
//        
//        if ([tempResult isEqualToString:@"1"]) {
//            
//            [appD.database executeUpdate:[NSString stringWithFormat:@"UPDATE userBookmarksTable SET isBookmark= '%@' WHERE id = '%@'",@"0",Bsid]];
//        } else {
//            [appD.database executeUpdate:[NSString stringWithFormat:@"UPDATE userBookmarksTable SET isBookmark= '%@' WHERE id = '%@'",@"1",Bsid]];
//        }
//        
//    }
//    [appD.database close];
//    
//}
//-(void)bookmarkNewsRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
//    [self stopProgressHUD];
//    [Utility showMessage:error withTitle:@"Error!"];
//}

#pragma mark -
#pragma mark - sharing
#pragma mark -

-(void)shareDataSetUp{
    shareIconArray = [[NSArray alloc] initWithObjects:@"facebook", @"whats_app",@"twitter",@"gmail",@"sms",nil];
    share = [[[NSBundle mainBundle] loadNibNamed:@"shareView" owner:nil options:nil] lastObject];
    share.shareCollectionView.backgroundColor = [UIColor whiteColor];
    share.frame = CGRectMake(0.0,SCREENHEIGHT-160, SCREENWIDTH,160);
    share.shareCollectionView.delegate = self;
    share.shareCollectionView.dataSource = self;
    [share.closeShareButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    UICollectionViewFlowLayout *layout1 = (UICollectionViewFlowLayout *)[share.shareCollectionView collectionViewLayout];
    layout1.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [share.shareCollectionView registerNib:[UINib nibWithNibName:@"shareCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"shareCollectionViewCell"];
    [share.shareCollectionView setContentOffset:CGPointZero animated:YES];
    [self.view bringSubviewToFront:share];
    share.hidden = YES;
    [self.view addSubview:share];
}

#pragma mark - Cancel Button Clicked

-(IBAction)closeButtonClicked:(id)sender{
    share.hidden = YES;
}

#pragma mark - collection Delegate

-(NSInteger)numberOfSectionsInCollectionView:
(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section
{
    return [shareIconArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    shareCollectionViewCell *cell = (shareCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"shareCollectionViewCell" forIndexPath:indexPath];
    cell.shareImageView.image = [UIImage imageNamed:[shareIconArray objectAtIndex:indexPath.row]];
    cell.shareImageView.layer.cornerRadius = 2.0;
    cell.shareImageView.layer.masksToBounds = YES;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //shareString = [[NSString stringWithFormat:@"%@",ImageSERVER_API] stringByAppendingString:[[self.videoPlayerArray objectAtIndex:self.selectedIndex] objectForKey:@"event_code"]];
    shareString = [[self.videoPlayerArray objectAtIndex:self.selectedIndex] objectForKey:@"event_code"];
    
    switch (indexPath.item) {
        case 0:
            [self postToFacebook];
            break;
        case 1:
            [[WASWhatsAppUtil getInstance] sendText:shareString] ;
            break;
        case 2:
            [self postToTwitter];
            break;
        case 3:
            [self showEmail];
            break;
        case 4:
            [self showSMS:shareString];
            break;
        case 5:
            
            break;
            
        default:
            [self showSMS:shareString];
            break;
    }
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *) collectionView
                        layout:(UICollectionViewLayout *) collectionViewLayout
        insetForSectionAtIndex:(NSInteger) section {
    
    return UIEdgeInsetsMake(0, 10, 0, 10); // top, left, bottom, right
}


- (CGFloat)collectionView:(UICollectionView *) collectionView
                   layout:(UICollectionViewLayout *) collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger) section {
    if (IPAD) {
        return 100.0;
    } else {
        return 20.0;
    }
    
}

#pragma mark - sms Send

- (void)showSMS:(NSString*)file {
    
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    NSString *message = [NSString stringWithFormat:@"%@", file];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            //NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            //NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            //NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
            
        default:
            //NSLog(@"Mail not sent.");
            break;
    }
    
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Post to tweeter

- (void)postToTwitter {
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:shareString];
        //[tweetSheet addURL:[NSURL URLWithString:shareString]];
        [tweetSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    //NSLog(@"Post Canceled");
                    break;
                case SLComposeViewControllerResultDone:
                    //NSLog(@"Post Sucessful");
                    break;
                    
                default:
                    break;
            }
        }];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    } else {
        UIAlertController *alertController = [UIAlertController  alertControllerWithTitle:@"Login Required"  message:@"Please Login to twitter"  preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Setting" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}


#pragma mark - Post to Facebook

- (void)postToFacebook{
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        //[controller setInitialText:shareString];
        [controller addURL:[NSURL URLWithString:shareString]];
        [controller setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    //NSLog(@"Post Canceled");
                    break;
                case SLComposeViewControllerResultDone:
                    //NSLog(@"Post Sucessful");
                    break;
                    
                default:
                    break;
            }
        }];
        [self presentViewController:controller animated:YES completion:Nil];
    } else {
        UIAlertController *alertController = [UIAlertController  alertControllerWithTitle:@"Login Required "  message:@"Please Login to Facebook "  preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Setting" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - Open Email

- (void)showEmail{
    
    MFMailComposeViewController *comp=[[MFMailComposeViewController alloc]init];
    [comp setMailComposeDelegate:self];
    if([MFMailComposeViewController canSendMail])
    {
        //[comp setToRecipients:[NSArray arrayWithObjects:@"imstkgp@gnail.com", nil]];
        [comp setSubject:@"From GSTSutra"];
        [comp setMessageBody:shareString isHTML:NO];
        [comp setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [self presentViewController:comp animated:YES completion:nil];
    }
    else{
        UIAlertView *alrt=[[UIAlertView alloc]initWithTitle:@"" message:@"" delegate:nil cancelButtonTitle:@"" otherButtonTitles:nil, nil];
        [alrt show];
        
    }
}


- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            //NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            //NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            //NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            //NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - share button click

- (IBAction)shareButtonClicked:(id)sender {
    share.hidden = NO;
    [self.view bringSubviewToFront:share];
    //[self.view addSubview:share];
    
    
}


- (IBAction)bookmarkButtonClicked:(id)sender {
    NewRequest *req = [[NewRequest alloc]init];
    req.delegate = self;

    if ([[sender imageForState:UIControlStateNormal] isEqual:[UIImage imageNamed:@"bookmark_n"]]){
        [sender setImage:[UIImage imageNamed:@"bookmark_p"] forState:UIControlStateNormal];

        if ([self checkReachability]) {
            [self startProgressHUD];
            [req bookMarkNewsWithStoryId: [[self.videoPlayerArray objectAtIndex:self.selectedIndex] objectForKey:@"id"] withStoryType:@"25" withBookmarkValue:@"1"];
        }
        else {
            [self stopProgressHUD];
            [self noInternetAlert];
        }
    } else{
        [sender setImage:[UIImage imageNamed:@"bookmark_n"] forState:UIControlStateNormal];
        if ([self checkReachability]) {
            [self startProgressHUD];
            [req bookMarkNewsWithStoryId: [[self.videoPlayerArray objectAtIndex:self.selectedIndex] objectForKey:@"id"] withStoryType:@"25" withBookmarkValue:@"0"];
        }
        else {
            [self stopProgressHUD];
            [self noInternetAlert];
        }

    }

}

-(void)bookmarkNewsRequestSuccessfulWithStatus:(NSString *)status{

    [self updateBookmarkWithSid:[NSString stringWithFormat:@"%@",[[self.videoPlayerArray objectAtIndex:self.selectedIndex] objectForKey:@"id"]] withBookmarkType:[NSString stringWithFormat:@"%@",@"25"]];
    [self stopProgressHUD];

}

-(void)setBookmarkImageWithSid:(NSString*)Bsid withBookmarkType : (NSString *)Btype{
    [appD.database open];

    NSString *tempQuery  = [[[@"select isBookmark from userBookmarksTable Where type = " stringByAppendingString:Btype] stringByAppendingString: @" and id = "] stringByAppendingString:Bsid];

    FMResultSet *results = [appD.database executeQuery:tempQuery];
    while([results next]) {
        dbBookmarkValue = [results stringForColumn:@"isBookmark"];
    }
}
-(void)updateBookmarkWithSid:(NSString*)Bsid withBookmarkType : (NSString *)Btype{
    BOOL resultSuccess = NO;
    NSString *tempResult = @"";
    [appD.database open];

    NSString *tempQuery  = [[[@"select isBookmark from userBookmarksTable Where type = " stringByAppendingString:Btype] stringByAppendingString: @" and id = "] stringByAppendingString:Bsid];

    FMResultSet *results = [appD.database executeQuery:tempQuery];
    while([results next]) {
        resultSuccess = YES;
        [results stringForColumn:@"isBookmark"];
        tempResult = [results stringForColumn:@"isBookmark"];
    }

    if (!resultSuccess) {
        //NSLog(@"Execute Insert ");
        [appD.database executeUpdate:@"insert into userBookmarksTable (type, id, isBookmark) values (?, ?, ?)",Btype,Bsid,@"1"];
    } else {
        //NSLog(@"Execute Update ");

        if ([tempResult isEqualToString:@"1"]) {

            [appD.database executeUpdate:[NSString stringWithFormat:@"UPDATE userBookmarksTable SET isBookmark= '%@' WHERE id = '%@'",@"0",Bsid]];
        } else {
            [appD.database executeUpdate:[NSString stringWithFormat:@"UPDATE userBookmarksTable SET isBookmark= '%@' WHERE id = '%@'",@"1",Bsid]];
        }

    }
    [appD.database close];

}
-(void)bookmarkNewsRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
    [Utility showMessage:error withTitle:@"Error!"];
}




#pragma mark - Like Button Clicked


- (IBAction)likeButtonClicked:(id)sender {
    
    NewRequest *req = [[NewRequest alloc]init];
    req.delegate = self;
    
    if ([[sender imageForState:UIControlStateNormal] isEqual:[UIImage imageNamed:@"like_n"]]){
        [sender setImage:[UIImage imageNamed:@"like_p"] forState:UIControlStateNormal];
        
        if ([self checkReachability]) {
            [self startProgressHUD];
            
            [req likeNewsWithStoryId:[[self.videoPlayerArray objectAtIndex:self.selectedIndex] objectForKey:@"id"] withStoryType:@"25" withLikeValue:@"1"];
            
        }
        else {
            [self stopProgressHUD];
            [self noInternetAlert];
        }
    } else{
        [sender setImage:[UIImage imageNamed:@"like_n"] forState:UIControlStateNormal];
        if ([self checkReachability]) {
            [self startProgressHUD];
            
            [req likeNewsWithStoryId:[[self.videoPlayerArray objectAtIndex:self.selectedIndex] objectForKey:@"id"] withStoryType:@"25" withLikeValue:@"0"];
        }
        else {
            [self stopProgressHUD];
            [self noInternetAlert];
        }
        
    }
    
}


#pragma mark - Like Delegate

-(void)likeNewsRequestSuccessfulWithStatus:(NSString *)status{
    
    
    [self updateLikeWithSid:[NSString stringWithFormat:@"%@",[[self.videoPlayerArray objectAtIndex:self.selectedIndex] objectForKey:@"id"]] withBookmarkType:[NSString stringWithFormat:@"%@",@"25"]];
    [self stopProgressHUD];
    
    
    [self updateNewLikeCountWithSid:[NSString stringWithFormat:@"%@",[[self.videoPlayerArray objectAtIndex:self.selectedIndex] objectForKey:@"id"]] withNewsType:[NSString stringWithFormat:@"%@",@"25"] withLikeCount:[NSString stringWithFormat:@"%@",status]];
    
    if ([[NSString stringWithFormat:@"%@",status] isEqualToString:@"0"]) {
        self.likeCountLabel.text = @"";
    } else {
        self.likeCountLabel.text = [NSString stringWithFormat:@"%@",status];
    }
    
    
}

-(void)setLikeImageWithSid:(NSString*)Bsid withBookmarkType : (NSString *)Btype{
    [appD.database open];
    
    NSString *tempQuery  = [[[@"select isLike from userLikeTable Where type = " stringByAppendingString:Btype] stringByAppendingString: @" and id = "] stringByAppendingString:Bsid];
    
    FMResultSet *results = [appD.database executeQuery:tempQuery];
    while([results next]) {
        dbLikeValue = [results stringForColumn:@"isLike"];
    }
}
-(void)updateLikeWithSid:(NSString*)Bsid withBookmarkType : (NSString *)Btype{
    BOOL resultSuccess = NO;
    NSString *tempResult = @"";
    [appD.database open];
    
    NSString *tempQuery  = [[[@"select isLike from userLikeTable Where type = " stringByAppendingString:Btype] stringByAppendingString: @" and id = "] stringByAppendingString:Bsid];
    
    FMResultSet *results = [appD.database executeQuery:tempQuery];
    while([results next]) {
        resultSuccess = YES;
        [results stringForColumn:@"isLike"];
        tempResult = [results stringForColumn:@"isLike"];
    }
    
    if (!resultSuccess) {
        //NSLog(@"Execute Insert ");
        [appD.database executeUpdate:@"insert into userLikeTable (type, id, isLike) values (?, ?, ?)",Btype,Bsid,@"1"];
    } else {
        //NSLog(@"Execute Update ");
        
        if ([tempResult isEqualToString:@"1"]) {
            
            [appD.database executeUpdate:[NSString stringWithFormat:@"UPDATE userLikeTable SET isLike = '%@' WHERE id = '%@'",@"0",Bsid]];
        } else {
            [appD.database executeUpdate:[NSString stringWithFormat:@"UPDATE userLikeTable SET isLike = '%@' WHERE id = '%@'",@"1",Bsid]];
        }
        
    }
    [appD.database close];
    
}
-(void)likeNewsRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
    [Utility showMessage:error withTitle:@"Error"];
}

#pragma mark
#pragma mark - get Like count
#pragma mark

-(void)updateLikeCountWithSid:(NSString*)Bsid withNewsType : (NSString *)Btype withLikeCount : (NSString *)LikeCount{
    BOOL resultSuccess = NO;
    [appD.database open];
    NSString *tempCountResult = @"";
    NSString *tempQuery  = [[[@"select newsLikeCacheCount from newsLikeCountTable Where newstype = " stringByAppendingString:Btype] stringByAppendingString: @" and newsid = "] stringByAppendingString:Bsid];
    
    FMResultSet *results = [appD.database executeQuery:tempQuery];
    while([results next]) {
        resultSuccess = YES;
        [results stringForColumn:@"newsLikeCacheCount"];
        tempCountResult = [results stringForColumn:@"newsLikeCacheCount"];
    }
    
    if (!resultSuccess) {
        //NSLog(@"Execute Insert for Like Count");
        [appD.database executeUpdate:@"insert into newsLikeCountTable (newstype ,newsid ,newsLikeCacheCount,newsLikeCount) values (?, ?, ?, ?)",Btype,Bsid,LikeCount,@"0"];
    } else {
        //NSLog(@"Execute Update for Like Count");
        
        
        if (![tempCountResult isEqualToString:LikeCount]) {
            
            [appD.database executeUpdate:[NSString stringWithFormat:@"UPDATE newsLikeCountTable SET newsLikeCacheCount = '%@', newsLikeCount = '%@' WHERE newsid = '%@' AND newstype = '%@'",LikeCount,@"0",Bsid,Btype]];
        }
        
    }
    [appD.database close];
    
}


-(void)updateNewLikeCountWithSid:(NSString*)Bsid withNewsType : (NSString *)Btype withLikeCount : (NSString *)LikeCount{
    [appD.database open];
    [appD.database executeUpdate:[NSString stringWithFormat:@"UPDATE newsLikeCountTable SET  newsLikeCount = '%@' WHERE newsid = '%@' AND newstype = '%@'",LikeCount,Bsid,Btype]];
    [appD.database close];
    
}

-(void)setLikeCountToLabelWithSid:(NSString*)Bsid withNewsType : (NSString *)Btype{
    [appD.database open];
    NSString *tempCount =@"";
    NSString *tempChache =@"";
    
    NSString *tempQuery  = [[[@"select newsLikeCacheCount , newsLikeCount from newsLikeCountTable Where newstype = " stringByAppendingString:Btype] stringByAppendingString: @" and newsid = "] stringByAppendingString:Bsid];
    
    FMResultSet *results = [appD.database executeQuery:tempQuery];
    while([results next]) {
        tempCount = [results stringForColumn:@"newsLikeCount"];
        tempChache = [results stringForColumn:@"newsLikeCacheCount"];
    }
    
    [appD.database close];
    
    if ([tempCount isEqualToString:@"0"]) {
        
        dbLikeCountValue = tempChache;
    } else {
        dbLikeCountValue = tempCount;
    }
    
    
}




@end
