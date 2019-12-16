//
//  BaseViewController.h
//  OMI-Pharmacy
//


#import <UIKit/UIKit.h>
#import "Utility.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "Constants.h"
#import <CoreLocation/CoreLocation.h>
#import "UIImageView+Letters.h"
#import "FMDatabase.h"
#import "AppDelegate.h"


@interface BaseViewController : UIViewController<CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
    AppDelegate *appD; 
}

@property (nonatomic,retain)MBProgressHUD *hud;

-(void)startProgressHUD;
-(void)stopProgressHUD;
-(BOOL)checkReachability;
-(void)noInternetAlert;
-(void)setNavigationBar;
-(void)setupMenuBarButtonItems;
-(void)setupBarButtonWithoutItems;
-(void)setNavigationBarTitleLabel:(NSString*)titleLabelText;

#pragma mark - Textfield Validation. 
- (BOOL)validateUserName:(NSString *)userName;
- (BOOL)validateFirstName:(NSString *)FirstName;
- (BOOL)validateEmail:(NSString *)emailid;
- (BOOL)validatepassword:(NSString *)password;
- (BOOL)validatePhone:(NSString *)phoneNumber;
- (BOOL)validatePincode:(NSString *)phoneNumber;
- (BOOL)validateCompanyName:(NSString *)CompanyName;
-(void)setupBackBarButtonItems;
//-(void)openLoginViewControllerAlert;
-(void)openLoginViewControllerAlertOnLeftMenuOrView:(BOOL)isLeftMenu;
-(BOOL)checkImageExtensionWithImage:(NSString*)imageURL;

-(NSString*)getYoutubeVideoThumbnail:(NSString*)youTubeUrl;


@end
