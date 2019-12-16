
#import "LeftSideViewController.h"
#import "MFSideMenu.h"
#import "Constants.h"
#import "BaseViewController.h"
#import "LoginViewController.h"
#import "LeftDrawerProfileTableViewCell.h"
#import "LeftDrawerIConTableViewCell.h"
#import "Utility.h"
#import "LoginViewController.h"
#import "UIImageView+Letters.h"
#import "HomeViewController.h"
#import "locationNewsViewController.h"
#import "ExpertsCornerViewController.h"
#import "ExpertTakeViewController.h"
#import "LawsViewController.h"
#import "ProfileViewController.h"
#import "LoginForgotAndChangePasswordRequest.h"
#import "LeftDrawerLogoTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "AboutUsViewController.h"
#import "VIdeoHomeViewController.h"
#import "SiteLinksViewController.h"
#import "FAQViewController.h"
#import "SettingsViewController.h"
#import "NewRequest.h"
#import "BookMarksViewController.h"
#import "ForumListViewController.h"
#import "demoViewController.h"
#import "NatureOfIssuesViewController.h"
#import "NatureOfIssueHomeViewController.h"
#import "LocationHomeViewController.h"
#import "NewsHomeViewController.h"

@interface LeftSideViewController ()<LoginForgotAndChangePasswordRequestDelegate,NewRequestDelegate>{
    
    NSMutableArray *iconImageArray,*headerTextArray,*stateArray,*selectedIconArray,*expertCornerArray,*industriesArray;
    NSIndexPath *selectedIndexPath;
    BOOL isLocationSelected,isExpertCornerSelected,isIndustriesSelected,isIndustryResponce;
    
}

@property (weak, nonatomic) IBOutlet UITableView *parentTableView;
@property (weak, nonatomic) IBOutlet UITableView *childTableView;

@end

@implementation LeftSideViewController

#pragma mark -
#pragma mark - Controller Life Cycle
#pragma mark -

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDrawerDataNotification:)name:@"reloadDrawerData" object:nil];
    isLocationSelected = NO;
    isIndustriesSelected = NO;
    isIndustryResponce = NO;
    isExpertCornerSelected = NO;
    
}

- (void) reloadDrawerDataNotification:(NSNotification *) notification{
    
    [self viewDidLoad];
    if (isIndustryResponce) {
        [self.childTableView reloadData];
        isIndustryResponce = NO;
    } else{
        [self.childTableView reloadData];
        [self.parentTableView reloadData];
    }
}

-(void)changeStatusBarBackgroundColor{
    UIApplication *app = [UIApplication sharedApplication];
    CGFloat statusBarHeight = app.statusBarFrame.size.height;
    
    UIView *statusBarView =  [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, statusBarHeight)];
    statusBarView.backgroundColor  =  [UIColor colorWithRed:42/255.0 green:49/255.0 blue:73/255.0 alpha:1.0];
    [self.view addSubview:statusBarView];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self changeStatusBarBackgroundColor];
    NSArray *tempArray;
    if ([[[USERDEFAULTS objectForKey:@"locationArray"] valueForKey:@"state_name"] count] > 0) {
       tempArray = [[NSMutableArray alloc] initWithArray:[[USERDEFAULTS objectForKey:@"locationArray"] valueForKey:@"state_name"]];
    }
    
    [self.parentTableView registerNib:[UINib nibWithNibName:@"LeftDrawerLogoTableViewCell" bundle:nil] forCellReuseIdentifier:@"LeftDrawerLogoTableViewCell"];
    
    self.childTableView.backgroundColor =[UIColor colorWithRed:42/255.0 green:50/255.0 blue:73/255.0 alpha:1];
    
    stateArray = [[NSMutableArray alloc]init];
    industriesArray = [[NSMutableArray alloc]init];
    expertCornerArray = [[NSMutableArray alloc]initWithObjects:@"Expert Corner",@"Expert Take", nil];
    [stateArray addObject:@"All"];
    [stateArray addObjectsFromArray:tempArray];
    [industriesArray addObjectsFromArray:[USERDEFAULTS objectForKey:@"IndustriesArray"]];
    
    iconImageArray = [[NSMutableArray alloc]initWithObjects:
                      @"",
                      @"",
                      @"home_n",
                      @"experts",
                      @"video",
                      @"forum_discussion",
                      @"industry",
                      @"nio",
                      @"location",
                      @"experts",
                      @"site_link",
                      @"faq",
                      @"acts",
                      @"form_n",
                      @"bookmark_n",
                      @"settings",
                      @"about",
                      @"share_n",
                      @"news",
                      nil];
    
    
    headerTextArray = [[NSMutableArray alloc]initWithObjects:
                       @"",
                       @"",
                       @"Home",
                       @"Expert Columns",
                       @"GSTtube",
                       @"Discussion Forum",
                       @"Industry",
                       @"Search by Issues",
                       @"Location",
                       @"Tax Ring",
                       @"GST in Press",
                       @"CBEC FAQs",
                       @"GST Laws",
                       @"GST Forms",
                       @"Bookmarks",
                       @"Settings",
                       @"About us",
                       @"Share App",
                       @"News",
                        nil];

}

#pragma mark - UITableview Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    @try {
        if (tableView == self.childTableView) {
            int selCount ;
            selCount = 0;
            if (isLocationSelected) {
                selCount = [stateArray count];
                
            } else if (isExpertCornerSelected){
                selCount = [expertCornerArray count];
            } else if (isIndustriesSelected){
                selCount = [industriesArray count];
            }
            return selCount;
        } else {
            return [iconImageArray count];
        }

    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == self.childTableView) {
        return 50;
    } else {
        if (indexPath.row == 0) {
            return 55;
        }
        if (indexPath.row == 1) {
            return 85;
        } else {
            return 38;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    @try {
        {
            
            if (tableView == self.childTableView) {
                
                static NSString *simpleTableIdentifier = @"SimpleTableItem";
                
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
                
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
                }
                if (isLocationSelected) {
                    cell.textLabel.text = [stateArray objectAtIndex:indexPath.row];
                    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
                    cell.textLabel.numberOfLines = 0;
                    cell.textLabel.textColor = [UIColor whiteColor];
                    cell.backgroundColor = [UIColor clearColor];
                    UIView *selectionColor = [[UIView alloc] init];
                    selectionColor.backgroundColor = [UIColor lightGrayColor];
                    cell.selectedBackgroundView = selectionColor;
                    
                    return cell;
                } else if (isExpertCornerSelected){
                    cell.textLabel.text = [expertCornerArray objectAtIndex:indexPath.row];
                    cell.textLabel.textColor = [UIColor whiteColor];
                    cell.backgroundColor = [UIColor clearColor];
                    UIView *selectionColor = [[UIView alloc] init];
                    selectionColor.backgroundColor = [UIColor lightGrayColor];
                    cell.selectedBackgroundView = selectionColor;
                    
                    return cell;
                } else if (isIndustriesSelected){
                    cell.textLabel.text = [[industriesArray objectAtIndex:indexPath.row] valueForKey:@"name"];
                    cell.textLabel.font = [UIFont fontWithName:centuryGothicRegular size:titleFont];
                    cell.textLabel.textColor = [UIColor whiteColor];
                    cell.backgroundColor = [UIColor clearColor];
                    UIView *selectionColor = [[UIView alloc] init];
                    selectionColor.backgroundColor = [UIColor lightGrayColor];
                    cell.selectedBackgroundView = selectionColor;
                    
                    return cell;
                }
                
                return cell;
                
            } else {
                static NSString *CellIdentifier = @"LeftDrawerIConTableViewCell";
                static NSString *profileCellIdentifier = @"LeftDrawerProfileTableViewCell";
                static NSString *topCellIdentifier = @"LeftDrawerLogoTableViewCell";
                LeftDrawerLogoTableViewCell *logoCell = (LeftDrawerLogoTableViewCell*)[tableView dequeueReusableCellWithIdentifier:topCellIdentifier];
                LeftDrawerIConTableViewCell *iconCell = (LeftDrawerIConTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                LeftDrawerProfileTableViewCell *profileCell= (LeftDrawerProfileTableViewCell*) [tableView dequeueReusableCellWithIdentifier:profileCellIdentifier];;
                
                
                if (indexPath.row == 0) {
                    
                    return  logoCell;
                }
                
                else  if (indexPath.row == 1) {
                    
                    if (profileCell == nil) {
                        profileCell = [[LeftDrawerProfileTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:profileCellIdentifier];
                        
                    }
                    
                    if ([self checkImageExtensionWithImage:[USERDEFAULTS valueForKey:@"profileImage"]])  {
                        
                        profileCell.profileImageView.layer.cornerRadius = profileCell.profileImageView.frame.size.height /2;
                        profileCell.profileImageView.layer.masksToBounds = YES;
                        profileCell.profileImageView.layer.borderWidth = 1.0;
                        [profileCell.profileImageView sd_setImageWithURL:[NSURL URLWithString:[ImageSERVER_API stringByAppendingString:[USERDEFAULTS valueForKey:@"profileImage"]]]placeholderImage:[UIImage imageNamed:@"username.png"]];
                        //NSLog(@"UserDefault Value of Fullname %@",[USERDEFAULTS valueForKey:@"fullName"]);
                        if ([USERDEFAULTS valueForKey:@"fullName"] == (id)[NSNull null] || [[USERDEFAULTS valueForKey:@"fullName"] isEqualToString:@""] ){
                            
                            profileCell.nameLabel.text = [USERDEFAULTS valueForKey:@"username"];
                            
                        } else {
                            profileCell.nameLabel.text = [USERDEFAULTS valueForKey:@"fullName"];
                            
                        }
                        

                    }
                    else {
                        //NSLog(@"UserDefault Value of Fullname %@",[USERDEFAULTS valueForKey:@"fullName"]);
                        if ([USERDEFAULTS valueForKey:@"fullName"] == (id)[NSNull null] || [[USERDEFAULTS valueForKey:@"fullName"] isEqualToString:@""] ){
                            //if ([[USERDEFAULTS valueForKey:@"fullName"] isEqualToString:@""]) {
                            //update username
                            profileCell.nameLabel.text = [USERDEFAULTS valueForKey:@"username"];
                            [profileCell.profileImageView setImageWithString:[USERDEFAULTS valueForKey:@"username"] color:nil circular:YES];
                        } else {
                            profileCell.nameLabel.text = [USERDEFAULTS valueForKey:@"fullName"];
                            [profileCell.profileImageView setImageWithString:[USERDEFAULTS valueForKey:@"fullName"] color:nil circular:YES];
                        }
                        
                    }
    
                    
                    if ([USERDEFAULTS boolForKey:@"isNotRegisterOrLoginUser"]) {
                        profileCell.logoutButton.hidden = YES;
                        profileCell.profileImageView.hidden = YES;
                        //profileCell.nameLabel.hidden = YES;
                    }else {
                        profileCell.logoutButton.hidden = NO;
                    }
                    [profileCell.logoutButton addTarget:self action:@selector(logoutButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                    
                    [profileCell.subcriptionButton addTarget:self action:@selector(SubcriptionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                    [profileCell.backgroundView setBackgroundColor:[UIColor colorWithRed:42/255.0 green:50/255.0 blue:73/255.0 alpha:1]];
                    profileCell.backgroundColor = profileCell.backgroundColor;
                    return profileCell;
                    
                } else {
                    
                    if (iconCell == nil) {
                        iconCell = [[LeftDrawerIConTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                        
                    }
                    
                    iconCell.iconImageVIew.image = [UIImage imageNamed:[iconImageArray objectAtIndex:indexPath.row]];
                    iconCell.headerLabel.text = [headerTextArray objectAtIndex:indexPath.row];
                    iconCell.headerLabel.font = [UIFont fontWithName:centuryGothicRegular size:titleFont];
                    iconCell.headerLabel.textColor = [UIColor grayColor];
                    
                    return  iconCell;
                    
                }
                
            }
            
        }
        
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

#pragma mark -
#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    @try {
        {
            if ([USERDEFAULTS boolForKey:@"isNotRegisterOrLoginUser"]) {
                [self openLoginViewControllerAlertOnLeftMenuOrView:YES];
            }else {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                
                if (tableView == self.childTableView) {
                    
                    if (isLocationSelected) {
                        isLocationSelected = NO;
                        isIndustriesSelected = NO;
                        NSMutableArray *tempArray = [[NSMutableArray alloc]initWithArray:[[USERDEFAULTS objectForKey:@"locationArray"] valueForKey:@"id"]];
                        NSMutableArray *tempArray1 = [[NSMutableArray alloc]initWithArray:[[USERDEFAULTS objectForKey:@"locationArray"] valueForKey:@"state_name"]];
                        // [tempArray setObject:@"0" atIndexedSubscript:0];
                        //[tempArray1 setObject:@"0" atIndexedSubscript:0];
                        if (indexPath.row == 0) {
                            //NSString *selectedIndex = [tempArray objectAtIndex:indexPath.row ];
                            [USERDEFAULTS setObject:@"0" forKey:@"locationID"];
                            [USERDEFAULTS setObject:@"All News" forKey:@"locationName"];
                            
                            ////NSLog(@"selected index location %@",selectedIndex);
                        } else {
                            NSString *selectedIndex = [tempArray objectAtIndex:indexPath.row - 1];
                            NSString *selectedState = [tempArray1 objectAtIndex:indexPath.row - 1];
                            [USERDEFAULTS setObject:selectedIndex forKey:@"locationID"];
                            [USERDEFAULTS setObject:selectedState forKey:@"locationName"];
                            //NSLog(@"selected index location %@",selectedIndex);
                        }
                        
                        //NSLog(@"selected Location ID %@",[USERDEFAULTS objectForKey:@"locationID"]);
                        self.childTableView.hidden = YES;
                        LocationHomeViewController  *locationNews = [self.storyboard instantiateViewControllerWithIdentifier:@"LocationHomeViewController"];
                        //locationNews.isIndustriesSelected = NO;
                        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
                        NSArray *controllers = [NSArray arrayWithObject:locationNews];
                        navigationController.viewControllers = controllers;
                        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
                        
                    } else if (isExpertCornerSelected){
                        
                        isExpertCornerSelected = NO;
                        
                        if (indexPath.row == 0) {
                            ExpertsCornerViewController  *expertVC = [storyboard instantiateViewControllerWithIdentifier:@"ExpertsCornerViewController"];
                            
                            UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
                            NSArray *controllers = [NSArray arrayWithObject:expertVC];
                            navigationController.viewControllers = controllers;
                            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
                        } else {
                            
                            ExpertTakeViewController  *expertVC = [storyboard instantiateViewControllerWithIdentifier:@"ExpertTakeViewController"];
                            UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
                            NSArray *controllers = [NSArray arrayWithObject:expertVC];
                            navigationController.viewControllers = controllers;
                            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
                        }
                        self.childTableView.hidden = YES;
                        
                    } else if (isIndustriesSelected) {
                        
                        NatureOfIssueHomeViewController  *locationNews = [self.storyboard instantiateViewControllerWithIdentifier:@"NatureOfIssueHomeViewController"];
                        self.childTableView.hidden = YES;
                        NSString *selectedIndex = [[industriesArray objectAtIndex:indexPath.row] valueForKey:@"id"];
                        NSString *selectedName = [[industriesArray objectAtIndex:indexPath.row] valueForKey:@"name"];
                        [USERDEFAULTS setObject:selectedIndex forKey:@"inDustriesID"];
                        [USERDEFAULTS setObject:selectedName forKey:@"inDustriesName"];
                        [USERDEFAULTS removeObjectForKey:@"NOIID"];
                        [USERDEFAULTS removeObjectForKey:@"selectedIndexes"];
                        locationNews.isIndustriesSelected = YES;
                        locationNews.selectedIndustryID = [[[industriesArray objectAtIndex:indexPath.row] valueForKey:@"id"]mutableCopy];
                        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
                        NSArray *controllers = [NSArray arrayWithObject:locationNews];
                        navigationController.viewControllers = controllers;
                        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
                    }
                    
                    
                }else {
                    
                    selectedIndexPath = [tableView indexPathForSelectedRow];
                    //[self.parentTableView reloadData];
                    switch (indexPath.row) {
                        case 0:{
                            [self showHideChildTable];
                        }break;
                        case 1: {
                            [self showHideChildTable];
                            ProfileViewController  *ProfileVC = [storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
                            UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
                            NSArray *controllers = [NSArray arrayWithObject:ProfileVC];
                            navigationController.viewControllers = controllers;
                            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
                            
                        }break;
                            
                        case 2: {
                            [self showHideChildTable];
                            HomeViewController  *HomeVC = [storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
                            UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
                            NSArray *controllers = [NSArray arrayWithObject:HomeVC];
                            navigationController.viewControllers = controllers;
                            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
                            
                        }break;
                        case 3: {
                            
                            [self showHideChildTable];
                            ExpertsCornerViewController  *laws = [storyboard instantiateViewControllerWithIdentifier:@"ExpertsCornerViewController"];
                            UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
                            NSArray *controllers = [NSArray arrayWithObject:laws];
                            navigationController.viewControllers = controllers;
                            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
                            
                        }break;
                        case 9: {
                            
                            [self showHideChildTable];
                            ExpertTakeViewController  *laws = [storyboard instantiateViewControllerWithIdentifier:@"ExpertTakeViewController"];
                            UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
                            NSArray *controllers = [NSArray arrayWithObject:laws];
                            navigationController.viewControllers = controllers;
                            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
                            
                        }break;
                            
                        case 8: {
                            self.childTableView.hidden = NO;
                            isExpertCornerSelected = NO;
                            isIndustriesSelected = NO;
                            
                            if (isLocationSelected) {
                                isLocationSelected = NO;
                                self.childTableView.hidden = YES;
                            } else {
                                isLocationSelected = YES;
                                self.childTableView.hidden = NO;
                                [self.childTableView reloadData];
                                [self.view bringSubviewToFront:self.childTableView];
                            }
                            
                            
                        }break;
                            
                        case 6: {
                            [self getIndustriesAPICall];
                            self.childTableView.hidden = NO;
                            isExpertCornerSelected = NO;
                            isLocationSelected = NO;
                            
                            if (isIndustriesSelected) {
                                isIndustriesSelected = NO;
                                self.childTableView.hidden = YES;
                            } else {
                                isIndustriesSelected = YES;
                                self.childTableView.hidden = NO;
                                [self.childTableView reloadData];
                                [self.view bringSubviewToFront:self.childTableView];
                            }
                            
                            
                        }break;
                            
                        case 12: {
                            
                            [self showHideChildTable];
                            LawsViewController  *laws = [storyboard instantiateViewControllerWithIdentifier:@"LawsViewController"];
                            laws.isFormsSelected = NO;
                            UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
                            NSArray *controllers = [NSArray arrayWithObject:laws];
                            navigationController.viewControllers = controllers;
                            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
                            
                            
                        }break;
                        case 4: {
                            
                            [self showHideChildTable];
                            VIdeoHomeViewController  *laws = [storyboard instantiateViewControllerWithIdentifier:@"VIdeoHomeViewController"];
                            UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
                            NSArray *controllers = [NSArray arrayWithObject:laws];
                            navigationController.viewControllers = controllers;
                            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
                            
                            
                        }break;
                            
                        case 10: {
                            
                            [self showHideChildTable];
                            SiteLinksViewController  *laws = [storyboard instantiateViewControllerWithIdentifier:@"SiteLinksViewController"];
                            UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
                            NSArray *controllers = [NSArray arrayWithObject:laws];
                            navigationController.viewControllers = controllers;
                            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
                            
                            
                        }break;
                            
                        case 11: {
                            
                            [self showHideChildTable];
                            FAQViewController  *laws = [storyboard instantiateViewControllerWithIdentifier:@"FAQViewController"];
                            UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
                            NSArray *controllers = [NSArray arrayWithObject:laws];
                            navigationController.viewControllers = controllers;
                            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
                            
                            
                        }break;
                            
                        case 14: {
                            
                            [self showHideChildTable];
                            BookMarksViewController  *laws = [storyboard instantiateViewControllerWithIdentifier:@"BookMarksViewController"];
                            UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
                            NSArray *controllers = [NSArray arrayWithObject:laws];
                            navigationController.viewControllers = controllers;
                            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
                            
                            
                        }break;
                            
                        case 15 : {
                            
                            [self showHideChildTable];
                            SettingsViewController  *laws = [storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
                            UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
                            NSArray *controllers = [NSArray arrayWithObject:laws];
                            navigationController.viewControllers = controllers;
                            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
                            
                            
                        }break;
                        case 5 : {
                            
                            [self showHideChildTable];
                            ForumListViewController  *laws = [storyboard instantiateViewControllerWithIdentifier:@"ForumListViewController"];
                            UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
                            NSArray *controllers = [NSArray arrayWithObject:laws];
                            navigationController.viewControllers = controllers;
                            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
                            
                            
                        }break;
                            
                            
                        case 16 : {
                            
                            [self showHideChildTable];
                            AboutUsViewController  *laws = [storyboard instantiateViewControllerWithIdentifier:@"AboutUsViewController"];
                            UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
                            NSArray *controllers = [NSArray arrayWithObject:laws];
                            navigationController.viewControllers = controllers;
                            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
                            
                            
                        }break;
                            
                        case 13: {
                            
                            [self showHideChildTable];
                            LawsViewController  *laws = [storyboard instantiateViewControllerWithIdentifier:@"LawsViewController"];
                            laws.isFormsSelected = YES;
                            UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
                            NSArray *controllers = [NSArray arrayWithObject:laws];
                            navigationController.viewControllers = controllers;
                            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
                            
                            
                        }break;
                            
                        case 7: {
                            
                            [self showHideChildTable];
                            NatureOfIssuesViewController  *laws = [storyboard instantiateViewControllerWithIdentifier:@"NatureOfIssuesViewController"];
                            laws.isIndustriesSelected = NO;
                            [USERDEFAULTS removeObjectForKey:@"inDustriesID"];
                            [USERDEFAULTS removeObjectForKey:@"NOIID"];
                            [USERDEFAULTS removeObjectForKey:@"selectedIndexes"];
                            UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
                            NSArray *controllers = [NSArray arrayWithObject:laws];
                            navigationController.viewControllers = controllers;
                            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
                            
                            
                        }break;
                            
                        case 17:{
                            
                            NSArray *objectsToShare = @[[USERDEFAULTS  objectForKey:@"shareURL"]];
                            
                            UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
                            
                            // Exclude all activities except AirDrop.
                            NSArray *excludedActivities = @[
                                                            UIActivityTypeAirDrop,
                                                            ];
                            controller.excludedActivityTypes = excludedActivities;
                            
                            // Present the controller
                            [self presentViewController:controller animated:YES completion:nil];
                        }break ;
                            
                        case 18:{
                            
                            [self showHideChildTable];
                            NewsHomeViewController  *laws = [storyboard instantiateViewControllerWithIdentifier:@"NewsHomeViewController"];
                            UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
                            NSArray *controllers = [NSArray arrayWithObject:laws];
                            navigationController.viewControllers = controllers;
                            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
                        }break ;
                            
                        default: {
                            [self showHideChildTable];
                            HomeViewController  *home = [storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
                            UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
                            NSArray *controllers = [NSArray arrayWithObject:home];
                            navigationController.viewControllers = controllers;
                            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
                        }
                            break;
                    }
                    
                }
            }
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

-(void)showHideChildTable{
    isLocationSelected = NO;
    isExpertCornerSelected = NO;
    isIndustriesSelected = NO ;
    self.childTableView.hidden = YES;

}


-(void)getIndustriesAPICall{
    if ([self checkReachability]) {
        NewRequest *req = [[NewRequest alloc] init];
        req.delegate = self;
        [req getAllIndustries];
    } else {
        [self noInternetAlert];
        
    }
}

-(void)industriesRequestSuccessfulWithResult:(NSArray *)result{
    [self stopProgressHUD];
    isIndustryResponce = YES;
    [USERDEFAULTS setObject:result forKey:@"IndustriesArray"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadDrawerData" object:self ];

}

-(void)industriesRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
    [Utility showMessage:error withTitle:@""];
    
}

// AlertController

-(void)logOutOperation {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Logout" message:@"Are you sure?" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self openLoginScreen];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // no operation dismiss view
    }]];
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self presentViewController:alertController animated:YES completion:nil];
    });

}


#pragma mark - Logout Button Action 

-(IBAction)logoutButtonClicked:(id)sender{
    
    [self logOutOperation];
    
}

#pragma mark - Subscribe Button Clicked

-(IBAction)SubcriptionButtonClicked:(id)sender{
    
  
    UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
    NSArray *controllers = [NSArray arrayWithObject:[self.storyboard instantiateViewControllerWithIdentifier:@"demoViewController"]];
    navigationController.viewControllers = controllers;
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
    
    
}



#pragma mark - Logout Operation 

-(void)openLoginScreen{
    
    @try {
        LoginForgotAndChangePasswordRequest *req = [[LoginForgotAndChangePasswordRequest alloc] init];
        req.delegate = self;
        [req getLogout];
        if(![USERDEFAULTS boolForKey:@"isRememberUsername"]){
            [USERDEFAULTS removeObjectForKey:@"userName"];
        }
        
        [USERDEFAULTS removeObjectForKey:@"password"];
        [USERDEFAULTS removeObjectForKey:@"userToken"];
        [USERDEFAULTS removeObjectForKey:@"fullName"];
        [USERDEFAULTS  setValue:@"Login/Register" forKey:@"fullName"];
        [USERDEFAULTS  removeObjectForKey:@"profileImage"];
        [USERDEFAULTS setBool:YES forKey:@"isNotRegisterOrLoginUser"];
        [USERDEFAULTS setValue:@"6cc466b19a4d77920b3707d0636f57ca" forKey:@"userToken"];
        [USERDEFAULTS setBool:YES forKey:@"isLogin"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadDrawerData" object:self ];
        HomeViewController *login = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        NSArray *controllers = [NSArray arrayWithObject:login];
        navigationController.viewControllers = controllers;
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
        [USERDEFAULTS synchronize];

    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}
#pragma mark - Logout Delegetes.

-(void)logoutRequestSuccessfulWithStatus:(NSString *)status{
    
    if(![USERDEFAULTS boolForKey:@"isRememberUsername"]){
        [USERDEFAULTS removeObjectForKey:@"userName"];
    }
    [USERDEFAULTS removeObjectForKey:@"password"];
    [USERDEFAULTS removeObjectForKey:@"userToken"];
    [USERDEFAULTS removeObjectForKey:@"fullName"];
    [USERDEFAULTS  setValue:@"Login/Register" forKey:@"fullName"];
    [USERDEFAULTS  removeObjectForKey:@"profileImage"];
    [USERDEFAULTS setBool:YES forKey:@"isNotRegisterOrLoginUser"];
    [USERDEFAULTS setValue:@"6cc466b19a4d77920b3707d0636f57ca" forKey:@"userToken"];
    [USERDEFAULTS setBool:YES forKey:@"isLogin"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadDrawerData" object:self ];
    HomeViewController *login = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
    UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
   NSArray *controllers = [NSArray arrayWithObject:login];
    navigationController.viewControllers = controllers;
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
    [USERDEFAULTS synchronize];
}

-(void)logoutRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    
    [Utility showMessage:error withTitle:@"Error!"];
}

@end
