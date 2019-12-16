//
//  LongNewsViewController.h
//  GSTSutra
//
//  Created by niyuj on 11/14/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface LongNewsViewController : BaseViewController

@property (nonatomic,strong)NSMutableArray *longViewNewsArray;
@property (nonatomic,assign)NSInteger selectedIndex;

@end
