//
//  topCenterView.h
//  GSTSutra
//
//  Created by niyuj on 11/24/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface topCenterView : UIView
@property (weak, nonatomic) IBOutlet UILabel *nameCenterLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileCenterImageView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) NSMutableArray *customConstraints;

@end
