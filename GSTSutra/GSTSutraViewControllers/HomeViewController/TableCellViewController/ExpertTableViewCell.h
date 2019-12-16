//
//  ExpertTableViewCell.h
//  GSTSutra
//
//  Created by niyuj on 12/1/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExpertTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *NewsImageView;
@property (weak, nonatomic) IBOutlet UILabel *NewsTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *NewsDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *NewDateLabel;

@end
