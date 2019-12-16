

#import "OTPGenrateAndVerifyRequest.h"
#import "Constants.h"
#import "AppData.h"

@implementation OTPGenrateAndVerifyRequest

-(void)bodyWithUrlRequest:(NSMutableURLRequest*)urlRequest postString:(NSMutableString*)postString{
    
    NSData *body ;
    body = [postString dataUsingEncoding:NSUTF8StringEncoding];
    
    [urlRequest setValue:[USERDEFAULTS valueForKey:@"userToken"] forHTTPHeaderField:@"token"];
    [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [urlRequest setHTTPBody:body];
    NSURLConnection *urlConnection;
    urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:YES];
}

-(void)verifyOTP:(NSString *)otpValue {
    requestType = @"verifyOTP";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/otp_verify"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"otp", otpValue];
    [postString appendFormat:@"&%@=%@", @"token", [USERDEFAULTS valueForKey:@"userToken"]];
    [postString appendFormat:@"&%@=%@", @"mac_id", [[NSUserDefaults standardUserDefaults]valueForKey:@"macID"]];
    [postString appendFormat:@"&%@=%@", @"device_token", [USERDEFAULTS valueForKey:@"deviceID"]];
    [postString appendFormat:@"&%@=%@", @"device_type", @"ios"];
    [self bodyWithUrlRequest:urlRequest postString:postString];
    
}

-(void) resendOTPMessage {
    requestType = @"resendOTP";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/resend_otp"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"token",[USERDEFAULTS valueForKey:@"userToken"]];
    [self bodyWithUrlRequest:urlRequest postString:postString];
}

-(void)verifyTermsAndCondition:(NSString *)otpValue {
    requestType = @"verifyTC";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/terms_condition"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"flag", otpValue];
    [postString appendFormat:@"&%@=%@", @"mac_id", [[NSUserDefaults standardUserDefaults]valueForKey:@"macID"]];
    [postString appendFormat:@"&%@=%@", @"device_token", [USERDEFAULTS valueForKey:@"deviceID"]];
    [postString appendFormat:@"&%@=%@", @"device_type", @"ios"];
    [self bodyWithUrlRequest:urlRequest postString:postString];
    
}



#pragma mark- NSURLConnection Protocol Methods

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.webData = [[NSMutableData alloc]init];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.webData appendData:data];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self requestCompletedWithData];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if ([requestType isEqualToString:@"verifyOTP"]) {
        if ([self.delegate respondsToSelector:@selector(verifyOTPRequestFailedWithStatus:wihtError:)]) {
            [self.delegate verifyOTPRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    } else if ([requestType isEqualToString:@"verifyTC"]) {
        if ([self.delegate respondsToSelector:@selector(verifyTermsAndConditionRequestFailedWithStatus:wihtError:)]) {
            [self.delegate verifyTermsAndConditionRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(resendOTPRequestFailedWithStatus:wihtError:)]) {
            [self.delegate resendOTPRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];}
    }
    
}

-(void)requestCompletedWithData {
    
    @try {
        
        NSString *temp = [[NSString alloc]initWithData:self.webData encoding:NSUTF8StringEncoding];
        //NSLog(@"Response = %@",temp);
        
        NSError *error;
        NSMutableDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:self.webData options:NSJSONReadingAllowFragments error:&error];
        
         if ([requestType isEqualToString:@"verifyOTP"]) {
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                if ([self.delegate respondsToSelector:@selector(verifyOTPRequestSuccessfulWithStatus:)]) {
                    //NSLog(@"Login Success!");
                    UserModel *user = [[UserModel alloc] init];
                    [USERDEFAULTS setValue:[[jsonDict objectForKey:@"result"] objectForKey:@"token"] forKey:@"userToken"];
                    [USERDEFAULTS synchronize];
                    user.UserName = [[jsonDict objectForKey:@"result"] objectForKey:@"username"];
                    [USERDEFAULTS setObject:[[jsonDict objectForKey:@"result"] objectForKey:@"username"] forKey:@"username"];
                    [USERDEFAULTS setValue:[[jsonDict objectForKey:@"result"] objectForKey:@"userid"] forKey:@"userid"];
                    [USERDEFAULTS  setValue:[[jsonDict objectForKey:@"result"] objectForKey:@"username"] forKey:@"username"];
                    user.FirstLastName = [[jsonDict objectForKey:@"result"] objectForKey:@"full_name"] ;
                    if (![[[jsonDict objectForKey:@"result"] objectForKey:@"full_name"] isEqual:[NSNull null]]){
                        [USERDEFAULTS  setValue:[[jsonDict objectForKey:@"result"] objectForKey:@"full_name"] forKey:@"fullName"];
                    }else {
                        [USERDEFAULTS  setValue:@"" forKey:@"fullName"];
                    }
                    user.profileImage = [[jsonDict objectForKey:@"result"] objectForKey:@"profile_pic"];
                    [USERDEFAULTS  setValue:[[jsonDict objectForKey:@"result"] objectForKey:@"profile_pic"] forKey:@"profileImage"];
                    user.EmailId = [[jsonDict objectForKey:@"result"] objectForKey:@"email"];
                    user.MobileNumber = [[jsonDict objectForKey:@"result"] objectForKey:@"mobile"];
                    user.CompanyName = [[jsonDict objectForKey:@"result"] objectForKey:@"company_name"];
                    user.isPaid = [[jsonDict objectForKey:@"result"] objectForKey:@"is_paid"];
                    [USERDEFAULTS  setValue:[[jsonDict objectForKey:@"result"] objectForKey:@"share_url_ios"] forKey:@"shareURL"];
                    user.City = [[jsonDict objectForKey:@"result"] objectForKey:@"city"];
                    user.isVerified = [[jsonDict objectForKey:@"result"] objectForKey:@"is_verified"] ;
                    user.locationArray = [[jsonDict objectForKey:@"result"] objectForKey:@"locations"];
                    [USERDEFAULTS setObject:[[jsonDict objectForKey:@"result"] objectForKey:@"locations"] forKey:@"locationArray"];
                    
                    [USERDEFAULTS setBool:[[[jsonDict objectForKey:@"result"] objectForKey:@"is_verified"] boolValue] forKey:@"isVerified"];
                    [AppData getInstance].currentUser = user;
                    [self.delegate verifyOTPRequestSuccessfulWithStatus:[jsonDict objectForKey:@"status"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(verifyOTPRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate verifyOTPRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                }
            }
         } else if ([requestType isEqualToString:@"verifyTC"]) {
             if ([[jsonDict objectForKey:@"status"] integerValue]) {
                 if ([self.delegate respondsToSelector:@selector(verifyTermsAndConditionRequestSuccessfulWithStatus:)]) {
                     [self.delegate verifyTermsAndConditionRequestSuccessfulWithStatus:[jsonDict objectForKey:@"status"]];
                 }
             } else {
                 if ([self.delegate respondsToSelector:@selector(verifyTermsAndConditionRequestFailedWithStatus:wihtError:)]) {
                     [self.delegate verifyTermsAndConditionRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                 }
             }
         } else if ([requestType isEqualToString:@"resendOTP"]) {
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                if ([self.delegate respondsToSelector:@selector(resendOTPRequestSuccessfulWithStatus:)]) {
                    [self.delegate resendOTPRequestSuccessfulWithStatus:[jsonDict objectForKey:@"status"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(resendOTPRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate resendOTPRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                }
            }
        }
    }
    @catch (NSException *exception) {
        
        //NSLog(@"Exception ");
    }
    @finally {
        
    }
}


@end
