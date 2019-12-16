//
//  ShowCommentTableViewCell.h
//  GSTSutra
//
//  Created by niyuj on 11/18/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShowCommentTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *editButtonClick;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *replyWhenAllHide;

@end
