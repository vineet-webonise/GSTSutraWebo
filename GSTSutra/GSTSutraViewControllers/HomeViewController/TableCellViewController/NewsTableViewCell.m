//
//  NewsTableViewCell.m
//  GSTSutra
//
//  Created by niyuj on 11/11/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import "NewsTableViewCell.h"

@implementation NewsTableViewCell

- (void)awakeFromNib {
    // Initialization code
     [super awakeFromNib];
    
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.NewsTitleLabel layoutIfNeeded];
    [self.NewsDetailLabel layoutIfNeeded];
    
}
-(void)viewDidLayoutSubviews{
   [self layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
