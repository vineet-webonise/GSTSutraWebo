//
//  ProfileViewController.m
//  GSTSutra
//
//  Created by niyuj on 11/9/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import "ProfileViewController.h"
#import "SignUpModel.h"
#import "SignUpRequest.h"
#import "signupTableViewCell.h"
#import "ChangePasswordViewController.h"
#import "HomeViewController.h"
#import "Constants.h"
#import "AppData.h"
#import "UIImageView+WebCache.h"
#import "LoginForgotAndChangePasswordRequest.h"
#import "uploadProfilePictureRequest.h"
#import "OTPViewController.h"
#import "UIImageView+Letters.h"


@interface ProfileViewController ()<UIGestureRecognizerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate,SignUpRequestDelegate,LoginForgotAndChangePasswordRequestDelegate,uploadProfilePictureRequestDelegate>{
    UITapGestureRecognizer *singleTap;
    NSArray *placeholdersArray,*iconImagesArray;
    BOOL isProfilePicSelected;
    SignUpModel *signUpData;
}

//@property (nonatomic, strong) SignUpModel *signUpData;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
- (IBAction)submitButtonClicked:(id)sender;
- (IBAction)cancelButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *registrationTableVIew;
- (IBAction)changePasswordButtonClicked:(id)sender;
@property(nonatomic,retain)NSString *txtMobileNumber;
@property (weak, nonatomic) IBOutlet UIButton *changePasswordButton;

@end

@implementation ProfileViewController

#pragma mark -
#pragma mark - Controller Life Cycle
#pragma mark -

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.rightBarButtonItem.enabled=NO;
    self.navigationItem.rightBarButtonItem=nil;
    if (!isProfilePicSelected) {
        signUpData = [[SignUpModel alloc] init];
        if ([self checkReachability]) {
            [self startProgressHUD];
            LoginForgotAndChangePasswordRequest *req = [[LoginForgotAndChangePasswordRequest alloc] init];
            req.delegate = self;
            [req getUserProfile];
            
        } else {
            [self stopProgressHUD];
            [self showMessage:@"No Internet " withTitle:@"Error"];
        }
    }
[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadDrawerData" object:self ];
}

#pragma mark - Get User Profile
-(void)getUserProfileRequestSuccessfulWithStatus:(NSString *)status{
    [self stopProgressHUD];
    
    @try {
        signUpData.UserName = userLogData.UserName;
        signUpData.FirstLastName = userLogData.FirstLastName;
        signUpData.FirstName = userLogData.FirstLastName;
        signUpData.profileImageURLString = [ImageSERVER_API stringByAppendingString:userLogData.profileImage];
        signUpData.EmailId = userLogData.EmailId;
        signUpData.MobileNumber = userLogData.MobileNumber;
        signUpData.City = userLogData.City;
        signUpData.CompanyName = userLogData.CompanyName;
        
        if ([self checkImageExtensionWithImage:signUpData.profileImageURLString]) {
            // Here we use the new provided sd_setImageWithURL: method to load the web image
            [self.profileImageView sd_setImageWithURL:[NSURL URLWithString:signUpData.profileImageURLString]placeholderImage:[UIImage imageNamed:@"userimage.png"]];
        } else {
            {
                if (signUpData.FirstName == (id)[NSNull null] || [signUpData.FirstName isEqualToString:@""] ){
                    //if ([[USERDEFAULTS valueForKey:@"fullName"] isEqualToString:@""]) {
                    //update username
                    
                    [self.profileImageView setImageWithString:[USERDEFAULTS valueForKey:@"username"] color:nil circular:YES];
                } else {
                    
                    [self.profileImageView setImageWithString:[USERDEFAULTS valueForKey:@"fullName"] color:nil circular:YES];
                }
                
            }
            
        }
        
        
        [self.registrationTableVIew reloadData];

    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

-(void)getUserProfileRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
    [self showMessage:error withTitle:@"Error"];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBarTitleLabel:@"Profile"];
    isProfilePicSelected = NO;
    // Set Background Image
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[Utility imageWithImage:[UIImage imageNamed:@"background"] scaledToSize:CGSizeMake(SCREENWIDTH, SCREENHEIGHT)]]];
    
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height /2;
    self.profileImageView.layer.masksToBounds = YES;
    self.profileImageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.profileImageView.layer.borderWidth = 1.0;
    // Enable tap guesture for image View.
    
    singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneTap:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    singleTap.delegate = self;
    [self.profileImageView addGestureRecognizer:singleTap];
    
    placeholdersArray = [[NSArray alloc] initWithObjects:
                         @"USERNAME",
                         @"NAME",
                         @"EMAIL ID",
                         @"MOBILE NUMBER",
                         @"COMPANY",
                         @"CITY",
                         nil];
    iconImagesArray = [[NSArray alloc] initWithObjects:
                       @"username",
                       @"username",
                       @"email",
                       @"mobile",
                       @"company",
                       @"city",
                       nil];
   signUpData = [[SignUpModel alloc] init];
    [self.changePasswordButton setAttributedTitle:[self buttonsWithUnderLineTitleString:self.changePasswordButton.titleLabel.text] forState:UIControlStateNormal];
}

#pragma mark
#pragma mark - UIButton With Underline.
#pragma mark

-(NSMutableAttributedString*)buttonsWithUnderLineTitleString:(NSString*)buttonTitle{
    
    NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:buttonTitle];
    [titleString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [titleString length])];
    return titleString;
    
}
# pragma mark -
# pragma mark - UITableview DataSource and delegate
# pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectio{
    
    return [placeholdersArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    @try {
        signupTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"signupTableViewCell"];
        if (cell==nil) {
            cell=[[signupTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"signupTableViewCell"];
        }
        
        cell.signUpTextField.placeholder = [placeholdersArray objectAtIndex:indexPath.row];
        cell.iconImageView.image = [UIImage imageNamed:[iconImagesArray objectAtIndex:indexPath.row]];
        [cell.containerView setBackgroundColor:[UIColor colorWithPatternImage:[Utility imageWithImage:[UIImage imageNamed:@"text_box"] scaledToSize:CGSizeMake(cell.containerView.frame.size.width, cell.containerView.frame.size.height)]]];
        cell.signUpTextField.delegate = self;
        cell.signUpTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        cell.signUpTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        cell.signUpTextField.tag = indexPath.row;
        
        if (indexPath.row == 0) {
            cell.signUpTextField.userInteractionEnabled = NO;
        } else {
            cell.signUpTextField.userInteractionEnabled = YES;
        }
        
        if (indexPath.row == 0) {
            if (userLogData.UserName) {
                cell.signUpTextField.text =  signUpData.UserName;
            } else {
                cell.signUpTextField.text= nil;
            }
            
        }else if (indexPath.row == 1){
            if (![userLogData.FirstLastName isEqual: [NSNull null]]) {
                
                cell.signUpTextField.text =  signUpData.FirstName;
                
            } else {
                cell.signUpTextField.text= nil;
            }
            
        }else if (indexPath.row == 2){
            if (![userLogData.EmailId isEqual: [NSNull null]]) {
                cell.signUpTextField.text =  signUpData.EmailId;;
            } else {
                cell.signUpTextField.text= nil;
            }
            
        }else if (indexPath.row == 3){
            if (![userLogData.MobileNumber isEqual: [NSNull null]]) {
                cell.signUpTextField.text =  signUpData.MobileNumber;
            } else {
                cell.signUpTextField.text= nil;
            }
            
        }else if (indexPath.row == 4){
            if (![userLogData.CompanyName isEqual: [NSNull null]]) {
                cell.signUpTextField.text =  signUpData.CompanyName;
            } else {
                cell.signUpTextField.text= nil;
            }
            
        }else if (indexPath.row == 5){
            if (![userLogData.City isEqual: [NSNull null]]) {
                cell.signUpTextField.text =  signUpData.City;
                
            } else {
                cell.signUpTextField.text= nil;
            }
        }
        cell.backgroundColor = [UIColor clearColor];
        
        return cell;
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}


-(void)openAlertWithTextField{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Mobile Number"
                                                                   message:@"Please enter your mobile number"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        // optionally configure the text field
       
        textField.placeholder = @"MOBILE NUMBER";
        textField.keyboardType = UIKeyboardTypePhonePad;
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



#pragma mark --------------------------------------------------------------
#pragma mark UITextField Delegate
#pragma mark ---------------------------------------------------------------

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    
    if (textField.tag == 2) {
        textField.keyboardType = UIKeyboardTypeEmailAddress;
        
    } else if (textField.tag == 3){
        [self openAlertWithTextField];
    }
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    if (textField.tag == 0) {
        signUpData.UserName = [textField.text stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];
    }else if (textField.tag == 1){
        signUpData.FirstName = textField.text;
    }else if (textField.tag == 2){
        signUpData.EmailId = textField.text;
    }else if (textField.tag == 3){
        signUpData.MobileNumber = textField.text;
    }else if (textField.tag == 4){
        signUpData.CompanyName = textField.text;
    }else if (textField.tag == 5){
        signUpData.City = textField.text;
    }
    
    
}
- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.tag == 3) {
        NSString *resultText = [textField.text stringByReplacingCharactersInRange:range withString:string];
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

# pragma mark -
# pragma mark - select profile picture action
# pragma mark -

-(void)oneTap:(UITapGestureRecognizer*)sender{
    [self takePhotoActionSheetDialog];
}

-(void)takePhotoActionSheetDialog{
    
    UIAlertController* alert = [UIAlertController
                                alertControllerWithTitle:nil      //  Must be "nil", otherwise a blank title area will appear above our two buttons
                                message:nil
                                preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* cancelButton = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action)
                                   {
                                       //  UIAlertController will automatically dismiss the view
                                   }];
    
    UIAlertAction* cameraButton = [UIAlertAction
                                   actionWithTitle:@"Take photo"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
                                   {
                                       //  The user tapped on "Take a photo"
                                       
                                       if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                                           
                                           [Utility showMessage:@"Device has no camera" withTitle:@"Error"];
                                           ;
                                       } else {
                                           
                                           UIImagePickerController *imagePickerController= [[UIImagePickerController alloc] init];
                                           imagePickerController.allowsEditing = YES;
                                           imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                                           imagePickerController.delegate = self;
                                           [self presentViewController:imagePickerController animated:YES completion:^{}];
                                       }
                                       
                                   }];
    
    UIAlertAction* galleryButton = [UIAlertAction
                                    actionWithTitle:@"Choose Existing"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        //  The user tapped on "Choose existing"
                                        UIImagePickerController *imagePickerController= [[UIImagePickerController alloc] init];
                                        imagePickerController.allowsEditing = YES;
                                        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                        imagePickerController.delegate = self;
                                        [self presentViewController:imagePickerController animated:YES completion:^{}];
                                    }];
    
    [alert addAction:cancelButton];
    [alert addAction:cameraButton];
    [alert addAction:galleryButton];
    
    if (IPAD) {
        [alert.popoverPresentationController setPermittedArrowDirections:0];
        
        //For set action sheet to middle of view.
        alert.popoverPresentationController.sourceView = self.view;
        alert.popoverPresentationController.sourceRect = self.view.bounds;
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.profileImageView.image = chosenImage;
    signUpData.profileImage = UIImageJPEGRepresentation(chosenImage, 0.0);
    isProfilePicSelected = YES;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}


#pragma mark -
#pragma mark - UIButton Action
#pragma mark -

- (IBAction)submitButtonClicked:(id)sender {
    //NSLog(@"Submit Button Clicked");
    
    if ([signUpData.FirstLastName isEqual:[NSNull null]]  || signUpData.FirstLastName == nil) {
        signUpData.FirstLastName = @"";
    } if ([signUpData.FirstName isEqual:[NSNull null]] || signUpData.FirstName == nil) {
        signUpData.FirstName = @"";
    } if ([signUpData.City isEqual:[NSNull null]] || signUpData.City == nil) {
        signUpData.City = @"";
    } if ([signUpData.CompanyName isEqual:[NSNull null]] || signUpData.CompanyName == nil) {
        signUpData.CompanyName = @"";
    }
    
   if (![self validateUserName:signUpData.UserName]) {
    
       [self showMessage:@"Username is invalid " withTitle:@""];
   }else if (![self validateEmail:signUpData.EmailId]) {
        
        [self showMessage:@"Email is invalid " withTitle:@""];
    } else {
        
        if ([self checkReachability]) {
            [self startProgressHUD];
            SignUpRequest *request = [[SignUpRequest alloc] init];
            request.delegate = self;
            signUpData.FirstLastName = signUpData.FirstName;
            [request updateProfileWithUser:signUpData];
            
        }else {
            [self stopProgressHUD];
            [self noInternetAlert];
        }

    }
}

#pragma mark - Validation Alert View

-(void)showMessage:(NSString*)message withTitle:(NSString *)title
{
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:title
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
        //do something when click button
    }];
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}


- (IBAction)cancelButtonClicked:(id)sender {
    //NSLog(@"Cancel Button Clicked");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadDrawerData" object:self ];
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"] animated:YES];
}


#pragma mark

-(void)profileUpdatedeSuccessfullyWithStatusInfo:(NSString *)status andWithMessage:(NSString *)message{
    [self stopProgressHUD];
    if (isProfilePicSelected) {
        [self startProgressHUD];
        uploadProfilePictureRequest *req = [[uploadProfilePictureRequest alloc] init];
        req.delegate = self;
        [req uploadUserProfilePicture:signUpData];
    } else {
        //[self viewWillAppear:YES];
        [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"] animated:YES];
        [Utility showMessage:@"Profile updated successfully" withTitle:@"Success!!"];
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadDrawerData" object:self ];
}

-(void)profileUpdateFailedWithStatusInfo:(NSString *)status andWithErrorMessage:(NSString *)errorMessage{
    [self stopProgressHUD];
    [Utility showMessage:errorMessage withTitle:@"Error"];
    
}

#pragma mark - Change Profile picture delegate

-(void)profilePictureUploadedSuccessfullyWithStatusInfo:(NSString *)status andWithMessage:(NSString *)message{
    [self stopProgressHUD];
    isProfilePicSelected = NO;
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"] animated:YES];
        //[self viewWillAppear:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadDrawerData" object:self ];
    [Utility showMessage:@"Profile updated successfully" withTitle:@"Success!"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadDrawerData" object:self ];

}
-(void)profilePictureUploadedFailedWithStatusInfo:(NSString *)status andWithErrorMessage:(NSString *)errorMessage{
    [self stopProgressHUD];
    isProfilePicSelected = YES;
    //[self.profileImageView setImageWithString:[USERDEFAULTS valueForKey:@"fullName"] color:nil circular:YES];
    [Utility showMessage:errorMessage withTitle:@"Error"];
}

#pragma mark - change mobile number

-(void)changeMobileNumberSuccessfullyWithStatusInfo:(NSString *)status andWithMessage:(NSString *)message{
    [self stopProgressHUD];
    
    // Open Confirm Otp screen
    OTPViewController *otpView = [self.storyboard instantiateViewControllerWithIdentifier:@"OTPViewController"];
    otpView.isHavingOTP = YES;
    [self.navigationController pushViewController:otpView animated:YES];
    [Utility showMessage:message withTitle:@"Success!"];
}
-(void)changeMobileNumberFailedWithStatusInfo:(NSString *)status andWithErrorMessage:(NSString *)errorMessage{
    [self stopProgressHUD];
    [Utility showMessage:errorMessage withTitle:@"Error!"];
}

- (IBAction)changePasswordButtonClicked:(id)sender {
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"ChangePasswordViewController"] animated:YES];
}
@end
