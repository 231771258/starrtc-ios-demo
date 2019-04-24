//
//  AppConfig.h
//  IMDemo
//
//  Created by Hanxiaojie on 2018/5/25.
//  Copyright © 2018年  Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, IFServiceType) {
    IFServiceTypePublic, //公有云
    IFServiceTypePrivate //私有云
};

@interface AppConfig : NSObject

@property (nonatomic, strong, readonly) NSString *appId;
@property (nonatomic, strong, readonly) NSString *userId;
@property (nonatomic, strong, readonly) NSString *host;
@property (nonatomic, strong, readonly) NSString *loginHost;
@property (nonatomic, strong, readonly) NSString *messageHost;
@property (nonatomic, strong, readonly) NSString *chatHost;
@property (nonatomic, strong, readonly) NSString *uploadHost;
@property (nonatomic, strong, readonly) NSString *downloadHost;
@property (nonatomic, strong, readonly) NSString *voipHost;

@property (nonatomic, assign) BOOL audioEnabled;
@property (nonatomic, assign) BOOL videoEnabled;

+ (instancetype)shareConfig;

+ (AppConfig *)appConfig:(IFServiceType)type;
+ (void)saveSystemSettingsForPublic:(NSDictionary *)params;
+ (void)saveSystemSettingsForPrivate:(NSDictionary *)params;

- (BOOL)liveEnable;
- (void)checkAppConfig;

//切换sdk部署服务类型，私有云或公有云
+ (void)switchSDKServiceType;
//sdk服务类型
+ (IFServiceType)SDKServiceType;

@end
