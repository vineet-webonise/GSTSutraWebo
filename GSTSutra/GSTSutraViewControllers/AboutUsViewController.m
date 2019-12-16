//
//  AboutUsViewController.m
//  GSTSutra
//
//  Created by niyuj on 12/8/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import "AboutUsViewController.h"
#import "Constants.h"

@interface AboutUsViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *aboutUsWebView;

@end

@implementation AboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBarTitleLabel:@"About Us"];
    //[self setupBackBarButtonItems];
    
    self.navigationItem.rightBarButtonItem.enabled=NO;
    self.navigationItem.rightBarButtonItem=nil;
    
    @try {
        [self.aboutUsWebView setBackgroundColor:[UIColor clearColor]];
        [self startProgressHUD];
        NSString *fullURL = [ImageSERVER_API stringByAppendingString:@"/app/about_us"];
        NSURL *url = [NSURL URLWithString:fullURL];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        [self.aboutUsWebView loadRequest:requestObj];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }

    
}

#pragma mark - web view delegates 

- (void)webViewDidStartLoad:(UIWebView *)webView{
    //[self stopProgressHUD];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self stopProgressHUD];
}

- (BOOL)webView:(UIWebView *)wv shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    // Determine if we want the system to handle it.
    @try {
        NSURL *url = request.URL;
        if (![url.scheme isEqual:@"http"] && ![url.scheme isEqual:@"https"]) {
            if ([[UIApplication sharedApplication]canOpenURL:url]) {
                [[UIApplication sharedApplication]openURL:url];
                [self stopProgressHUD];
                return NO;
            }
        }
        
        return YES;

    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error{
    [self stopProgressHUD];
}


@end
