//
//  NewsModel.h
//  GSTSutra
//
//  Created by niyuj on 11/14/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsModel : NSObject

@property (nonatomic, strong) NSString *NewsImage;
@property (nonatomic, strong) NSString *NewsID;
@property (nonatomic, strong) NSString *NewsTitle;
@property (nonatomic, strong) NSString *NewsSubtitle;
@property (nonatomic, strong) NSString *NewsShortViewData;
@property (nonatomic, strong) NSString *NewsLongViewURL;
@property (nonatomic, strong) NSString *NewsRating;
@property (nonatomic, strong) NSString *NewsDateTime;
@property (nonatomic, strong) NSString *NewsLocation;
@property (nonatomic, strong) NSString *NewsType;
@property (nonatomic, strong) NSString *isadvertise;
@property (nonatomic, strong) NSString *ADVTitle;
@property (nonatomic, strong) NSString *ADVImageURL;
@property (nonatomic, strong) NSString *ADVdURL;
@property (nonatomic, strong) NSString *isLiked;
@property (nonatomic, strong) NSString *isBookMark;
@property (nonatomic, strong) NSArray *CommentsArray;
@property (nonatomic, strong) NSString *CommentId;
@property (nonatomic, strong) NSString *CommentUserName;
@property (nonatomic, strong) NSString *CommentUserImageURL;
@property (nonatomic, strong) NSString *CommentText;
@property (nonatomic, strong) NSString *CommentDateTime;
@property (nonatomic, strong) NSString *NewsContent;
@property (nonatomic, strong) NSString *NewsStoryType;



@end
