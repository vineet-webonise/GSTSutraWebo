//
//  UserDetailsViewController.m
//  GSTSutra
//
//  Created by niyuj on 1/31/17.
//  Copyright © 2017 niyuj. All rights reserved.
//

#import "UserDetailsViewController.h"
#import "LoginForgotAndChangePasswordRequest.h"
#import "QuartzCore/QuartzCore.h"
#import "NIDropDown.h"
#import "userDetailTableViewCell.h"
#import "SignUpRequest.h"
#import "SignUpModel.h"
#import "Constants.h"
#import "AppData.h"
#import "NIDropDown.h"

@interface UserDetailsViewController ()<LoginForgotAndChangePasswordRequestDelegate,UITextFieldDelegate,NIDropDownDelegate>{
    SignUpModel *signUpData;
    NSArray *placeholdersArray;
    UIButton *btnSelect;
    NIDropDown *dropDown;
    BOOL isButtonSelected;
    int selectedIndex;
    
}

@property (weak, nonatomic) IBOutlet UITableView *userDetailTableView;
- (IBAction)PurchaseButtonClicked:(id)sender;
- (IBAction)CancelButtonClicked:(id)sender;

-(void)rel;

@end

@implementation UserDetailsViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    signUpData = [[SignUpModel alloc] init];
    [self setNavigationBarTitleLabel:@"User Details"];
    self.navigationItem.rightBarButtonItem.enabled=NO;
    self.navigationItem.rightBarButtonItem=nil;
    isButtonSelected = NO;
    placeholdersArray = [[NSArray alloc] initWithObjects:
                         @"USER NAME",
                         @"INVOICE NAME",
                         @"INVOICE ADDRESS",
                         @"COUNTRY",
                         @"EMAIL ID",
                         @"MOBILE NUMBER",
                         @"COMPANY",
                         @"CITY",
                         @"STATE",
                         @"PINCODE",
                         nil];
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
    signUpData.UserName = userLogData.UserName;
    signUpData.FirstLastName = userLogData.FirstLastName;
    signUpData.EmailId = userLogData.EmailId;
    signUpData.MobileNumber = userLogData.MobileNumber;
    signUpData.City = userLogData.City;
    signUpData.CompanyName = userLogData.CompanyName;
    [self.userDetailTableView reloadData];
    
}

-(void)getUserProfileRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
    [Utility showMessage:error withTitle:@"Error"];
}


# pragma mark -
# pragma mark - UITableview DataSource and delegate
# pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectio{
    
    return [placeholdersArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
        userDetailTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"userDetailTableViewCell"];
    if (cell==nil) {
        cell=[[userDetailTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"userDetailTableViewCell"];
        
    }
    if (indexPath.row == 0) {
        cell.signUpTextField.userInteractionEnabled = NO;
    } else {
        cell.signUpTextField.userInteractionEnabled = YES;
    }

    cell.signUpTextField.placeholder = [placeholdersArray objectAtIndex:indexPath.row];
    cell.signUpTextField.delegate = self;
    cell.signUpTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    cell.signUpTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    cell.signUpTextField.tag = indexPath.row;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.row == 8 || indexPath.row == 9) {
        
        cell.signUpTextField.hidden=YES;
        cell.selectCountryButton.hidden = NO;
        [[cell.selectCountryButton layer] setBorderWidth:1.0f];
        [[cell.selectCountryButton layer] setBorderColor:[UIColor blackColor].CGColor];
        [self.view bringSubviewToFront:cell.selectCountryButton ];
        
        if (indexPath.row == 9) {
            [cell.selectCountryButton setTitle:@"Select Country" forState:UIControlStateNormal];
        } else if (indexPath.row == 8){
            [cell.selectCountryButton setTitle:@"Select State" forState:UIControlStateNormal];
        }
        btnSelect = cell.selectCountryButton;
        [cell.selectCountryButton addTarget:self action:@selector(selectClicked:) forControlEvents:UIControlEventTouchUpInside];
        
    } else {
        cell.signUpTextField.hidden=NO;
        cell.selectCountryButton.hidden = YES;
    }
    cell.selectCountryButton.tag = indexPath.row;
    
    if (indexPath.row == 0) {
        if (userLogData.UserName) {
            cell.signUpTextField.text =  signUpData.UserName;
        } else {
            cell.signUpTextField.text= nil;
        }
        
    }else if (indexPath.row == 1){
        if (![userLogData.FirstLastName isEqual: [NSNull null]]) {
            
            cell.signUpTextField.text =  signUpData.FirstLastName;
            
        } else {
            cell.signUpTextField.text= nil;
        }
        
    }else if (indexPath.row == 2){
        if (![userLogData.Address isEqual: [NSNull null]]) {
            
            cell.signUpTextField.text =  signUpData.Address;
        } else {
            cell.signUpTextField.text= nil;
        }
        
    }else if (indexPath.row == 3){
        if (![userLogData.Country isEqual: [NSNull null]]) {
            cell.signUpTextField.text =  signUpData.Country;
        } else {
            cell.signUpTextField.text= nil;
        }
        
    }else if (indexPath.row == 4){
        if (![userLogData.EmailId isEqual: [NSNull null]]) {
            cell.signUpTextField.text =  signUpData.EmailId;
        } else {
           cell. signUpTextField.text= nil;
        }
        
    }else if (indexPath.row == 5){
        if (![userLogData.MobileNumber isEqual: [NSNull null]]) {
            cell.signUpTextField.text =  signUpData.MobileNumber;
        } else {
            cell.signUpTextField.text= nil;
        }
        
    }else if (indexPath.row == 6){
        if (![userLogData.CompanyName isEqual: [NSNull null]]) {
            cell.signUpTextField.text =  signUpData.CompanyName;
            
        } else {
            cell.signUpTextField.text= nil;
        }
    }
    else if (indexPath.row == 7){
        if (![userLogData.City isEqual: [NSNull null]]) {
            cell.signUpTextField.text =  signUpData.City;
            
        } else {
            cell.signUpTextField.text= nil;
        }
    }
    else if (indexPath.row == 8){
        if (![userLogData.State isEqual: [NSNull null]]) {
            cell.signUpTextField.text =  signUpData.State;
            
        } else {
            cell.signUpTextField.text= nil;
        }
    }
    else if (indexPath.row == 9){
        if (![userLogData.Pincode isEqual: [NSNull null]]) {
            cell.signUpTextField.text =  signUpData.Pincode;
            
        } else {
            cell.signUpTextField.text= nil;
        }
    }
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    if ( indexPath.row ==selectedIndex && isButtonSelected) {
        return 250;
    }else {
        return 55;
    }
}

#pragma mark --------------------------------------------------------------
#pragma mark UITextField Delegate
#pragma mark ---------------------------------------------------------------

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (textField.tag == 4){
        textField.keyboardType = UIKeyboardTypeEmailAddress;
    }
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    if (textField.tag == 0) {
        signUpData.UserName = [textField.text stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];
    }else if (textField.tag == 1){
        signUpData.FirstLastName = [textField.text stringByTrimmingCharactersInSet:
                                [NSCharacterSet whitespaceCharacterSet]];
    }else if (textField.tag == 2){
        signUpData.Address = [textField.text stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];
    }else if (textField.tag == 3){
        signUpData.Country = textField.text;
    }else if (textField.tag == 4){
        signUpData.EmailId = textField.text;
    }else if (textField.tag == 5){
        signUpData.MobileNumber = textField.text;
    }else if (textField.tag == 6){
        signUpData.CompanyName = textField.text;
    }else if (textField.tag == 7){
        signUpData.City = textField.text;
    }else if (textField.tag == 8){
        signUpData.State = textField.text;
    }else if (textField.tag == 4){
        signUpData.Pincode = textField.text;
    }
    
    
}
- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.tag == 4) {
        NSString *resultText = [textField.text stringByReplacingCharactersInRange:range
                                                                       withString:string];
        return resultText.length <= 10;
    } else {
        return 100;
    }
    
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}



- (IBAction)selectClicked:(UIButton*)sender {
    isButtonSelected = YES;
    selectedIndex = sender.tag;
    [self.userDetailTableView reloadData];
    NSArray * arr = [[NSArray alloc] init];
    arr = [NSArray arrayWithObjects:@"Hello 0", @"Hello 1", @"Hello 2", @"Hello 3", @"Hello 4", @"Hello 5", @"Hello 6", @"Hello 7", @"Hello 8", @"Hello 9",nil];
    NSArray * arrImage = [[NSArray alloc] init];
    arrImage = [NSArray arrayWithObjects:[UIImage imageNamed:@"apple.png"], [UIImage imageNamed:@"apple2.png"], [UIImage imageNamed:@"apple.png"], [UIImage imageNamed:@"apple2.png"], [UIImage imageNamed:@"apple.png"], [UIImage imageNamed:@"apple2.png"], [UIImage imageNamed:@"apple.png"], [UIImage imageNamed:@"apple2.png"], [UIImage imageNamed:@"apple.png"], [UIImage imageNamed:@"apple2.png"], nil];
    [self.view bringSubviewToFront:dropDown];
    if(dropDown == nil) {
        CGFloat f = 200;
        dropDown = [[NIDropDown alloc]showDropDown:sender :&f :arr :arrImage :@"down"];
        dropDown.delegate = self;
        
        
    }
    else {
        [dropDown hideDropDown:sender];
        isButtonSelected = NO;
        [self.userDetailTableView reloadData];
        [self rel];
    }
    
}

- (void) niDropDownDelegateMethod: (NIDropDown *) sender {
    [self rel];
    isButtonSelected = NO;
    //NSLog(@"%@", btnSelect.titleLabel.text);
}

-(void)rel{
    //    [dropDown release];
    dropDown = nil;
}



- (IBAction)PurchaseButtonClicked:(id)sender {
    
    
    if (![self validateUserName:signUpData.UserName]) {
        
        [Utility showMessage:@"User is Invalid " withTitle:@""];
    }else
        if (![self validateFirstName:signUpData.FirstName]) {
            
            [Utility showMessage:@"First Name is Invalid " withTitle:@""];
        }else if (![self validateFirstName:signUpData.LastName]) {
            
            [Utility showMessage:@"Last Name is Invalid " withTitle:@""];
        } else if (![self validateEmail:signUpData.EmailId]) {
            
            [Utility showMessage:@"Email is Invalid " withTitle:@""];
        }else if (![self validateCompanyName:signUpData.CompanyName]) {
            
            [Utility showMessage:@"Company is Invalid " withTitle:@""];
        }else if (![self validateCompanyName:signUpData.City]) {
            
            [Utility showMessage:@"City is Invalid " withTitle:@""];
        } else {
            
            if ([self checkReachability]) {
                [self startProgressHUD];
                SignUpRequest *request = [[SignUpRequest alloc] init];
                request.delegate = self;
                [request updateProfileWithUser:signUpData];
                
            }else {
                [self stopProgressHUD];
                [self noInternetAlert];
            }
            
        }

    
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"PurchaseDetailsViewController"] animated:YES];
}




- (IBAction)CancelButtonClicked:(id)sender {
    
//    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"] animated:YES];
    
     [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"demoViewController"] animated:YES];
}
@end
