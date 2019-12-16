//
//  SignUpRequest.m
//  TGAPP
//
//  Created by Rahul Kalavar on 10/15/14.
//  Copyright (c) 2014 Eeshana. All rights reserved.
//

#import "SignUpRequest.h"
#import "Constants.h"
#import "Utility.h"
#import "SignUpModel.h"
#import "UserModel.h"
#import "AppData.h"

@implementation SignUpRequest{
    NSString *requestType;
}

-(NSString*)convertSymbolicAndOpratorInString:(NSString*)stringToReplace{
    
  return   [stringToReplace stringByReplacingOccurrencesOfString:@"&" withString:@"%26" options:NSRegularExpressionSearch range:NSMakeRange(0, [stringToReplace length])];
}

-(void)registerWithUser:(SignUpModel*)signUpData {
    
    requestType = @"signUp";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/register"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"username", [self convertSymbolicAndOpratorInString:signUpData.UserName]];
    [postString appendFormat:@"&%@=%@", @"pass", [self convertSymbolicAndOpratorInString:signUpData.Password]];
    [postString appendFormat:@"&%@=%@", @"email", signUpData.EmailId];
    [postString appendFormat:@"&%@=%@", @"mobile", signUpData.MobileNumber];
    [postString appendFormat:@"&%@=%@", @"company_name", [self convertSymbolicAndOpratorInString:signUpData.CompanyName]];
    [postString appendFormat:@"&%@=%@", @"city", [self convertSymbolicAndOpratorInString:signUpData.City]];
    [postString appendFormat:@"&%@=%@", @"subscriber_name", [self convertSymbolicAndOpratorInString:signUpData.FirstLastName]];
    [postString appendFormat:@"&%@=%@", @"device_token", [[NSUserDefaults standardUserDefaults]valueForKey:@"deviceID"]];
    [postString appendFormat:@"&%@=%@", @"device_type", @"ios"];
    [postString appendFormat:@"&%@=%@", @"version", @"v2"];
    [postString appendFormat:@"&%@=%@", @"mac_id", [[NSUserDefaults standardUserDefaults]valueForKey:@"macID"]];
    
    [self bodyWithUrlRequest:urlRequest postString:postString];
    
}

-(void)checkUserIsAlreadyExistOrNotWithUserName:(SignUpModel *)signUpData{
    
    requestType = @"userNameAPI";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/check_username"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"username", [self convertSymbolicAndOpratorInString:signUpData.UserName]];
    [self bodyWithUrlRequest:urlRequest postString:postString];
    
}


-(void)updateProfileWithUser:(SignUpModel*)signUpData {
    
    requestType = @"updateProfile";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/update_profile"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"username", signUpData.UserName];
    //[postString appendFormat:@"&%@=%@", @"pass", signUpData.Password];
    [postString appendFormat:@"&%@=%@", @"email", signUpData.EmailId];
    //[postString appendFormat:@"&%@=%@", @"mobile", signUpData.MobileNumber];
    [postString appendFormat:@"&%@=%@", @"company_name", [self convertSymbolicAndOpratorInString:signUpData.CompanyName]];
    [postString appendFormat:@"&%@=%@", @"city", [self convertSymbolicAndOpratorInString:signUpData.City]];
    [postString appendFormat:@"&%@=%@", @"subscriber_name", [self convertSymbolicAndOpratorInString:signUpData.FirstLastName]];
    [postString appendFormat:@"&%@=%@", @"device_token", [[NSUserDefaults standardUserDefaults]valueForKey:@"deviceID"]];
    [postString appendFormat:@"&%@=%@", @"user_type", @"doctor"];
    [postString appendFormat:@"&%@=%@", @"device_type", @"ios"];
    [postString appendFormat:@"&%@=%@", @"mac_id", [[NSUserDefaults standardUserDefaults]valueForKey:@"macID"]];
    
    [self bodyWithUrlRequest:urlRequest postString:postString];
    
}

-(void)changeMobileNumber:(NSString *)mobileNumber {
    
    requestType = @"changeMobileNumber";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/change_mobile"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"mobile", mobileNumber];
    [self bodyWithUrlRequest:urlRequest postString:postString];
    
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
    //NSLog(@"%@", error.localizedDescription);
    if ([requestType isEqualToString:@"signUp"]) {
        
        if ([self.delegate respondsToSelector:@selector(registrationFailedWithStatusInfo:andWithErrorMessage:)]) {
            [self.delegate registrationFailedWithStatusInfo:@"0" andWithErrorMessage:error.localizedDescription];
        }
    
    }else if ([requestType isEqualToString:@"userNameAPI"]){
        
        if ([self.delegate respondsToSelector:@selector(chackUsernameFailedWithStatusInfo:andWithErrorMessage:)]) {
            [self.delegate chackUsernameFailedWithStatusInfo:@"0" andWithErrorMessage:error.localizedDescription];
        }
        
    } else if ([requestType isEqualToString:@"changeMobileNumber"]){
        
        if ([self.delegate respondsToSelector:@selector(changeMobileNumberFailedWithStatusInfo:andWithErrorMessage:)]) {
            [self.delegate changeMobileNumberFailedWithStatusInfo:@"0" andWithErrorMessage:error.localizedDescription];
        }
        
    }else {
        
        if ([self.delegate respondsToSelector:@selector(profileUpdateFailedWithStatusInfo:andWithErrorMessage:)]) {
            [self.delegate profileUpdateFailedWithStatusInfo:@"0" andWithErrorMessage:error.localizedDescription];
            
        }
    }
}

-(void)requestCompletedWithData {
    NSString *temp = [[NSString alloc]initWithData:self.webData encoding:NSUTF8StringEncoding];
    //NSLog(@"Response = %@",temp);
    
    NSError *error;
    NSMutableDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:self.webData options:NSJSONReadingAllowFragments error:&error];
    if ([requestType isEqualToString:@"signUp"]){
        
        if ([[jsonDict objectForKey:@"status"] integerValue]) {
            
            //[USERDEFAULTS setValue:[[jsonDict objectForKey:@"result"] objectForKey:@"token"] forKey:@"userToken"];
            [USERDEFAULTS setBool:NO forKey:@"isNotRegisterOrLoginUser"];
            [USERDEFAULTS synchronize];
            
            if ([self.delegate respondsToSelector:@selector(registrationCompletedSuccessfullyWithStatusInfo:andWithMessage:)]) {
                [USERDEFAULTS setValue:[[jsonDict objectForKey:@"result"] objectForKey:@"token"] forKey:@"userToken"];
                [self.delegate registrationCompletedSuccessfullyWithStatusInfo:[jsonDict objectForKey:@"status"]  andWithMessage:[jsonDict objectForKey:@"msg"]];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(registrationFailedWithStatusInfo:andWithErrorMessage:)]) {
                [self.delegate registrationFailedWithStatusInfo:[jsonDict valueForKey:@"status"] andWithErrorMessage:[jsonDict valueForKey:@"msg"]];
            }
            
        }

    }else if ([requestType isEqualToString:@"userNameAPI"]){
        
        if ([[jsonDict objectForKey:@"status"] integerValue]) {
            
            if ([self.delegate respondsToSelector:@selector(chackUsernameSuccessfullyWithStatusInfo:andWithMessage:)]) {
                
                [self.delegate chackUsernameSuccessfullyWithStatusInfo:[jsonDict objectForKey:@"status"]  andWithMessage:[jsonDict objectForKey:@"msg"]];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(chackUsernameFailedWithStatusInfo:andWithErrorMessage:)]) {
                [self.delegate chackUsernameFailedWithStatusInfo:[jsonDict valueForKey:@"status"] andWithErrorMessage:[jsonDict valueForKey:@"msg"]];
            }
            
        }
        
    } else if ([requestType isEqualToString:@"changeMobileNumber"]){
        
        if ([[jsonDict objectForKey:@"status"] integerValue]) {
            
            if ([self.delegate respondsToSelector:@selector(changeMobileNumberSuccessfullyWithStatusInfo:andWithMessage:)]) {
                
                [self.delegate changeMobileNumberSuccessfullyWithStatusInfo:[jsonDict objectForKey:@"status"]  andWithMessage:[jsonDict objectForKey:@"msg"]];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(changeMobileNumberFailedWithStatusInfo:andWithErrorMessage:)]) {
                [self.delegate changeMobileNumberFailedWithStatusInfo:[jsonDict valueForKey:@"status"] andWithErrorMessage:[jsonDict valueForKey:@"msg"]];
            }
            
        }
        
    } else { // Update Profile
        
        if ([[jsonDict objectForKey:@"status"] integerValue]) {
            
            if ([self.delegate respondsToSelector:@selector(profileUpdatedeSuccessfullyWithStatusInfo:andWithMessage:)]) {
                
                [self.delegate profileUpdatedeSuccessfullyWithStatusInfo:[jsonDict objectForKey:@"status"]  andWithMessage:[jsonDict objectForKey:@"msg"]];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(profileUpdateFailedWithStatusInfo:andWithErrorMessage:)]) {
                [self.delegate profileUpdateFailedWithStatusInfo:[jsonDict valueForKey:@"status"] andWithErrorMessage:[jsonDict valueForKey:@"msg"]];
            }
            
        }
        
        
    }

}

@end
