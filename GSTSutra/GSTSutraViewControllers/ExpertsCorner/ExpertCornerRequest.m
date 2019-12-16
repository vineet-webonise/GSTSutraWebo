//
//  ExpertCornerRequest.m
//  GSTSutra
//
//  Created by niyuj on 11/23/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import "ExpertCornerRequest.h"
#import "Constants.h"
#import "AppData.h"
#import "NewsModel.h"

@implementation ExpertCornerRequest

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

-(void)expertWithLowerLimit:(NSString *)lowerLimit withUpperLimit:(NSString *)upperLimit{
    requestType = @"ExpertAPI";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/expert_corner_subject"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"token", [USERDEFAULTS valueForKey:@"userToken"]];
    [postString appendFormat:@"&%@=%@", @"lower_limit", lowerLimit];
    [postString appendFormat:@"&%@=%@", @"upper_limit", upperLimit];
    [postString appendFormat:@"&%@=%@", @"mac_id", [[NSUserDefaults standardUserDefaults]valueForKey:@"macID"]];
    [postString appendFormat:@"&%@=%@", @"device_token", [USERDEFAULTS valueForKey:@"deviceID"]];
    [postString appendFormat:@"&%@=%@", @"device_type", @"ios"];
    [self bodyWithUrlRequest:urlRequest postString:postString];
    
}

-(void)forumListWithLowerLimit:(NSString *)lowerLimit withUpperLimit:(NSString *)upperLimit{
    requestType = @"forumAPI";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/get_forumall"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"token", [USERDEFAULTS valueForKey:@"userToken"]];
    [postString appendFormat:@"&%@=%@", @"lower_limit", lowerLimit];
    [postString appendFormat:@"&%@=%@", @"upper_limit", upperLimit];
    [postString appendFormat:@"&%@=%@", @"mac_id", [[NSUserDefaults standardUserDefaults]valueForKey:@"macID"]];
    [postString appendFormat:@"&%@=%@", @"device_token", [USERDEFAULTS valueForKey:@"deviceID"]];
    [postString appendFormat:@"&%@=%@", @"device_type", @"ios"];
    [self bodyWithUrlRequest:urlRequest postString:postString];
    
}


-(void)lawsWithLowerLimit:(NSString *)lowerLimit withUpperLimit:(NSString *)upperLimit {
    requestType = @"lawsAPI";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/get_acts"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"token", [USERDEFAULTS valueForKey:@"userToken"]];
    [postString appendFormat:@"&%@=%@", @"lower_limit", lowerLimit];
    [postString appendFormat:@"&%@=%@", @"upper_limit", upperLimit];
    if (self.isForms) {
    [postString appendFormat:@"&%@=%@", @"type", @"1"];
    }
    
    [postString appendFormat:@"&%@=%@", @"mac_id", [[NSUserDefaults standardUserDefaults]valueForKey:@"macID"]];
    [postString appendFormat:@"&%@=%@", @"device_token", [USERDEFAULTS valueForKey:@"deviceID"]];
    [postString appendFormat:@"&%@=%@", @"device_type", @"ios"];
    [self bodyWithUrlRequest:urlRequest postString:postString];
    
}

-(void)faqsWithLowerLimit:(NSString *)lowerLimit withUpperLimit:(NSString *)upperLimit {
    requestType = @"FaqAPI";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/get_faq_list"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"token", [USERDEFAULTS valueForKey:@"userToken"]];
    [postString appendFormat:@"&%@=%@", @"lower_limit", lowerLimit];
    [postString appendFormat:@"&%@=%@", @"upper_limit", upperLimit];
    [self bodyWithUrlRequest:urlRequest postString:postString];
    
}

-(void)getBookmarksWithLowerLimit:(NSString *)lowerLimit withUpperLimit:(NSString *)upperLimit {
    requestType = @"BookmarkAPI";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/get_bookmark_list"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"token", [USERDEFAULTS valueForKey:@"userToken"]];
    [postString appendFormat:@"&%@=%@", @"lower_limit", lowerLimit];
    [postString appendFormat:@"&%@=%@", @"upper_limit", upperLimit];
    [self bodyWithUrlRequest:urlRequest postString:postString];
    
}


-(void)shareLinksWithLowerLimit:(NSString *)lowerLimit withUpperLimit:(NSString *)upperLimit {
    requestType = @"shareLinksAPI";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/get_site_links"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"token", [USERDEFAULTS valueForKey:@"userToken"]];
    [postString appendFormat:@"&%@=%@", @"lower_limit", lowerLimit];
    [postString appendFormat:@"&%@=%@", @"upper_limit", upperLimit];
    [self bodyWithUrlRequest:urlRequest postString:postString];
    
}



-(void)expertTakeWithLowerLimit:(NSString *)lowerLimit withUpperLimit:(NSString *)upperLimit{
    requestType = @"ExpertTakeAPI";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/get_taxringall"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"token", [USERDEFAULTS valueForKey:@"userToken"]];
    [postString appendFormat:@"&%@=%@", @"lower_limit", lowerLimit];
    [postString appendFormat:@"&%@=%@", @"upper_limit", upperLimit];
    [postString appendFormat:@"&%@=%@", @"mac_id", [[NSUserDefaults standardUserDefaults]valueForKey:@"macID"]];
    [postString appendFormat:@"&%@=%@", @"device_token", [USERDEFAULTS valueForKey:@"deviceID"]];
    [postString appendFormat:@"&%@=%@", @"device_type", @"ios"];
    [self bodyWithUrlRequest:urlRequest postString:postString];
    
}

-(void)getNotificationValue{
    requestType = @"getNotificationAPI";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/get_notification_value"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"token", [USERDEFAULTS valueForKey:@"userToken"]];
    
    [self bodyWithUrlRequest:urlRequest postString:postString];
    
}

-(void)setNotificationValue:(NSString *)value{
    requestType = @"setNotificationAPI";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/set_notification_value"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"token", [USERDEFAULTS valueForKey:@"userToken"]];
    [postString appendFormat:@"&%@=%@", @"is_notification", value];
    
    [self bodyWithUrlRequest:urlRequest postString:postString];
    
}

-(void)getDetailForumData:(NSString *)value{

    requestType = @"forumDetailAPI";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/get_forum_by_nid"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"token", [USERDEFAULTS valueForKey:@"userToken"]];
    [postString appendFormat:@"&%@=%@", @"nid", value];
    
    [self bodyWithUrlRequest:urlRequest postString:postString];
    
}

-(void)editForumCommentWithCommentID:(NSString *)commentid commentString:(NSString *)commentSr withNID:(NSString *)nid{
    
    requestType = @"EditForumAPI";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/edit_forum_comment"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"token", [USERDEFAULTS valueForKey:@"userToken"]];
    [postString appendFormat:@"&%@=%@", @"nid", nid];
    [postString appendFormat:@"&%@=%@", @"comment_id", commentid];
    [postString appendFormat:@"&%@=%@", @"comment", [commentSr stringByReplacingOccurrencesOfString:@"&" withString:@"%26" options:NSRegularExpressionSearch range:NSMakeRange(0, [commentSr length])]];
    
    [self bodyWithUrlRequest:urlRequest postString:postString];
    
}

-(void)deleteForumCommentWithCommentID:(NSString *)commentid commentString:(NSString *)commentSr withNID:(NSString *)nid{
    
    requestType = @"deleteForumCommentAPI";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/delete_forum_comment"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"token", [USERDEFAULTS valueForKey:@"userToken"]];
    [postString appendFormat:@"&%@=%@", @"nid", nid];
    [postString appendFormat:@"&%@=%@", @"comment_id", commentid];
    [postString appendFormat:@"&%@=%@", @"comment", commentSr];
    
    [self bodyWithUrlRequest:urlRequest postString:postString];
    
}

-(void)replyToForumCommentWithCommentID:(NSString *)commentid commentString:(NSString *)commentSr withNID:(NSString *)nid{
    requestType = @"replyToForumCommentAPI";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/reply_forum_comment"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"token", [USERDEFAULTS valueForKey:@"userToken"]];
    [postString appendFormat:@"&%@=%@", @"nid", nid];
    [postString appendFormat:@"&%@=%@", @"comment_id", commentid];
    [postString appendFormat:@"&%@=%@", @"comment", [commentSr stringByReplacingOccurrencesOfString:@"&" withString:@"%26" options:NSRegularExpressionSearch range:NSMakeRange(0, [commentSr length])]];
    
    [self bodyWithUrlRequest:urlRequest postString:postString];
    
}

-(void)replyToStoryForumCommentWithCommentID:(NSString *)commentid commentString:(NSString *)commentSr withNID:(NSString *)nid{
    
    requestType = @"replyToForumStoryAPI";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/post_forum_comment"]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"%@=%@", @"token", [USERDEFAULTS valueForKey:@"userToken"]];
    [postString appendFormat:@"&%@=%@", @"nid", nid];
    //[postString appendFormat:@"&%@=%@", @"comment_id", commentid];
    
    [postString appendFormat:@"&%@=%@", @"comment", [commentSr stringByReplacingOccurrencesOfString:@"&" withString:@"%26" options:NSRegularExpressionSearch range:NSMakeRange(0, [commentSr length])]];
    
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
    if ([requestType isEqualToString:@"ExpertAPI"]) {
        if ([self.delegate respondsToSelector:@selector(expertRequestFailedWithStatus:wihtError:)]) {
            [self.delegate expertRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    }else if ([requestType isEqualToString:@"lawsAPI"]) {
        if ([self.delegate respondsToSelector:@selector(getLawsRequestFailedWithStatus:wihtError:)]) {
            [self.delegate getLawsRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    }else if ([requestType isEqualToString:@"forumAPI"]) {
        if ([self.delegate respondsToSelector:@selector(getForumListRequestFailedWithStatus:wihtError:)]) {
            [self.delegate getForumListRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    }else if ([requestType isEqualToString:@"BookmarkAPI"]) {
        if ([self.delegate respondsToSelector:@selector(getBookmarkRequestFailedWithStatus:wihtError:)]) {
            [self.delegate getBookmarkRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    }else if ([requestType isEqualToString:@"FaqAPI"]) {
        if ([self.delegate respondsToSelector:@selector(getFAQRequestFailedWithStatus:wihtError:)]) {
            [self.delegate getFAQRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    }else if ([requestType isEqualToString:@"shareLinksAPI"]) {
        if ([self.delegate respondsToSelector:@selector(getLawsRequestFailedWithStatus:wihtError:)]) {
            [self.delegate getshareLinksRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    }else if ([requestType isEqualToString:@"ExpertTakeAPI"]) {
        if ([self.delegate respondsToSelector:@selector(expertTakeRequestFailedWithStatus:wihtError:)]) {
            [self.delegate expertTakeRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    }else if ([requestType isEqualToString:@"forumDetailAPI"]) {
        if ([self.delegate respondsToSelector:@selector(getForumDetailRequestFailedWithStatus:wihtError:)]) {
            [self.delegate getForumDetailRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    }else if ([requestType isEqualToString:@"getNotificationAPI"]) {
        if ([self.delegate respondsToSelector:@selector(getNotificationSwitchValueRequestFailedWithStatus:wihtError:)]) {
            [self.delegate getNotificationSwitchValueRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
        
    }else if ([requestType isEqualToString:@"setNotificationAPI"]) {
        if ([self.delegate respondsToSelector:@selector(setNotificationSwitchValueRequestFailedWithStatus:wihtError:)]) {
            [self.delegate setNotificationSwitchValueRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    }else if ([requestType isEqualToString:@"EditForumAPI"]) {
        if ([self.delegate respondsToSelector:@selector(editCommentRequestFailedWithStatus:wihtError:)]) {
            [self.delegate editCommentRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    }else if ([requestType isEqualToString:@"deleteForumCommentAPI"]) {
        if ([self.delegate respondsToSelector:@selector(deleteCommentRequestFailedWithStatus:wihtError:)]) {
            [self.delegate deleteCommentRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    }else if ([requestType isEqualToString:@"replyToForumStoryAPI"]) {
        if ([self.delegate respondsToSelector:@selector(replyToStoryRequestFailedWithStatus:wihtError:)]) {
            [self.delegate replyToStoryRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    }else if ([requestType isEqualToString:@"replyToForumCommentAPI"]) {
        if ([self.delegate respondsToSelector:@selector(replyToCommentRequestFailedWithStatus:wihtError:)]) {
            [self.delegate replyToCommentRequestFailedWithStatus:@"0" wihtError:error.localizedDescription];
        }
    }
    
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
        }else if ([requestType isEqualToString:@"lawsAPI"]) {
            
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                
                if ([self.delegate respondsToSelector:@selector(getLawsRequestSuccessfulWithResult:)]) {
                    
                    [self.delegate getLawsRequestSuccessfulWithResult:[jsonDict objectForKey:@"result"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(getLawsRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate getLawsRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                }
            }
        }else if ([requestType isEqualToString:@"forumAPI"]) {
            
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                
                if ([self.delegate respondsToSelector:@selector(getForumListRequestSuccessfulWithResult:)]) {
                    
                    [self.delegate getForumListRequestSuccessfulWithResult:[jsonDict objectForKey:@"result"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(getForumListRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate getForumListRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                }
            }
        }else if ([requestType isEqualToString:@"EditForumAPI"]) {
            
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                
                if ([self.delegate respondsToSelector:@selector(editCommentRequestSuccessfulWithResult:)]) {
                    
                    [self.delegate editCommentRequestSuccessfulWithResult:[jsonDict objectForKey:@"msg"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(editCommentRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate editCommentRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                }
            }
        }else if ([requestType isEqualToString:@"deleteForumCommentAPI"]) {
            
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                
                if ([self.delegate respondsToSelector:@selector(deleteCommentRequestSuccessfulWithResult:)]) {
                    
                    [self.delegate deleteCommentRequestSuccessfulWithResult:[jsonDict objectForKey:@"msg"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(deleteCommentRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate deleteCommentRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                }
            }
        }else if ([requestType isEqualToString:@"replyToForumCommentAPI"]) {
            
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                
                if ([self.delegate respondsToSelector:@selector(replyToCommentRequestSuccessfulWithResult:)]) {
                    
                    [self.delegate replyToCommentRequestSuccessfulWithResult:[jsonDict objectForKey:@"msg"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(replyToCommentRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate replyToCommentRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                }
            }
        }else if ([requestType isEqualToString:@"replyToForumStoryAPI"]) {
            
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                
                if ([self.delegate respondsToSelector:@selector(replyToStoryRequestSuccessfulWithResult:)]) {
                    
                    [self.delegate replyToStoryRequestSuccessfulWithResult:[jsonDict objectForKey:@"msg"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(replyToStoryRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate replyToStoryRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                }
            }
        }else if ([requestType isEqualToString:@"forumDetailAPI"]) {
            
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                
                if ([self.delegate respondsToSelector:@selector(getForumDetailRequestSuccessfulWithResult:)]) {
                    
                    [self.delegate getForumDetailRequestSuccessfulWithResult:[jsonDict objectForKey:@"result"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(getForumListRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate getForumListRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                }
            }
        }else if ([requestType isEqualToString:@"BookmarkAPI"]) {
            
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                
                if ([self.delegate respondsToSelector:@selector(getBookmarkRequestSuccessfulWithResult:)]) {
                    
                    [self.delegate getBookmarkRequestSuccessfulWithResult:[jsonDict objectForKey:@"result"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(getBookmarkRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate getBookmarkRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                }
            }
        }else if ([requestType isEqualToString:@"FaqAPI"]) {
            
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                
                if ([self.delegate respondsToSelector:@selector(getFAQRequestSuccessfulWithResult:)]) {
                    
                    [self.delegate getFAQRequestSuccessfulWithResult:[jsonDict objectForKey:@"result"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(getFAQRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate getFAQRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                }
            }
        }else if ([requestType isEqualToString:@"shareLinksAPI"]) {
            
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                
                if ([self.delegate respondsToSelector:@selector(getshareLinksRequestSuccessfulWithResult:)]) {
                    
                    [self.delegate getshareLinksRequestSuccessfulWithResult:[jsonDict objectForKey:@"result"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(getshareLinksRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate getshareLinksRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                }
            }
        }else if ([requestType isEqualToString:@"getNotificationAPI"]) {
            
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                
                if ([self.delegate respondsToSelector:@selector(getNotificationSwitchValueRequestSuccessfulWithResult:)]) {
                    
                    [self.delegate getNotificationSwitchValueRequestSuccessfulWithResult:[jsonDict objectForKey:@"result"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(getNotificationSwitchValueRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate getNotificationSwitchValueRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                }
            }
        }else if ([requestType isEqualToString:@"setNotificationAPI"]) {
            
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                
                if ([self.delegate respondsToSelector:@selector(setNotificationSwitchValueRequestSuccessfulWithResult:)]) {
                    
                    [self.delegate setNotificationSwitchValueRequestSuccessfulWithResult:[jsonDict objectForKey:@"result"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(setNotificationSwitchValueRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate setNotificationSwitchValueRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
                }
            }
        } else if ([requestType isEqualToString:@"ExpertTakeAPI"]) {
            
            if ([[jsonDict objectForKey:@"status"] integerValue]) {
                
                if ([self.delegate respondsToSelector:@selector(expertTakeRequestSuccessfulWithResult:)]) {
        
                    [self.delegate expertTakeRequestSuccessfulWithResult:[jsonDict objectForKey:@"result"]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(expertTakeRequestFailedWithStatus:wihtError:)]) {
                    [self.delegate expertTakeRequestFailedWithStatus:[jsonDict objectForKey:@"status"] wihtError:[jsonDict objectForKey:@"msg"]];
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
