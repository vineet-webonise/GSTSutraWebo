//
//  demoViewController.m
//  GSTSutra
//
//  Created by niyuj on 2/1/17.
//  Copyright © 2017 niyuj. All rights reserved.
//

#import "demoViewController.h"
#import "NIDropDown.h"
#import "QuartzCore/QuartzCore.h"
#import "LoginForgotAndChangePasswordRequest.h"
#import "QuartzCore/QuartzCore.h"
#import "NIDropDown.h"
#import "userDetailTableViewCell.h"
#import "purchaseRequest.h"
#import "SignUpModel.h"
#import "Constants.h"
#import "AppData.h"
#import "NIDropDown.h"
#import "PurchaseDetailsViewController.h"

@interface demoViewController ()<LoginForgotAndChangePasswordRequestDelegate,UITextFieldDelegate,NIDropDownDelegate,PurchaseRequestDelegate>{
    SignUpModel *signUpData;
    NSArray *placeholdersArray;
    UIButton *btnSelect;
    NIDropDown *dropDown;
    BOOL isButtonSelected;
    int selectedIndex;
    
}
- (IBAction)CancelButtonClicked:(id)sender;

- (IBAction)purchaseButtonClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *usename;
@property (weak, nonatomic) IBOutlet UITextField *fullname;
@property (weak, nonatomic) IBOutlet UITextField *address;
@property (weak, nonatomic) IBOutlet UITextField *pincode;
@property (weak, nonatomic) IBOutlet UITextField *city;
@property (weak, nonatomic) IBOutlet UIButton *stateTextField;

@property (weak, nonatomic) IBOutlet UIButton *countryButton;
- (IBAction)countryButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *stateButton;
- (IBAction)StateButtonClicked:(id)sender;

@end

@implementation demoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    signUpData = [[SignUpModel alloc] init];
    [self setNavigationBarTitleLabel:@"User Details"];
    
    //self.navigationItem.rightBarButtonItem.enabled=NO;
    self.navigationItem.rightBarButtonItem=nil;
    
    [self setupBarButtonWithoutItems];
    
    [Utility SetPanGestureOff];
    
    self.city.delegate = self;
    self.usename.delegate = self;
    
    self.pincode.keyboardType = UIKeyboardTypePhonePad;
    [[self.stateButton layer] setBorderWidth:1.0f];
    [[self.stateButton layer] setBorderColor:([UIColor lightGrayColor].CGColor)];
    
    [[self.countryButton layer] setBorderWidth:1.0f];
    [[self.countryButton layer] setBorderColor:([UIColor lightGrayColor].CGColor)];
    
    if ([self checkReachability]) {
        [self startProgressHUD];
        LoginForgotAndChangePasswordRequest *req = [[LoginForgotAndChangePasswordRequest alloc] init];
        req.delegate = self;
        [req getUserProfile];
        
    } else {
        [self stopProgressHUD];
        [self noInternetAlert];
    }
    
}

#pragma mark - Get User Profile
-(void)getUserProfileRequestSuccessfulWithStatus:(NSString *)status{
    
    [self stopProgressHUD];
    
    @try {
        signUpData.UserName = userLogData.UserName;
        signUpData.FirstLastName = userLogData.FirstLastName;
        signUpData.City = userLogData.City;
        signUpData.CountryID = @"103";
        
        self.usename.text = signUpData.UserName;
        self.fullname.text = signUpData.FirstLastName;
        self.address.text = signUpData.Address;
        self.city.text = signUpData.City;
        self.pincode.text = signUpData.Pincode;
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
}

-(void)getUserProfileRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
    [Utility showMessage:error withTitle:@"Error"];
}


-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    @try {
        if (textField == self.fullname){
            signUpData.FirstLastName = [textField.text stringByTrimmingCharactersInSet:
                                        [NSCharacterSet whitespaceCharacterSet]];
        }
        else if (textField == self.address){
            signUpData.Address = [self.address.text stringByTrimmingCharactersInSet:
                                  [NSCharacterSet whitespaceCharacterSet]];
        }else if (textField == self.city){
            signUpData.City = self.city.text;
        }else if (textField == self.pincode){
            signUpData.Pincode = self.pincode.text;
        }
        

    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}




- (IBAction)StateButtonClicked:(id)sender {
    [self.view resignFirstResponder];

    @try {
        isButtonSelected = NO;
        NSArray * arr = [[NSArray alloc]  initWithArray:[[USERDEFAULTS objectForKey:@"locationArray"] valueForKey:@"state_name"]];
        
        NSArray * arrImage = [[NSArray alloc] init];
        
        if(dropDown == nil) {
            CGFloat f = 200;
            dropDown = [[NIDropDown alloc]showDropDown:sender :&f :arr :arrImage :@"down"];
            dropDown.delegate = self;
        }
        else {
            [dropDown hideDropDown:sender];
            [self rel];
        }

    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

- (void) niDropDownDelegateMethod: (NIDropDown *) sender {
    
    @try {
        //NSLog(@"Value %@",dropDown.SelectedIndex);
        
        //NSLog(@"Value %@",[[[USERDEFAULTS objectForKey:@"locationArray"] valueForKey:@"id"] objectAtIndex:[dropDown.SelectedIndex integerValue]]);
        signUpData.StateID = [[[USERDEFAULTS objectForKey:@"locationArray"] valueForKey:@"id"] objectAtIndex:[dropDown.SelectedIndex integerValue]];
        
        [self rel];
        signUpData.State = self.stateButton.titleLabel.text;

    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

-(void)niDropDownReturnSelectedIndexDelegateMethod:(NSString *)sender{
    //NSLog(@"Value sender  %@",sender);
}

-(void)rel{
    //[dropDown release];
    dropDown = nil;
}



#pragma mark Redirect To Home Screen 

- (IBAction)CancelButtonClicked:(id)sender {
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"] animated:YES];
    
}

#pragma mark Redirect To Payment Option
- (IBAction)purchaseButtonClicked:(id)sender {
    
    
    @try {
        if (![self validateUserName:signUpData.UserName]) {
            
            [Utility showMessage:@"User is Invalid " withTitle:@""];
        }else
            if (![self validateCompanyName:signUpData.FirstLastName]) {
                
                [Utility showMessage:@"Full Name is Invalid " withTitle:@""];
            }else if (![self validateCompanyName:signUpData.Address]) {
                
                [Utility showMessage:@"Address is Invalid " withTitle:@""];
            }else if (![self validatePincode:signUpData.Pincode]) {
                
                [Utility showMessage:@"pincode is Invalid " withTitle:@""];
            }else if (![self validateCompanyName:signUpData.City]) {
                
                [Utility showMessage:@"City is Invalid " withTitle:@""];
            }else if (![self validateCompanyName:signUpData.State]) {
                
                [Utility showMessage:@"Please select state" withTitle:@""];
            } else {
                
                if ([self checkReachability]) {
                    [self startProgressHUD];
                    purchaseRequest *request = [[purchaseRequest alloc] init];
                    request.delegate = self;
                    [request userDetailsForSubscriptionPurchase:signUpData];
                    
                }else {
                    [self stopProgressHUD];
                    [self noInternetAlert];
                }
                
            }

    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
    
}



-(void)userDetailPurchaseRequestSuccessfulWithResult:(NSString *)resultUrl{
    [self stopProgressHUD];
    
    PurchaseDetailsViewController *prc =[self.storyboard instantiateViewControllerWithIdentifier:@"PurchaseDetailsViewController"];
    prc.urlString = resultUrl;
    [self.navigationController pushViewController:prc animated:YES];
    
}
-(void)userDetailPurchaseRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
    [Utility showMessage:error withTitle:@""];
}
@end
