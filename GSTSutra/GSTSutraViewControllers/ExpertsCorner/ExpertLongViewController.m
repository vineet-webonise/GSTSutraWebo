//
//  ExpertLongViewController.m
//  GSTSutra
//
//  Created by niyuj on 11/23/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import "ExpertLongViewController.h"
#import "ShortNewsViewController.h"
#import "HCSStarRatingView.h"
#import "NewRequest.h"
#import "ShowCommentTableViewCell.h"
#import "TypeCommentTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+Letters.h"
#import "topTwoExpertView.h"
#import "topCenterView.h"
#import "topThreeExpertView.h"
#import "topTwoExpertView.h"
#import "HeaderTableViewCell.h"
#import "NewsTableViewCell.h"
#import "NewsHeaderTableViewCell.h"
#import "AdvertiseTableViewCell.h"
#import "LongNewsViewController.h"

//share
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
#import "WASWhatsAppUtil.h"
#import <SafariServices/SafariServices.h>
#import "shareView.h"
#import "shareCollectionViewCell.h"
#import <MessageUI/MFMailComposeViewController.h>

typedef enum{
    kSendText = 0,
    kSendImage,
    kSendTextWithImage,
    kSendAudio,
    kSendCancel
} options;


@interface ExpertLongViewController ()<UIGestureRecognizerDelegate,NewRequestDelegate,UITextViewDelegate,UITextViewDelegate,UIScrollViewDelegate,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate,UIActionSheetDelegate,UIDocumentInteractionControllerDelegate,SFSafariViewControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>{
    NSString *postString,*rateValueString;
    topCenterView *centerExpertView;
    topTwoExpertView *twoExpertView;
    topThreeExpertView *threeExpertView;
     NSMutableArray *relatedStoryArray;
    
    NSString *shareString,*dbBookmarkValue,*dbLikeValue,*editStringID,*dbCommentCountValue,*dbLikeCountValue;
    NSMutableArray *commnetsArray;
    UIScrollView *helpScrollView;
    NSMutableArray *imagesArray;
    UIDocumentInteractionController *docControll;
    shareView *share;
    NSArray *shareIconArray;
     BOOL isEditComment;
    
}
@property (weak, nonatomic) IBOutlet UIView *expertTopView;
@property (weak, nonatomic) IBOutlet UIWebView *expertLongNewsWebView;
@property (weak, nonatomic) IBOutlet UILabel *expertNewsTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *expertNewsDateLabel;
- (IBAction)likeButtonClicked:(id)sender;
- (IBAction)commentButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *ratingView;
@property (weak, nonatomic) IBOutlet UITableView *commentTableView;
- (IBAction)relatedStoryButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *relatedStoryTableView;
- (IBAction)shareButtonClicked:(id)sender;
- (IBAction)bookmarkButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *bookmarkButton;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;

//
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;

@end

@implementation ExpertLongViewController

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
   
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBarTitleLabel:@"Expert Columns"];
    //[self setupBackBarButtonItems];
    self.view.backgroundColor = [UIColor whiteColor];
    isEditComment = NO ;
    commnetsArray = [[NSMutableArray alloc] init];
    centerExpertView = [[[NSBundle mainBundle] loadNibNamed:@"topView" owner:nil options:nil] lastObject];
    twoExpertView = [[[NSBundle mainBundle] loadNibNamed:@"topTwoExpertView" owner:nil options:nil] lastObject];
    threeExpertView = [[[NSBundle mainBundle] loadNibNamed:@"topThreeExpertView" owner:nil options:nil] lastObject];
    relatedStoryArray = [[NSMutableArray alloc] init];
    _ratingView.allowsHalfStars = YES;
    
    if ([USERDEFAULTS boolForKey:@"isNotRegisterOrLoginUser"]) {
        [self openLoginViewControllerAlertOnLeftMenuOrView:NO];
    }else {
    if (appD.isFromNotification) {
        [self notificationAPICall];
        
    } else {
        [self webViewDataAndGesture];
    }
    }
    

    self.commentTableView.hidden = YES;
    self.relatedStoryTableView.hidden = YES;
    self.relatedStoryTableView.layer.borderWidth = 1.0;
    self.commentTableView.layer.borderWidth = 1.0;
    self.commentTableView.layer.borderColor = [UIColor grayColor].CGColor;
    self.relatedStoryTableView.layer.borderColor = [UIColor grayColor].CGColor;
    
    [self.commentTableView registerNib:[UINib nibWithNibName:@"ShowCommentTableViewCell" bundle:nil] forCellReuseIdentifier:@"ShowCommentTableViewCell"];
    [self.commentTableView registerNib:[UINib nibWithNibName:@"HeaderTableViewCell" bundle:nil] forCellReuseIdentifier:@"HeaderTableViewCell"];
    [self.commentTableView registerNib:[UINib nibWithNibName:@"TypeCommentTableViewCell" bundle:nil] forCellReuseIdentifier:@"TypeCommentTableViewCell"];
    
    [self.relatedStoryTableView registerNib:[UINib nibWithNibName:@"HeaderTableViewCell" bundle:nil] forCellReuseIdentifier:@"HeaderTableViewCell"];
    [self.relatedStoryTableView registerNib:[UINib nibWithNibName:@"HeaderTableViewCell" bundle:nil] forCellReuseIdentifier:@"HeaderTableViewCell"];
    [self.relatedStoryTableView registerNib:[UINib nibWithNibName:@"NewsTableViewCell" bundle:nil] forCellReuseIdentifier:@"NewsTableViewCell"];
    [self.relatedStoryTableView registerNib:[UINib nibWithNibName:@"NewsHeaderTableViewCell" bundle:nil] forCellReuseIdentifier:@"NewsHeaderTableViewCell"];
    [self.relatedStoryTableView registerNib:[UINib nibWithNibName:@"AdvertiseTableViewCell" bundle:nil] forCellReuseIdentifier:@"AdvertiseTableViewCell"];
    
    [self shareDataSetUp];
}

-(void)notificationAPICall{
    [self stopProgressHUD];
    if ([self checkReachability]) {
        [self startProgressHUD];
        appD.isFromNotification = NO;
        NewRequest *req = [[NewRequest alloc] init];
        req.delegate=self;
        [req getNotificationNewsWithStoryId:appD.sid withStoryType:@"9"];
    }
    else {
        [self stopProgressHUD];
        [self noInternetAlert];
    }
    
}

-(void)newsNotificationRequestSuccessfulWithResult:(NSArray *)result{
    [self stopProgressHUD];
    self.expertLongViewNewsArray = [result mutableCopy];
    self.selectedIndex = 0;
    [self webViewDataAndGesture];
}
-(void)newsNotificationRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
}


-(void)webViewDataAndGesture{
    @try {
    [self setBookmarkImageWithSid:[NSString stringWithFormat:@"%@",[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"sid"]] withBookmarkType:[NSString stringWithFormat:@"%@",[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"story_type"]]];
    
    if ([dbBookmarkValue isEqualToString:@"1"]) {
        //Bookmark Selected image set
        [self.bookmarkButton setImage:[UIImage imageNamed:@"bookmark_p"] forState:UIControlStateNormal];
        dbBookmarkValue = @"";
    } else {
        // Not select
        [self.bookmarkButton setImage:[UIImage imageNamed:@"bookmark_n"] forState:UIControlStateNormal];
    }
    
    
    [self setLikeImageWithSid:[NSString stringWithFormat:@"%@",[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"sid"]] withBookmarkType:[NSString stringWithFormat:@"%@",[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"story_type"]]];
    
    if ([dbLikeValue isEqualToString:@"1"]) {
        //Bookmark Selected image set
        [self.likeButton setImage:[UIImage imageNamed:@"like_p"] forState:UIControlStateNormal];
        dbLikeValue = @"";
    } else {
        // Not select
        [self.likeButton setImage:[UIImage imageNamed:@"like_n"] forState:UIControlStateNormal];
    }

    
    
        // comment count
        
        
        [self updateCommentCountWithSid:[NSString stringWithFormat:@"%@",[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"sid"]] withNewsType:[NSString stringWithFormat:@"%@",[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"story_type"]] withCommentCount:[NSString stringWithFormat:@"%lu",[[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"comments"] count]]];
        
        
        [self setCommentCountToLabelWithSid:[NSString stringWithFormat:@"%@",[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"sid"]] withNewsType:[NSString stringWithFormat:@"%@",[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"story_type"]]];
        
        [self updateLikeCountWithSid:[NSString stringWithFormat:@"%@",[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"sid"]] withNewsType:[NSString stringWithFormat:@"%@",[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"story_type"]] withLikeCount:[NSString stringWithFormat:@"%@",[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"likes_count"]]];
        
        
        [self setLikeCountToLabelWithSid:[NSString stringWithFormat:@"%@",[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"sid"]] withNewsType:[NSString stringWithFormat:@"%@",[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"story_type"]]];

        
    
    self.expertNewsTitleLabel.text = [[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"headline"];
    self.expertNewsTitleLabel.font = [UIFont fontWithName:centuryGothicBold size:titleFont];
    self.expertNewsDateLabel.text = [[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"date"];
    self.ratingView.value = [[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"rating"]floatValue];
    [self addSingleExpert];
    NSString *fullURL = [ImageSERVER_API stringByAppendingString:[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"longview"]];
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    self.expertLongNewsWebView.backgroundColor = [UIColor whiteColor];
    //self.expertLongNewsWebView.scalesPageToFit = YES;
    [self.expertLongNewsWebView loadRequest:requestObj];
    
        if ([dbCommentCountValue isEqualToString:@"0"]) {
            self.commentCountLabel.text =@"";
        }else{
            self.commentCountLabel.text = dbCommentCountValue;
        }
        if ([dbLikeCountValue isEqualToString:@"0"]) {
            self.likeCountLabel.text = @"";
        } else {
            self.likeCountLabel.text = dbLikeCountValue;
        }
        
        
    UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightSwipeGesture:)];
    rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightSwipeGesture];
    [self.expertLongNewsWebView.scrollView.panGestureRecognizer requireGestureRecognizerToFail:rightSwipeGesture];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

#pragma mark
#pragma mark - get comment count
#pragma mark

-(void)updateCommentCountWithSid:(NSString*)Bsid withNewsType : (NSString *)Btype withCommentCount : (NSString *)commentCount{
    BOOL resultSuccess = NO;
    [appD.database open];
    NSString *tempCountResult = @"";
    NSString *tempQuery  = [[[@"select newsCommentCount from newsCommentCountTable Where newstype = " stringByAppendingString:Btype] stringByAppendingString: @" and newsid = "] stringByAppendingString:Bsid];
    
    FMResultSet *results = [appD.database executeQuery:tempQuery];
    while([results next]) {
        resultSuccess = YES;
        [results stringForColumn:@"newsCommentCount"];
        tempCountResult = [results stringForColumn:@"newsCommentCount"];
    }
    
    if (!resultSuccess) {
        //NSLog(@"Execute Insert ");
        [appD.database executeUpdate:@"insert into newsCommentCountTable (newstype ,newsid ,newsCommentCount ,postComment ,deleteComment) values (?, ?, ?,?,?)",Btype,Bsid,commentCount,@"0",@"0"];
    } else {
        //NSLog(@"Execute Update");
        
        
        if (![tempCountResult isEqualToString:commentCount]) {
            
            [appD.database executeUpdate:[NSString stringWithFormat:@"UPDATE newsCommentCountTable SET newsCommentCount = '%@' WHERE newsid = '%@' AND newstype = '%@'",commentCount,Bsid,Btype]];
        }
        
    }
    [appD.database close];
    
}


-(void)setCommentCountToLabelWithSid:(NSString*)Bsid withNewsType : (NSString *)Btype{
    [appD.database open];
    NSString *temp =@"";
    
    NSString *tempQuery  = [[[@"select ((newsCommentCount + postComment)-deleteComment) As totalCount from newsCommentCountTable Where newstype = " stringByAppendingString:Btype] stringByAppendingString: @" and newsid = "] stringByAppendingString:Bsid];
    
    FMResultSet *results = [appD.database executeQuery:tempQuery];
    while([results next]) {
        temp = [results stringForColumn:@"totalCount"];
    }
    
    dbCommentCountValue = temp;
    [appD.database close];
    
}


-(void)newCommentCountWithSid:(NSString*)Bsid withNewsType : (NSString *)Btype withCommentCount : (NSString *)commentCount{
    [appD.database open];
    NSString *temp =@"";
    NSString *tempQuery  = [[[@"select newsCommentCount from newsCommentCountTable Where newstype = " stringByAppendingString:Btype] stringByAppendingString: @" and newsid = "] stringByAppendingString:Bsid];
    
    FMResultSet *results = [appD.database executeQuery:tempQuery];
    while([results next]) {
        temp = [results stringForColumn:@"newsCommentCount"];
    }
    
    
    if ([temp intValue] >= [commentCount intValue]) {
        if(![temp isEqualToString:commentCount])
        {
            NSString *tempDeleteCount = [NSString stringWithFormat:@"%d",([temp intValue] - [commentCount intValue])];
            
            
            [appD.database executeUpdate:[NSString stringWithFormat:@"UPDATE newsCommentCountTable SET deleteComment = '%@', postComment = '%@' WHERE newsid = '%@' AND newstype = '%@'",tempDeleteCount,@"0",Bsid,Btype]];
            
            
        } else {
            
            [appD.database executeUpdate:[NSString stringWithFormat:@"UPDATE newsCommentCountTable SET deleteComment = '%@', postComment = '%@' WHERE newsid = '%@' AND newstype = '%@'",@"0",@"0",Bsid,Btype]];
            
            
        }
    } else {
        NSString *tempDeleteCount = [NSString stringWithFormat:@"%d",([commentCount intValue] - [temp intValue])];
        [appD.database executeUpdate:[NSString stringWithFormat:@"UPDATE newsCommentCountTable SET deleteComment = '%@', postComment = '%@' WHERE newsid = '%@' AND newstype = '%@'",@"0",tempDeleteCount,Bsid,Btype]];
    }
    
    [appD.database close];
    
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
    NSString *temp =@"";
    NSString *tempChache =@"";
    
    NSString *tempQuery  = [[[@"select newsLikeCacheCount , newsLikeCount from newsLikeCountTable Where newstype = " stringByAppendingString:Btype] stringByAppendingString: @" and newsid = "] stringByAppendingString:Bsid];
    
    FMResultSet *results = [appD.database executeQuery:tempQuery];
    while([results next]) {
        temp = [results stringForColumn:@"newsLikeCount"];
        tempChache = [results stringForColumn:@"newsLikeCacheCount"];
    }
    
    [appD.database close];
    
    if ([temp isEqualToString:@"0"]) {
        
        dbLikeCountValue = tempChache;
    } else {
        dbLikeCountValue = temp;
    }
    
    
}

-(void)addSingleExpert{
    centerExpertView.nameCenterLabel.text =[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"expert_name"];
    centerExpertView.nameCenterLabel.font = [UIFont fontWithName:centuryGothicBold size:titleFont];
    NSString *newsImageUrl = [[NSString stringWithFormat:@"%@",ImageSERVER_API] stringByAppendingString:[[self.expertLongViewNewsArray  objectAtIndex:self.selectedIndex] objectForKey:@"image"]];
    ;
    // Here we use the new provided sd_setImageWithURL: method to load the web image
    [centerExpertView.profileCenterImageView sd_setImageWithURL:[NSURL URLWithString:[newsImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]placeholderImage:[UIImage imageNamed:@"userimage.png"]];
    
    centerExpertView.profileCenterImageView.layer.cornerRadius = centerExpertView.profileCenterImageView.frame.size.height /2;
    centerExpertView.profileCenterImageView.layer.masksToBounds = YES;
    
    [self.expertTopView addSubview:centerExpertView];
}

-(void)addExpertAndCoExpert{
    if ([[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"co_experts"]count] == 1) {
        
        NSMutableArray *commentArray;
        
        if ([[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"co_experts"]count] > 0) {
            
            commentArray = [[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"co_experts"] mutableCopy];
            
            NSString *rightImageUrl = [[NSString stringWithFormat:@"%@",ImageSERVER_API] stringByAppendingString:[[commentArray  objectAtIndex:0] objectForKey:@"picture"]];
            twoExpertView.leftTwoLabel.text = [[commentArray objectAtIndex:0] objectForKey:@"name"];
            // Here we use the new provided sd_setImageWithURL: method to load the web image
            [twoExpertView.leftTwoImageView sd_setImageWithURL:[NSURL URLWithString:[rightImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]placeholderImage:[UIImage imageNamed:@"userimage.png"]];
            
            twoExpertView.leftTwoImageView.layer.cornerRadius =twoExpertView.leftTwoImageView.frame.size.height /2;
            twoExpertView.leftTwoImageView.layer.masksToBounds = YES;
            
        }
        
        twoExpertView.rightTwoLabel.text =[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"expert_name"];
        NSString *newsImageUrl = [[NSString stringWithFormat:@"%@",ImageSERVER_API] stringByAppendingString:[[self.expertLongViewNewsArray  objectAtIndex:self.selectedIndex] objectForKey:@"image"]];
        ;
        // Here we use the new provided sd_setImageWithURL: method to load the web image
        [twoExpertView.rightTwoImageView sd_setImageWithURL:[NSURL URLWithString:[newsImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]placeholderImage:[UIImage imageNamed:@"userimage.png"]];
        
        twoExpertView.rightTwoImageView.layer.cornerRadius =twoExpertView.rightTwoImageView.frame.size.height /2;
        twoExpertView.rightTwoImageView.layer.masksToBounds = YES;
        
        [self.expertTopView addSubview:twoExpertView];
        
    } else if ([[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"co_experts"]count] == 2){
        
        NSMutableArray *commentArray;
        
        if ([[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"co_experts"]count] > 1) {
            
            commentArray = [[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"co_experts"] mutableCopy];
            
            NSString *rightImageUrl = [[NSString stringWithFormat:@"%@",ImageSERVER_API] stringByAppendingString:[[commentArray  objectAtIndex:0] objectForKey:@"picture"]];
            threeExpertView.centerThreeLabel.text = [[commentArray objectAtIndex:0] objectForKey:@"name"];
            // Here we use the new provided sd_setImageWithURL: method to load the web image
            [threeExpertView.centerThreeImageView sd_setImageWithURL:[NSURL URLWithString:[rightImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]placeholderImage:[UIImage imageNamed:@"userimage.png"]];
            
            threeExpertView.centerThreeImageView.layer.cornerRadius =threeExpertView.centerThreeImageView.frame.size.height /2;
            threeExpertView.centerThreeImageView.layer.masksToBounds = YES;
            
            
            
            
            NSString *leftImageUrl = [[NSString stringWithFormat:@"%@",ImageSERVER_API] stringByAppendingString:[[commentArray  objectAtIndex:1] objectForKey:@"picture"]];
            threeExpertView.leftThreeLabel.text = [[commentArray objectAtIndex:1] objectForKey:@"name"];
            // Here we use the new provided sd_setImageWithURL: method to load the web image
            [threeExpertView.leftThreeImageView sd_setImageWithURL:[NSURL URLWithString:[leftImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]placeholderImage:[UIImage imageNamed:@"userimage.png"]];
            
            threeExpertView.leftThreeImageView.layer.cornerRadius =threeExpertView.leftThreeImageView.frame.size.height /2;
            threeExpertView.leftThreeImageView.layer.masksToBounds = YES;
            
            
        }
        
        
        threeExpertView.rightThreeLabel.text =[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"expert_name"];
        NSString *newsImageUrl = [[NSString stringWithFormat:@"%@",ImageSERVER_API] stringByAppendingString:[[self.expertLongViewNewsArray  objectAtIndex:self.selectedIndex] objectForKey:@"image"]];
        ;
        // Here we use the new provided sd_setImageWithURL: method to load the web image
        [threeExpertView.rightThreeImageView sd_setImageWithURL:[NSURL URLWithString:[newsImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]placeholderImage:[UIImage imageNamed:@"userimage.png"]];
        
        threeExpertView.rightThreeImageView.layer.cornerRadius =threeExpertView.rightThreeImageView.frame.size.height /2;
        threeExpertView.rightThreeImageView.layer.masksToBounds = YES;
        
        
        [self.expertTopView addSubview:threeExpertView];
    } else{
        centerExpertView.nameCenterLabel.text =[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"expert_name"];
        NSString *newsImageUrl = [[NSString stringWithFormat:@"%@",ImageSERVER_API] stringByAppendingString:[[self.expertLongViewNewsArray  objectAtIndex:self.selectedIndex] objectForKey:@"image"]];
        ;
        // Here we use the new provided sd_setImageWithURL: method to load the web image
        [centerExpertView.profileCenterImageView sd_setImageWithURL:[NSURL URLWithString:[newsImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]placeholderImage:[UIImage imageNamed:@"userimage.png"]];
        
        centerExpertView.profileCenterImageView.layer.cornerRadius = centerExpertView.profileCenterImageView.frame.size.height /2;
        centerExpertView.profileCenterImageView.layer.masksToBounds = YES;
        
        [self.expertTopView addSubview:centerExpertView];
    }
    
}

#pragma mark - Swipe Gesture

-(void)handleRightSwipeGesture:(UISwipeGestureRecognizer*)gestureRecognizer{
  
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    [self startProgressHUD];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self stopProgressHUD];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error{
    [self stopProgressHUD];
}

#pragma mark - star rating popup 

-(void)openAlertWithStarRating{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Rate this story"
                                                                   message:@"\n\n\n\n"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    HCSStarRatingView *starRatingView = [HCSStarRatingView new];
    starRatingView.maximumValue = 5;
    starRatingView.minimumValue = 0;
    starRatingView.value = 0.0;
    starRatingView.allowsHalfStars = YES;
    starRatingView.accurateHalfStars = YES;
    starRatingView.emptyStarImage = [UIImage imageNamed:@"star_ee"];
    starRatingView.filledStarImage = [UIImage imageNamed:@"star_ff"];
    starRatingView.frame = CGRectMake(50,30, 160, 100);
    starRatingView.backgroundColor = [UIColor clearColor];
    starRatingView.clipsToBounds = YES;
    alert.view.userInteractionEnabled = YES;
    [starRatingView addTarget:self action:@selector(didChangeValuesFromAlert:) forControlEvents:UIControlEventValueChanged];
    [alert.view addSubview:starRatingView];
    [alert.view bringSubviewToFront:starRatingView];
    starRatingView.userInteractionEnabled = YES;
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Submit"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         if (rateValueString.length!=0) {
                                                             [self rateThisStoryAPICall];
                                                         } else{
                                                             [Utility showMessage:@"" withTitle:@"Please rate story by clicking star icon"];
                                                         }
                                                         
                                                     }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                        self.ratingView.value = [[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"rating"]floatValue];
                                                             
                                                         }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)didChangeValuesFromAlert:(HCSStarRatingView *)sender {
    
    //NSLog(@"Changed value from Alert rating to %.1f", sender.value);
    if (sender.value > 0) {
        rateValueString = [NSString stringWithFormat:@"%.1f",sender.value];
    } else {
        rateValueString = @"";
    }
}

-(void)rateThisStoryAPICall{
    
    if ([self checkReachability]) {
        NewRequest *news = [[NewRequest alloc] init];
        news.delegate = self;
        [news rateNewsWithStoryId:[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"sid"] withStoryType:[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"story_type"] withRateValue:rateValueString];
        
        
    }else {
        [self noInternetAlert];
    }

    
}


- (IBAction)didChangeValue:(HCSStarRatingView *)sender {
    
    self.ratingView.value = [[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"rating"]floatValue];
    [self openAlertWithStarRating];
    
}

#pragma mark - Table view data source

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (tableView == self.relatedStoryTableView) {
        return [relatedStoryArray count];
    } else {
        return [commnetsArray count];
        
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *headerCommentcellIdentifier = @"HeaderTableViewCell";
    HeaderTableViewCell *hederCommentcell = (HeaderTableViewCell*)[tableView dequeueReusableCellWithIdentifier:headerCommentcellIdentifier];
    if(tableView == self.relatedStoryTableView){
        hederCommentcell.headerLabel.text = @"Related Story";
    } else {
        hederCommentcell.headerLabel.text = @"Comment";
    }
    [hederCommentcell.cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    return hederCommentcell;
}
-(void)cancelButtonClicked : (UIButton*)sender{
    [self resignFirstResponder];
    self.commentTableView.hidden = YES;
    self.relatedStoryTableView.hidden = YES;
    [self.commentTableView reloadData];
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    static NSString *typeCommentcellIdentifier = @"TypeCommentTableViewCell";
    TypeCommentTableViewCell *typeCommentcell = (TypeCommentTableViewCell*)[tableView dequeueReusableCellWithIdentifier:typeCommentcellIdentifier];
    
    // Here we use the new provided sd_setImageWithURL: method to load the web image
    
    typeCommentcell.userImageView.layer.cornerRadius = typeCommentcell.userImageView.frame.size.height /2;
    typeCommentcell.userImageView.layer.masksToBounds = YES;
    typeCommentcell.userImageView.layer.borderWidth = 1.0;
    
    if ([self checkImageExtensionWithImage:[USERDEFAULTS valueForKey:@"profileImage"]])  {
        [typeCommentcell.userImageView sd_setImageWithURL:[NSURL URLWithString:[ImageSERVER_API stringByAppendingString:[USERDEFAULTS valueForKey:@"profileImage"]]]placeholderImage:[UIImage imageNamed:@"username.png"]];
    }
    else {
        [typeCommentcell.userImageView setImageWithString:[USERDEFAULTS valueForKey:@"fullName"] color:nil circular:YES];
        
    }
    
    if (isEditComment) {
        [typeCommentcell.postButton setTitle:@"Update" forState:UIControlStateNormal];
        [typeCommentcell.postButton addTarget:self action:@selector(updateCommentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [typeCommentcell.postButton setTitle:@"Post" forState:UIControlStateNormal];
        [typeCommentcell.postButton addTarget:self action:@selector(postCommentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }

    typeCommentcell.commentTextView.delegate = self;
    typeCommentcell.commentTextView.layer.borderWidth = 1.5f;
    typeCommentcell.commentTextView.layer.borderColor = [[UIColor blackColor] CGColor];
    typeCommentcell.commentTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    if (postString.length >0) {
        
        typeCommentcell.commentTextView.text = postString;
    }
    
    return typeCommentcell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    //    if (!self.commentTableView.hidden) {
    //        return 44.0;
    //    } else {
    //        return 0;
    //    }
    
    return 44.0;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (!self.commentTableView.hidden) {
        return 170.0;
    } else {
        return 0;
    }
    
    return 170;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *NewscellIdentifier = @"NewsTableViewCell";
    NewsTableViewCell *Newscell = (NewsTableViewCell*)[tableView dequeueReusableCellWithIdentifier:NewscellIdentifier];
    static NSString *ADVCellIdentifier = @"AdvertiseTableViewCell";
    AdvertiseTableViewCell *ADVCell = (AdvertiseTableViewCell*)[tableView dequeueReusableCellWithIdentifier:ADVCellIdentifier];
    
    static NSString *showCommentcellIdentifier = @"ShowCommentTableViewCell";
    ShowCommentTableViewCell *showCommentcell = (ShowCommentTableViewCell*)[tableView dequeueReusableCellWithIdentifier:showCommentcellIdentifier];
    
    static NSString *typeCommentcellIdentifier = @"TypeCommentTableViewCell";
    TypeCommentTableViewCell *typeCommentcell = (TypeCommentTableViewCell*)[tableView dequeueReusableCellWithIdentifier:typeCommentcellIdentifier];
    
    if (tableView == self.relatedStoryTableView) {
        
        NSString *newsImageUrl = [[NSString stringWithFormat:@"%@",ImageSERVER_API] stringByAppendingString:[[relatedStoryArray objectAtIndex:indexPath.row] objectForKey:@"image"]];
        
        Newscell.selectionStyle = UITableViewCellSelectionStyleNone;
        ADVCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        // Here we use the new provided sd_setImageWithURL: method to load the web image
        [Newscell.NewsImageView sd_setImageWithURL:[NSURL URLWithString:[newsImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"userimage.png"]];
        Newscell.NewsTitleLabel.text = [[relatedStoryArray objectAtIndex:indexPath.row] objectForKey:@"headline"];
        Newscell.NewsTitleLabel.font = [UIFont fontWithName:centuryGothicBold size:titleFont];
        Newscell.NewsDetailLabel.text = [[relatedStoryArray objectAtIndex:indexPath.row] objectForKey:@"shortview"];
        Newscell.NewDateLabel.text = [[relatedStoryArray objectAtIndex:indexPath.row] objectForKey:@"date"];
        
        return Newscell;
        
    } else {
        
        showCommentcell.selectionStyle = UITableViewCellSelectionStyleNone;
        typeCommentcell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if ([commnetsArray count]>0 && (indexPath.row < [commnetsArray count])){
            
            @try {
                // Here we use the new provided sd_setImageWithURL: method to load the web image
                NSString *newsImageUrl = [[NSString stringWithFormat:@"%@",ImageSERVER_API] stringByAppendingString:[[commnetsArray objectAtIndex:indexPath.row] objectForKey:@"commented_user_profile_pic"]];
                if ([self checkImageExtensionWithImage:newsImageUrl]) {
                    [showCommentcell.userImageView sd_setImageWithURL:[NSURL URLWithString:newsImageUrl]placeholderImage:[UIImage imageNamed:@"userimage.png"]];
                }else if(![[[commnetsArray objectAtIndex:indexPath.row] objectForKey:@"fullname"] isEqualToString:@""]){
                    [showCommentcell.userImageView setImageWithString:[[commnetsArray objectAtIndex:indexPath.row] objectForKey:@"fullname"] color:nil circular:YES];
                } else {
                    [showCommentcell.userImageView setImageWithString:[[commnetsArray objectAtIndex:indexPath.row] objectForKey:@"username"] color:nil circular:YES];
                }
                
                showCommentcell.userImageView.layer.cornerRadius = showCommentcell.userImageView.frame.size.height /2;
                showCommentcell.userImageView.layer.masksToBounds = YES;
                showCommentcell.userImageView.layer.borderWidth = 1.0;
                if(![[[commnetsArray objectAtIndex:indexPath.row] objectForKey:@"fullname"] isEqualToString:@""]){
                    showCommentcell.nameLabel.text = [[commnetsArray objectAtIndex:indexPath.row] objectForKey:@"fullname"];
                } else {
                    showCommentcell.nameLabel.text = [[commnetsArray objectAtIndex:indexPath.row] objectForKey:@"username"];
                }
                
                showCommentcell.commentLabel.text = [[commnetsArray objectAtIndex:indexPath.row] objectForKey:@"comment"];
                showCommentcell.dateLabel.text = [[commnetsArray objectAtIndex:indexPath.row] objectForKey:@"posted_date"];
                ;
                
                if ([[USERDEFAULTS valueForKey:@"userid"] isEqualToString:[[commnetsArray objectAtIndex:indexPath.row] objectForKey:@"userid"]]) {
                    showCommentcell.deleteButton.hidden = NO;
                    showCommentcell.editButtonClick.hidden = NO;
                    
                } else {
                    showCommentcell.deleteButton.hidden = YES;
                    showCommentcell.editButtonClick.hidden = YES;
                }
                [showCommentcell.deleteButton addTarget:self action:@selector(deleteCommentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                 [showCommentcell.editButtonClick addTarget:self action:@selector(editCommentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                
                showCommentcell.deleteButton.tag = [[[commnetsArray objectAtIndex:indexPath.row] objectForKey:@"comment_id"] integerValue];
                showCommentcell.editButtonClick.tag = [[[commnetsArray objectAtIndex:indexPath.row] objectForKey:@"comment_id"] integerValue];
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
         
            
            
            return showCommentcell;
            
        } else {
            return showCommentcell;
        }
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.relatedStoryTableView) {
        return 132;
    } else {
        return UITableViewAutomaticDimension;
    }
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //minimum size of your cell, it should be single line of label if you are not clear min. then return UITableViewAutomaticDimension;
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.relatedStoryTableView)
//    {
//        self.selectedIndex = indexPath.row ;
//        self.expertLongViewNewsArray = [relatedStoryArray mutableCopy];
//        self.relatedStoryTableView.hidden = YES;
//        [self webViewDataAndGesture];
//        
//    }
    
    {
        self.selectedIndex = indexPath.row ;
        self.expertLongViewNewsArray = [relatedStoryArray mutableCopy];
        self.relatedStoryTableView.hidden = YES;
        if ([[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"story_type"] integerValue] == 8) {
            
            LongNewsViewController *shortView = [self.storyboard instantiateViewControllerWithIdentifier:@"LongNewsViewController"];
            shortView.selectedIndex =  indexPath.row ;
            shortView.longViewNewsArray = [relatedStoryArray mutableCopy];
            [self.navigationController pushViewController:shortView animated:YES];
            
        } else {
            [self webViewDataAndGesture];
        }
    }
}

#pragma mark - TextView Delegates

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    //NSLog(@"textViewShouldBeginEditing:");
    if ([textView.text isEqualToString:@"Write Comment"]) {
        textView.text = @"";
    }
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    //NSLog(@"textViewDidBeginEditing:");
    
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    //NSLog(@"PostString with character");
    return YES;
}

- (void)textViewDidChangeSelection:(UITextView *)textView{
    postString = textView.text;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    //NSLog(@"textViewShouldEndEditing:");
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    //NSLog(@"textViewDidEndEditing:");
    [self.commentTableView reloadData];
    
}

#pragma mark  - likeDelegate

#pragma mark - edit Comment

-(IBAction)editCommentButtonClicked:(UIButton*)sender{
    //NSString *tempStr = [NSString stringWithFormat:@"%ld",(long)sender.tag];
    editStringID = [NSString stringWithFormat:@"%d",sender.tag ];
    for (int i = 0 ; i< [commnetsArray count]; i++) {
        
        if ([[[commnetsArray objectAtIndex:i] objectForKey:@"comment_id"] integerValue] == sender.tag) {
            postString = [[commnetsArray objectAtIndex:i] objectForKey:@"comment"] ;
            [self.commentTableView reloadData];
            isEditComment = YES;
        }
        
    }
    
    
    
}

#pragma mark - update Comment
-(void)updateCommentButtonClicked:(UIButton*)sender{
    
    NSString *trimmedString = [postString stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];
    
    if (trimmedString.length > 0 ) {
        if ([self checkReachability]) {
            [self startProgressHUD];
            [self.view endEditing:TRUE];
            NewRequest *newsReq = [[NewRequest alloc] init];
            newsReq.delegate=self;
            [newsReq updateCommentWithCommentID:editStringID withUpdatedCommentString:postString];
            
        } else {
            [self noInternetAlert];
        }
    } else {
        
        [Utility showMessage:@"Please Write Something in Comment Box" withTitle:@"Empty "];
        [self.commentTableView reloadData];
    }
}

-(void)updateCommentRequestSuccessfulWithStatus:(NSString *)status{
    [self stopProgressHUD];
    postString=@"";
    editStringID = @"";
    isEditComment = NO;
    [self getCommnentsAPICall];
    [Utility showMessage:@"Comment updated successfully" withTitle:@""];
    
}
-(void)updateCommentRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
    [Utility showMessage:error withTitle:@""];
}


#pragma mark - Comment Delegate

-(void)setCommentRequestSuccessfulWithStatus:(NSString *)status{
    [self stopProgressHUD];
    postString=@"";
    [self getCommnentsAPICall];
    [Utility showMessage:status withTitle:@""];
}
-(void)setCommentRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
    [Utility showMessage:error withTitle:@"Error"];
}

-(void)postCommentButtonClicked:(UIButton*)sender{
    
    NSString *trimmedString = [postString stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];
    
    if (trimmedString.length > 0 ) {
        if ([self checkReachability]) {
            [self startProgressHUD];
            [self.view endEditing:TRUE];
            NewRequest *newsReq = [[NewRequest alloc] init];
            newsReq.delegate=self;
            [newsReq setCommentWithStoryId:[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"sid"] withStoryType:[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"story_type"] withCommentString:postString];
            
        } else {
            [self noInternetAlert];
        }
    } else {
        
        [Utility showMessage:@"Please Write Something in Comment Box" withTitle:@"Empty "];
        [self.commentTableView reloadData];
    }
}

- (IBAction)commentButtonClicked:(id)sender {
    postString =@"";
    [self.relatedStoryTableView setHidden:YES];
    //NSLog(@"Comment button Clicked");
    
    if (self.commentTableView.hidden) {
        self.commentTableView.hidden = NO;
        [self getCommnentsAPICall];
    } else {
        self.commentTableView.hidden = YES;
    }
}

#pragma mark -  get Comment Delegate

-(void)getCommentRequestSuccessfulWithStatus:(NSArray*)result{
    [self stopProgressHUD];
   
    [self newCommentCountWithSid:[NSString stringWithFormat:@"%@",[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"sid"]] withNewsType:[NSString stringWithFormat:@"%@",[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"story_type"]] withCommentCount:[NSString stringWithFormat:@"%lu",(unsigned long)[result count]]];
    
    NSString *cmntCount = [NSString stringWithFormat:@"%lu",(unsigned long)[result count]];
    if ([cmntCount isEqualToString:@"0"]) {
        self.commentCountLabel.text = @"";
    }else {
        self.commentCountLabel.text = cmntCount;
    }

    
    
    [commnetsArray removeAllObjects];
    [commnetsArray addObjectsFromArray:result];
    [self.commentTableView reloadData];
    self.commentTableView.hidden = NO;
    [self.view bringSubviewToFront:self.commentTableView];
    
}

-(void)getCommentRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
    //[Utility showMessage:@"no comments" withTitle:@"count"];
}

-(IBAction)deleteCommentButtonClicked:(UIButton*)sender{
    //NSString *tempStr = [NSString stringWithFormat:@"%ld",(long)sender.tag];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Delete Comment" message:@"Are you sure?" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if ([self checkReachability]) {
            [self startProgressHUD];
            NewRequest *req = [[NewRequest alloc] init];
            req.delegate = self;
            [req deleteCommentWithCommentID:[NSString stringWithFormat:@"%ld",(long)sender.tag]];
            
        }else {
            [self stopProgressHUD];
        }
        
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // no operation dismiss view
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
    //    dispatch_async(dispatch_get_main_queue(), ^ {
    //        [self presentViewController:alertController animated:YES completion:nil];
    //    });
    
    
}

#pragma mark - Delete Comment Delegate

-(void)deleteCommentRequestSuccessfulWithStatus:(NSString *)status{
    [self stopProgressHUD];
    [self getCommnentsAPICall];
    [Utility showMessage:@"Comment deleted successfully" withTitle:@""];
    
}

-(void)deleteCommentRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
    [Utility showMessage:error withTitle:@"Fails"];
    
}

-(void)getCommnentsAPICall{
    if ([self checkReachability]) {
        [self startProgressHUD];
        NewRequest *req = [[NewRequest alloc]init];
        req.delegate = self;
        [req getCommentWithStoryId:[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"sid"] withStoryType:[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"story_type"]];
    }
    else {
        [self stopProgressHUD];
        [self noInternetAlert];
        self.commentTableView.hidden = YES;
    }
}

-(void)deleteCommnentsAPICall{
    if ([self checkReachability]) {
        [self startProgressHUD];
        NewRequest *req = [[NewRequest alloc]init];
        req.delegate = self;
        [req deleteCommentWithCommentID:@""];
    }
    else {
        [self stopProgressHUD];
        [self noInternetAlert];
        self.commentTableView.hidden = YES;
    }
}


#pragma mark - Related Story Button Clicked

- (IBAction)relatedStoryButtonClicked:(id)sender {
    
    //NSLog(@"related story button Clicked");
    [self.commentTableView setHidden:YES];
    
    if (self.relatedStoryTableView.hidden) {
        [self relatedStoryAPICALL];
    } else {
        self.relatedStoryTableView.hidden = YES;
    }
    
}

#pragma mark - Related Story API CAll

-(void)relatedStoryAPICALL {
    if ([self checkReachability]) {
        [self startProgressHUD];
        NewRequest *req = [[NewRequest alloc]init];
        req.delegate = self;
        [req newsRelatedWithStoryId:[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"sid"] andWithStoryType:[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"story_type"]];
        
    }
    else {
        [self stopProgressHUD];
        [self noInternetAlert];
    }
}

#pragma mark  - Related Story Delegate

-(void)newsRelatedRequestSuccessfulWithResult:(NSArray *)result{
    [self stopProgressHUD];
    [relatedStoryArray removeAllObjects];
    [relatedStoryArray addObjectsFromArray:result];
    if (relatedStoryArray.count>0) {
        self.relatedStoryTableView.hidden = NO;
        [self.relatedStoryTableView reloadData];
        [self.view bringSubviewToFront:self.relatedStoryTableView];
    }
}

-(void)newsRelatedRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
    [relatedStoryArray removeAllObjects];
    self.relatedStoryTableView.hidden = YES;
    [self.relatedStoryTableView reloadData];
    [Utility showMessage:error withTitle:@""];
    
}


#pragma mark  - likeDelegate

-(void)rateNewsRequestSuccessfulWithStatus:(NSString *)status{
    
    self.ratingView.value = [status floatValue];
    
}
-(void)rateNewsRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    
    [Utility showMessage:error withTitle:@"Error"];
}

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
//    shareString = [[NSString stringWithFormat:@"%@",ImageSERVER_API] stringByAppendingString:[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"sharelink"]];
    
    shareString = [USERDEFAULTS  objectForKey:@"shareURL"];
    
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
    //    switch (result) {
    //        case MessageComposeResultCancelled:
    //            break;
    //
    //        case MessageComposeResultFailed:
    //        {
    //            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //            [warningAlert show];
    //            break;
    //        }
    //
    //        case MessageComposeResultSent:
    //            break;
    //
    //        default:
    //            break;
    //    }
    
    
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
    self.commentTableView.hidden = YES;
    self.relatedStoryTableView.hidden = YES;
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
            [req bookMarkNewsWithStoryId: [[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"sid"] withStoryType:[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"story_type"] withBookmarkValue:@"1"];
        }
        else {
            [self stopProgressHUD];
            [self noInternetAlert];
        }
    } else{
        [sender setImage:[UIImage imageNamed:@"bookmark_n"] forState:UIControlStateNormal];
        if ([self checkReachability]) {
            [self startProgressHUD];
            [req bookMarkNewsWithStoryId: [[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"sid"] withStoryType:[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"story_type"] withBookmarkValue:@"0"];
        }
        else {
            [self stopProgressHUD];
            [self noInternetAlert];
        }
        
    }
    
}

-(void)bookmarkNewsRequestSuccessfulWithStatus:(NSString *)status{
    
    [self updateBookmarkWithSid:[NSString stringWithFormat:@"%@",[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"sid"]] withBookmarkType:[NSString stringWithFormat:@"%@",[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"story_type"]]];
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
            [req likeNewsWithStoryId:[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"sid"] withStoryType:[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"story_type"] withLikeValue:@"1"];
            
        }
        else {
            [self stopProgressHUD];
            [self noInternetAlert];
        }
    } else{
        [sender setImage:[UIImage imageNamed:@"like_n"] forState:UIControlStateNormal];
        if ([self checkReachability]) {
            [self startProgressHUD];
            [req likeNewsWithStoryId:[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"sid"] withStoryType:[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"story_type"] withLikeValue:@"0"];
        }
        else {
            [self stopProgressHUD];
            [self noInternetAlert];
        }
        
    }
    
}


#pragma mark - Like Delegate

-(void)likeNewsRequestSuccessfulWithStatus:(NSString *)status{
    
    [self updateLikeWithSid:[NSString stringWithFormat:@"%@",[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"sid"]] withBookmarkType:[NSString stringWithFormat:@"%@",[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"story_type"]]];
    [self stopProgressHUD];
    
    [self updateNewLikeCountWithSid:[NSString stringWithFormat:@"%@",[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"sid"]] withNewsType:[NSString stringWithFormat:@"%@",[[self.expertLongViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"story_type"]] withLikeCount:[NSString stringWithFormat:@"%@",status]];
    
    
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






@end
