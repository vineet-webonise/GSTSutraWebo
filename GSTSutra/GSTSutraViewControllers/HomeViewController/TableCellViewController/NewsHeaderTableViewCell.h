//
//  NewsHeaderTableViewCell.h
//  GSTSutra
//
//  Created by niyuj on 11/11/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsHeaderTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *NewsHeaderImageView;
@property (weak, nonatomic) IBOutlet UILabel *NewsHeaderLabel;
@property (weak, nonatomic) IBOutlet UIButton *bookmarkButtonClicked;

@end
