//
//  NatureOfIssueRequest.h
//  GSTSutra
//
//  Created by niyuj on 2/15/17.
//  Copyright © 2017 niyuj. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol NatureOfIssueRequestDelegate <NSObject>

@optional

-(void)expertRequestSuccessfulWithResult:(NSArray*)result;
-(void)expertRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

-(void)getNOIListingRequestSuccessfulWithResult:(NSArray*)result;
-(void)getNOIListingRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

-(void)filterNOIRequestSuccessfulWithResult:(NSArray*)result;
-(void)filterNOIRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

-(void)locationDataRequestSuccessfulWithResult:(NSArray*)result;
-(void)locationDataRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

@end

@interface NatureOfIssueRequest : NSObject <NSURLConnectionDataDelegate, NSURLConnectionDelegate> {
    
    NSString *requestType;
}

@property (nonatomic, strong) NSMutableData *webData;
@property (nonatomic, assign) BOOL isForms;
@property (nonatomic, weak) id<NatureOfIssueRequestDelegate> delegate;

-(void)getNatureOfIssuesListing;
-(void)expertWithLowerLimit:(NSString *)lowerLimit withUpperLimit:(NSString *)upperLimit ;

-(void)filterWithLowerLimit:(NSString *)lowerLimit withUpperLimit:(NSString *)upperLimit IndustryType:(NSString*)industryType issueType:(NSString*)issueType storyType:(NSString*)storyType;


-(void)locationDataWithLowerLimit:(NSString *)lowerLimit withUpperLimit:(NSString *)upperLimit locationType:(NSString*)locationType isFormsType:(NSString*)isFormsType storyType:(NSString*)storyType;

@end
