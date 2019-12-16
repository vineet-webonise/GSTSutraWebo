//
//  ForumReplyCommentEditViewController.m
//  GSTSutra
//
//  Created by niyuj on 1/28/17.
//  Copyright © 2017 niyuj. All rights reserved.
//

#import "ForumReplyCommentEditViewController.h"
#import "ExpertCornerRequest.h"
#import "UIImageView+WebCache.h"

@interface ForumReplyCommentEditViewController ()<UITextViewDelegate,ExpertRequestDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UITextView *userCommentTextView;
@property (weak, nonatomic) IBOutlet UIButton *postButton;
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;

@end

@implementation ForumReplyCommentEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.isEditComment)
        [self setNavigationBarTitleLabel:@"Update"];
    else
    [self setNavigationBarTitleLabel:@"Reply"];
    [self setupBackBarButtonItems];
    self.navigationItem.rightBarButtonItem.enabled=NO;
    self.navigationItem.rightBarButtonItem=nil;
    
    @try {
        self.userImageView.layer.cornerRadius = self.userImageView.frame.size.height /2;
        self.userImageView.layer.masksToBounds = YES;
        self.userImageView.layer.borderWidth = 1.0;
        
        if ([self checkImageExtensionWithImage:[USERDEFAULTS valueForKey:@"profileImage"]])  {
            [self.userImageView sd_setImageWithURL:[NSURL URLWithString:[ImageSERVER_API stringByAppendingString:[USERDEFAULTS valueForKey:@"profileImage"]]]placeholderImage:[UIImage imageNamed:@"username.png"]];
        }
        else {
            [self.userImageView setImageWithString:[USERDEFAULTS valueForKey:@"fullName"] color:nil circular:YES];
            
        }
        
        
        
        
        self.commentTextView.delegate = self;
        self.commentTextView.layer.borderWidth = 1.5f;
        self.commentTextView.layer.borderColor = [[UIColor blackColor] CGColor];
        self.commentTextView.autocorrectionType = UITextAutocorrectionTypeNo;
        self.commentTextView.attributedText = [[NSAttributedString alloc] initWithData:[self.editableText dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]} documentAttributes:nil error:nil];
        
        if (_isEditComment) {
            [self.postButton setTitle:@"Update" forState:UIControlStateNormal];
            [self.postButton addTarget:self action:@selector(updateCommentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            
        } else {
            [self.postButton setTitle:@"Post" forState:UIControlStateNormal];
            [self.postButton addTarget:self action:@selector(postCommentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        }

    } @catch (NSException *exception) {
        
    } @finally {
        
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

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    //NSLog(@"textViewShouldEndEditing:");
    
    return YES;
}
- (void)textViewDidChangeSelection:(UITextView *)textView{
    //postString = textView.text;
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    //NSLog(@"textViewDidEndEditing:");
    
    
}

-(void)postCommentButtonClicked:(UIButton*)sender{

    @try {
        NSString *trimmedString = [self.commentTextView.text stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceCharacterSet]];
        
        if (trimmedString.length > 0 ) {
            if ([self checkReachability]) {
                [self startProgressHUD];
                ExpertCornerRequest *newsReq = [[ExpertCornerRequest alloc] init];
                newsReq.delegate=self;
                if (_isReplyToComment) {
                    
                    [newsReq replyToForumCommentWithCommentID:_commentID commentString:trimmedString withNID:self.nID];
                } else {
                    [newsReq replyToStoryForumCommentWithCommentID:_commentID commentString:trimmedString withNID:self.nID];
                    
                }
                
                
                
            } else {
                [self noInternetAlert];
            }
        } else {
            
            [Utility showMessage:@"Please Write Something in Comment Box" withTitle:@"Empty "];
            
            
        }

    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

-(void)updateCommentButtonClicked:(UIButton*)sender{
    [self.view resignFirstResponder];
    
    @try {
        NSString *trimmedString = [self.commentTextView.text stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceCharacterSet]];
        
        if (trimmedString.length > 0 ) {
            if ([self checkReachability]) {
                [self startProgressHUD];
                ExpertCornerRequest *newsReq = [[ExpertCornerRequest alloc] init];
                newsReq.delegate=self;
                
                [newsReq editForumCommentWithCommentID:_commentID commentString:trimmedString withNID:self.nID];
                
            } else {
                [self noInternetAlert];
            }
        } else {
            
            [Utility showMessage:@"Please Write Something in Comment Box" withTitle:@"Empty "];
            
            
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

#pragma mark
#pragma mark - Edit comment 
#pragma mark

-(void)editCommentRequestSuccessfulWithResult:(NSString *)msg{
     [self stopProgressHUD];
    
    [self.navigationController popViewControllerAnimated:YES];
    [Utility showMessage:@"Comment updated successfully" withTitle:@""];
}
-(void)editCommentRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
    [Utility showMessage:error withTitle:@""];
}

#pragma mark
#pragma mark - Reply to story
#pragma mark

-(void)replyToStoryRequestSuccessfulWithResult:(NSString *)msg{
    [self stopProgressHUD];
    
    [self.navigationController popViewControllerAnimated:YES];
    [Utility showMessage:@"Comment posted successfully" withTitle:@""];
    
}

-(void)replyToStoryRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
    [Utility showMessage:error withTitle:@""];
    
    
}

#pragma mark
#pragma mark - Reply to comment
#pragma mark

-(void)replyToCommentRequestSuccessfulWithResult:(NSString *)msg{
    [self stopProgressHUD];
    
    [self.navigationController popViewControllerAnimated:YES];
    [Utility showMessage:@"Comment posted successfully" withTitle:@""];
    
}

-(void)replyToCommentRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
    [Utility showMessage:error withTitle:@""];
}

@end
