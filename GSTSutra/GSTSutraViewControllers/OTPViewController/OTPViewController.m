

#import "OTPViewController.h"
#import "TextFieldValidator.h"
#import "AppData.h"
#import "LoginForgotAndChangePasswordRequest.h"
#import "SignUpRequest.h"

@interface OTPViewController ()<LoginForgotAndChangePasswordRequestDelegate,SignUpRequestDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet TextFieldValidator *otpTextField;
- (IBAction)nextButtonClick:(id)sender;
- (IBAction)resendOPTButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *resendOTPButton;
- (IBAction)changeMobileNumberButtonClicked:(id)sender;
@property(nonatomic,retain)NSString *txtMobileNumber;

@property (weak, nonatomic) IBOutlet UIButton *changeMobileNumber;
@property (weak, nonatomic) IBOutlet UIButton *resendOTP;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@end

@implementation OTPViewController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //self.navigationController.navigationBar.hidden = YES;
    self.navigationController.navigationBarHidden = YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.otpTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.otpTextField.delegate = self;
    // Set Background Image
    
    @try {
        if (self.isFromLogin) {
            [self openAlertWithTextField];
        }
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[Utility imageWithImage:[UIImage imageNamed:@"background"] scaledToSize:CGSizeMake(SCREENWIDTH, SCREENHEIGHT)]]];
        self.resendOTPButton.hidden = YES;
        [USERDEFAULTS setBool:NO forKey:@"isVerified"];
        [USERDEFAULTS setBool:YES forKey:@"isLogin"];
        
        
        
        if (!self.isHavingOTP) {
            //[self callWSToGetOTP];
        } else {
            
        }
        
        [self createButtonWithUnderline];
        [self.otpTextField addRegx:@"^.{6,6}$" withMsg:@"OTP Should be 6 Digit"];
        [self startTimer];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
}

#pragma mark -Button With Undeline

-(void)createButtonWithUnderline{
    
    [self.changeMobileNumber setAttributedTitle:[self buttonsWithUnderLineTitleString:self.changeMobileNumber.titleLabel.text] forState:UIControlStateNormal];
    
    [self.nextButton setAttributedTitle:[self buttonsWithUnderLineTitleString:self.nextButton.titleLabel.text] forState:UIControlStateNormal];
    
    [self.resendOTP setAttributedTitle:[self buttonsWithUnderLineTitleString:self.resendOTP.titleLabel.text] forState:UIControlStateNormal];
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
#pragma mark - Get OTP API Call 

-(void)callWSToGetOTP{
    OTPGenrateAndVerifyRequest *req = [[OTPGenrateAndVerifyRequest alloc] init];
    req.delegate = self;
    [req resendOTPMessage];
}

-(void)startTimer{
    [NSTimer scheduledTimerWithTimeInterval:35.0
                                     target:self
                                   selector:@selector(enableResendOTPButton:)
                                   userInfo:nil
                                    repeats:YES];
}
-(void)enableResendOTPButton : (NSTimer*)sender {
    self.resendOTPButton.hidden = NO;
    [sender invalidate];
}


- (IBAction)nextButtonClick:(id)sender {
    
    if ([self.otpTextField validate]) {
        if ([self checkReachability]) {
            [self startProgressHUD];
            OTPGenrateAndVerifyRequest *req = [[OTPGenrateAndVerifyRequest alloc] init];
            req.delegate = self;
            [req verifyOTP:self.otpTextField.text];
        }else {
            [self stopProgressHUD];
            [self noInternetAlert];
        }
        
    }else {
        [Utility showMessage:@"Please enter valid OTP" withTitle:@"Warning"];
    }
}

- (IBAction)resendOPTButtonClicked:(id)sender {
    
    if ([self checkReachability]) {
        [self callWSToGetOTP];
    }else {
        [self stopProgressHUD];
        [self noInternetAlert];
    }
    self.resendOTPButton.hidden = YES;
    [self startTimer];
}

-(void)resendOTPRequestSuccessfulWithStatus:(NSString *)status{
    [self stopProgressHUD];
}

-(void)resendOTPRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error {
    [self stopProgressHUD];

    [Utility showMessage:error withTitle:@""];
}


#pragma mark - is verified 

-(void)verifyOTPRequestSuccessfulWithStatus:(NSString *)status {
    
    [self stopProgressHUD];
    [USERDEFAULTS setBool:NO forKey:@"isLogin"];
    [USERDEFAULTS setBool:YES forKey:@"isVerified"];
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"] animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadDrawerData" object:self ];
}

-(void)verifyOTPRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];

    [Utility showMessage:error withTitle:@""];
}
- (IBAction)changeMobileNumberButtonClicked:(id)sender {
    [self openAlertWithTextField];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *currentString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (currentString.length == 6) {
        // call next button API
        
        {
            
                if ([self checkReachability]) {
                    [self startProgressHUD];
                    OTPGenrateAndVerifyRequest *req = [[OTPGenrateAndVerifyRequest alloc] init];
                    req.delegate = self;
                    [req verifyOTP:currentString];
                }else {
                    [self stopProgressHUD];
                    [self noInternetAlert];
                }
                
            }
        
    }
    return YES;
}

-(void)openAlertWithTextField{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Mobile Number "
                                                                   message:@"Please enter your mobile number"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        // optionally configure the text field
        
        textField.placeholder = @"MOBILE NUMBER";
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Change"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         UITextField *textField = [alert.textFields firstObject];
                                                         
                                                         self.txtMobileNumber = textField.text;
                                                         //NSLog(@"Alert textfield %@",textField.text);
                                                         [textField resignFirstResponder];
                                                         [self changeMobileNumberAction];
                                                     }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                             
                                                         }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)changeMobileNumberAction{
    
    if ([self validatePhone:self.txtMobileNumber]) {
        // Call change mobile API.
        if ([self checkReachability]) {
            [self startProgressHUD];
            SignUpRequest *req = [[SignUpRequest alloc] init];
            req.delegate = self ;
            [req changeMobileNumber:self.txtMobileNumber];
            
        } else {
            [self stopProgressHUD];
            [self noInternetAlert];
        }
        
    } else {
        [Utility showMessage:@"Please enter valid mobile number" withTitle:@""];
        [self openAlertWithTextField];
    }
    
}

-(void)changeMobileNumberSuccessfullyWithStatusInfo:(NSString *)status andWithMessage:(NSString *)message{
    [self stopProgressHUD];
    [Utility showMessage:@"Mobile number change successfully." withTitle:@"Success!"];
}
-(void)changeMobileNumberFailedWithStatusInfo:(NSString *)status andWithErrorMessage:(NSString *)errorMessage{
    [self stopProgressHUD];
    
}

@end
