//
//  uploadProfilePictureRequest.m
//  Pharmacy-Customer
//
//  Created by niyuj on 5/17/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import "uploadProfilePictureRequest.h"
#import "Constants.h"
#import "AppData.h"

@implementation uploadProfilePictureRequest


-(void)uploadUserProfilePicture:(SignUpModel*)signUpData {
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_API, @"/change_profile_pic"]];
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    
    [urlRequest setValue:[USERDEFAULTS valueForKey:@"userToken"] forHTTPHeaderField:@"token"];
    [urlRequest setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition:multipart/form-data; name=\"profile_pic\"; filename=\"cust.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    //[body appendData:[NSData dataWithData:signUpData.profileImage]];
    [body appendData:signUpData.profileImage];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    // close form
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
    
    [urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // set request body
    [urlRequest setHTTPBody:body];
    NSURLConnection *urlConnection;
    urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:YES];
    
}

#pragma mark- NSURLConnection Protocol Methods

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.webData = [[NSMutableData alloc]init];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.webData appendData:data];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self requestCompletedWithData];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //NSLog(@"%@", error.localizedDescription);
    if ([self.delegate respondsToSelector:@selector(profilePictureUploadedFailedWithStatusInfo:andWithErrorMessage:)]) {
        [self.delegate profilePictureUploadedFailedWithStatusInfo:@"0" andWithErrorMessage:error.localizedDescription];
    }
}

-(void)requestCompletedWithData {
    NSString *temp = [[NSString alloc]initWithData:self.webData encoding:NSUTF8StringEncoding];
    //NSLog(@"Response = %@",temp);
    
    NSError *error;
    NSMutableDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:self.webData options:NSJSONReadingAllowFragments error:&error];
    
    if ([[jsonDict objectForKey:@"status"] integerValue]) {
        
        if ([self.delegate respondsToSelector:@selector(profilePictureUploadedSuccessfullyWithStatusInfo:andWithMessage:)]) {
            [USERDEFAULTS  setValue:[jsonDict objectForKey:@"result"] forKey:@"profileImage"];
            [self.delegate profilePictureUploadedSuccessfullyWithStatusInfo:[jsonDict objectForKey:@"status"]  andWithMessage:[jsonDict objectForKey:@"msg"]];
            
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(profilePictureUploadedFailedWithStatusInfo:andWithErrorMessage:)]) {
            [self.delegate profilePictureUploadedFailedWithStatusInfo:[jsonDict objectForKey:@"status"] andWithErrorMessage:[jsonDict objectForKey:@"msg"]];
        }
        
    }
}

@end
