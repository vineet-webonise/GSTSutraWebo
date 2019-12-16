//
//  LoginViewController.m
//  GSTSutra
//
//  Created by niyuj on 10/20/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import "LoginViewController.h"
#import "TextFieldValidator.h"
#import "Utility.h"
#import "HomeViewController.h"
#import "LoginForgotAndChangePasswordRequest.h"
#import "AcceptT&CViewController.h"
#import "OTPViewController.h"

@interface LoginViewController ()<LoginForgotAndChangePasswordRequestDelegate>
- (IBAction)loginButtonClicked:(id)sender;
- (IBAction)forgotPasswordButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *foregetPasswordButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@property (weak, nonatomic) IBOutlet TextFieldValidator *usernameTextField;
@property (weak, nonatomic) IBOutlet TextFieldValidator *passwordTextField;
@property(nonatomic,retain)NSString *txtEmailID;
@property (weak, nonatomic) IBOutlet UIView *usenameView;
@property (weak, nonatomic) IBOutlet UIView *passwordView;
- (IBAction)RememberPasswordButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *RememberPasswordButton;

@end

@implementation LoginViewController

#pragma mark -
#pragma mark - Controller Life Cycle
#pragma mark -

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //Hide Navigation bar
    self.navigationController.navigationBarHidden = YES;
    // Do not open Left Drawer
    [Utility SetPanGestureOff];
    

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpView];
     //NSLog(@"userToken from DB %@",[USERDEFAULTS valueForKey:@"userToken"]);
    
}

#pragma mark
#pragma mark - Set up View 
#pragma mark

-(void)setUpView{
    
    // validate textfields
    self.usernameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.usernameTextField addRegx:@"^.{1,80}$" withMsg:@"Please enter valid user name"];
    [self.passwordTextField addRegx:@"^.{1,80}$" withMsg:@"Please enter valid password"];
    self.usernameTextField.returnKeyType = UIReturnKeyNext;
    
    if([USERDEFAULTS boolForKey:@"isRememberUsername"]){
        self.usernameTextField.text = [USERDEFAULTS valueForKey:@"userName"];
        [self.RememberPasswordButton setImage:[UIImage imageNamed:@"chkboxtic"] forState:UIControlStateNormal];
    } else {
        self.usernameTextField.text = @"";
        [self.RememberPasswordButton setImage:[UIImage imageNamed:@"checkbox"] forState:UIControlStateNormal];
    }
        
    
    // Set Background Image
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[Utility imageWithImage:[UIImage imageNamed:@"background"] scaledToSize:CGSizeMake(SCREENWIDTH, SCREENHEIGHT)]]];
    
    [self.usenameView setBackgroundColor:[UIColor colorWithPatternImage:[Utility imageWithImage:[UIImage imageNamed:@"text_box"] scaledToSize:CGSizeMake(SCREENWIDTH - 80, self.usenameView.frame.size.height)]]];
    [self.passwordView setBackgroundColor:[UIColor colorWithPatternImage:[Utility imageWithImage:[UIImage imageNamed:@"text_box"] scaledToSize:CGSizeMake(SCREENWIDTH - 80, self.passwordView.frame.size.height)]]];
    
    
    // Set Button Underline
    
    [self.foregetPasswordButton setAttributedTitle:[self buttonsWithUnderLineTitleString:self.foregetPasswordButton.titleLabel.text] forState:UIControlStateNormal];
    
    [self.registerButton setAttributedTitle:[self buttonsWithUnderLineTitleString:self.registerButton.titleLabel.text] forState:UIControlStateNormal];
}

#pragma mark
#pragma mark - UIButton With Underline.
#pragma mark

-(NSMutableAttributedString*)buttonsWithUnderLineTitleString:(NSString*)buttonTitle{
    
    NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:buttonTitle];
    [titleString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [titleString length])];
    return titleString;
    
}

#pragma mark -
#pragma mark - UIButton Actions
#pragma mark -

- (IBAction)loginButtonClicked:(id)sender {
    
    if ([self.usernameTextField validate] & [self.passwordTextField validate]) {
        
        if ([self checkReachability]) {
            [self startProgressHUD];
            
                        LoginForgotAndChangePasswordRequest *request = [[LoginForgotAndChangePasswordRequest alloc] init];
                        request.delegate = self;
                        [request loginWithUsername:self.usernameTextField.text andPassword:self.passwordTextField.text];
            
        }else {
            [self noInternetAlert];
            [self stopProgressHUD];
        }
        
        
    }else {
        [Utility showMessage:@"please tap red iCon" withTitle:@"Error!"];
        
    }
    
}

- (IBAction)forgotPasswordButtonClicked:(id)sender {
    
    [self openAlertWithTextField];
}

#pragma mark
#pragma mark UITextField Delegate
#pragma mark


-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.usernameTextField]) {
        [self.passwordTextField becomeFirstResponder];
    } else {
        [self.passwordTextField resignFirstResponder];
    }
    return YES;
}


#pragma mark - Login Request

-(void)loginRequestSuccessfulWithStatus:(NSString *)status{
    [self stopProgressHUD];
    [USERDEFAULTS setBool:NO forKey:@"isLogin"];
    [USERDEFAULTS setBool:NO forKey:@"isNotRegisterOrLoginUser"];
    [USERDEFAULTS setValue:self.usernameTextField.text forKey:@"userName"];
    [USERDEFAULTS setValue:self.passwordTextField.text forKey:@"password"];
    [USERDEFAULTS synchronize];
    OTPViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OTPViewController"];
    
    if (![USERDEFAULTS boolForKey:@"terms"]){
        vc.isFromLogin = YES;
        [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"AcceptT_CViewController"] animated:YES];
        
    }else if (appD.isFromNotification){
        if (appD.stype == 8) {
            [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"LongNewsViewController"] animated:YES];
        } else if (appD.stype == 9) {
            [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"ExpertLongViewController"] animated:YES];
        }else if (appD.stype == 11) {
            [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"ExpertTakeLngViewController"] animated:YES];
        }else if (appD.stype == 25) {
            [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"videoPlayerViewController"] animated:YES];
        }else if (appD.stype == 22) {
            [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"SiteLinksViewController"] animated:YES];
        } else if (appD.stype == 23) {
            [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"ForumDetailViewController"] animated:YES];
        }
        
        
    }else if ([USERDEFAULTS boolForKey:@"isVerified"]) {
        [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"] animated:YES];
    } else {
        // open OTP Screen
        
        vc.isFromLogin = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadDrawerData" object:self ];
    
}

-(void)loginRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
    [USERDEFAULTS setBool:YES forKey:@"isLogin"];
    [Utility showMessage:error withTitle:@"Error!"];
}


-(void)openAlertWithTextField{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Forgot Password"
                                                                   message:@"Please Enter UserName"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        // optionally configure the text field
        textField.keyboardType = UIKeyboardTypeEmailAddress;
        textField.placeholder = @"USERNAME";
        
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"SUBMIT"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         UITextField *textField = [alert.textFields firstObject];
                                                         
                                                         self.txtEmailID = textField.text;
                                                         //NSLog(@"Alert textfield %@",textField.text);
                                                         [textField resignFirstResponder];
                                                         [self forgotPasswordAPICall];
                                                     }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"CANCEL"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                             
                                                         }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}


-(void)forgotPasswordAPICall{
    
    // check for valid Username
    if ([ self validateUserName:self.txtEmailID]) {
        // Call Forgot password API.
        if ([self checkReachability]) {
            [self startProgressHUD];
            LoginForgotAndChangePasswordRequest *req = [[LoginForgotAndChangePasswordRequest alloc] init];
            req.delegate = self ;
            [req forgotPasswordForUserName:self.txtEmailID];
            
        } else {
            [self stopProgressHUD];
            [self noInternetAlert];
        }
        
    } else {
        [Utility showMessage:@"Please enter valid Username" withTitle:@"warning"];
        [self openAlertWithTextField];
    }
    
}


#pragma mark - Forgot password Delegate

-(void)forgotPasswordEmailSentSuccessfullyWithStatus:(NSString *)status withMessage:(NSString *)message{
    [self stopProgressHUD];
    [Utility showMessage:message withTitle:@"Success!!"];
    
}

-(void)forgotPasswordEmailSentFailureWithStatus:(NSString *)status andWithErrorMessage:(NSString *)message{
    
    [self stopProgressHUD];
    [Utility showMessage:message withTitle:@"Error!!"];
    
}

- (IBAction)RememberPasswordButtonClicked:(id)sender {
    if ([sender isSelected]) {
        [sender setImage:[UIImage imageNamed:@"checkbox"] forState:UIControlStateNormal];
        [USERDEFAULTS setBool:NO forKey:@"isRememberUsername"];
        [sender setSelected:NO];
    } else {
        [sender setImage:[UIImage imageNamed:@"chkboxtic"] forState:UIControlStateNormal];
         [USERDEFAULTS setBool:YES forKey:@"isRememberUsername"];
        [sender setSelected:YES];
    }
    
}
@end
