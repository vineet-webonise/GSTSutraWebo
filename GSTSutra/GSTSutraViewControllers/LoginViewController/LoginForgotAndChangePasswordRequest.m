
#import "LoginForgotAndChangePasswordRequest.h"
#import "Constants.h"
#import "AppData.h"

@implementation LoginForgotAndChangePasswordRequest

-(NSString*)convertSymbolicAndOpratorInString:(NSString*)stringToReplace{
    
    return   [stringToReplace stringByReplacingOccurrencesOfString:@"&" withString:@"%26" options:NSRegularExpressionSearch range:NSMakeRange(0, [stringToReplace length])];
}

-(void)bodyWithUrlRequest:(NSMutableURLRequest*)urlRequest postString:(NSMutableString*)postString{
    
    NSData *body ;
    body = [postString dataUsingEncoding:NSUTF8StringEncoding];
    [urlRequest setValue:[USERDEFAULTS valueForKey:@"userToken"] forHTTPHeaderField:@"token"];
    //NSLog(@"TOken Value in news %@", [USERDEFAULTS valueForKey:@"userToken"]);
    [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [urlRequest setHTTPBody:body];
    NSURLConnection *urlConnection;
    urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:YES];
}

//login Request

-(void)loginWithUsername:(NSString *)username andPassword:(NSString *)password {
    
    requestType = @"login";
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_API,@"/login"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"username", [self convertSymbolicAndOpratorInString:username]];
    [postString appendFormat:@"&%@=%@", @"password", [self convertSymbolicAndOpratorInString:password]];
    [postString appendFormat:@"&%@=%@", @"device_token", [USERDEFAULTS valueForKey:@"deviceID"]];
    [postString appendFormat:@"&%@=%@", @"device_type", @"ios"];
    [postString appendFormat:@"&%@=%@", @"version", @"v2"];
    [postString appendFormat:@"&%@=%@", @"mac_id", [USERDEFAULTS valueForKey:@"macID"]];
    [self bodyWithUrlRequest:urlRequest postString:postString];
}


// changePassword
-(void)changeCurrentPassword:(NSString*)currentPassword withNewPassword:(NSString*)NewPassword {
    
    requestType = @"changePassword";
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/change_password"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    
    [postString appendFormat:@"%@=%@", @"oldpassword", [self convertSymbolicAndOpratorInString:currentPassword]];
    [postString appendFormat:@"&%@=%@", @"newpassword", [self convertSymbolicAndOpratorInString:NewPassword]];
    
    [self bodyWithUrlRequest:urlRequest postString:postString];
    
}

-(void) getUserProfile{
    
    requestType = @"getUserProfile";
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/get_profile"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    //[postString appendFormat:@"%@=%@", @"id",userLogData.doctorID];
    //[postString appendFormat:@"&%@=%@", @"user_type", @"doctor"];
    [self bodyWithUrlRequest:urlRequest postString:postString];
}
// Forgot password

-(void)forgotPasswordForUserName:(NSString*)userName {
    requestType = @"forgotPassword";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/forgot_password"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"username", userName];
    [self bodyWithUrlRequest:urlRequest postString:postString];
    
}


// logout

-(void) getLogout {
    requestType = @"logout";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/logout"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    //[postString appendFormat:@"%@=%@", @"id", userLogData.doctorID];
    //[postString appendFormat:@"&%@=%@", @"user_type", @"doctor"];
    
    [postString appendFormat:@"&%@=%@", @"mac_id", [[NSUserDefaults standardUserDefaults]valueForKey:@"macID"]];
    
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
    if ([requestType isEqualToString:@"forgotPassword"]) {
        if ([self.delegate respondsToSelector:@selector(forgotPasswordEmailSentFailureWithStatus:andWithErrorMessage:)]) {
            [self.delegate forgotPasswordEmailSentFailureWithStatus:@"0" andWithErrorMessage:error.localizedDescription];
        }
    }else if ([requestType isEqualToString:@"changePassword"]) {
        if ([self.delegate respondsToSelector:@selector(confirmPasswordRequestFailedWithStatus:wihtError:)]) {
            [self.delegate confirmPasswordRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    } else if ([requestType isEqualToString:@"logout"]) {
        if ([self.delegate respondsToSelector:@selector(logoutRequestFailedWithStatus:wihtError:)]) {
            [self.delegate logoutRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];}
    }else if ([requestType isEqualToString:@"getUserProfile"]) {
        if ([self.delegate respondsToSelector:@selector(getUserProfileRequestFailedWithStatus:wihtError:)]) {
            [self.delegate getUserProfileRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];}
    }else {
        if ([self.delegate respondsToSelector:@selector(loginRequestFailedWithStatus:wihtError:)]) {
            [self.delegate loginRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    }
    
}

-(void)requestCompletedWithData {
    
    @try {
        
        NSString *temp = [[NSString alloc]initWithData:self.webData encoding:NSUTF8StringEncoding];
        //NSLog(@"Response = %@",temp);
        
        NSError *error;
        NSMutableDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:self.webData options:NSJSONReadingAllowFragments error:&error];
        if ([requestType isEqualToString:@"login"]){ //LOGIN
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                //NSLog(@"Login Success!");
                UserModel *user = [[UserModel alloc] init];
                [USERDEFAULTS setValue:[[jsonDict objectForKey:@"result"] objectForKey:@"token"] forKey:@"userToken"];
                [USERDEFAULTS setValue:[[jsonDict objectForKey:@"result"] objectForKey:@"userid"] forKey:@"userid"];
                [USERDEFAULTS synchronize];
                user.UserName = [[jsonDict objectForKey:@"result"] objectForKey:@"username"];
                [USERDEFAULTS setObject:[[jsonDict objectForKey:@"result"] objectForKey:@"username"] forKey:@"username"];
                [USERDEFAULTS  setBool:[[[jsonDict objectForKey:@"result"] objectForKey:@"terms"] boolValue] forKey:@"terms"];
                [USERDEFAULTS setBool:NO forKey:@"isNotRegisterOrLoginUser"];
                [USERDEFAULTS  removeObjectForKey:@"fullName"];
                user.FirstLastName = [[jsonDict objectForKey:@"result"] objectForKey:@"full_name"] ;
                if ([[[jsonDict objectForKey:@"result"] objectForKey:@"full_name"] isEqual:[NSNull null]]){
                    [USERDEFAULTS  setValue:@"" forKey:@"fullName"];
                   
                }else {
                     [USERDEFAULTS  setValue:[[jsonDict objectForKey:@"result"] objectForKey:@"full_name"] forKey:@"fullName"];
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
                [USERDEFAULTS setValue:[[jsonDict objectForKey:@"result"] objectForKey:@"token"] forKey:@"userToken"];
                [USERDEFAULTS setBool:[[[jsonDict objectForKey:@"result"] objectForKey:@"is_verified"] boolValue] forKey:@"isVerified"];
                [AppData getInstance].currentUser = user;
    
                [self.delegate loginRequestSuccessfulWithStatus:[jsonDict objectForKey:@"status"]];
            }else {
                if ([self.delegate respondsToSelector:@selector(loginRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate loginRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                    
                }
            }
            
        } else if ([requestType isEqualToString:@"getUserProfile"]){ //UserProfile
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
               
                UserModel *user = [[UserModel alloc] init];
                [USERDEFAULTS setValue:[[jsonDict objectForKey:@"result"] objectForKey:@"token"] forKey:@"userToken"];
                [USERDEFAULTS synchronize];
                user.UserName = [[jsonDict objectForKey:@"result"] objectForKey:@"username"];
                
                [USERDEFAULTS  setValue:[[jsonDict objectForKey:@"result"] objectForKey:@"username"] forKey:@"username"];
                user.FirstLastName = [[jsonDict objectForKey:@"result"] objectForKey:@"full_name"] ;
                [USERDEFAULTS setBool:NO forKey:@"isNotRegisterOrLoginUser"];
                
                if (![[[jsonDict objectForKey:@"result"] objectForKey:@"full_name"] isEqual: [NSNull null]]) {
                    [USERDEFAULTS  setValue:[[jsonDict objectForKey:@"result"] objectForKey:@"full_name"] forKey:@"fullName"];
                } else {
                    [USERDEFAULTS  setValue:@"" forKey:@"fullName"];
                }
                
                user.profileImage = [[jsonDict objectForKey:@"result"] objectForKey:@"profile_pic"];
                [USERDEFAULTS  setValue:[[jsonDict objectForKey:@"result"] objectForKey:@"profile_pic"] forKey:@"profileImage"];
                user.EmailId = [[jsonDict objectForKey:@"result"] objectForKey:@"email"];
                user.MobileNumber = [[jsonDict objectForKey:@"result"] objectForKey:@"mobile"];
                user.CompanyName = [[jsonDict objectForKey:@"result"] objectForKey:@"company_name"];
                user.isPaid = [[jsonDict objectForKey:@"result"] objectForKey:@"is_paid"];
                user.City = [[jsonDict objectForKey:@"result"] objectForKey:@"city"];
                user.isVerified = [[jsonDict objectForKey:@"result"] objectForKey:@"is_verified"] ;
                user.locationArray = [[jsonDict objectForKey:@"result"] objectForKey:@"locations"];
                [USERDEFAULTS setObject:[[jsonDict objectForKey:@"result"] objectForKey:@"locations"] forKey:@"locationArray"];
                
                [USERDEFAULTS setBool:[[[jsonDict objectForKey:@"result"] objectForKey:@"is_verified"] boolValue] forKey:@"isVerified"];
                
                [AppData getInstance].currentUser = user;
                
                [self.delegate getUserProfileRequestSuccessfulWithStatus:[jsonDict objectForKey:@"status"]];
            }else {
                if ([self.delegate respondsToSelector:@selector(getUserProfileRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate getUserProfileRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                }
            }
            
        }else if ([requestType isEqualToString:@"forgotPassword"]) {
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                if ([self.delegate respondsToSelector:@selector(forgotPasswordEmailSentSuccessfullyWithStatus:withMessage:)]) {
                    [self.delegate forgotPasswordEmailSentSuccessfullyWithStatus:[jsonDict objectForKey:@"status"] withMessage:[jsonDict objectForKey:@"msg"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(forgotPasswordEmailSentFailureWithStatus:andWithErrorMessage:)]) {
                    [self.delegate forgotPasswordEmailSentFailureWithStatus:[jsonDict objectForKey:@"status"] andWithErrorMessage:[jsonDict objectForKey:@"msg"]];
                }
            }
        } else if ([requestType isEqualToString:@"logout"]) {
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                if ([self.delegate respondsToSelector:@selector(logoutRequestSuccessfulWithStatus:)]) {
                    [self.delegate logoutRequestSuccessfulWithStatus:[jsonDict objectForKey:@"status"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(logoutRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate logoutRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                }
            }
        } else {
            
            //change password
            
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                if ([self.delegate respondsToSelector:@selector(confirmPasswordRequestSuccessfulWithStatus:withMessage:)]) {
                    [self.delegate confirmPasswordRequestSuccessfulWithStatus:[jsonDict objectForKey:@"status"] withMessage:[jsonDict objectForKey:@"msg"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(confirmPasswordRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate confirmPasswordRequestFailedWithStatus: [jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                }
            }
            
        }
    }
    @catch (NSException *exception) {
        
        //NSLog(@"Exception login %@ ",exception);
    }
    @finally {
        
    }
}


@end
