//
//  SignUpRequest.h
//  TGAPP
//
//  Created by Rahul Kalavar on 10/15/14.
//  Copyright (c) 2014 Eeshana. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SignUpModel.h"


@protocol SignUpRequestDelegate <NSObject>

@optional

//register profile. 
-(void)registrationCompletedSuccessfullyWithStatusInfo:(NSString*)status andWithMessage:(NSString*)message;
-(void)registrationFailedWithStatusInfo:(NSString*)status andWithErrorMessage:(NSString*)errorMessage;
//update profile
-(void)profileUpdatedeSuccessfullyWithStatusInfo:(NSString*)status andWithMessage:(NSString*)message;
-(void)profileUpdateFailedWithStatusInfo:(NSString*)status andWithErrorMessage:(NSString*)errorMessage;
//change Mobile number
-(void)changeMobileNumberSuccessfullyWithStatusInfo:(NSString*)status andWithMessage:(NSString*)message;
-(void)changeMobileNumberFailedWithStatusInfo:(NSString*)status andWithErrorMessage:(NSString*)errorMessage;

//change Mobile number
-(void)chackUsernameSuccessfullyWithStatusInfo:(NSString*)status andWithMessage:(NSString*)message;
-(void)chackUsernameFailedWithStatusInfo:(NSString*)status andWithErrorMessage:(NSString*)errorMessage;

@end

@interface SignUpRequest : NSObject<NSURLConnectionDataDelegate, NSURLConnectionDelegate>

@property (nonatomic, retain) NSMutableData *webData;
@property (nonatomic, weak) id<SignUpRequestDelegate> delegate;

-(void)registerWithUser:(SignUpModel*)signUpData;
-(void)checkUserIsAlreadyExistOrNotWithUserName:(SignUpModel*)signUpData;
-(void)updateProfileWithUser:(SignUpModel*)signUpData;
-(void)changeMobileNumber:(NSString*)mobileNumber;
@end
