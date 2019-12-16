//
//  LawsLongViewController.m
//  GSTSutra
//
//  Created by niyuj on 11/28/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import "LawsLongViewController.h"

@interface LawsLongViewController (){
    UIScrollView *titleScrolview, *discriptionScrolview;
}
@property (weak, nonatomic) IBOutlet UILabel *lawTitle;
@property (weak, nonatomic) IBOutlet UILabel *lawDiscriptionLabel;
@property (weak, nonatomic) IBOutlet UIWebView *lawsWebView;
- (IBAction)downloadButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *discriptionTextview;

@end

@implementation LawsLongViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.isFormsSelected) {
        [self setNavigationBarTitleLabel:@"GST Forms"];
    } else{
        [self setNavigationBarTitleLabel:@"GST Laws"];
    }
    [self setupBackBarButtonItems];
    
    @try {
        self.lawTitle.text = [[self.longViewLawsArray objectAtIndex:self.selectedIndex] objectForKey:@"title"];
        self.lawTitle.font = [UIFont fontWithName:centuryGothicBold size:titleFont];
        [self.discriptionTextview setContentOffset:CGPointZero animated:YES];
        self.lawDiscriptionLabel.font = [UIFont fontWithName:centuryGothicRegular size:normalFont];
        self.discriptionTextview.font = [UIFont fontWithName:centuryGothicRegular size:normalFont];
        
        
        self.discriptionTextview.text = [[self.longViewLawsArray objectAtIndex:self.selectedIndex] objectForKey:@"description"];
        self.discriptionTextview.editable = NO;
        
        self.lawsWebView.hidden = NO;
        self.lawsWebView.scalesPageToFit = YES;
        self.lawsWebView.backgroundColor = [UIColor clearColor];
        
        NSString *fullURL = [[ImageSERVER_API stringByAppendingString:[[self.longViewLawsArray objectAtIndex:self.selectedIndex] objectForKey:@"pdflink"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        if ([self checkImageExtensionWithImage:fullURL]) {
            self.lawsWebView.userInteractionEnabled = YES;
            
            NSURL *url = [NSURL URLWithString:fullURL];
            
            NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
            [self.lawsWebView loadRequest:requestObj];
        } else {
            [Utility showMessage:@"No attachment found" withTitle:@""];
            self.lawsWebView.userInteractionEnabled = NO;
        }

    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
}


-(BOOL)checkImageExtensionWithImage:(NSString*)imageURL{
    NSArray *imageExtensions = @[@"pdf"];
    
    // Iterate & match the URL objects from your checking results
    NSString *extension = [[NSURL URLWithString: imageURL] pathExtension];
    if ([imageExtensions containsObject:extension]) {
        
        return true;
    } else {
        //no Image in URL
        return false;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    [self startProgressHUD];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self stopProgressHUD];
    NSCachedURLResponse *urlResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:webView.request];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) urlResponse.response;
    NSInteger statusCode = httpResponse.statusCode;
    if (statusCode > 399) {
        NSError *error = [NSError errorWithDomain:@"HTTP Error" code:httpResponse.statusCode userInfo:@{@"response":httpResponse}];
        [self webView:webView didFailLoadWithError:error];
        // Forward the error to webView:didFailLoadWithError: or other
        
    }
    else {
        // No HTTP error
    }
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error{
    [self stopProgressHUD];
    
}
- (IBAction)downloadButtonClicked:(id)sender {
    
    @try {
        NSString *fullURL = [[ImageSERVER_API stringByAppendingString:[[self.longViewLawsArray objectAtIndex:self.selectedIndex] objectForKey:@"pdflink"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSURL *url = [NSURL URLWithString:fullURL];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        } else{
            [Utility showMessage:@"Invalid Url" withTitle:@"Error!"];
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
}
@end
