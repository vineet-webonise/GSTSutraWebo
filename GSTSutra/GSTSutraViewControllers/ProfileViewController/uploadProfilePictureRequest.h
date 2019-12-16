//
//  uploadProfilePictureRequest.h
//  Pharmacy-Customer
//
//  Created by niyuj on 5/17/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SignUpModel.h"
#import "UserModel.h"

@protocol uploadProfilePictureRequestDelegate <NSObject>

@optional

-(void)profilePictureUploadedSuccessfullyWithStatusInfo:(NSString*)status andWithMessage:(NSString*)message;
-(void)profilePictureUploadedFailedWithStatusInfo:(NSString*)status andWithErrorMessage:(NSString*)errorMessage;

@end
@interface uploadProfilePictureRequest : NSObject<NSURLConnectionDataDelegate, NSURLConnectionDelegate>

@property (nonatomic, retain) NSMutableData *webData;
@property (nonatomic, weak) id<uploadProfilePictureRequestDelegate> delegate;

-(void)uploadUserProfilePicture:(SignUpModel*)signUpData;

@end
