

#import "BaseViewController.h"
#import "OTPGenrateAndVerifyRequest.h"

@interface OTPViewController : BaseViewController<OTPGenrateAndVerifyRequestDelegate>
@property (nonatomic , assign) BOOL isHavingOTP;
@property (nonatomic , assign) BOOL isFromLogin;
@end
