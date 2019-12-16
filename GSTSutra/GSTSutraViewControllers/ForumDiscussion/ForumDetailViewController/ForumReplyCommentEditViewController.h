//
//  ForumReplyCommentEditViewController.h
//  GSTSutra
//
//  Created by niyuj on 1/28/17.
//  Copyright © 2017 niyuj. All rights reserved.
//

#import "BaseViewController.h"

@interface ForumReplyCommentEditViewController : BaseViewController
@property(nonatomic,assign)BOOL isEditComment;
@property(nonatomic,assign)NSString *nID;
@property(nonatomic,assign)NSString *editableText;
@property(nonatomic,assign)NSString *commentID;
@property(nonatomic,assign)BOOL isReplyToComment;




@end
