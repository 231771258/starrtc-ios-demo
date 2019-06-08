//
//  AppConfig.m
//  IMDemo
//
//  Created by Hanxiaojie on 2018/5/25.
//  Copyright © 2018年  Admin. All rights reserved.
//

#import "AppConfig.h"
#import "InterfaceUrls.h"

#define APPID @"starRTC"
#define Platform @"iOS"
#define ConfigUpdateTime @"2018-06-18 09:00"

static NSString * const kAppConfigParametersPublicKey = @"AppConfigParameters";
static NSString * const kAppConfigParametersPrivateKey = @"AppConfigParametersPrivate";

@interface AppConfig ()
{
    BOOL _liveEnable;
}
@end

@implementation AppConfig

+ (instancetype)shareConfig {
    static AppConfig *appConfigManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appConfigManager = [[self alloc] initWithType:[AppConfig SDKServiceType]];
    });
    return appConfigManager;
}

- (instancetype)initWithType:(IFServiceType)type
{
    self = [super init];
    if (self) {
        _userId = UserId;
        _appId = IFHAppId;
        _host = @"https://api.starrtc.com/public";
        _loginHost = @"ips2.starrtc.com:9920";
        
        NSString *appConfigParamsKey = (type == IFServiceTypePublic)? kAppConfigParametersPublicKey:kAppConfigParametersPrivateKey;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *params = [userDefaults objectForKey:appConfigParamsKey];
        if (params) {
            [self setValuesForKeysWithDictionary:params];
            
        } else {
            if (type == IFServiceTypePrivate) {
                _messageHost = @"129.204.145.78:19903";
                _chatHost = @"129.204.145.78:19906";
                _uploadHost = @"129.204.145.78:19931";
                _downloadHost = @"129.204.145.78:19928";
                _voipHost = @"129.204.145.78:10086";
//                _messageHost = @"aisee.f3322.org:19903";
//                _chatHost = @"aisee.f3322.org:19906";
//                _uploadHost = @"aisee.f3322.org:19931";
//                _downloadHost = @"aisee.f3322.org:19928";
//                _voipHost = @"aisee.f3322.org:10086";
            } else {
                _messageHost = @"ips2.starrtc.com:9904";
                _chatHost = @"ips2.starrtc.com:9907";
                _uploadHost = @"ips2.starrtc.com:9929";
                _downloadHost = @"ips2.starrtc.com:9926";
                _voipHost = @"voip2.starrtc.com:10086";
            }
        }
        
        self.videoEnabled = YES;
        self.audioEnabled = YES;
    }
    return self;
}

+ (BOOL)liveEnable {
    return [[AppConfig shareConfig] liveEnable];
}

- (BOOL)liveEnable{
    return _liveEnable;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

- (void)checkAppConfig{

#ifdef DEBUG
    _liveEnable = YES;
    return;
#endif
    
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [dateformatter setTimeZone:sourceTimeZone];
    NSDate *configUpdateDate = [dateformatter dateFromString:ConfigUpdateTime];
    NSDate *currentDate = [NSDate date];
    
    if ([currentDate compare:configUpdateDate] == NSOrderedDescending) {
        NSString *vesion = [ILGLocalData preferencePlistObject:@"CFBundleShortVersionString"];
        NSString *parameter = [NSString stringWithFormat:@"platform=%@&version=v%@&appid=%@",Platform,vesion,APPID];
        
        [InterfaceUrls getAppConfigUrlParameter:parameter success:^(id responseObject) {
            NSDictionary *data = [responseObject objectForKey:@"data"];
            if (data && [data objectForKey:@"liveStatus"]) {
                
                _liveEnable = [[data objectForKey:@"liveStatus"] boolValue];
                
            }
        } failure:^(NSError *error) {
            NSLog(@"AppConfig失败");
        }];
    } else {
        _liveEnable = NO;
        NSLog(@"还没到时间");
    }
    
}

+ (void)saveSystemSettingsForPublic:(NSDictionary *)params {
    [[NSUserDefaults standardUserDefaults] setObject:params forKey:kAppConfigParametersPublicKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (void)saveSystemSettingsForPrivate:(NSDictionary *)params {
    [[NSUserDefaults standardUserDefaults] setObject:params forKey:kAppConfigParametersPrivateKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (AppConfig *)appConfigForLocal:(IFServiceType)type {
    return [[AppConfig alloc] initWithType:type];
}

static NSString * const kIFSDKServiceTypeKey = @"kIFSDKServiceTypeKey";
+ (void)switchSDKServiceType
{
    IFServiceType type = IFServiceTypePublic;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:kIFSDKServiceTypeKey]) {
        IFServiceType tmpType = [[userDefaults objectForKey:kIFSDKServiceTypeKey] integerValue];
        if (tmpType == IFServiceTypePublic) {
            type = IFServiceTypePrivate;
        } else {
            type = IFServiceTypePublic;
        }
    } else {
        type = IFServiceTypePrivate;
    }
    
    [userDefaults setObject:@(type) forKey:kIFSDKServiceTypeKey];
    [userDefaults synchronize];
}

+ (IFServiceType)SDKServiceType
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:kIFSDKServiceTypeKey]) {
        return [[userDefaults objectForKey:kIFSDKServiceTypeKey] integerValue];
    } else {
        return IFServiceTypePublic;
    }
}

@end
