//
//  ServerResponce.m
//  Mappd
//
//  Created by Nazim on 12/08/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "ServerResponce.h"
#import "GlobalConstant.h"

@implementation ServerResponce


+(ServerResponce *)sharedInstance
{
    static ServerResponce *_sharedInstance = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[ServerResponce alloc] init];
    });
    return _sharedInstance;
    
}
-(void)invalidateCurrentRunningTask
{
    //    [session invalidateAndCancel];
}

-(NSArray *)getResponceFromServer:(NSString *)URLName withAPIName:(NSString *)apiName DictionartyToServer:(NSDictionary *)dictionaryToServer withHTTPMethod: (NSString *)httpMethod{

    NSData * dataFromServer = [self dataFromServerWithURL:URLName WithApiName:apiName DictionaryToServer:dictionaryToServer withHTTPMethod:httpMethod];
    
    if (dataFromServer != nil)
    {
        NSArray * arrayOfDictionaryFromServer = [NSJSONSerialization JSONObjectWithData:dataFromServer options:kNilOptions error:nil];
        
        return arrayOfDictionaryFromServer;
    }
    return nil;
    
}


-(NSData *)dataFromServerWithURL:(NSString *)url WithApiName:(NSString *)apiName DictionaryToServer:(NSDictionary *)dictionaryToServer withHTTPMethod: (NSString *)httpMethod
{
    //    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    NSURL *URL = [[NSURL alloc]init];;
    
    if ([apiName isEqualToString:@""]) {
        
        URL = [[NSURL alloc]initWithString:url];
    }else{
        
        URL = [[NSURL URLWithString:url] URLByAppendingPathComponent:apiName];
    }
    
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:URL];
    urlRequest.HTTPMethod = httpMethod;
    
    UserDetails *userDetails = [UserDetails MR_findFirst];
    
    if (userDetails.authToken != nil) {
        NSString *authToken = userDetails.authToken;
        [urlRequest addValue:[NSString stringWithFormat:@"Bearer %@", authToken] forHTTPHeaderField:@"Authorization"];

    }
    
    if ([httpMethod isEqualToString:@"GET"]) {
        
        
    }else{
        
        NSData *postData = [[NSData alloc]init];
        [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        postData = [NSJSONSerialization dataWithJSONObject:dictionaryToServer options:kNilOptions error:nil];
        urlRequest.HTTPBody = postData;
        
        NSString *string = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
#if DEBUG
        NSLog(@"JSON OBJECT IS: %@", string);
#endif
    }
    
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    __block NSData *serverData = nil;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
#pragma mark - Set the standard time for fetching data
    configuration.timeoutIntervalForRequest = 240; //ie For 2 min it will wait for responce from server
    configuration.timeoutIntervalForResource = 240;
    session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:nil];
    
    NSURLSessionDataTask *loadDataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        //        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if (error != nil) {
#pragma mark - Write Delegate code for network failure
            NSLog(@"Server Failed");
            if (self.delegate!=nil) {
                [self.delegate serverFailedWithTitle:@"Server Failed" SubtitleString:@"Sorry Something went wrong.Please try again later."];
                [session finishTasksAndInvalidate];
            }else{
                NSLog(@"Delegate Not Working");
            }
            
            
        }else{
            
            serverData = data;
            
        }
        dispatch_semaphore_signal(semaphore);
        
    }];
    [loadDataTask resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return serverData;
    
}

-(NSData *)getDataFromServer:(NSString *)URLName withAPIName:(NSString *)apiName DictionartyToServer:(NSDictionary *)dictionaryToServer withHTTPMethod:(NSString *)httpMethod
{
    
    return [self dataFromServerWithURL:URLName WithApiName:apiName DictionaryToServer:dictionaryToServer withHTTPMethod: httpMethod];
}


@end
