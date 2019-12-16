//
//  SettingsViewController.m
//  GSTSutra
//
//  Created by niyuj on 11/9/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import "SettingsViewController.h"
#import "AboutUsViewController.h"
#import "AcceptT&CViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MessageUI.h>
#import "ExpertCornerRequest.h"
#import "Constants.h"

@interface SettingsViewController ()<MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate,ExpertRequestDelegate>{
    NSMutableArray *titleArray,*imagesArray;
    NSString *notificationSwitchValueString;
}

@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;
@property (weak, nonatomic) IBOutlet UIView *fontAlert;
@property (weak, nonatomic) IBOutlet UIButton *smallFontButton;
- (IBAction)smallFontButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *largeFontButton;
- (IBAction)largeFontButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *mediumFontButton;
- (IBAction)mediumFontButtonClicked:(id)sender;

- (IBAction)cancelButtonClicked:(id)sender;
- (IBAction)okButtonClicked:(id)sender;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBarTitleLabel:@"Settings"];
    self.fontAlert.hidden = YES;
    
    self.navigationItem.rightBarButtonItem.enabled=NO;
    self.navigationItem.rightBarButtonItem=nil;
    
    @try {
        [self getNotificationValueAPICALL];
        titleArray = [[NSMutableArray alloc] initWithObjects:@"Notifications",@"Font Size",@"Feedback" ,@"Terms" ,nil];
        imagesArray = [[NSMutableArray alloc] initWithObjects:@"notifications",@"font_size",@"feedback" ,@"terms",nil];
        
        if ([[USERDEFAULTS objectForKey:@"font"] isEqualToString:@"small"]) {
            
            [self.smallFontButton setImage:[UIImage imageNamed:@"radio_button_p"] forState:UIControlStateNormal];
            [self.mediumFontButton setImage:[UIImage imageNamed:@"radio_button_n"] forState:UIControlStateNormal];
            [self.largeFontButton setImage:[UIImage imageNamed:@"radio_button_n"] forState:UIControlStateNormal];
            
            
        } else if ([[USERDEFAULTS objectForKey:@"font"] isEqualToString:@"medium"]){
            
            
            [self.smallFontButton setImage:[UIImage imageNamed:@"radio_button_n"] forState:UIControlStateNormal];
            [self.mediumFontButton setImage:[UIImage imageNamed:@"radio_button_p"] forState:UIControlStateNormal];
            [self.largeFontButton setImage:[UIImage imageNamed:@"radio_button_n"] forState:UIControlStateNormal];
            
            
        }else if ([[USERDEFAULTS objectForKey:@"font"] isEqualToString:@"large"]){
            
            
            [self.smallFontButton setImage:[UIImage imageNamed:@"radio_button_n"] forState:UIControlStateNormal];
            [self.mediumFontButton setImage:[UIImage imageNamed:@"radio_button_n"] forState:UIControlStateNormal];
            [self.largeFontButton setImage:[UIImage imageNamed:@"radio_button_p"] forState:UIControlStateNormal];
            
        }
        
        
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

-(void)getNotificationValueAPICALL{
    if ([self checkReachability]) {
        [self startProgressHUD];
        ExpertCornerRequest *req = [[ExpertCornerRequest alloc] init];
        req.delegate = self;
        [req getNotificationValue];
    }else {
        [self noInternetAlert];
    }
}
-(void)setNotificationValueAPICALLWithValue:(NSString*)value{
    if ([self checkReachability]) {
        [self startProgressHUD];
        ExpertCornerRequest *req = [[ExpertCornerRequest alloc] init];
        req.delegate = self;
        [req setNotificationValue:value];
    }else {
        [self noInternetAlert];
    }
}

-(void)getNotificationSwitchValueRequestSuccessfulWithResult:(NSArray *)result{
    [self stopProgressHUD];
    notificationSwitchValueString = [NSString stringWithFormat:@"%@",[result valueForKey:@"is_notification"]];
    //NSLog(@"get Notification switch value %@",notificationSwitchValueString);
    [self.settingsTableView reloadData];
}
-(void)getNotificationSwitchValueRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
}

-(void)setNotificationSwitchValueRequestSuccessfulWithResult:(NSArray *)result{
    [self stopProgressHUD];
    //NSLog(@"set Notification switch value %@",result);
    notificationSwitchValueString = [NSString stringWithFormat:@"%@",[result valueForKey:@"is_notification"]];
    //NSLog(@"get Notification switch value %@",notificationSwitchValueString);
    [self.settingsTableView reloadData];
}
-(void)setNotificationSwitchValueRequestFailedWithStatus:(NSString *)status wihtError:(NSString *)error{
    [self stopProgressHUD];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [imagesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"CellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
     cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UIImageView *imgView = (UIImageView*)[cell viewWithTag:10];
    UILabel *titleLable = (UILabel*)[cell viewWithTag:11];
    UISwitch *notificationSwitch = (UISwitch*)[cell viewWithTag:12];
    imgView.image = [UIImage imageNamed:[imagesArray objectAtIndex:indexPath.row]];
    titleLable.text = [titleArray objectAtIndex:indexPath.row];
    titleLable.font = [UIFont fontWithName:centuryGothicRegular size:[[USERDEFAULTS objectForKey:@"titleFont"] integerValue]];
    
    [notificationSwitch addTarget:self action:@selector(switchToggled:) forControlEvents: UIControlEventValueChanged];
    if (indexPath.row == 0) {
        notificationSwitch.hidden = NO;
        
        [notificationSwitch setOnTintColor:[UIColor colorWithRed:42/255.0 green:49/255.0 blue:73/255.0 alpha:1.0]];
        if ([notificationSwitchValueString isEqualToString: @"1"]) {
            [notificationSwitch setOn:YES];
        }else {
            [notificationSwitch setOn:NO];
            
        }
    } else {
        notificationSwitch.hidden = YES;
    }
    if (indexPath.row == 0) {
        if (notificationSwitch.isOn) {
            [notificationSwitch setOnTintColor:[UIColor colorWithRed:42/255.0 green:49/255.0 blue:73/255.0 alpha:1.0]];
        } else{
            [notificationSwitch setTintColor:[UIColor grayColor]];
        }
    }
    
    
    return cell;
    
}

- (void) switchToggled:(UISwitch *)sender {
    

    
    if ([sender isOn]) {
        
        [sender setTintColor:[UIColor grayColor]];
        [self setNotificationValueAPICALLWithValue:@"1"];
        
        
    } else {
        [sender setOnTintColor:[UIColor blueColor]];
        [self setNotificationValueAPICALLWithValue:@"0"];
    }
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 1) {
        self.fontAlert.hidden = NO;
    }else if (indexPath.row == 2) {
        self.fontAlert.hidden = YES;
        [self showEmail];
    }else if (indexPath.row == 3) {
        self.fontAlert.hidden = YES;
        AcceptT_CViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AcceptT_CViewController"];
        vc.isFromMenu = YES;
        [self.navigationController pushViewController:vc animated:YES];
    } else{
        self.fontAlert.hidden = YES;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60;
}

#pragma mark - Open Email

- (void)showEmail{
    
    MFMailComposeViewController *comp=[[MFMailComposeViewController alloc]init];
    [comp setMailComposeDelegate:self];
    if([MFMailComposeViewController canSendMail])
    {
        [comp setToRecipients:[NSArray arrayWithObjects:@"gstsutra@taxsutra.com", nil]];
        //[comp setSubject:@"From GSTsutra"];
        [comp setMessageBody:@"" isHTML:NO];
        [comp setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [self presentViewController:comp animated:YES completion:nil];
    }
    else{
        UIAlertView *alrt=[[UIAlertView alloc]initWithTitle:@"" message:@"" delegate:nil cancelButtonTitle:@"" otherButtonTitles:nil, nil];
        [alrt show];
        
    }
}


- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            //NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            //NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            //NSLog(@"Mail sent");
            [Utility showMessage:@"Mail sent succesfully" withTitle:@"Success!!"];
            break;
        case MFMailComposeResultFailed:
            //NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark -
#pragma mark - Button Clicked 
#pragma mark -

- (IBAction)smallFontButtonClicked:(id)sender {
    
    @try {
        [self.smallFontButton setImage:[UIImage imageNamed:@"radio_button_p"] forState:UIControlStateNormal];
        [self.mediumFontButton setImage:[UIImage imageNamed:@"radio_button_n"] forState:UIControlStateNormal];
        [self.largeFontButton setImage:[UIImage imageNamed:@"radio_button_n"] forState:UIControlStateNormal];
        [USERDEFAULTS setObject:@"small" forKey:@"font"];
        [USERDEFAULTS setObject:@"12" forKey:@"titleFont"];
        [USERDEFAULTS setObject:@"11" forKey:@"normalFont"];
        [self.settingsTableView reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadDrawerData" object:self ];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
}
- (IBAction)largeFontButtonClicked:(id)sender {
    
    [self.smallFontButton setImage:[UIImage imageNamed:@"radio_button_n"] forState:UIControlStateNormal];
    [self.mediumFontButton setImage:[UIImage imageNamed:@"radio_button_n"] forState:UIControlStateNormal];
    [self.largeFontButton setImage:[UIImage imageNamed:@"radio_button_p"] forState:UIControlStateNormal];
    [USERDEFAULTS setObject:@"large" forKey:@"font"];
    [USERDEFAULTS setObject:@"16" forKey:@"titleFont"];
    [USERDEFAULTS setObject:@"14" forKey:@"normalFont"];
    [self.settingsTableView reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadDrawerData" object:self ];
}
- (IBAction)mediumFontButtonClicked:(id)sender {
    
    [self.smallFontButton setImage:[UIImage imageNamed:@"radio_button_n"] forState:UIControlStateNormal];
    [self.mediumFontButton setImage:[UIImage imageNamed:@"radio_button_p"] forState:UIControlStateNormal];
    [self.largeFontButton setImage:[UIImage imageNamed:@"radio_button_n"] forState:UIControlStateNormal];
    [USERDEFAULTS setObject:@"medium" forKey:@"font"];
    [USERDEFAULTS setObject:@"14" forKey:@"titleFont"];
    [USERDEFAULTS setObject:@"12" forKey:@"normalFont"];
    [self.settingsTableView reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadDrawerData" object:self ];
}
- (IBAction)cancelButtonClicked:(id)sender {
    self.fontAlert.hidden = YES;
    
}

- (IBAction)okButtonClicked:(id)sender {
    self.fontAlert.hidden = YES;
    [self.settingsTableView reloadData];
}
@end
