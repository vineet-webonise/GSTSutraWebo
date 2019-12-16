//
//  ExpertCornerRequest.h
//  GSTSutra
//
//  Created by niyuj on 11/23/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ExpertRequestDelegate <NSObject>

@optional

-(void)expertRequestSuccessfulWithResult:(NSArray*)result;
-(void)expertRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

-(void)getLawsRequestSuccessfulWithResult:(NSArray*)result;
-(void)getLawsRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

-(void)getFAQRequestSuccessfulWithResult:(NSArray*)result;
-(void)getFAQRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

-(void)getshareLinksRequestSuccessfulWithResult:(NSArray*)result;
-(void)getshareLinksRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

-(void)expertTakeRequestSuccessfulWithResult:(NSArray*)result;
-(void)expertTakeRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

-(void)getBookmarkRequestSuccessfulWithResult:(NSArray*)result;
-(void)getBookmarkRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

-(void)getNotificationSwitchValueRequestSuccessfulWithResult:(NSArray*)result;
-(void)getNotificationSwitchValueRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

-(void)setNotificationSwitchValueRequestSuccessfulWithResult:(NSArray*)result;
-(void)setNotificationSwitchValueRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

-(void)getForumListRequestSuccessfulWithResult:(NSArray*)result;
-(void)getForumListRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

-(void)getForumDetailRequestSuccessfulWithResult:(NSArray*)result;
-(void)getForumDetailRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;


-(void)editCommentRequestSuccessfulWithResult:(NSString*)msg;
-(void)editCommentRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

-(void)deleteCommentRequestSuccessfulWithResult:(NSString*)msg;
-(void)deleteCommentRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

-(void)replyToCommentRequestSuccessfulWithResult:(NSString*)msg;
-(void)replyToCommentRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;

-(void)replyToStoryRequestSuccessfulWithResult:(NSString*)msg;
-(void)replyToStoryRequestFailedWithStatus:(NSString*)status wihtError:(NSString*)error;


@end


@interface ExpertCornerRequest : NSObject<NSURLConnectionDataDelegate, NSURLConnectionDelegate> {
    
    NSString *requestType;
}

@property (nonatomic, strong) NSMutableData *webData;
@property (nonatomic, assign) BOOL isForms;
@property (nonatomic, weak) id<ExpertRequestDelegate> delegate;

-(void)expertWithLowerLimit:(NSString *)lowerLimit withUpperLimit:(NSString *)upperLimit ;

-(void)forumListWithLowerLimit:(NSString *)lowerLimit withUpperLimit:(NSString *)upperLimit ;


-(void)lawsWithLowerLimit:(NSString *)lowerLimit withUpperLimit:(NSString *)upperLimit ;

-(void)faqsWithLowerLimit:(NSString *)lowerLimit withUpperLimit:(NSString *)upperLimit;

-(void)shareLinksWithLowerLimit:(NSString *)lowerLimit withUpperLimit:(NSString *)upperLimit;

-(void)expertTakeWithLowerLimit:(NSString *)lowerLimit withUpperLimit:(NSString *)upperLimit ;

-(void)getBookmarksWithLowerLimit:(NSString *)lowerLimit withUpperLimit:(NSString *)upperLimit ;

-(void)getNotificationValue;
-(void)setNotificationValue:(NSString*) value;

-(void)getDetailForumData:(NSString*) value;
-(void)editForumCommentWithCommentID:(NSString *)commentid commentString:(NSString *)commentSr withNID : (NSString*)nid ;

-(void)deleteForumCommentWithCommentID:(NSString *)commentid commentString:(NSString *)commentSr withNID : (NSString*)nid ;
-(void)replyToForumCommentWithCommentID:(NSString *)commentid commentString:(NSString *)commentSr withNID : (NSString*)nid ;
-(void)replyToStoryForumCommentWithCommentID:(NSString *)commentid commentString:(NSString *)commentSr withNID : (NSString*)nid ;

@end
