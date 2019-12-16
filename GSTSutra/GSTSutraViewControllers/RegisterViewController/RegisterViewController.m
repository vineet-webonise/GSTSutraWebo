
#import "RegisterViewController.h"
#import "SignUpModel.h"
#import "SignUpRequest.h"
#import "signupTableViewCell.h"
#import "uploadProfilePictureRequest.h"
#import "OTPViewController.h"


@interface RegisterViewController ()<UIGestureRecognizerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate,SignUpRequestDelegate,uploadProfilePictureRequestDelegate>{
    UITapGestureRecognizer *singleTap;
    NSArray *placeholdersArray,*iconImagesArray;
    BOOL isProfilePicSelected,isUserExist;
}

@property (nonatomic, strong) SignUpModel *signUpData;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
- (IBAction)submitButtonClicked:(id)sender;
- (IBAction)cancelButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *TermsAndConditionView;
- (IBAction)AcceptButtonClicked:(id)sender;
- (IBAction)DeclineButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *registrationTableVIew;
@property (weak, nonatomic) IBOutlet UIWebView *termsWebView;

@end

@implementation RegisterViewController

#pragma mark -
#pragma mark - Controller Life Cycle
#pragma mark -

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //Hide Navigation bar
    self.navigationController.navigationBarHidden = YES;
    // Set background to terms and condition view
    
    [self.TermsAndConditionView setBackgroundColor:[UIColor colorWithPatternImage:[Utility imageWithImage:[UIImage imageNamed:@"trms_n_conditions"] scaledToSize:CGSizeMake(self.view.frame.size.width,self. view.frame.size.height)]]];
    [self.registrationTableVIew reloadData];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isProfilePicSelected = NO;
    isUserExist = NO;
    // Set Background Image
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[Utility imageWithImage:[UIImage imageNamed:@"background"] scaledToSize:CGSizeMake(SCREENWIDTH, SCREENHEIGHT)]]];

        self.TermsAndConditionView.hidden = YES;
    
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
                              @"EMAIL ID",
                              @"USERNAME",
                              @"PASSWORD",
                              @"MOBILE NUMBER",
                              @"NAME",
                              @"COMPANY",
                              @"CITY",
                              nil];
    iconImagesArray = [[NSArray alloc] initWithObjects:
                         @"email",
                         @"username",
                         @"Password",
                         @"mobile",
                         @"username",
                         @"company",
                         @"city",
                         nil];
    self.signUpData = [[SignUpModel alloc] init];
}



# pragma mark -
# pragma mark - UITableview DataSource and delegate
# pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectio{
    
    return [placeholdersArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    signupTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"signupTableViewCell"];
    if (cell==nil) {
        cell=[[signupTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"signupTableViewCell"];
    }
    
    @try {
        cell.signUpTextField.placeholder = [placeholdersArray objectAtIndex:indexPath.row];
        cell.iconImageView.image = [UIImage imageNamed:[iconImagesArray objectAtIndex:indexPath.row]];
        [cell.containerView setBackgroundColor:[UIColor colorWithPatternImage:[Utility imageWithImage:[UIImage imageNamed:@"text_box"] scaledToSize:CGSizeMake(SCREENWIDTH - 90, cell.containerView.frame.size.height)]]];
        cell.signUpTextField.delegate = self;
        cell.signUpTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        if (indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 6 || indexPath.row == 7 ) {
            cell.signUpTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        } else {
            cell.signUpTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        }
        
        cell.signUpTextField.tag = indexPath.row;
        UILabel *star = (UILabel*)[cell viewWithTag:8];
        
        if (indexPath.row >3) {
            star.hidden = YES;
        }
        
        if (indexPath.row == 0) {
            if (self.signUpData.EmailId) {
                cell.signUpTextField.text =  self.signUpData.EmailId;
                [cell.signUpTextField canBecomeFocused];
            } else {
                cell.signUpTextField.text= nil;
            }
            
        }else if (indexPath.row == 1){
            if (self.signUpData.UserName) {
                cell.signUpTextField.text =  self.signUpData.UserName;
            } else {
                cell.signUpTextField.text= nil;
            }
            
        }else if (indexPath.row == 2){
            if (self.signUpData.Password) {
                cell.signUpTextField.text =  self.signUpData.Password;;
            } else {
                cell.signUpTextField.text= nil;
            }
            
        }else if (indexPath.row == 3){
            if (self.signUpData.MobileNumber) {
                cell.signUpTextField.text =  self.signUpData.MobileNumber;;
            } else {
                cell.signUpTextField.text= nil;
            }
            
        }else if (indexPath.row == 4){
            if (self.signUpData.FirstName) {
                cell.signUpTextField.text =  self.signUpData.FirstName;
            } else {
                cell.signUpTextField.text= nil;
            }
            
        }else if (indexPath.row == 5){
            if (self.signUpData.CompanyName) {
                cell.signUpTextField.text =  self.signUpData.CompanyName;
            } else {
                cell.signUpTextField.text= nil;
            }
            
        }else if (indexPath.row == 6){
            if (self.signUpData.City) {
                cell.signUpTextField.text =  self.signUpData.City;
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

-(void)chackUsernameSuccessfullyWithStatusInfo:(NSString *)status andWithMessage:(NSString *)message{
    
    isUserExist = NO;
}
-(void)chackUsernameFailedWithStatusInfo:(NSString *)status andWithErrorMessage:(NSString *)errorMessage{
    isUserExist = YES;
    [Utility showMessage:errorMessage withTitle:@""];
}

#pragma mark --------------------------------------------------------------
#pragma mark UITextField Delegate
#pragma mark ---------------------------------------------------------------

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    
    if (textField.tag == 0) {
        textField.keyboardType = UIKeyboardTypeEmailAddress;
        
    } else if (textField.tag == 2){
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.secureTextEntry = YES;
        
    } else if (textField.tag == 3){
        textField.keyboardType = UIKeyboardTypePhonePad;
    }
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    if (textField.tag == 0) {
        self.signUpData.EmailId = textField.text;
        self.signUpData.UserName =  [[textField.text componentsSeparatedByString:@"@"] firstObject];
        [self.registrationTableVIew reloadData];
        SignUpRequest *req = [[SignUpRequest alloc] init];
        req.delegate = self;
        [req checkUserIsAlreadyExistOrNotWithUserName:self.signUpData];
        
    }else if (textField.tag == 1){
        self.signUpData.UserName = [textField.text stringByTrimmingCharactersInSet:
                                    [NSCharacterSet whitespaceCharacterSet]];
        SignUpRequest *req = [[SignUpRequest alloc] init];
        req.delegate = self;
        [req checkUserIsAlreadyExistOrNotWithUserName:self.signUpData];
        
    }else if (textField.tag == 2){
        self.signUpData.Password = textField.text;
    }else if (textField.tag == 3){
        self.signUpData.MobileNumber = textField.text;
    }else if (textField.tag == 4){
        self.signUpData.FirstName = textField.text;
    }else if (textField.tag == 5){
        self.signUpData.CompanyName = textField.text;
    }else if (textField.tag == 6){
        self.signUpData.City = textField.text;
    }
    
}
- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.tag == 3) {
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
        self.signUpData.profileImage = UIImageJPEGRepresentation(chosenImage, 0.0);
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
    
    @try {
        if ([self.signUpData.FirstLastName isEqual:[NSNull null]]  || self.signUpData.FirstLastName == nil) {
            self.signUpData.FirstLastName = @"";
        } if ([self.signUpData.FirstName isEqual:[NSNull null]] || self.signUpData.FirstName == nil) {
            self.signUpData.FirstName = @"";
        } if ([self.signUpData.City isEqual:[NSNull null]] || self.signUpData.City == nil) {
            self.signUpData.City = @"";
        } if ([self.signUpData.CompanyName isEqual:[NSNull null]] || self.signUpData.CompanyName == nil) {
            self.signUpData.CompanyName = @"";
        }
        
        if (![self validateUserName:self.signUpData.UserName]) {
            
            [self showMessage:@"Username is invalid" withTitle:@""];
        } else if (![self validateEmail:self.signUpData.EmailId]) {
            
            [self showMessage:@"Email id  invalid" withTitle:@""];
        } else if (![self validatepassword:self.signUpData.Password]) {
            
            [self showMessage:@"Password is invalid" withTitle:@""];
        }else if (![self validatePhone:self.signUpData.MobileNumber]) {
            
            [self showMessage:@"Mobile number is invalid" withTitle:@""];
        } else {
            if (isUserExist) {
                [Utility showMessage:@"Username already exist" withTitle:@""];
            } else {
                self.TermsAndConditionView.hidden = NO;
                [self.view bringSubviewToFront:self.TermsAndConditionView];
                [self loadwebViewUrl];
            }
        }

    } @catch (NSException *exception) {
        
    } @finally {
        
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
    [self.navigationController popViewControllerAnimated:YES];
   // [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"] animated:YES];
}

- (IBAction)AcceptButtonClicked:(id)sender {
    //NSLog(@"Accept Button Clicked");
    
    if ([self checkReachability]) {
        [self startProgressHUD];
        SignUpRequest *request = [[SignUpRequest alloc] init];
        request.delegate = self;
        self.signUpData.FirstLastName = self.signUpData.FirstName;
        [request registerWithUser:self.signUpData];
        
    }else {
        [self stopProgressHUD];
        [self noInternetAlert];
    }

}

- (IBAction)DeclineButtonClicked:(id)sender {
    //NSLog(@"Decline Button Clicked");
    self.TermsAndConditionView.hidden = YES;
}

#pragma mark - register delegate

-(void)registrationCompletedSuccessfullyWithStatusInfo:(NSString *)status andWithMessage:(NSString *)message{
    [self stopProgressHUD];
    
    if (isProfilePicSelected) {
        uploadProfilePictureRequest *req = [[uploadProfilePictureRequest alloc] init];
        req.delegate = self;
        [req uploadUserProfilePicture:self.signUpData];
    } else {
        
        OTPViewController *otp = [self.storyboard instantiateViewControllerWithIdentifier:@"OTPViewController"];
        otp.isHavingOTP = YES;
        [self.navigationController pushViewController:otp animated:YES];
        [Utility showMessage:message withTitle:@"success!"];
    }
    
    
}

-(void)registrationFailedWithStatusInfo:(NSString *)status andWithErrorMessage:(NSString *)errorMessage {
    [self stopProgressHUD];
    [self showMessage:errorMessage withTitle:@"Fail!"];
    
}

#pragma mark - Change Profile picture delegate
-(void)profilePictureUploadedSuccessfullyWithStatusInfo:(NSString *)status andWithMessage:(NSString *)message{
    [self stopProgressHUD];
    isProfilePicSelected = NO;
    OTPViewController *otp = [self.storyboard instantiateViewControllerWithIdentifier:@"OTPViewController"];
    otp.isHavingOTP = YES;
    [self.navigationController pushViewController:otp animated:YES];
    [self showMessage:message withTitle:@"success!"];
}
-(void)profilePictureUploadedFailedWithStatusInfo:(NSString *)status andWithErrorMessage:(NSString *)errorMessage{
    [self stopProgressHUD];
    [self showMessage:errorMessage withTitle:@"Error"];
}

#pragma mark - webview

-(void)loadwebViewUrl{
    
    //[ImageSERVER_API stringByAppendingString:[[self.longViewNewsArray objectAtIndex:self.selectedIndex] objectForKey:@"longview"]];
    self.termsWebView.hidden = NO;
    NSString *urlAddress = [SERVER_API stringByAppendingString:@"/terms_and_conditions"];
    //Create a URL object.
    NSURL *url = [NSURL URLWithString:urlAddress];
    
    //URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    self.termsWebView.backgroundColor = [UIColor clearColor];
    //Load the request in the UIWebView.
    [self.termsWebView loadRequest:requestObj];
    
    
}
#pragma mark - Web View Delegates

- (void)webViewDidStartLoad:(UIWebView *)webView;
{
    [self startProgressHUD];
}
//a web view starts loading
- (void)webViewDidFinishLoad:(UIWebView *)webView;
{

    [self stopProgressHUD];
}
//web view finishes loading
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
{
    [self stopProgressHUD];
    
}

@end
