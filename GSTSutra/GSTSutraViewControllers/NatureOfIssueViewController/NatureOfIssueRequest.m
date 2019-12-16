//
//  NatureOfIssueRequest.m
//  GSTSutra
//
//  Created by niyuj on 2/15/17.
//  Copyright © 2017 niyuj. All rights reserved.
//

#import "NatureOfIssueRequest.h"
#import "Constants.h"
#import "AppData.h"
#import "NewsModel.h"

@implementation NatureOfIssueRequest

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

-(void)getNatureOfIssuesListing{
    requestType = @"NOIAPI";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/get_NatureOfIssueslist_api"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"token", [USERDEFAULTS valueForKey:@"userToken"]];
    [self bodyWithUrlRequest:urlRequest postString:postString];
    
}

-(void)expertWithLowerLimit:(NSString *)lowerLimit withUpperLimit:(NSString *)upperLimit{
    requestType = @"ExpertAPI";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/expert_corner_subject"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"token", [USERDEFAULTS valueForKey:@"userToken"]];
    [postString appendFormat:@"&%@=%@", @"lower_limit", lowerLimit];
    [postString appendFormat:@"&%@=%@", @"upper_limit", upperLimit];
    
    [self bodyWithUrlRequest:urlRequest postString:postString];
    
}


-(void)filterWithLowerLimit:(NSString *)lowerLimit withUpperLimit:(NSString *)upperLimit IndustryType:(NSString*)industryType issueType:(NSString*)issueType storyType:(NSString*)storyType{
    requestType = @"FilterAPI";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/industry_filter"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"token", [USERDEFAULTS valueForKey:@"userToken"]];

    [postString appendFormat:@"&%@=%@", @"lower_limit", lowerLimit];
    [postString appendFormat:@"&%@=%@", @"upper_limit", upperLimit];
    [postString appendFormat:@"&%@=%@", @"story_type", storyType];
    [postString appendFormat:@"&%@=%@", @"issue_type", issueType];
    [postString appendFormat:@"&%@=%@", @"industry_type", industryType];
    
    [self bodyWithUrlRequest:urlRequest postString:postString];
    
}

-(void)locationDataWithLowerLimit:(NSString *)lowerLimit withUpperLimit:(NSString *)upperLimit locationType:(NSString*)locationType isFormsType:(NSString*)isFormsType storyType:(NSString*)storyType{
    requestType = @"LocationAPI";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/location_filter"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"token", [USERDEFAULTS valueForKey:@"userToken"]];
    
    [postString appendFormat:@"&%@=%@", @"lower_limit", lowerLimit];
    [postString appendFormat:@"&%@=%@", @"upper_limit", upperLimit];
    [postString appendFormat:@"&%@=%@", @"story_type", storyType];
    [postString appendFormat:@"&%@=%@", @"location_type",locationType];
    [postString appendFormat:@"&%@=%@", @"laws_type", isFormsType];
    
    [self bodyWithUrlRequest:urlRequest postString:postString];
    
}


-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if ([requestType isEqualToString:@"ExpertAPI"]) {
        if ([self.delegate respondsToSelector:@selector(expertRequestFailedWithStatus:wihtError:)]) {
            [self.delegate expertRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    } else if ([requestType isEqualToString:@"NOIAPI"]) {
        if ([self.delegate respondsToSelector:@selector(getNOIListingRequestFailedWithStatus:wihtError:)]) {
            [self.delegate getNOIListingRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    } else if ([requestType isEqualToString:@"FilterAPI"]) {
        if ([self.delegate respondsToSelector:@selector(filterNOIRequestFailedWithStatus:wihtError:)]) {
            [self.delegate filterNOIRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    } else if ([requestType isEqualToString:@"LocationAPI"]) {
        if ([self.delegate respondsToSelector:@selector(locationDataRequestFailedWithStatus:wihtError:)]) {
            [self.delegate locationDataRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    }
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

-(void)requestCompletedWithData {
    
    @try {
        
        NSString *temp = [[NSString alloc]initWithData:self.webData encoding:NSUTF8StringEncoding];
        //NSLog(@"Response = %@",temp);
        
        NSError *error;
        NSMutableDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:self.webData options:NSJSONReadingAllowFragments error:&error];
        
        if ([requestType isEqualToString:@"ExpertAPI"]) {
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                if ([self.delegate respondsToSelector:@selector(expertRequestSuccessfulWithResult:)]) {
                    
                    [self.delegate expertRequestSuccessfulWithResult:[jsonDict objectForKey:@"result"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(expertRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate expertRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                }
            }
        } else if ([requestType isEqualToString:@"NOIAPI"]) {
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                if ([self.delegate respondsToSelector:@selector(getNOIListingRequestSuccessfulWithResult:)]) {
                    
                    [self.delegate getNOIListingRequestSuccessfulWithResult:[jsonDict objectForKey:@"result"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(getNOIListingRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate getNOIListingRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                }
            }
        } else if ([requestType isEqualToString:@"FilterAPI"]) {
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                if ([self.delegate respondsToSelector:@selector(filterNOIRequestSuccessfulWithResult:)]) {
                    
                    [self.delegate filterNOIRequestSuccessfulWithResult:[jsonDict objectForKey:@"result"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(filterNOIRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate filterNOIRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                }
            }
        }else if ([requestType isEqualToString:@"LocationAPI"]) {
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                if ([self.delegate respondsToSelector:@selector(locationDataRequestSuccessfulWithResult:)]) {
                    
                    [self.delegate locationDataRequestSuccessfulWithResult:[jsonDict objectForKey:@"result"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(locationDataRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate locationDataRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                }
            }
        }
        
    }
    @catch (NSException *exception) {
        
        //NSLog(@"Exception");
    }
    @finally {
        
    }
}


@end
