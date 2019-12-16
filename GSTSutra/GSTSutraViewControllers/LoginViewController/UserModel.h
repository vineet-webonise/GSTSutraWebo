//
//  UserModel.h
//  Pharmacy-Customer
//
//  Created by niyuj on 5/16/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject

@property (nonatomic, strong) NSString *UserName;
@property (nonatomic, strong) NSString *FirstName ;
@property (nonatomic, strong) NSString *LastName;
@property (nonatomic, strong) NSString *profileImage;
@property (nonatomic, strong) NSString *EmailId;
@property (nonatomic, strong) NSString *Password;
@property (nonatomic, strong) NSString *MobileNumber;
@property (nonatomic, strong) NSString *CompanyName;
@property (nonatomic, strong) NSString *isVerified;
@property (nonatomic, strong) NSString *City;
@property (nonatomic, strong) NSString *FirstLastName;
@property (nonatomic, strong) NSString *isPaid;
@property (nonatomic, strong) NSMutableArray *locationArray;
@property (nonatomic, strong) NSString *Address;
@property (nonatomic, strong) NSString *State;
@property (nonatomic, strong) NSString *Pincode;
@property (nonatomic, strong) NSString *Country;

@end
