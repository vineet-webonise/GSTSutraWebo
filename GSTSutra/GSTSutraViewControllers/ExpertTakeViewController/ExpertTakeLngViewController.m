//
//  ExpertTakeLngViewController.m
//  GSTSutra
//
//  Created by niyuj on 11/24/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import "ExpertTakeLngViewController.h"
#import "UIImageView+WebCache.h"
#import "HCSStarRatingView.h"
#import "NewRequest.h"

@interface ExpertTakeLngViewController ()<NewRequestDelegate>{
    NSMutableArray *commentArray;
    NSString *rateValueString;
    BOOL  isToggle;
}
@property (weak, nonatomic) IBOutlet UICollectionView *expertTakeCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *expertTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *expertDateLacel;
@property (weak, nonatomic) IBOutlet UITextView *expertTextView;
@property (weak, nonatomic) IBOutlet UILabel *expertCommentNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *expertCommentTitaleLabel;
@property (weak, nonatomic) IBOutlet UITextView *expertCommentTextview;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *ratingView;

@end

@implementation ExpertTakeLngViewController


// Notification

-(void)notificationAPICall{
    [self stopProgressHUD];
    if ([self checkReachability]) {
        [self startProgressHUD];
        appD.isFromNotification = NO;
        NewRequest *req = [[NewRequest alloc] init];
        req.delegate=self;
        [req getNotificationNewsWithStoryId:appD.sid withStoryType:@"11"];
    }
    else {
        [self stopProgressHUD];
        [self noInternetAlert];
    }
    
}

-(void)newsNotificationRequestSuccessfulWithResult:(NSArray *)result{
    [self stopProgressHUD];
    self.expertTakeArray = [result mutableCopy];
    self.selectedIndex = 0;
    [self setExpertTakeData];
    [self.expertTakeCollectionView reloadData];
}
-(void)newsNotificationRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
}




- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBarTitleLabel:@"Tax Ring"];
    [self setupBackBarButtonItems];
    
    // Notification Api Call
    
    if ([USERDEFAULTS boolForKey:@"isNotRegisterOrLoginUser"]) {
        [self openLoginViewControllerAlertOnLeftMenuOrView:NO];
    }else {
        
        if (appD.isFromNotification) {
            
            [self notificationAPICall];
        } else {
            [self setExpertTakeData];
        }
    }

    isToggle = NO;
    self.PreviouslyselectedItem = 0;
    self.expertTakeCollectionView.backgroundColor = [UIColor clearColor];
    commentArray = [[NSMutableArray alloc] init];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)[self.expertTakeCollectionView collectionViewLayout];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [self.expertCommentTextview setContentOffset:CGPointZero animated:YES];
    
}



-(void)setExpertTakeData{

    @try {
        self.expertDateLacel.text = [[self.expertTakeArray objectAtIndex:self.selectedIndex] objectForKey:@"date"];
        //self.expertTextView.text = [[self.expertTakeArray objectAtIndex:self.selectedIndex] objectForKey:@"shortview"];
        self.expertTextView.attributedText = [[NSAttributedString alloc] initWithData:[[[self.expertTakeArray objectAtIndex:self.selectedIndex] objectForKey:@"shortview"] dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]} documentAttributes:nil error:nil];
        [self.expertTextView setContentOffset:CGPointZero animated:YES];
        self.expertTitleLabel.text = [[self.expertTakeArray objectAtIndex:self.selectedIndex] objectForKey:@"title"];
        self.expertTitleLabel.font = [UIFont fontWithName:centuryGothicBold size:titleFont];
        self.ratingView.value = [[[self.expertTakeArray objectAtIndex:self.selectedIndex] objectForKey:@"rating"]floatValue];
        
        self.expertTextView.font = [UIFont fontWithName:centuryGothicRegular size:normalFont];
        self.expertTextView.textAlignment = NSTextAlignmentLeft;

    } @catch (NSException *exception) {
        
    } @finally {
        
    }
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
                                                            self.ratingView.value = [[[self.expertTakeArray objectAtIndex:self.selectedIndex] objectForKey:@"rating"]floatValue];
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
        [news rateNewsWithStoryId:[[self.expertTakeArray objectAtIndex:self.selectedIndex] objectForKey:@"nid"] withStoryType:[[self.expertTakeArray objectAtIndex:self.selectedIndex] objectForKey:@"story_type"] withRateValue:rateValueString];
        
        
    }else {
        [self noInternetAlert];
    }
    
    
}


- (IBAction)didChangeValue:(HCSStarRatingView *)sender {
    self.ratingView.value = [[[self.expertTakeArray objectAtIndex:self.selectedIndex] objectForKey:@"rating"]floatValue];
    [self openAlertWithStarRating];
    
}



-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section
{
    return [[[self.expertTakeArray objectAtIndex:self.selectedIndex] objectForKey:@"experts"] count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *myCell = [collectionView
                                    dequeueReusableCellWithReuseIdentifier:@"imageCell"
                                    forIndexPath:indexPath];
    
   
    if ([[[self.expertTakeArray objectAtIndex:self.selectedIndex] objectForKey:@"experts"] count] > indexPath.row) {
        
        commentArray = [[[self.expertTakeArray objectAtIndex:self.selectedIndex] objectForKey:@"experts"] mutableCopy];
    }
    
    if ([commentArray count]>0 && (indexPath.row < [commentArray count])){
        UIImageView * imageView = (UIImageView*)[myCell viewWithTag:10];
        
     NSString *newsImageUrl = [[NSString stringWithFormat:@"%@",ImageSERVER_API] stringByAppendingString:[[commentArray objectAtIndex:indexPath.row] objectForKey:@"image"]];
        //NSLog(@"ImageUrlInExpertTake %@",newsImageUrl);
     
    // Here we use the new provided sd_setImageWithURL: method to load the web image
    [imageView sd_setImageWithURL:[NSURL URLWithString:[newsImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]placeholderImage:[UIImage imageNamed:@"usernam.png"]];
        
        
        
        
    imageView.layer.cornerRadius = imageView.frame.size.height /2;
    imageView.layer.masksToBounds = YES;
        
        if (indexPath.item == 0) {
            self.expertCommentNameLabel.text = [[commentArray objectAtIndex:indexPath.row] objectForKey:@"name"];
            self.expertCommentNameLabel.font = [UIFont fontWithName:centuryGothicBold size:titleFont];
            self.expertCommentTitaleLabel.text = [[commentArray objectAtIndex:indexPath.row] objectForKey:@"designation"];
            self.expertCommentTitaleLabel.font = [UIFont fontWithName:centuryGothicBold size:titleFont];
            
          self.expertCommentTextview.attributedText = [[NSAttributedString alloc] initWithData:[[[commentArray objectAtIndex:indexPath.row] objectForKey:@"comment"] dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]} documentAttributes:nil error:nil];
            [self.expertCommentTextview setContentOffset:CGPointZero animated:YES];
            self.expertCommentTextview.font = [UIFont fontWithName:centuryGothicRegular size:normalFont];
            self.expertCommentTextview.textAlignment = NSTextAlignmentLeft;
            imageView.layer.borderWidth = 1.0f;
        } else if (indexPath.item == self.selectedItem){
            self.expertCommentNameLabel.text = [[commentArray objectAtIndex:indexPath.row] objectForKey:@"name"];
            self.expertCommentNameLabel.font = [UIFont fontWithName:centuryGothicBold size:titleFont];
            self.expertCommentTitaleLabel.text = [[commentArray objectAtIndex:indexPath.row] objectForKey:@"designation"];
            self.expertCommentTitaleLabel.font = [UIFont fontWithName:centuryGothicBold size:titleFont];
            self.expertCommentTextview.attributedText = [[NSAttributedString alloc] initWithData:[[[commentArray objectAtIndex:indexPath.row] objectForKey:@"comment"] dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                                                                                                                                            NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]} documentAttributes:nil error:nil];
            [self.expertCommentTextview setContentOffset:CGPointZero animated:YES];
            self.expertCommentTextview.font = [UIFont fontWithName:centuryGothicRegular size:normalFont];
            self.expertCommentTextview.textAlignment = NSTextAlignmentLeft;
            imageView.layer.borderWidth = 0.0f;
        }
        
        if (self.selectedItem == indexPath.item) {
            imageView.layer.borderWidth = 1.0f;
        } else {
            imageView.layer.borderWidth = 0.0f;
        }
    }
    
    
    return myCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    [self.expertTakeCollectionView
//     selectItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedItem inSection:0]
//     animated:YES
//     scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    self.selectedItem = indexPath.item;
     [self.expertTakeCollectionView reloadData];
    
//    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
//    UIImageView * imageView = (UIImageView*)[cell viewWithTag:10];
//    
//    
//    if (self.PreviouslyselectedItem != indexPath.item) {
//        imageView.layer.borderWidth = 0.0f;
//    }
//    self.PreviouslyselectedItem = self.selectedItem;
    
    
//    if (self.selectedItem == indexPath.item) {
//        imageView.layer.borderWidth = 2.0f;
//    } else {
//        imageView.layer.borderWidth = 0.0f;
//    }
   
    
//    if ([[[self.expertTakeArray objectAtIndex:self.selectedIndex] objectForKey:@"experts"] count] > indexPath.row) {
//        
//        commentArray = [[[self.expertTakeArray objectAtIndex:self.selectedIndex] objectForKey:@"experts"] mutableCopy];
//    }
//    
//    if ([commentArray count]>0 && (indexPath.row < [commentArray count])){
//       
//        self.expertCommentNameLabel.text = [[commentArray objectAtIndex:indexPath.row] objectForKey:@"name"];
//        self.expertCommentTitaleLabel.text = [[commentArray objectAtIndex:indexPath.row] objectForKey:@"designation"];
//        self.expertCommentTextview.text = [[commentArray objectAtIndex:indexPath.row] objectForKey:@"comment"];
//    }
    

}

- (void)collectionView:(UICollectionView *)collectionView deselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
}

-(void)rateNewsRequestSuccessfulWithStatus:(NSString *)status{
    
    self.ratingView.value = [status floatValue];
    
}
-(void)rateNewsRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    
    [Utility showMessage:error withTitle:@"Error"];
}


@end
