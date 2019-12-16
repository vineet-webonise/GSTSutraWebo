//
//  TypeCommentTableViewCell.h
//  GSTSutra
//
//  Created by niyuj on 11/18/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TypeCommentTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UITextView *userCommentTextView;
@property (weak, nonatomic) IBOutlet UIButton *postButton;
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;

@end
