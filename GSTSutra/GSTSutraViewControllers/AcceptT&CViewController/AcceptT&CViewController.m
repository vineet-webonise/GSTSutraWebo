//
//  AcceptT&CViewController.m
//  GSTSutra
//
//  Created by niyuj on 10/25/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import "AcceptT&CViewController.h"
#import "OTPViewController.h"

@interface AcceptT_CViewController ()<OTPGenrateAndVerifyRequestDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *TermsAndConditionWebview;
- (IBAction)acceptButtonClicked:(id)sender;
- (IBAction)declineButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *acceptDeclineViewHeightConstrain;

@end

@implementation AcceptT_CViewController

#pragma mark -
#pragma mark - View Life Cycle.
#pragma mark -

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem.enabled=NO;
    self.navigationItem.rightBarButtonItem=nil;
    
    if (self.isFromMenu) {
        self.acceptDeclineViewHeightConstrain.constant = 0;
        [self.view updateConstraints];
    }
    [self setNavigationBarTitleLabel:@"Terms & Conditions"];
    NSString *urlAddress = [SERVER_API stringByAppendingString:@"/terms_and_conditions"];
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    self.TermsAndConditionWebview.backgroundColor = [UIColor clearColor];
    [self.TermsAndConditionWebview loadRequest:requestObj];
    
}
#pragma mark - webview Delegates 

- (void)webViewDidStartLoad:(UIWebView *)webView{
    [self startProgressHUD];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self stopProgressHUD];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error{
    [self stopProgressHUD];
}

- (IBAction)acceptButtonClicked:(id)sender {
    
    if ([self checkReachability]) {
        [self startProgressHUD];
        OTPGenrateAndVerifyRequest *req = [[OTPGenrateAndVerifyRequest alloc] init];
        req.delegate = self;
        [req verifyTermsAndCondition:@"1"];
    } else {
        [self noInternetAlert];
    }
    
}

- (IBAction)declineButtonClicked:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - Accept Terms & Condition Delegate 

-(void)verifyTermsAndConditionRequestSuccessfulWithStatus:(NSString *)status{
    [self stopProgressHUD];
    [USERDEFAULTS setBool:YES forKey:@"terms"];
    if ([USERDEFAULTS boolForKey:@"isVerified"]) {
        [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"] animated:YES];
    }  else {
        // open OTP Screen
        OTPViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OTPViewController"];
        vc.isFromLogin = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadDrawerData" object:self ];
    
}
-(void)verifyTermsAndConditionRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
}


@end
