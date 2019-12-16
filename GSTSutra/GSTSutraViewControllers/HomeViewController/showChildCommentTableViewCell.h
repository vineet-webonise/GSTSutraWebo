//
//  showChildCommentTableViewCell.h
//  GSTSutra
//
//  Created by niyuj on 1/24/17.
//  Copyright © 2017 niyuj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface showChildCommentTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *childImageView;
@property (weak, nonatomic) IBOutlet UILabel *childNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *childCommentLabel;
@property (weak, nonatomic) IBOutlet UILabel *childDateLabel;
@property (weak, nonatomic) IBOutlet UIButton *childDeleteButton;
@property (weak, nonatomic) IBOutlet UIButton *childEditButton;
@property (weak, nonatomic) IBOutlet UIButton *childReplyButton;
@property (weak, nonatomic) IBOutlet UIButton *ReplyWhenAllHidden;

@end
