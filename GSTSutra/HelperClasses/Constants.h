//
//  Constants.h


#ifndef TGAPP_Constants_h
#define TGAPP_Constants_h


#pragma mark Develoipment Url


//#define SERVER_API @"http://gst.test.taxsutra.com/app"
//#define ImageSERVER_API @"http://gst.test.taxsutra.com"


#pragma mark Distribution URL

//#define SERVER_API @"http://gstsutra.com/app"
//#define ImageSERVER_API @"http://gstsutra.com"

//Preprod url's, the above 2 lines must be uncommented & bellow 2 lines must be commented to set prod environment of app.
#define SERVER_API @"http://preprod.gstsutra.com/app"
#define ImageSERVER_API @"http://preprod.gstsutra.com"


#define APPDELEGATE ((AppDelegate*)[[UIApplication sharedApplication] delegate])
#define USERDEFAULTS [NSUserDefaults standardUserDefaults]

#define IPAD     UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad


#define SCREENWIDTH self.view.frame.size.width
#define SCREENHEIGHT self.view.frame.size.height

#define userLogData [AppData getInstance].currentUser

#define titleFont [[USERDEFAULTS objectForKey:@"titleFont"] integerValue]
#define normalFont [[USERDEFAULTS objectForKey:@"normalFont"] integerValue]

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)



#define userLogData [AppData getInstance].currentUser

//******************
#define NOTIFICATION_RECEIVED_KEY @"NotificationReceived"

#define  centuryGothicRegular @"CenturyGothic"
#define  centuryGothicBold @"CenturyGothic-Bold"


#define placeholderColor [UIColor colorWithRed:242.0/250 green:179.0/255 blue:45.0/255 alpha:1]

#define THIRD_YELLOWCOLOR [UIColor colorWithRed:238/255.0 green:210/255.0 blue:140/255.0 alpha:1]

//fonts:
#define ADJECTIVE_FONT [UIFont systemFontOfSize:14]




#endif
