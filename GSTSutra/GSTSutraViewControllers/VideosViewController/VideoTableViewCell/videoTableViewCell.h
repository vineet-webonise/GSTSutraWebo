//
//  videoTableViewCell.h
//  GSTSutra
//
//  Created by niyuj on 12/6/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface videoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *videoTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *videoDateLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIImageView *videoThumbnailImageView;

@end
