//
//  ServerResponce.h
//  Mappd
//
//  Created by Nazim on 08/12/17.
//  Copyright © 2017 Nazimm. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ServerFailedDelegate <NSObject>

-(void)serverFailedWithTitle: (NSString *)title SubtitleString: (NSString *)subtitle;

@end

@interface ServerResponce : NSObject

+(ServerResponce *)sharedInstance;
-(NSArray *)getResponceFromServer:(NSString *)URLName withAPIName:(NSString *)apiName DictionartyToServer:(NSDictionary *)dictionaryToServer withHTTPMethod: (NSString *)httpMethod;
-(void)invalidateCurrentRunningTask;
-(NSData *)getDataFromServer:(NSString *)URLName withAPIName:(NSString *)apiName DictionartyToServer:(NSDictionary *)dictionaryToServer withHTTPMethod: (NSString *)httpMethod;
@property(nonatomic,weak)id<ServerFailedDelegate>delegate;


@end


