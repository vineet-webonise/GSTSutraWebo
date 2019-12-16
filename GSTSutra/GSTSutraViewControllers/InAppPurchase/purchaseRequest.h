//
//  purchaseRequest.h
//  GSTSutra
//
//  Created by niyuj on 2/2/17.
//  Copyright © 2017 niyuj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SignUpModel.h"

@protocol PurchaseRequestDelegate <NSObject>

@optional

-(void)userDetailPurchaseRequestSuccessfulWithResult:(NSString*)resultUrl;
-(void)userDetailPurchaseRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

-(void)isUserPaidRequestSuccessfulWithResult:(NSString*)result;
-(void)isBlockedRequestSuccessfulWithResult:(NSString*)result;
-(void)isUserPaidRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

@end

@interface purchaseRequest : NSObject<NSURLConnectionDataDelegate, NSURLConnectionDelegate> {
    
    NSString *requestType;
}
@property (nonatomic, strong) NSMutableData *webData;
@property (nonatomic, weak) id<PurchaseRequestDelegate> delegate;

-(void)userDetailsForSubscriptionPurchase:(SignUpModel*)signUpData;
-(void)checkUserSubscription;
@end
