//
//  NatureOfIssueHomeViewController.h
//  GSTSutra
//
//  Created by niyuj on 2/10/17.
//  Copyright © 2017 niyuj. All rights reserved.
//


#import "YSLContainerViewController.h"


@interface NatureOfIssueHomeViewController : YSLContainerViewController<YSLContainerViewControllerDelegate>

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic,assign)BOOL isIndustriesSelected;
@property (nonatomic, strong)NSMutableArray *selectedIDs;
@property (nonatomic, strong)NSMutableArray *selectedIndustryID;



@end
