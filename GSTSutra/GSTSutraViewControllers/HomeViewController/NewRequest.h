//
//  NewRequest.h
//  GSTSutra
//
//  Created by niyuj on 11/12/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol NewRequestDelegate <NSObject>

@optional

-(void)newsRequestSuccessfulWithResult:(NSArray*)result;
-(void)newsRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

-(void)newsForIndustriesRequestSuccessfulWithResult:(NSArray*)result;
-(void)newsForIndustriesRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

-(void)newsNotificationRequestSuccessfulWithResult:(NSArray*)result;
-(void)newsNotificationRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

-(void)industriesRequestSuccessfulWithResult:(NSArray*)result;
-(void)industriesRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

-(void)newsRelatedRequestSuccessfulWithResult:(NSArray*)result;
-(void)newsRelatedRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

-(void)bookmarkNewsRequestSuccessfulWithStatus:(NSString*)status;
-(void)bookmarkNewsRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

-(void)viewNewsRequestSuccessfulWithStatus:(NSString*)status;
-(void)viewNewsRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

-(void)likeNewsRequestSuccessfulWithStatus:(NSString*)status;
-(void)likeNewsRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

-(void)rateNewsRequestSuccessfulWithStatus:(NSString*)status;
-(void)rateNewsRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

-(void)setCommentRequestSuccessfulWithStatus:(NSString*)status;
-(void)setCommentRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

-(void)getCommentRequestSuccessfulWithStatus:(NSArray*)result;
-(void)getCommentRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;
-(void)deleteCommentRequestSuccessfulWithStatus:(NSString*)status;
-(void)deleteCommentRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

-(void)updateCommentRequestSuccessfulWithStatus:(NSString*)status;
-(void)updateCommentRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

-(void)VideoRequestSuccessfulWithResult:(NSArray*)result;
-(void)videoRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

-(void)getUserBookmarkRequestSuccessfulWithResult:(NSArray*)result;
-(void)getUserBookmarkRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

-(void)getUserLikeRequestSuccessfulWithResult:(NSArray*)result;
-(void)getUserLikeRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

-(void)getAllADVRequestSuccessfulWithResult:(NSArray*)result;
-(void)getAllADVRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

-(void)setVideoViewRequestSuccessfulWithResult:(NSArray*)result;
-(void)setVideoViewRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;


@end


@interface NewRequest : NSObject<NSURLConnectionDataDelegate, NSURLConnectionDelegate> {
    
    NSString *requestType;
}

@property (nonatomic, strong) NSMutableData *webData;
@property (nonatomic, weak) id<NewRequestDelegate> delegate;

-(void)newsWithLowerLimit:(NSString *)lowerLimit withUpperLimit:(NSString *)upperLimit newsType:(NSString*)newsType locationType:(NSString*)locationType;

-(void)newsWithLowerLimit:(NSString *)lowerLimit withUpperLimit:(NSString *)upperLimit newsType:(NSString*)newsType industryType:(NSString*)industryType;

-(void)newsRelatedWithStoryId:(NSString *)storyID andWithStoryType:(NSString*)storyType;

-(void)likeNewsWithStoryId:(NSString *)storyID withStoryType:(NSString *)storyType withLikeValue:(NSString*)lid;

-(void)bookMarkNewsWithStoryId:(NSString *)storyID withStoryType:(NSString *)storyType withBookmarkValue:(NSString*)bid;

-(void)viewNewsWithStoryId:(NSString *)storyID withStoryType:(NSString *)storyType withViewId:(NSString*)viewId;

-(void)rateNewsWithStoryId:(NSString *)storyID withStoryType:(NSString *)storyType withRateValue:(NSString*)starValue;

-(void)setCommentWithStoryId:(NSString *)storyID withStoryType:(NSString *)storyType withCommentString:(NSString*)comment;

-(void)getCommentWithStoryId:(NSString *)storyID withStoryType:(NSString *)storyType;
-(void)getNotificationNewsWithStoryId:(NSString *)storyID withStoryType:(NSString *)storyType;

-(void)deleteCommentWithCommentID:(NSString *)commentID;

-(void)updateCommentWithCommentID:(NSString *)commentID withUpdatedCommentString:(NSString*)commentString;

-(void)setYouTubeVideoViewCountWithID : (NSString*)eID;


-(void)getVideoUrlsWithLowerLimit:(NSString *)lowerLimit withUpperLimit:(NSString *)upperLimit  videoType:(NSString*)videoType;
-(void)getVideoUrls;

-(void)getAllIndustries;

-(void)getUserLikes;
-(void)getUserBookmarks;
-(void)getAllAdvertisements;

@end
