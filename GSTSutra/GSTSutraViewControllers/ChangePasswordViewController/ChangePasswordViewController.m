//
//  ChangePasswordViewController.m
//  GSTSutra
//
//  Created by niyuj on 11/9/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "TextFieldValidator.h"
#import "LoginForgotAndChangePasswordRequest.h"

@interface ChangePasswordViewController ()<LoginForgotAndChangePasswordRequestDelegate>
@property (weak, nonatomic) IBOutlet TextFieldValidator *oldPasswordTextfield;
@property (weak, nonatomic) IBOutlet TextFieldValidator *passwordTextField;
@property (weak, nonatomic) IBOutlet TextFieldValidator *confirmPassword;
@property (weak, nonatomic) IBOutlet UIButton *saveButtonClicked;
- (IBAction)cancelButtonClicked:(id)sender;

@end

@implementation ChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Utility SetPanGestureOff];
    self.navigationController.navigationBarHidden = NO;
    [self setNavigationBarTitleLabel:@"Change Password"];
    
    [self setupBackBarButtonItems];
    
    self.navigationItem.rightBarButtonItem.enabled=NO;
    self.navigationItem.rightBarButtonItem=nil;
    

    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[Utility imageWithImage:[UIImage imageNamed:@"background"] scaledToSize:CGSizeMake(SCREENWIDTH, SCREENHEIGHT)]]];
    
    [self.saveButtonClicked addTarget:self action:@selector(savePasswordButtonClicke:) forControlEvents:UIControlEventTouchUpInside];
    [self.confirmPassword addConfirmValidationTo:self.passwordTextField withMsg:[NSString stringWithFormat:@"%@",@"Confirm password didn’t match"]];
     [self.passwordTextField addRegx:@"^.{1,80}$" withMsg:@"Please enter valid password"];
    
}

#pragma mark
#pragma mark UITextField Delegate
#pragma mark


-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    //TODO:Validation
    
    
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    
    
    
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

#pragma mark
#pragma mark UIButtonActions
#pragma mark


- (IBAction)savePasswordButtonClicke:(UIButton*)sender {
    
    @try {
//        if (![self.oldPasswordTextfield.text isEqualToString:self.passwordTextField.text ]) {
            if([self.oldPasswordTextfield validate] & [self.passwordTextField validate] & [self.confirmPassword validate]){
                //Success
                if (![self.oldPasswordTextfield.text isEqualToString:self.passwordTextField.text ]) {
                //NSLog(@"Valid data");
                if ([self checkReachability]) {
                    [self startProgressHUD];
                    LoginForgotAndChangePasswordRequest * req = [[LoginForgotAndChangePasswordRequest alloc] init];
                    req.delegate = self;
                    [req changeCurrentPassword:self.oldPasswordTextfield.text withNewPassword:self.passwordTextField.text];
                    
                }else {
                    [self stopProgressHUD];
                    [self noInternetAlert];
                }
                } else {
                    [Utility showMessage:@"Old and new password is same" withTitle:@""];
                }
                
            }else {
                // Error
                [Utility showMessage:@"Please tap red icon..." withTitle:@""];
            }
        //}
        
//        else {
//            [Utility showMessage:@"Old and new password is same" withTitle:@"Error!"];
//        }

    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
    }

-(void)confirmPasswordRequestSuccessfulWithStatus:(NSString *)status withMessage:(NSString *)message{
    [self stopProgressHUD];
    
    [self.navigationController popViewControllerAnimated:YES];
    [Utility showMessage:message withTitle:@"Congratulations!"];
}

-(void)confirmPasswordRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
    [Utility showMessage:error withTitle:@"Error!"];
    
}

- (IBAction)cancelButtonClicked:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}
@end
