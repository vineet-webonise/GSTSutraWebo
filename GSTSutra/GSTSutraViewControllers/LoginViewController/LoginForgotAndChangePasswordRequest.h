
#import <Foundation/Foundation.h>

@protocol LoginForgotAndChangePasswordRequestDelegate <NSObject>

@optional
// change Password
-(void)confirmPasswordRequestSuccessfulWithStatus:(NSString*)status withMessage:(NSString*)message;
-(void)confirmPasswordRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

//forgot Password
-(void)forgotPasswordEmailSentSuccessfullyWithStatus:(NSString*)status withMessage:(NSString*)message;
-(void)forgotPasswordEmailSentFailureWithStatus:(NSString*)status andWithErrorMessage:(NSString*)message;

//Login
-(void)loginRequestSuccessfulWithStatus:(NSString*)status;
-(void)loginRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

//LogOut
-(void)logoutRequestSuccessfulWithStatus:(NSString*)status;
-(void)logoutRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

//getProfile
-(void)getUserProfileRequestSuccessfulWithStatus:(NSString*)status;
-(void)getUserProfileRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

@end


@interface LoginForgotAndChangePasswordRequest : NSObject <NSURLConnectionDataDelegate, NSURLConnectionDelegate> {
    
    NSString *requestType;
}

@property (nonatomic, strong) NSMutableData *webData;
@property (nonatomic, weak) id<LoginForgotAndChangePasswordRequestDelegate> delegate;

-(void)changeCurrentPassword:(NSString*)currentPassword withNewPassword:(NSString*)NewPassword;

-(void)forgotPasswordForUserName:(NSString*)userName;
-(void)loginWithUsername:(NSString*)username andPassword:(NSString*)password;
-(void) getLogout;
-(void) getUserProfile;


@end
