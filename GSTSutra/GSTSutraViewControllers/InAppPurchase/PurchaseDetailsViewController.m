//
//  PurchaseDetailsViewController.m
//  GSTSutra
//
//  Created by niyuj on 1/31/17.
//  Copyright © 2017 niyuj. All rights reserved.
//

#import "PurchaseDetailsViewController.h"

@interface PurchaseDetailsViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *PurchaseWebView;
- (IBAction)cancelTransactionButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@end

@implementation PurchaseDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBarTitleLabel:@"Payment"];
    self.navigationItem.rightBarButtonItem.enabled=NO;
    self.navigationItem.rightBarButtonItem=nil;
    
    [self setupBarButtonWithoutItems];
    [Utility SetPanGestureOff];
    [self startProgressHUD];
    
    NSString *fullURL = [ImageSERVER_API stringByAppendingString:self.urlString];
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    self.PurchaseWebView.backgroundColor = [UIColor whiteColor];
    [self.PurchaseWebView loadRequest:requestObj];
}

#pragma mark -
#pragma mark - Webview Url
#pragma mark -

- (void)webViewDidStartLoad:(UIWebView *)webView{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self stopProgressHUD];
}
-(BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
navigationType:(UIWebViewNavigationType)navigationType
{
    @try {
        NSString *urlString = request.URL.absoluteString;
        if ([urlString hasSuffix:@"gotohome_app_url"]){
            
            //NSLog(@"Funtion Call goto home");
            [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"] animated:YES];
            return NO;
        }else if ([urlString hasSuffix:@"paymentsuccess"]){
            
            self.cancelButton.hidden = YES;
            
        }
        else if ([urlString hasSuffix:@"gotocancel_app_url"]){
            
            [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"demoViewController"] animated:YES];
            return NO;
            
        }
        return YES;

    } @catch (NSException *exception) {
        
    } @finally {
        
    }
   }
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error{
    [self stopProgressHUD];
}

- (IBAction)cancelTransactionButtonClicked:(id)sender {
    @try {
        
        {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Do you want to cancel transaction?" preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"demoViewController"] animated:YES];
                ;
            }]];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                // no operation dismiss view
            }]];
            
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self presentViewController:alertController animated:YES completion:nil];
            });
            
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}
@end
