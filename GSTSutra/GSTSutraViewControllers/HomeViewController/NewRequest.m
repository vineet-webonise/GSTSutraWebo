//
//  NewRequest.m
//  GSTSutra
//
//  Created by niyuj on 11/12/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import "NewRequest.h"
#import "Constants.h"
#import "AppData.h"
#import "NewsModel.h"
#import "AppDelegate.h"

@implementation NewRequest{
    //AppDelegate *appD;
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

-(void)newsWithLowerLimit:(NSString *)lowerLimit withUpperLimit:(NSString *)upperLimit newsType:(NSString *)newsType industryType:(NSString *)industryType{
    requestType = @"IndustryNewsAPI";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/get_news_data_memcache_by_industry"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setTimeoutInterval:120];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"token", [USERDEFAULTS valueForKey:@"userToken"]];
    [postString appendFormat:@"&%@=%@", @"lower_limit", lowerLimit];
    [postString appendFormat:@"&%@=%@", @"upper_limit", upperLimit];
    [postString appendFormat:@"&%@=%@", @"news_type", newsType];
    [postString appendFormat:@"&%@=%@", @"industry_type", industryType];
    
    [postString appendFormat:@"&%@=%@", @"mac_id", [[NSUserDefaults standardUserDefaults]valueForKey:@"macID"]];
    [postString appendFormat:@"&%@=%@", @"device_token", [USERDEFAULTS valueForKey:@"deviceID"]];
    [postString appendFormat:@"&%@=%@", @"device_type", @"ios"];
    [self bodyWithUrlRequest:urlRequest postString:postString];
    
}

-(void)newsWithLowerLimit:(NSString *)lowerLimit withUpperLimit:(NSString *)upperLimit newsType:(NSString*)newsType locationType:(NSString*)locationType{
    requestType = @"NewsAPI";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/get_news_data"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setTimeoutInterval:120];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"token", [USERDEFAULTS valueForKey:@"userToken"]];
    [postString appendFormat:@"&%@=%@", @"lower_limit", lowerLimit];
    [postString appendFormat:@"&%@=%@", @"upper_limit", upperLimit];
    [postString appendFormat:@"&%@=%@", @"news_type", newsType];
    [postString appendFormat:@"&%@=%@", @"location_type", locationType];
    
    [postString appendFormat:@"&%@=%@", @"mac_id", [[NSUserDefaults standardUserDefaults]valueForKey:@"macID"]];
    [postString appendFormat:@"&%@=%@", @"device_token", [USERDEFAULTS valueForKey:@"deviceID"]];
    [postString appendFormat:@"&%@=%@", @"device_type", @"ios"];
    [self bodyWithUrlRequest:urlRequest postString:postString];
    
}


-(void)getNotificationNewsWithStoryId:(NSString *)storyID withStoryType:(NSString *)storyType{
    
    requestType = @"NewsNotificationAPI";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/notification_news_by_id"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setTimeoutInterval:120];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"token", [USERDEFAULTS valueForKey:@"userToken"]];
    [postString appendFormat:@"&%@=%@", @"sid", storyID];
    [postString appendFormat:@"&%@=%@", @"story_type", storyType];
    
    NSString *temp = [(AppDelegate*)[[UIApplication sharedApplication] delegate] msg];
    [postString appendFormat:@"&%@=%@", @"groupname", [temp stringByReplacingOccurrencesOfString:@"&" withString:@"%26" options:NSRegularExpressionSearch range:NSMakeRange(0, [temp length])]];

    [postString appendFormat:@"&%@=%@", @"groupdate", [(AppDelegate*)[[UIApplication sharedApplication] delegate] sid]];
    
    [self bodyWithUrlRequest:urlRequest postString:postString];
    
}



-(void)likeNewsWithStoryId:(NSString *)storyID withStoryType:(NSString *)storyType withLikeValue:(NSString *)lid {
    requestType = @"likeNews";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/set_likes"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"token",[USERDEFAULTS valueForKey:@"userToken"]];
    [postString appendFormat:@"&%@=%@", @"sid", storyID];
    [postString appendFormat:@"&%@=%@", @"story_type", storyType];
    [postString appendFormat:@"&%@=%@", @"is_like", lid];
    [self bodyWithUrlRequest:urlRequest postString:postString];
}

-(void)getVideoUrlsWithLowerLimit:(NSString *)lowerLimit withUpperLimit:(NSString *)upperLimit  videoType:(NSString*)videoType{
    requestType = @"video";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/get_youtube_links"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"token",[USERDEFAULTS valueForKey:@"userToken"]];
    [postString appendFormat:@"&%@=%@", @"lower_limit", lowerLimit];
    [postString appendFormat:@"&%@=%@", @"upper_limit", upperLimit];
    [postString appendFormat:@"&%@=%@", @"youtube_type", videoType];
    [self bodyWithUrlRequest:urlRequest postString:postString];
}

-(void)setYouTubeVideoViewCountWithID:(NSString *)eID {
    requestType = @"VideoViewCountAPI";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/set_youtube_views_api"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"token",[USERDEFAULTS valueForKey:@"userToken"]];
    [postString appendFormat:@"&%@=%@", @"eid", eID];
    [self bodyWithUrlRequest:urlRequest postString:postString];
}

-(void)getAllAdvertisements {
    requestType = @"ADVAPI";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/advertisement_api"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"token",[USERDEFAULTS valueForKey:@"userToken"]];
    [self bodyWithUrlRequest:urlRequest postString:postString];
}

-(void)getUserLikes {
    requestType = @"userLike";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/get_user_like_list"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"token",[USERDEFAULTS valueForKey:@"userToken"]];
    [self bodyWithUrlRequest:urlRequest postString:postString];
}

-(void)getUserBookmarks {
    requestType = @"userBookmark";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/get_user_bookmark_list"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"token",[USERDEFAULTS valueForKey:@"userToken"]];
    [self bodyWithUrlRequest:urlRequest postString:postString];
}

-(void)getAllIndustries {
    requestType = @"industries";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/get_industry_data"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"token",[USERDEFAULTS valueForKey:@"userToken"]];
    [self bodyWithUrlRequest:urlRequest postString:postString];
}

-(void)getCommentWithStoryId:(NSString *)storyID withStoryType:(NSString *)storyType {
    requestType = @"getComment";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/get_comment"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"token",[USERDEFAULTS valueForKey:@"userToken"]];
    [postString appendFormat:@"&%@=%@", @"sid", storyID];
    [postString appendFormat:@"&%@=%@", @"story_type", storyType];
    [self bodyWithUrlRequest:urlRequest postString:postString];
}

-(void)deleteCommentWithCommentID:(NSString *)commentID{
    requestType = @"deleteComment";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/delete_comment"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"token",[USERDEFAULTS valueForKey:@"userToken"]];
    [postString appendFormat:@"&%@=%@", @"comment_id", commentID];
    [self bodyWithUrlRequest:urlRequest postString:postString];
}

-(void)updateCommentWithCommentID:(NSString *)commentID withUpdatedCommentString:(NSString *)commentString {
    
    requestType = @"updateComment";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/edit_comment"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"token",[USERDEFAULTS valueForKey:@"userToken"]];
    [postString appendFormat:@"&%@=%@", @"comment_id", commentID];
    
    [postString appendFormat:@"&%@=%@", @"comment", [commentString stringByReplacingOccurrencesOfString:@"&" withString:@"%26" options:NSRegularExpressionSearch range:NSMakeRange(0, [commentString length])]];
    [self bodyWithUrlRequest:urlRequest postString:postString];
}

 -(void)newsRelatedWithStoryId:(NSString *)storyID andWithStoryType:(NSString*)storyType{
    requestType = @"relatedStory";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/releted_stories"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"token",[USERDEFAULTS valueForKey:@"userToken"]];
     [postString appendFormat:@"&%@=%@", @"sid", storyID];
     [postString appendFormat:@"&%@=%@", @"story_type", storyType];
    [self bodyWithUrlRequest:urlRequest postString:postString];
}

-(void)rateNewsWithStoryId:(NSString *)storyID withStoryType:(NSString *)storyType withRateValue:(NSString*)starValue{
    
    requestType = @"rateNews";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/set_ratings"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"token",[USERDEFAULTS valueForKey:@"userToken"]];
    [postString appendFormat:@"&%@=%@", @"sid", storyID];
    [postString appendFormat:@"&%@=%@", @"story_type", storyType];
    [postString appendFormat:@"&%@=%@", @"score", starValue];
    [self bodyWithUrlRequest:urlRequest postString:postString];
}

-(void)setCommentWithStoryId:(NSString *)storyID withStoryType:(NSString *)storyType withCommentString:(NSString*)comment{
    
    requestType = @"commentNews";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/set_comment"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"token",[USERDEFAULTS valueForKey:@"userToken"]];
    [postString appendFormat:@"&%@=%@", @"sid", storyID];
    [postString appendFormat:@"&%@=%@", @"story_type", storyType];
    
    [postString appendFormat:@"&%@=%@", @"comment", [comment stringByReplacingOccurrencesOfString:@"&" withString:@"%26" options:NSRegularExpressionSearch range:NSMakeRange(0, [comment length])]];
    [self bodyWithUrlRequest:urlRequest postString:postString];
    
}

-(void)bookMarkNewsWithStoryId:(NSString *)storyID withStoryType:(NSString *)storyType withBookmarkValue:(NSString *)bid {
    requestType = @"bookmarkNews";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/set_bookmarks"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"token",[USERDEFAULTS valueForKey:@"userToken"]];
    [postString appendFormat:@"&%@=%@", @"sid", storyID];
    [postString appendFormat:@"&%@=%@", @"story_type", storyType];
    [postString appendFormat:@"&%@=%@", @"is_bookmarks", bid];
    [self bodyWithUrlRequest:urlRequest postString:postString];
}

-(void)viewNewsWithStoryId:(NSString *)storyID withStoryType:(NSString *)storyType withViewId:(NSString*)viewId{
    requestType = @"viewNews";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/set_news_views"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"token",[USERDEFAULTS valueForKey:@"userToken"]];
    [postString appendFormat:@"&%@=%@", @"sid", storyID];
    [postString appendFormat:@"&%@=%@", @"story_type", storyType];
    [postString appendFormat:@"&%@=%@", @"is_view", viewId];
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
    if ([requestType isEqualToString:@"NewsAPI"]) {
        if ([self.delegate respondsToSelector:@selector(newsRequestFailedWithStatus:wihtError:)]) {
            [self.delegate newsRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    }else if ([requestType isEqualToString:@"IndustryNewsAPI"]) {
        if ([self.delegate respondsToSelector:@selector(newsForIndustriesRequestFailedWithStatus:wihtError:)]) {
            [self.delegate newsForIndustriesRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    }else if ([requestType isEqualToString:@"IndustryNewsAPI"]) {
        if ([self.delegate respondsToSelector:@selector(newsForIndustriesRequestFailedWithStatus:wihtError:)]) {
            [self.delegate newsForIndustriesRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    }else if ([requestType isEqualToString:@"NewsNotificationAPI"]) {
        if ([self.delegate respondsToSelector:@selector(newsNotificationRequestFailedWithStatus:wihtError:)]) {
            [self.delegate newsNotificationRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    }else if ([requestType isEqualToString:@"ADVAPI"]) {
        if ([self.delegate respondsToSelector:@selector(getAllADVRequestFailedWithStatus:wihtError:)]) {
            [self.delegate getAllADVRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    } else if ([requestType isEqualToString:@"industries"]) {
        if ([self.delegate respondsToSelector:@selector(industriesRequestFailedWithStatus:wihtError:)]) {
            [self.delegate industriesRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    }else if ([requestType isEqualToString:@"likeNews"]) {
        if ([self.delegate respondsToSelector:@selector(likeNewsRequestFailedWithStatus:wihtError:)]) {
            [self.delegate likeNewsRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    }else if ([requestType isEqualToString:@"VideoViewCountAPI"]) {
        if ([self.delegate respondsToSelector:@selector(setVideoViewRequestFailedWithStatus:wihtError:)]) {
            [self.delegate setVideoViewRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    }else if ([requestType isEqualToString:@"userLike"]) {
        if ([self.delegate respondsToSelector:@selector(getUserLikeRequestFailedWithStatus:wihtError:)]) {
            [self.delegate getUserLikeRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    }else if ([requestType isEqualToString:@"userBookmark"]) {
        if ([self.delegate respondsToSelector:@selector(getUserBookmarkRequestFailedWithStatus:wihtError:)]) {
            [self.delegate getUserBookmarkRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    }else if ([requestType isEqualToString:@"relatedStory"]) {
        if ([self.delegate respondsToSelector:@selector(newsRelatedRequestFailedWithStatus:wihtError:)]) {
            [self.delegate newsRelatedRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    } else if ([requestType isEqualToString:@"video"]) {
        if ([self.delegate respondsToSelector:@selector(videoRequestFailedWithStatus:wihtError:)]) {
            [self.delegate videoRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    } else if ([requestType isEqualToString:@"rateNews"]) {
        if ([self.delegate respondsToSelector:@selector(rateNewsRequestFailedWithStatus:wihtError:)]) {
            [self.delegate rateNewsRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    }else if ([requestType isEqualToString:@"bookmarkNews"]) {
        if ([self.delegate respondsToSelector:@selector(bookmarkNewsRequestFailedWithStatus:wihtError:)]) {
            [self.delegate bookmarkNewsRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    } else if ([requestType isEqualToString:@"commentNews"]) {
        if ([self.delegate respondsToSelector:@selector(setCommentRequestFailedWithStatus:wihtError:)]) {
            [self.delegate setCommentRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    }else if ([requestType isEqualToString:@"getComment"]) {
        if ([self.delegate respondsToSelector:@selector(getCommentRequestFailedWithStatus:wihtError:)]) {
            [self.delegate getCommentRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    }else if ([requestType isEqualToString:@"deleteComment"]) {
        if ([self.delegate respondsToSelector:@selector(deleteCommentRequestFailedWithStatus:wihtError:)]) {
            [self.delegate deleteCommentRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    }else if ([requestType isEqualToString:@"updateComment"]) {
        if ([self.delegate respondsToSelector:@selector(updateCommentRequestFailedWithStatus:wihtError:)]) {
            [self.delegate updateCommentRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    }else {
        if ([self.delegate respondsToSelector:@selector(viewNewsRequestFailedWithStatus:wihtError:)]) {
            [self.delegate viewNewsRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];}
    }
    
}

-(void)requestCompletedWithData {
    
    @try {
        
        NSString *temp = [[NSString alloc]initWithData:self.webData encoding:NSUTF8StringEncoding];
        //NSLog(@"Response = %@",temp);
        
        NSError *error;
        NSMutableDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:self.webData options:NSJSONReadingAllowFragments error:&error];
        
        if ([requestType isEqualToString:@"NewsAPI"]) {
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                if ([self.delegate respondsToSelector:@selector(newsRequestSuccessfulWithResult:)]) {
                    
                    NewsModel *news = [[NewsModel alloc] init];
                    
                    for (int i = 0; i < [[jsonDict objectForKey:@"result"] count]; i++){
                        
                        news.NewsID = [[[jsonDict objectForKey:@"result"] objectAtIndex:i]objectForKey:@"sid"];
                        news.NewsImage = [[[jsonDict objectForKey:@"result"] objectAtIndex:i] objectForKey:@"image"] ;
                        news.NewsShortViewData = [[[jsonDict objectForKey:@"result"] objectAtIndex:i] objectForKey:@"shortview"];
                        news.NewsLongViewURL = [[[jsonDict objectForKey:@"result"] objectAtIndex:i] objectForKey:@"longview"];
                        news.isBookMark = [[[jsonDict objectForKey:@"result"] objectAtIndex:i] objectForKey:@"isbookmark"];
                        news.NewsDateTime = [[[jsonDict objectForKey:@"result"] objectAtIndex:i] objectForKey:@"date"];
                        news.NewsTitle = [[[jsonDict objectForKey:@"result"] objectAtIndex:i] objectForKey:@"headline"];
                        news.NewsType = [[[jsonDict objectForKey:@"result"] objectAtIndex:i] objectForKey:@"type"];
                        news.isadvertise = [[[jsonDict objectForKey:@"result"] objectAtIndex:i] objectForKey:@"IsAdvertise"] ;
                        news.NewsRating = [[[jsonDict objectForKey:@"result"] objectAtIndex:i] objectForKey:@"rating"];
                        news.isLiked = [[[jsonDict objectForKey:@"result"] objectAtIndex:i] objectForKey:@"islikes"];
                        news.NewsRating = [[[jsonDict objectForKey:@"result"] objectAtIndex:i] objectForKey:@"content"];
                        news.NewsRating = [[[jsonDict objectForKey:@"result"] objectAtIndex:i] objectForKey:@"story_type"];
                
                        [AppData getInstance].newsData = news;
                        
                    }
                
                    [self.delegate newsRequestSuccessfulWithResult:[jsonDict objectForKey:@"result"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(newsRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate newsRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                }
            }
        }else if ([requestType isEqualToString:@"IndustryNewsAPI"]) {
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                if ([self.delegate respondsToSelector:@selector(newsForIndustriesRequestSuccessfulWithResult:)]) {
                    
                    [self.delegate newsForIndustriesRequestSuccessfulWithResult:[jsonDict objectForKey:@"result"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(newsForIndustriesRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate newsForIndustriesRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                }
            }
        }else if ([requestType isEqualToString:@"VideoViewCountAPI"]) {
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                if ([self.delegate respondsToSelector:@selector(setVideoViewRequestSuccessfulWithResult:)]) {
                    
                    [self.delegate setVideoViewRequestSuccessfulWithResult:[jsonDict objectForKey:@"result"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(setVideoViewRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate setVideoViewRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                }
            }
        }else if ([requestType isEqualToString:@"NewsNotificationAPI"]) {
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                if ([self.delegate respondsToSelector:@selector(newsNotificationRequestSuccessfulWithResult:)]) {
                    [self.delegate newsNotificationRequestSuccessfulWithResult:[jsonDict objectForKey:@"result"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(newsNotificationRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate newsNotificationRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                }
            }
        }else if ([requestType isEqualToString:@"ADVAPI"]) {
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                if ([self.delegate respondsToSelector:@selector(getAllADVRequestSuccessfulWithResult:)]) {
                    [self.delegate getAllADVRequestSuccessfulWithResult:[jsonDict objectForKey:@"result"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(getAllADVRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate getAllADVRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                }
            }
        } else if ([requestType isEqualToString:@"relatedStory"]) {
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                if ([self.delegate respondsToSelector:@selector(newsRelatedRequestSuccessfulWithResult:)]) {
                    [self.delegate newsRelatedRequestSuccessfulWithResult:[jsonDict objectForKey:@"result"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(newsRelatedRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate newsRelatedRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                }
            }
        }else if ([requestType isEqualToString:@"likeNews"]) {
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                if ([self.delegate respondsToSelector:@selector(likeNewsRequestSuccessfulWithStatus:)]) {
                    [self.delegate likeNewsRequestSuccessfulWithStatus:[jsonDict objectForKey:@"result"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(likeNewsRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate likeNewsRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                }
            }
        }else if ([requestType isEqualToString:@"userLike"]) {
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                if ([self.delegate respondsToSelector:@selector(getUserLikeRequestSuccessfulWithResult:)]) {
                    [self.delegate getUserLikeRequestSuccessfulWithResult:[jsonDict objectForKey:@"result"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(getUserLikeRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate getUserLikeRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                }
            }
        }else if ([requestType isEqualToString:@"userBookmark"]) {
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                if ([self.delegate respondsToSelector:@selector(getUserBookmarkRequestSuccessfulWithResult:)]) {
                    [self.delegate getUserBookmarkRequestSuccessfulWithResult:[jsonDict objectForKey:@"result"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(getUserBookmarkRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate getUserBookmarkRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                }
            }
        }else if ([requestType isEqualToString:@"video"]) {
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                if ([self.delegate respondsToSelector:@selector(VideoRequestSuccessfulWithResult:)]) {
                    [self.delegate VideoRequestSuccessfulWithResult:[jsonDict objectForKey:@"result"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(videoRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate videoRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                }
            }
        }else if ([requestType isEqualToString:@"industries"]) {
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                if ([self.delegate respondsToSelector:@selector(industriesRequestSuccessfulWithResult:)]) {
                    [self.delegate industriesRequestSuccessfulWithResult:[jsonDict objectForKey:@"result"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(industriesRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate industriesRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                }
            }
        } else if ([requestType isEqualToString:@"commentNews"]) {
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                if ([self.delegate respondsToSelector:@selector(setCommentRequestSuccessfulWithStatus:)]) {
                    [self.delegate setCommentRequestSuccessfulWithStatus:[jsonDict objectForKey:@"msg"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(setCommentRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate setCommentRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                }
            }
        }else if ([requestType isEqualToString:@"rateNews"]) {
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                if ([self.delegate respondsToSelector:@selector(rateNewsRequestSuccessfulWithStatus:)]) {
                    [self.delegate rateNewsRequestSuccessfulWithStatus:[jsonDict objectForKey:@"result"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(rateNewsRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate rateNewsRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                }
            }
        }else if ([requestType isEqualToString:@"getComment"]) {
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                if ([self.delegate respondsToSelector:@selector(getCommentRequestSuccessfulWithStatus:)]) {
                    [self.delegate getCommentRequestSuccessfulWithStatus:[jsonDict objectForKey:@"result"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(getCommentRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate getCommentRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                }
            }
        } else if ([requestType isEqualToString:@"deleteComment"]) {
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                if ([self.delegate respondsToSelector:@selector(deleteCommentRequestSuccessfulWithStatus:)]) {
                    [self.delegate deleteCommentRequestSuccessfulWithStatus:[jsonDict objectForKey:@"result"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(deleteCommentRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate deleteCommentRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                }
            }
        }else if ([requestType isEqualToString:@"updateComment"]) {
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                if ([self.delegate respondsToSelector:@selector(updateCommentRequestSuccessfulWithStatus:)]) {
                    [self.delegate updateCommentRequestSuccessfulWithStatus:[jsonDict objectForKey:@"result"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(updateCommentRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate updateCommentRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                }
            }
        } else if ([requestType isEqualToString:@"bookmarkNews"]) {
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                if ([self.delegate respondsToSelector:@selector(bookmarkNewsRequestSuccessfulWithStatus:)]) {
                    [self.delegate bookmarkNewsRequestSuccessfulWithStatus:[jsonDict objectForKey:@"msg"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(bookmarkNewsRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate bookmarkNewsRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                }
            }
        }else if ([requestType isEqualToString:@"viewNews"]) {
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                if ([self.delegate respondsToSelector:@selector(viewNewsRequestSuccessfulWithStatus:)]) {
                    [self.delegate viewNewsRequestSuccessfulWithStatus:[jsonDict objectForKey:@"status"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(viewNewsRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate viewNewsRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
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
