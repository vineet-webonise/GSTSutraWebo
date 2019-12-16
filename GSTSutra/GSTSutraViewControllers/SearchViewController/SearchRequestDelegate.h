//
//  SearchRequestDelegate.h
//  GSTSutra
//
//  Created by niyuj on 1/18/17.
//  Copyright © 2017 niyuj. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SearchRequestDelegateMethod <NSObject>
@optional

-(void)searchRequestSuccessfulWithResult:(NSArray*)result;
-(void)searchRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;


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

-(void)VideoRequestSuccessfulWithResult:(NSArray*)result;
-(void)videoRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

-(void)getUserBookmarkRequestSuccessfulWithResult:(NSArray*)result;
-(void)getUserBookmarkRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

-(void)getUserLikeRequestSuccessfulWithResult:(NSArray*)result;
-(void)getUserLikeRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;


@end


@interface SearchRequestDelegate : NSObject<NSURLConnectionDataDelegate, NSURLConnectionDelegate> {
    
    NSString *requestType;
}

@property (nonatomic, strong) NSMutableData *webData;
@property (nonatomic, weak) id<SearchRequestDelegateMethod> delegate;

-(void)searchText:(NSString*)text;

-(void)newsWithLowerLimit:(NSString *)lowerLimit withUpperLimit:(NSString *)upperLimit newsType:(NSString*)newsType locationType:(NSString*)locationType;

-(void)newsRelatedWithStoryId:(NSString *)storyID andWithStoryType:(NSString*)storyType;

-(void)likeNewsWithStoryId:(NSString *)storyID withStoryType:(NSString *)storyType withLikeValue:(NSString*)lid;
-(void)bookMarkNewsWithStoryId:(NSString *)storyID withStoryType:(NSString *)storyType withBookmarkValue:(NSString*)bid;
-(void)viewNewsWithStoryId:(NSString *)storyID withStoryType:(NSString *)storyType withViewId:(NSString*)viewId;
-(void)rateNewsWithStoryId:(NSString *)storyID withStoryType:(NSString *)storyType withRateValue:(NSString*)starValue;
-(void)setCommentWithStoryId:(NSString *)storyID withStoryType:(NSString *)storyType withCommentString:(NSString*)comment;

-(void)getCommentWithStoryId:(NSString *)storyID withStoryType:(NSString *)storyType;
-(void)getNotificationNewsWithStoryId:(NSString *)storyID withStoryType:(NSString *)storyType;
-(void)deleteCommentWithCommentID:(NSString *)commentID;

-(void)getVideoUrls;
-(void)getAllIndustries;

-(void)getUserLikes;
-(void)getUserBookmarks;


@end
