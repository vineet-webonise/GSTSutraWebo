//
//  purchaseRequest.m
//  GSTSutra
//
//  Created by niyuj on 2/2/17.
//  Copyright © 2017 niyuj. All rights reserved.
//

#import "purchaseRequest.h"
#import "Constants.h"
#import "AppData.h"
#import "NewsModel.h"

@implementation purchaseRequest

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

-(void)userDetailsForSubscriptionPurchase:(SignUpModel*)signUpData{
    requestType = @"purchaseAPI";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/payment_account_details_api"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"token", [USERDEFAULTS valueForKey:@"userToken"]];
    
    [postString appendFormat:@"&%@=%@", @"username", signUpData.UserName];
    [postString appendFormat:@"&%@=%@", @"country_id", signUpData.CountryID];
    [postString appendFormat:@"&%@=%@", @"state_id", signUpData.StateID];
    [postString appendFormat:@"&%@=%@", @"state_name", signUpData.State];
    [postString appendFormat:@"&%@=%@", @"address", signUpData.Address];
    [postString appendFormat:@"&%@=%@", @"pincode", signUpData.Pincode];
    [postString appendFormat:@"&%@=%@", @"city", signUpData.City];
    [postString appendFormat:@"&%@=%@", @"invoicee_name", signUpData.FirstLastName];
    [postString appendFormat:@"&%@=%@", @"invoicee_addr", signUpData.Address];
    [self bodyWithUrlRequest:urlRequest postString:postString];
    
}

-(void)checkUserSubscription{

    requestType = @"checkAPI";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/check_user_trial_period"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"token", [USERDEFAULTS valueForKey:@"userToken"]];
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
    if ([requestType isEqualToString:@"purchaseAPI"]) {
        if ([self.delegate respondsToSelector:@selector(userDetailPurchaseRequestFailedWithStatus:wihtError:)]) {
            [self.delegate userDetailPurchaseRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    }else if ([requestType isEqualToString:@"checkAPI"]) {
        if ([self.delegate respondsToSelector:@selector(isUserPaidRequestFailedWithStatus:wihtError:)]) {
            [self.delegate isUserPaidRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    }
}

-(void)requestCompletedWithData {
    
    @try {
        
        NSString *temp = [[NSString alloc]initWithData:self.webData encoding:NSUTF8StringEncoding];
        //NSLog(@"Response = %@",temp);
        
        NSError *error;
        NSMutableDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:self.webData options:NSJSONReadingAllowFragments error:&error];
        
        if ([requestType isEqualToString:@"purchaseAPI"]) {
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                if ([self.delegate respondsToSelector:@selector(userDetailPurchaseRequestSuccessfulWithResult:)]) {
                    
                    [self.delegate userDetailPurchaseRequestSuccessfulWithResult:[jsonDict objectForKey:@"result"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(userDetailPurchaseRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate userDetailPurchaseRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                }
            }
        } else if ([requestType isEqualToString:@"checkAPI"]) {
            if ([[jsonDict objectForKey:@"status"] integerValue] == 1) {
                if ([self.delegate respondsToSelector:@selector(isUserPaidRequestSuccessfulWithResult:)]) {
                    
                    [self.delegate isUserPaidRequestSuccessfulWithResult:[jsonDict objectForKey:@"result"]];
                }
            }else if ([[jsonDict objectForKey:@"status"] integerValue] == 2) {
                if ([self.delegate respondsToSelector:@selector(isBlockedRequestSuccessfulWithResult:)]) {
                    
                    [self.delegate isBlockedRequestSuccessfulWithResult:[jsonDict objectForKey:@"msg"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(isUserPaidRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate isUserPaidRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
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
