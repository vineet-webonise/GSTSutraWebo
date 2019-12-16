

#import <Foundation/Foundation.h>

@protocol OTPGenrateAndVerifyRequestDelegate <NSObject>

@optional


-(void)verifyOTPRequestSuccessfulWithStatus:(NSString*)status;
-(void)verifyOTPRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

-(void)resendOTPRequestSuccessfulWithStatus:(NSString*)status;
-(void)resendOTPRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

-(void)verifyTermsAndConditionRequestSuccessfulWithStatus:(NSString*)status;
-(void)verifyTermsAndConditionRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

@end

@interface OTPGenrateAndVerifyRequest : NSObject <NSURLConnectionDataDelegate, NSURLConnectionDelegate> {
    
    NSString *requestType;
}

@property (nonatomic, strong) NSMutableData *webData;
@property (nonatomic, weak) id<OTPGenrateAndVerifyRequestDelegate> delegate;

-(void) resendOTPMessage;
-(void)verifyOTP:(NSString*)otpValue;
-(void)verifyTermsAndCondition:(NSString*)otpValue;


@end
