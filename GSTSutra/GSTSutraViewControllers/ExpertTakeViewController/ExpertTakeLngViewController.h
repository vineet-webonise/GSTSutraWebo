//
//  ExpertTakeLngViewController.h
//  GSTSutra
//
//  Created by niyuj on 11/24/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import "BaseViewController.h"

@interface ExpertTakeLngViewController : BaseViewController
@property (nonatomic,strong)NSMutableArray *expertTakeArray;
@property (nonatomic,assign)NSInteger selectedIndex;
@property (nonatomic,assign)NSInteger selectedItem;
@property (nonatomic,assign)NSInteger PreviouslyselectedItem;

@end
