//
//  ShortNewsViewController.h
//  GSTSutra
//
//  Created by niyuj on 11/11/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ShortNewsViewController :BaseViewController
@property (nonatomic,strong)NSMutableArray *shortViewNewsArray;
@property (nonatomic,assign)NSInteger selectedIndex;
@property (nonatomic,strong)NSString *selectedNewsType;



@end
