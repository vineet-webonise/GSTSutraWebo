//
//  shareView.h
//  collectionDemo
//
//  Created by niyuj on 12/28/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "shareCollectionViewCell.h"

@interface shareView : UIView
@property (weak, nonatomic) IBOutlet UICollectionView *shareCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *closeShareButton;

@end
