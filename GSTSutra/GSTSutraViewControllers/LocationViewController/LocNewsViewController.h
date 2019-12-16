//
//  LocNewsViewController.h
//  GSTSutra
//
//  Created by niyuj on 2/13/17.
//  Copyright © 2017 niyuj. All rights reserved.
//

#import "BaseViewController.h"

@interface LocNewsViewController : BaseViewController
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic,assign)BOOL isIndustriesSelected;
@property(nonatomic,assign)BOOL isHomePageLoaded;

@end
