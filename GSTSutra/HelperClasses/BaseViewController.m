//
//  BaseViewController.m
//  OMI-Pharmacy


#import "BaseViewController.h"
#import "MFSideMenu.h"
#import "LoginViewController.h"
#import "SearchViewController.h"




@interface BaseViewController (){
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
}

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMenuBarButtonItems];
    [self setNavigationBar];
    appD = APPDELEGATE;
    
}

#pragma mark - Navigation Controller 

-(void)setNavigationBarTitleLabel:(NSString*)titleLabelText{
    UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectZero];
    titleView.font = [UIFont fontWithName:centuryGothicBold size:18];
    titleView.textColor = [UIColor whiteColor];
    titleView.text = titleLabelText;
    [titleView sizeToFit];
    titleView.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = titleView;
}

-(void)setNavigationBar{
    
    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:42/255.0 green:49/255.0 blue:73/255.0 alpha:1.0];
    
    [self setupMenuBarButtonItems];
    
}

-(void)setupMenuBarButtonItems {
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -16;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, [self leftMenuBarButtonItem], nil];
    self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
    
}


-(void)setupBackBarButtonItems {
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -16;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, [self leftBackBarButtonItem], nil];
    self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
    
}

-(void)setupBarButtonWithoutItems {
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -16;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, [self leftBarButtonWithoutItem], nil];
    self.navigationItem.rightBarButtonItem = nil;
    
}




- (UIBarButtonItem *)leftMenuBarButtonItem {
    
    UIButton *leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBarButton setFrame:CGRectMake(0, 0, 45, 45)];
    [leftBarButton setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    [leftBarButton addTarget:self action:@selector(leftSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
}

- (UIBarButtonItem *)leftBackBarButtonItem {
    
    UIButton *leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBarButton setFrame:CGRectMake(0, 0, 45, 45)];
    [leftBarButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [leftBarButton addTarget:self action:@selector(leftSideBackButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
}

- (UIBarButtonItem *)leftBarButtonWithoutItem {
    
    UIButton *leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBarButton setFrame:CGRectMake(0, 0, 45, 45)];
    [leftBarButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [leftBarButton addTarget:self action:@selector(leftSideButtonWithoutItemPressed:) forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
}

- (void)leftSideButtonWithoutItemPressed:(id)sender {
    
}

- (void)leftSideBackButtonPressed:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(UIBarButtonItem*)rightMenuBarButtonItem {
    UIButton *rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBarButton setFrame:CGRectMake(0, 0, 45, 45)];
    [rightBarButton setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [rightBarButton addTarget:self action:@selector(rightSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
}

- (void)leftSideMenuButtonPressed:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        [self setupMenuBarButtonItems];
    }];
}

-(void)rightSideMenuButtonPressed:(id)sender {
    
    if ([USERDEFAULTS boolForKey:@"isNotRegisterOrLoginUser"]) {
        [self openLoginViewControllerAlertOnLeftMenuOrView:NO];
    } else {
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"] animated:YES];
    }
}

#pragma mark - check image extension

-(BOOL)checkImageExtensionWithImage:(NSString*)imageURL{
    NSArray *imageExtensions = @[@"png", @"jpg", @"gif",@"jpeg"]; //...
    
    // Iterate & match the URL objects from your checking results
    NSString *extension = [[NSURL URLWithString: imageURL] pathExtension];
        if ([imageExtensions containsObject:extension]) {
            
            return true;
        } else {
            //no Image in URL 
            return false;
        }
}


#pragma mark - HUD methods

//method for starting Progress HUD for network activity
-(void)startProgressHUD {
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.labelText = NSLocalizedString(@"Please Wait...", nil);
    [self.hud show:YES];
}

//method for stoping Progress HUD for network activity
-(void)stopProgressHUD {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

-(BOOL)checkReachability {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    
    switch (internetStatus) {
        case NotReachable:
            return 0;
            break;
        case ReachableViaWiFi:
            return 1;
            break;
        case ReachableViaWWAN:
            return 1;
            break;
            
        default:
            return 0;
            break;
    }
}

-(void)noInternetAlert{
    [self stopProgressHUD];
    
    [Utility showMessage:@"No internet connection, please try again " withTitle:@""];
}

#pragma mark-  TextFields Validation

- (BOOL)validateUserName:(NSString *)userName
{
    NSString *phoneRegex = @"^.{1,80}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [phoneTest evaluateWithObject:userName];
}
- (BOOL)validateFirstName:(NSString *)FirstName
{
    NSString *phoneRegex = @"^[A-Za-z]{1,60}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    
    return [phoneTest evaluateWithObject:FirstName];
}

- (BOOL)validateCompanyName:(NSString *)CompanyName
{
    NSString *phoneRegex = @"^.{1,80}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    
    return [phoneTest evaluateWithObject:CompanyName];
}


- (BOOL)validateEmail:(NSString *)emailid{
    NSString *phoneRegex = @"[A-Z0-9a-z._%+-]{1,}+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [phoneTest evaluateWithObject:emailid];
}
- (BOOL)validatepassword:(NSString *)password{
    NSString *phoneRegex = @"^.{1,80}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    
    return [phoneTest evaluateWithObject:password];
}
- (BOOL)validatePhone:(NSString *)phoneNumber
{
    NSString *phoneRegex = @"[0-9]{10}";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    
    return [phoneTest evaluateWithObject:phoneNumber];
}

- (BOOL)validatePincode:(NSString *)phoneNumber
{
    NSString *phoneRegex = @"[0-9]{6}";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    
    return [phoneTest evaluateWithObject:phoneNumber];
}

-(void)openLoginViewControllerAlertOnLeftMenuOrView : (BOOL)isLeftMenu{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"You are not signed in"
                                                                   message:@"Login or Register for free access."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"LOGIN OR REGISTER"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                        
                                                         [self openLoginScreenWithBoolValue:isLeftMenu];
                                                     }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"CANCEL"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                             
                                                         }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)openLoginScreenWithBoolValue:(BOOL)isMenu{
    if (isMenu) {
       LoginViewController  *login = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        NSArray *controllers = [NSArray arrayWithObject:login];
        navigationController.viewControllers = controllers;
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
        
    } else {
    
   [ self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"] animated:YES];
    }
}


-(NSString*)getYoutubeVideoThumbnail:(NSString*)youTubeUrl
{
    NSString* video_id = @"";
    
    if (youTubeUrl.length > 0)
    {
        NSError *error = NULL;
        NSRegularExpression *regex =
        [NSRegularExpression regularExpressionWithPattern:@"(?<=watch\\?v=|/videos/|embed\\/)[^#\\&\\?]*"
                                                  options:NSRegularExpressionCaseInsensitive
                                                    error:&error];
        NSTextCheckingResult *match = [regex firstMatchInString:youTubeUrl
                                                        options:0
                                                          range:NSMakeRange(0, [youTubeUrl length])];
        if (match)
        {
            NSRange videoIDRange = [match rangeAtIndex:0];
            video_id = [youTubeUrl substringWithRange:videoIDRange];
            
            //NSLog(@"%@",video_id);
        }
    }
    
    NSString* thumbImageUrl = [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/mqdefault.jpg",video_id];
    
    return thumbImageUrl;
}

@end
