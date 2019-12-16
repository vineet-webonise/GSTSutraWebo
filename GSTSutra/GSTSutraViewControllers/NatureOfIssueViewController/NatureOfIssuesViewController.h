//
//  NatureOfIssuesViewController.h
//  GSTSutra
//
//  Created by niyuj on 1/2/17.
//  Copyright © 2017 niyuj. All rights reserved.
//

#import "BaseViewController.h"

@interface NatureOfIssuesViewController : BaseViewController

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic,assign)BOOL isIndustriesSelected;
@property (nonatomic,assign)BOOL isFromHomeScreen;
@property (nonatomic, strong)NSMutableArray *selectedIDs;

@end
